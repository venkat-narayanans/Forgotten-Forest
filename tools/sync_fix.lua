local SSS = game:GetService("ServerScriptService")
local tffServer = SSS:FindFirstChild("TFFServer")
local services = tffServer:FindFirstChild("Services")
local mod_SurvivalService = services:FindFirstChild("SurvivalService")
if not mod_SurvivalService then
    mod_SurvivalService = Instance.new("ModuleScript")
    mod_SurvivalService.Name = "SurvivalService"
    mod_SurvivalService.Parent = services
end
mod_SurvivalService.Source = [=====[--!strict
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
local _weatherService: any = nil
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
    _weatherService = dependencies.WeatherService

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

    local function onPlayerAdded(player: Player)
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
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end

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

                        -- Environmental Survival: Warmth & Sanity Dynamics
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        local isSafe = rootPart and _worldService and _worldService.IsInsideSafeZone(rootPart.Position)
                        local weatherWarmthMult = _weatherService and _weatherService.GetWarmthMultiplier() or 1.0
                        local weatherSanityMult = _weatherService and _weatherService.GetSanityMultiplier() or 1.0

                        if isSafe then
                            -- Safe Haven Recovery
                            stats.Health = math.min(stats.MaxHealth, stats.Health + (SurvivalConfig.SafeHavenHealthRegen * dt))
                            stats.Warmth = math.min(stats.MaxWarmth, stats.Warmth + (SurvivalConfig.WarmthRecoveryNearFire * dt))
                            stats.Sanity = math.min(stats.MaxSanity, stats.Sanity + (SurvivalConfig.SafeHavenSanityRegen * dt))
                            humanoid.Health = stats.Health
                        else
                            -- Check if player is holding a torch or lantern
                            local tool = char:FindFirstChildWhichIsA("Tool")
                            local hasLight = tool and (tool.Name == "torch" or tool.Name == "advanced_lantern")

                            if hasLight then
                                stats.Warmth = math.min(stats.MaxWarmth, stats.Warmth + (2.0 * dt))
                            else
                                stats.Warmth = math.max(0, stats.Warmth - (SurvivalConfig.WarmthDecayColdZone * weatherWarmthMult * dt))
                            end

                            -- Hypothermia damage if freezing
                            if stats.Warmth <= 0 then
                                stats.Health = math.max(0, stats.Health - (2.5 * dt))
                                humanoid.Health = stats.Health
                                if stats.Health <= 0 then
                                    stats.IsDowned = true
                                    stats.DownedTimer = BalanceConfig.DownedDuration
                                    stats.IsSprinting = false
                                end
                            end

                            -- Sanity decay in deep wilderness
                            if rootPart and rootPart.Position.Z < -250 then
                                local sanityDrain = (hasLight and 0.3 or 1.0) * weatherSanityMult * dt
                                stats.Sanity = math.max(0, stats.Sanity - sanityDrain)
                            end
                        end

                        syncStatsToClient(player)
                    end
                end
            end
        end
    end)
end

function SurvivalService.DrainStamina(player: Player, amount: number): boolean
    local stats = _playerStats[player.UserId]
    if not stats or stats.IsDowned then return false end
    if stats.Stamina < amount then return false end
    stats.Stamina = math.max(0, stats.Stamina - amount)
    _lastSprintTime[player.UserId] = os.clock()
    syncStatsToClient(player)
    return true
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

function SurvivalService.HealHealth(player: Player, amount: number): boolean
    local stats = _playerStats[player.UserId]
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
    if not stats or not humanoid or stats.IsDowned then return false end
    if stats.Health >= stats.MaxHealth then return false end

    stats.Health = math.min(stats.MaxHealth, stats.Health + amount)
    humanoid.Health = stats.Health
    syncStatsToClient(player)
    return true
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
]=====]
local mod_InventoryService = services:FindFirstChild("InventoryService")
if not mod_InventoryService then
    mod_InventoryService = Instance.new("ModuleScript")
    mod_InventoryService.Name = "InventoryService"
    mod_InventoryService.Parent = services
