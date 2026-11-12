--!strict
--[[
    SurvivalService.lua
    Server-authoritative manager for player survival attributes:
    Health, Stamina, Warmth, Sanity, Downed state, Timed Revivals, and Idempotent Death Penalties.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementConfig = require(ReplicatedStorage.TFF.Shared.Config.MovementConfig)
local SurvivalConfig = require(ReplicatedStorage.TFF.Shared.Config.SurvivalConfig)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local SurvivalService = {}
SurvivalService.__index = SurvivalService

local _worldService: any = nil
local _inventoryService: any = nil
local _playerStats: { [number]: Types.PlayerStats } = {}
local _lastSprintTime: { [number]: number } = {}
local _activeRevives: { [number]: { targetId: number, startTime: number } } = {}
local _isProcessingDeath: { [number]: boolean } = {}

local function createInitialStats(): Types.PlayerStats
    return {
        Health = SurvivalConfig.MaxHealth,
        MaxHealth = SurvivalConfig.MaxHealth,
        Stamina = SurvivalConfig.MaxStamina,
        MaxStamina = SurvivalConfig.MaxStamina,
        Warmth = SurvivalConfig.MaxWarmth,
        MaxWarmth = SurvivalConfig.MaxWarmth,
        Sanity = SurvivalConfig.MaxSanity,
        MaxSanity = SurvivalConfig.MaxSanity,
        IsSprinting = false,
        IsDowned = false,
        DownedTimer = 0,
    }
end

local function syncStatsToClient(player: Player)
    local stats = _playerStats[player.UserId]
    if not stats then return end

    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncStats)
    if syncRemote then
        syncRemote:FireClient(player, stats)
    end
end

function SurvivalService.Init(dependencies: { [string]: any })
    print("[SurvivalService] Initializing SurvivalService...")
    _worldService = dependencies.WorldService
    _inventoryService = dependencies.InventoryService

    local sprintRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestSprint)
    if sprintRemote then
        sprintRemote.OnServerEvent:Connect(function(player: Player, wantsSprint: boolean)
            SurvivalService.SetSprinting(player, wantsSprint == true)
        end)
    end

    local reviveRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestRevive)
    if reviveRemote then
        reviveRemote.OnServerEvent:Connect(function(player: Player, targetUserId: number)
            SurvivalService.StartRevive(player, targetUserId)
        end)
    end
end

function SurvivalService.Start()
    print("[SurvivalService] SurvivalService started.")

    Players.PlayerAdded:Connect(function(player)
        _playerStats[player.UserId] = createInitialStats()
        _lastSprintTime[player.UserId] = os.clock()
        _isProcessingDeath[player.UserId] = false

        player.CharacterAdded:Connect(function(char)
            local stats = _playerStats[player.UserId]
            if stats then
                stats.Health = stats.MaxHealth
                stats.Stamina = stats.MaxStamina
                stats.IsDowned = false
                stats.DownedTimer = 0
                _isProcessingDeath[player.UserId] = false
                syncStatsToClient(player)
            end
        end)

        syncStatsToClient(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        _playerStats[player.UserId] = nil
        _lastSprintTime[player.UserId] = nil
        _activeRevives[player.UserId] = nil
        _isProcessingDeath[player.UserId] = nil
    end)

    -- Simulation tick (0.5s)
    task.spawn(function()
        local dt = 0.5
        while true do
            task.wait(dt)
            local now = os.clock()

            -- 1. Check active timed revives (4-second duration)
            for reviverId, reviveData in pairs(_activeRevives) do
                local reviver = Players:GetPlayerByUserId(reviverId)
                local target = Players:GetPlayerByUserId(reviveData.targetId)
                local reviverChar = reviver and reviver.Character
                local targetChar = target and target.Character
                local reviverRoot = reviverChar and reviverChar:FindFirstChild("HumanoidRootPart") :: BasePart?
                local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart") :: BasePart?

                if not reviver or not target or not reviverRoot or not targetRoot then
                    _activeRevives[reviverId] = nil
                else
                    local dist = (reviverRoot.Position - targetRoot.Position).Magnitude
                    if dist > BalanceConfig.DefaultInteractionRange + 2 then
                        -- Reviver moved too far -> cancel revive
                        _activeRevives[reviverId] = nil
                    elseif (now - reviveData.startTime) >= BalanceConfig.ReviveDuration then
                        -- Revive completed successfully!
                        _activeRevives[reviverId] = nil
                        SurvivalService.CompleteRevive(reviver, target)
                    end
                end
            end

            -- 2. Player Stats & Downed Timers
            for _, player in ipairs(Players:GetPlayers()) do
                local stats = _playerStats[player.UserId]
                local char = player.Character
                local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?

                if stats and humanoid and humanoid.Health > 0 then
                    if stats.IsDowned then
                        stats.DownedTimer -= dt
                        if stats.DownedTimer <= 0 then
                            SurvivalService.HandlePlayerDeath(player)
                        else
                            syncStatsToClient(player)
                        end
                    else
                        -- Stamina drain & recovery
                        if stats.IsSprinting then
                            stats.Stamina = math.max(0, stats.Stamina - (MovementConfig.SprintDrainRate * dt))
                            _lastSprintTime[player.UserId] = now
                            if stats.Stamina <= 0 then
                                SurvivalService.SetSprinting(player, false)
                            end
                        else
                            local idleDuration = now - (_lastSprintTime[player.UserId] or 0)
                            if idleDuration >= MovementConfig.RegenDelayAfterSprint then
                                stats.Stamina = math.min(stats.MaxStamina, stats.Stamina + (MovementConfig.StaminaRegenRate * dt))
                            end
                        end

                        -- Safe Haven Regeneration
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        if rootPart and _worldService and _worldService.IsInsideSafeZone(rootPart.Position) then
                            stats.Health = math.min(stats.MaxHealth, stats.Health + (SurvivalConfig.SafeHavenHealthRegen * dt))
                            stats.Sanity = math.min(stats.MaxSanity, stats.Sanity + (SurvivalConfig.SafeHavenSanityRegen * dt))
                            humanoid.Health = stats.Health
                        end

                        syncStatsToClient(player)
                    end
                end
            end
        end
    end)
end

function SurvivalService.SetSprinting(player: Player, isSprinting: boolean)
    local stats = _playerStats[player.UserId]
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
    if not stats or not humanoid or stats.IsDowned then return end

    if isSprinting then
        if stats.Stamina >= MovementConfig.MinStaminaToStartSprint then
            stats.IsSprinting = true
            humanoid.WalkSpeed = MovementConfig.SprintSpeed
        else
            stats.IsSprinting = false
            humanoid.WalkSpeed = MovementConfig.WalkSpeed
        end
    else
        stats.IsSprinting = false
        humanoid.WalkSpeed = MovementConfig.WalkSpeed
    end
    syncStatsToClient(player)
end

function SurvivalService.ApplyDamage(player: Player, amount: number)
    local stats = _playerStats[player.UserId]
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
    if not stats or not humanoid or stats.IsDowned then return end

    -- Taking damage interrupts any active revive being channeled by this player
    if _activeRevives[player.UserId] then
        _activeRevives[player.UserId] = nil
        print(string.format("[SurvivalService] Revive interrupted for %s due to taking damage", player.Name))
    end

    stats.Health = math.max(0, stats.Health - amount)
    humanoid.Health = stats.Health

    if stats.Health <= 0 then
        -- Enter Downed state
        stats.IsDowned = true
        stats.DownedTimer = BalanceConfig.DownedDuration
        stats.IsSprinting = false
        humanoid.WalkSpeed = MovementConfig.DownedWalkSpeed

        local downedRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.DownedStateChanged)
        if downedRemote then
            downedRemote:FireAllClients(player.UserId, true, BalanceConfig.DownedDuration)
        end
    end
    syncStatsToClient(player)
end

function SurvivalService.StartRevive(reviver: Player, targetUserId: number): boolean
    local reviverStats = _playerStats[reviver.UserId]
    local targetStats = _playerStats[targetUserId]
    if not reviverStats or reviverStats.IsDowned then return false end
    if not targetStats or not targetStats.IsDowned then return false end

    local reviverChar = reviver.Character
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    local targetChar = targetPlayer and targetPlayer.Character
    local reviverRoot = reviverChar and reviverChar:FindFirstChild("HumanoidRootPart") :: BasePart?
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not reviverRoot or not targetRoot then return false end

    local dist = (reviverRoot.Position - targetRoot.Position).Magnitude
    if dist > BalanceConfig.DefaultInteractionRange + 2 then
        return false
    end

    _activeRevives[reviver.UserId] = {
        targetId = targetUserId,
        startTime = os.clock(),
    }
    print(string.format("[SurvivalService] %s started reviving %s (4s channel)", reviver.Name, targetPlayer.Name))
    return true
end

function SurvivalService.CompleteRevive(reviver: Player, target: Player)
    local targetStats = _playerStats[target.UserId]
    if not targetStats or not targetStats.IsDowned then return end

    targetStats.IsDowned = false
    targetStats.DownedTimer = 0
    targetStats.Health = BalanceConfig.ReviveHealthRestored

    local targetChar = target.Character
    local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid") :: Humanoid?
    if targetHumanoid then
        targetHumanoid.Health = targetStats.Health
        targetHumanoid.WalkSpeed = MovementConfig.WalkSpeed
    end

    local downedRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.DownedStateChanged)
    if downedRemote then
        downedRemote:FireAllClients(target.UserId, false, 0)
    end
    syncStatsToClient(target)
    print(string.format("[SurvivalService] %s successfully revived %s! Restored %d Health.", reviver.Name, target.Name, BalanceConfig.ReviveHealthRestored))
end

function SurvivalService.HandlePlayerDeath(player: Player)
    local userId = player.UserId
    if _isProcessingDeath[userId] then
        -- Idempotency check: prevent duplicate death processing
        return
    end
    _isProcessingDeath[userId] = true

    print(string.format("[SurvivalService] Processing death for %s...", player.Name))

    -- 1. Deduct 20% of eligible carried resources
    local lostItems = {}
    if _inventoryService then
        lostItems = _inventoryService.ApplyDeathResourcePenalty(player)
    end

    -- Format summary message
    local summaryParts = {}
    for itemId, count in pairs(lostItems) do
        table.insert(summaryParts, string.format("%dx %s", count, itemId))
    end
    local lossSummary = #summaryParts > 0 and table.concat(summaryParts, ", ") or "None"

    local notifyRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.ShowNotification)
    if notifyRemote then
        notifyRemote:FireClient(player, "You have succumbed to the forest.", "Carried resources lost (20%): " .. lossSummary, "Warning")
    end

    -- 2. Respawn character at Safe Haven Plaza
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
        if humanoid then humanoid.Health = 0 end
    end

    local stats = _playerStats[userId]
    if stats then
        stats.IsDowned = false
        stats.DownedTimer = 0
        stats.Health = stats.MaxHealth
        stats.Stamina = stats.MaxStamina
    end

    local downedRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.DownedStateChanged)
    if downedRemote then
        downedRemote:FireAllClients(userId, false, 0)
    end

    task.delay(3, function()
        _isProcessingDeath[userId] = false
    end)
end

function SurvivalService.GetStats(player: Player): Types.PlayerStats?
    return _playerStats[player.UserId]
end

return SurvivalService