end
mod_InventoryService.Source = [=====[--!strict
--[[
    InventoryService.lua
    Server-authoritative inventory and communal Safe Haven storage management.
    Ensures atomic transactions, stack integrity, and prevents duplication exploits.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local InventoryService = {}
InventoryService.__index = InventoryService

local _profileService: any = nil
local _survivalService: any = nil
local _sharedStorage: { [string]: number } = {}

local function syncProfileToClient(player: Player)
    local profile = _profileService.GetProfile(player)
    if not profile then return end
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

local function broadcastSharedStorage()
    local updateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SharedStorageUpdated)
    if updateRemote then
        updateRemote:FireAllClients(_sharedStorage)
    end
end

function InventoryService.Init(dependencies: { [string]: any })
    print("[InventoryService] Initializing InventoryService...")
    _profileService = dependencies.ProfileService
    _survivalService = dependencies.SurvivalService

    -- Connect storage remotes
    local depositRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestDepositStorage)
    if depositRemote then
        depositRemote.OnServerEvent:Connect(function(player: Player, itemId: string, quantity: number)
            InventoryService.TryDepositToSharedStorage(player, itemId, quantity)
        end)
    end

    local withdrawRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestWithdrawStorage)
    if withdrawRemote then
        withdrawRemote.OnServerEvent:Connect(function(player: Player, itemId: string, quantity: number)
            InventoryService.TryWithdrawFromSharedStorage(player, itemId, quantity)
        end)
    end

    -- Connect tool equipping & consumption remotes
    local equipRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestEquipItem)
    if equipRemote then
        equipRemote.OnServerEvent:Connect(function(player: Player, slotIndex: number)
            InventoryService.EquipItem(player, slotIndex)
        end)
    end

    local useRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestUseItem)
    if useRemote then
        useRemote.OnServerEvent:Connect(function(player: Player, slotIndex: number)
            InventoryService.UseItem(player, slotIndex)
        end)
    end
end

function InventoryService.Start()
    print("[InventoryService] InventoryService started.")
    local function onPlayerAdded(player: Player)
        local updateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SharedStorageUpdated)
        if updateRemote then
            updateRemote:FireClient(player, _sharedStorage)
        end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end
end

function InventoryService.GetItemCount(player: Player, itemId: string): number
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return 0 end

    local count = 0
    for _, item in ipairs(profile.inventory) do
        if item.ItemId == itemId then
            count += item.Quantity
        end
    end
    return count
end

function InventoryService.TryAddItem(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 or quantity > 999 then return false end
    local def = ItemDefinitions[itemId]
    if not def then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    local maxSlots = BalanceConfig.DefaultInventorySlots
    local remainingToAdd = quantity

    -- First pass: fill existing stacks
    for _, item in ipairs(profile.inventory) do
        if item.ItemId == itemId and item.Quantity < def.StackLimit then
            local space = def.StackLimit - item.Quantity
            local toAdd = math.min(space, remainingToAdd)
            item.Quantity += toAdd
            remainingToAdd -= toAdd
            if remainingToAdd <= 0 then break end
        end
    end

    -- Second pass: add new slots if space permits
    while remainingToAdd > 0 do
        if #profile.inventory >= maxSlots then
            -- Inventory is full
            syncProfileToClient(player)
            return false
        end

        local toAdd = math.min(def.StackLimit, remainingToAdd)
        table.insert(profile.inventory, {
            ItemId = itemId,
            Quantity = toAdd,
        })
        remainingToAdd -= toAdd
    end

    syncProfileToClient(player)
    return true
end

function InventoryService.TryRemoveItem(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    local currentCount = InventoryService.GetItemCount(player, itemId)
    if currentCount < quantity then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    local remainingToRemove = quantity
    local index = #profile.inventory
    while index >= 1 and remainingToRemove > 0 do
        local item = profile.inventory[index]
        if item.ItemId == itemId then
            if item.Quantity <= remainingToRemove then
                remainingToRemove -= item.Quantity
                table.remove(profile.inventory, index)
            else
                item.Quantity -= remainingToRemove
                remainingToRemove = 0
            end
        end
        index -= 1
    end

    syncProfileToClient(player)
    return true
end

function InventoryService.TryDepositToSharedStorage(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    if not ItemDefinitions[itemId] then return false end

    if InventoryService.TryRemoveItem(player, itemId, quantity) then
        _sharedStorage[itemId] = (_sharedStorage[itemId] or 0) + quantity
        broadcastSharedStorage()
        return true
    end
    return false
end

function InventoryService.TryWithdrawFromSharedStorage(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    local available = _sharedStorage[itemId] or 0
    if available < quantity then return false end

    if InventoryService.TryAddItem(player, itemId, quantity) then
        _sharedStorage[itemId] -= quantity
        if _sharedStorage[itemId] <= 0 then
            _sharedStorage[itemId] = nil
        end
        broadcastSharedStorage()
        return true
    end
    return false
end

function InventoryService.EquipItem(player: Player, slotIndex: number): boolean
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return false end
    local slot = profile.inventory[slotIndex]
    if not slot then return false end

    local char = player.Character
    if not char then return false end

    -- Check if already holding this tool
    local currentTool = char:FindFirstChildWhichIsA("Tool")
    if currentTool and currentTool.Name == slot.ItemId then
        currentTool:Destroy()
        return true
    elseif currentTool then
        currentTool:Destroy()
    end

    -- Clone tool from ServerStorage.TFF.Templates.Tools
    local ServerStorage = game:GetService("ServerStorage")
    local tff = ServerStorage:FindFirstChild("TFF")
    local templates = tff and tff:FindFirstChild("Templates")
    local tools = templates and templates:FindFirstChild("Tools")
    local toolTemplate = tools and tools:FindFirstChild(slot.ItemId) :: Tool?
    if toolTemplate then
        local equippedTool = toolTemplate:Clone()
        equippedTool.Parent = char
        return true
    end
    return false
end

function InventoryService.UseItem(player: Player, slotIndex: number): boolean
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return false end
    local slot = profile.inventory[slotIndex]
    if not slot or slot.Quantity <= 0 then return false end

    if slot.ItemId == "healing_potion" and _survivalService then
        local healed = _survivalService.HealHealth(player, 40)
        if healed then
            InventoryService.TryRemoveItem(player, "healing_potion", 1)
            return true
        end
    end
    return false
end

function InventoryService.ApplyDeathResourcePenalty(player: Player): { [string]: number }
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return {} end

    local lostItems: { [string]: number } = {}

    for i = #profile.inventory, 1, -1 do
        local slot = profile.inventory[i]
        local def = ItemDefinitions[slot.ItemId]
        if def and not def.IsQuestProtected and def.Category == "Resource" then
            local toLose = math.floor(slot.Quantity * (BalanceConfig.DeathResourceLossPercent / 100))
            if toLose > 0 then
                slot.Quantity -= toLose
                lostItems[slot.ItemId] = (lostItems[slot.ItemId] or 0) + toLose
                if slot.Quantity <= 0 then
                    table.remove(profile.inventory, i)
                end
            end
        end
    end

    syncProfileToClient(player)
    return lostItems
end

return InventoryService
]=====]
local mod_TimeCycleService = services:FindFirstChild("TimeCycleService")
if not mod_TimeCycleService then
    mod_TimeCycleService = Instance.new("ModuleScript")
    mod_TimeCycleService.Name = "TimeCycleService"
    mod_TimeCycleService.Parent = services
end
mod_TimeCycleService.Source = [=====[--!strict
--[[
    TimeCycleService.lua
    Server-authoritative controller for the 20-minute day/night cycle.
    Manages atmospheric transitions, Lighting parameters, and client synchronization.
]]

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CycleConfig = require(ReplicatedStorage.TFF.Shared.Config.CycleConfig)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local TimeCycleService = {}
TimeCycleService.__index = TimeCycleService

local _currentPhaseIndex = 1
local _phaseTimeRemaining = CycleConfig.PhaseDurations[CycleConfig.PhaseOrder[1]]
local _isRunning = false

local function getCurrentPhase(): Types.TimePhase
    return CycleConfig.PhaseOrder[_currentPhaseIndex] :: Types.TimePhase
end

local function applyLightingForPhase(phaseName: string, transitionDuration: number)
    local profile = CycleConfig.LightingProfiles[phaseName]
    if not profile then return end

    local tweenInfo = TweenInfo.new(transitionDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local goals = {
        ClockTime = profile.ClockTime,
        Brightness = profile.Brightness,
        OutdoorAmbient = profile.OutdoorAmbient,
        FogColor = profile.FogColor,
        FogStart = profile.FogStart,
        FogEnd = profile.FogEnd,
    }

    local tween = TweenService:Create(Lighting, tweenInfo, goals)
    tween:Play()
end

local function broadcastPhaseUpdate()
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncTimeCycle)
    if syncRemote then
        syncRemote:FireAllClients(getCurrentPhase(), _phaseTimeRemaining, Lighting.ClockTime)
    end
end

function TimeCycleService.Init(_dependencies: { [string]: any })
    print("[TimeCycleService] Initializing TimeCycleService...")
    local initialPhase = getCurrentPhase()
    local profile = CycleConfig.LightingProfiles[initialPhase]
    if profile then
        Lighting.ClockTime = profile.ClockTime
        Lighting.Brightness = profile.Brightness
        Lighting.OutdoorAmbient = profile.OutdoorAmbient
        Lighting.FogColor = profile.FogColor
        Lighting.FogStart = profile.FogStart
        Lighting.FogEnd = profile.FogEnd
    end
end

function TimeCycleService.Start()
    print("[TimeCycleService] TimeCycleService started.")
    _isRunning = true

    local function syncPlayer(player: Player)
        local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncTimeCycle)
        if syncRemote then
            syncRemote:FireClient(player, getCurrentPhase(), _phaseTimeRemaining, Lighting.ClockTime)
        end
    end
    Players.PlayerAdded:Connect(syncPlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(syncPlayer, player)
    end

    -- Cycle tick loop (1 update per second)
    task.spawn(function()
        while _isRunning do
            task.wait(1)
            _phaseTimeRemaining -= 1

            if _phaseTimeRemaining <= 0 then
                _currentPhaseIndex = (_currentPhaseIndex % #CycleConfig.PhaseOrder) + 1
                local nextPhase = getCurrentPhase()
                _phaseTimeRemaining = CycleConfig.PhaseDurations[nextPhase]
                print(string.format("[TimeCycleService] Transitioned to phase: %s (Duration: %ds)", nextPhase, _phaseTimeRemaining))
                applyLightingForPhase(nextPhase, 10.0)
            end

            -- Broadcast periodically or at phase change
            if _phaseTimeRemaining % 10 == 0 or _phaseTimeRemaining <= 5 then
                broadcastPhaseUpdate()
            end
        end
    end)
end

function TimeCycleService.GetCurrentPhase(): Types.TimePhase
    return getCurrentPhase()
end

function TimeCycleService.GetTimeRemaining(): number
    return _phaseTimeRemaining
end

return TimeCycleService
]=====]
local mod_WeatherService = services:FindFirstChild("WeatherService")
if not mod_WeatherService then
    mod_WeatherService = Instance.new("ModuleScript")
    mod_WeatherService.Name = "WeatherService"
    mod_WeatherService.Parent = services
end
mod_WeatherService.Source = [=====[--!strict
--[[
    WeatherService.lua
    Server-authoritative weather simulation and atmosphere synchronization.
    Supports Clear, Light Rain, Heavy Rain, Dense Fog, and supernatural Fog Surge.
    Affects Warmth and Sanity decay rates per Master Game Specification Section 9.
]]

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

export type WeatherState = "Clear" | "Light Rain" | "Heavy Rain" | "Dense Fog" | "Fog Surge"

export type WeatherProfile = {
    Name: WeatherState,
    WarmthDrainMultiplier: number,
    SanityDrainMultiplier: number,
    AtmosphereDensity: number,
    AtmosphereHaze: number,
    AtmosphereColor: Color3,
    Description: string,
}

local WEATHER_PROFILES: { [WeatherState]: WeatherProfile } = {
    ["Clear"] = {
        Name = "Clear",
        WarmthDrainMultiplier = 1.0,
        SanityDrainMultiplier = 1.0,
        AtmosphereDensity = 0.28,
        AtmosphereHaze = 0.5,
        AtmosphereColor = Color3.fromRGB(195, 215, 235),
        Description = "Gentle forest breeze with mild temperatures.",
    },
    ["Light Rain"] = {
        Name = "Light Rain",
        WarmthDrainMultiplier = 1.35,
        SanityDrainMultiplier = 1.15,
        AtmosphereDensity = 0.45,
        AtmosphereHaze = 1.2,
        AtmosphereColor = Color3.fromRGB(145, 165, 185),
        Description = "Chilly drizzle dampens coats and steadily accelerates warmth loss.",
    },
    ["Heavy Rain"] = {
        Name = "Heavy Rain",
        WarmthDrainMultiplier = 1.85,
        SanityDrainMultiplier = 1.35,
        AtmosphereDensity = 0.65,
        AtmosphereHaze = 2.5,
        AtmosphereColor = Color3.fromRGB(115, 130, 150),
        Description = "Torrential downpour with gusting winds. Keep fires burning.",
    },
    ["Dense Fog"] = {
        Name = "Dense Fog",
        WarmthDrainMultiplier = 1.5,
        SanityDrainMultiplier = 1.7,
        AtmosphereDensity = 0.80,
        AtmosphereHaze = 3.5,
        AtmosphereColor = Color3.fromRGB(120, 140, 145),
        Description = "Thick, damp mist blankets the valley floor, muffling sound and clouding the mind.",
    },
    ["Fog Surge"] = {
        Name = "Fog Surge",
        WarmthDrainMultiplier = 2.5,
        SanityDrainMultiplier = 2.3,
        AtmosphereDensity = 0.92,
        AtmosphereHaze = 6.0,
        AtmosphereColor = Color3.fromRGB(80, 125, 130),
        Description = "SUPERNATURAL FOG SURGE: Freezing shadows envelop the valley. Return to Safe Haven immediately!",
    },
}

local WeatherService = {}
WeatherService.__index = WeatherService

local _currentWeather: WeatherProfile = WEATHER_PROFILES["Clear"]
local _atmosphere: Atmosphere? = nil
local _isSurgeActive = false

local function ensureAtmosphere(): Atmosphere
    local atmos = Lighting:FindFirstChildWhichIsA("Atmosphere")
    if not atmos then
        atmos = Instance.new("Atmosphere")
        atmos.Name = "ValleyAtmosphere"
        atmos.Parent = Lighting
    end
    return atmos
end

function WeatherService.Init(_dependencies: { [string]: any })
    print("[WeatherService] Initializing WeatherService...")
    _atmosphere = ensureAtmosphere()
end

function WeatherService.Start()
    print("[WeatherService] WeatherService started.")
    WeatherService.SetWeather("Clear")

    local function syncPlayer(player: Player)
        local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncWeather)
        if syncRemote then
            syncRemote:FireClient(player, _currentWeather.Name, _currentWeather.WarmthDrainMultiplier, _currentWeather.AtmosphereDensity, _currentWeather.Description)
        end
    end
    Players.PlayerAdded:Connect(syncPlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(syncPlayer, player)
    end

    -- Dynamic weather transition cycle (every 180 - 240 seconds if not in active Fog Surge)
    task.spawn(function()
        local weatherSequence: { WeatherState } = { "Clear", "Light Rain", "Dense Fog", "Clear", "Heavy Rain", "Dense Fog" }
        local seqIdx = 1
        while true do
            task.wait(200)
            if not _isSurgeActive then
                seqIdx = (seqIdx % #weatherSequence) + 1
                WeatherService.SetWeather(weatherSequence[seqIdx])
            end
        end
    end)
end

function WeatherService.SetWeather(weatherName: WeatherState)
    local profile = WEATHER_PROFILES[weatherName]
    if not profile then return end

    _currentWeather = profile

    -- Apply to server Lighting
    if _atmosphere then
        _atmosphere.Density = profile.AtmosphereDensity
        _atmosphere.Haze = profile.AtmosphereHaze
        _atmosphere.Color = profile.AtmosphereColor
    end

    -- Broadcast to clients
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncWeather)
    if syncRemote then
        syncRemote:FireAllClients(profile.Name, profile.WarmthDrainMultiplier, profile.AtmosphereDensity, profile.Description)
    end

    print(string.format("[WeatherService] Weather changed to %s (Warmth Multiplier: %.2fx, Fog: %.2f)", profile.Name, profile.WarmthDrainMultiplier, profile.AtmosphereDensity))
end

function WeatherService.TriggerFogSurge(durationSeconds: number)
    _isSurgeActive = true
    WeatherService.SetWeather("Fog Surge")

    task.delay(durationSeconds or 90, function()
        _isSurgeActive = false
        WeatherService.SetWeather("Dense Fog")
    end)
end

function WeatherService.GetCurrentWeather(): WeatherProfile
    return _currentWeather
end

function WeatherService.GetWarmthMultiplier(): number
    return _currentWeather.WarmthDrainMultiplier
end

function WeatherService.GetSanityMultiplier(): number
    return _currentWeather.SanityDrainMultiplier
end

return WeatherService
]=====]
return "SERVICES SYNCED CLEANLY!"