local SSS = game:GetService("ServerScriptService")
local tffServer = SSS:FindFirstChild("TFFServer")
tffServer:FindFirstChild("Bootstrap").Source = [=====[--!strict
--[[
    Bootstrap.server.lua
    Master server bootstrap for The Forgotten Forest.
    Initializes dependencies, sets up network remotes, and starts core gameplay services.
]]

print("==================================================")
print("  THE FORGOTTEN FOREST — SERVER INITIALIZATION   ")
print("==================================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- 1. Ensure network remotes exist
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
RemoteRegistry.GetOrCreateRemotesFolder()

-- Create all standard events
for _, eventName in pairs(RemoteRegistry.Events) do
    RemoteRegistry.GetRemoteEvent(eventName)
end

-- Create all standard functions
for _, funcName in pairs(RemoteRegistry.Functions) do
    RemoteRegistry.GetRemoteFunction(funcName)
end

-- 2. Load service modules
local ServicesFolder = ServerScriptService.TFFServer.Services

local ProfileService = require(ServicesFolder.ProfileService)
local WorldService = require(ServicesFolder.WorldService)
local TimeCycleService = require(ServicesFolder.TimeCycleService)
local WeatherService = require(ServicesFolder.WeatherService)
local SurvivalService = require(ServicesFolder.SurvivalService)
local InventoryService = require(ServicesFolder.InventoryService)
local CraftingService = require(ServicesFolder.CraftingService)
local ProgressionService = require(ServicesFolder.ProgressionService)
local RewardService = require(ServicesFolder.RewardService)
local ResourceService = require(ServicesFolder.ResourceService)
local QuestService = require(ServicesFolder.QuestService)
local CombatService = require(ServicesFolder.CombatService)
local CreatureService = require(ServicesFolder.CreatureService)
local EventService = require(ServicesFolder.EventService)
local BossEncounterService = require(ServicesFolder.BossEncounterService)
local PlayerService = require(ServicesFolder.PlayerService)

local services = {
    ProfileService = ProfileService,
    WorldService = WorldService,
    TimeCycleService = TimeCycleService,
    WeatherService = WeatherService,
    SurvivalService = SurvivalService,
    InventoryService = InventoryService,
    CraftingService = CraftingService,
    ProgressionService = ProgressionService,
    RewardService = RewardService,
    ResourceService = ResourceService,
    QuestService = QuestService,
    CombatService = CombatService,
    CreatureService = CreatureService,
    EventService = EventService,
    BossEncounterService = BossEncounterService,
    PlayerService = PlayerService,
}

local orderedServiceKeys = {
    "WorldService",
    "ProfileService",
    "ProgressionService",
    "RewardService",
    "InventoryService",
    "WeatherService",
    "SurvivalService",
    "TimeCycleService",
    "ResourceService",
    "CraftingService",
    "CombatService",
    "CreatureService",
    "EventService",
    "BossEncounterService",
    "QuestService",
    "PlayerService",
}

-- 3. Phase 1: Initialize all services
print("[Bootstrap] Initializing services...")
for _, key in ipairs(orderedServiceKeys) do
    local service = services[key]
    if service and typeof(service.Init) == "function" then
        service.Init(services)
    end
end

-- 4. Phase 2: Start all services
print("[Bootstrap] Starting services...")
for _, key in ipairs(orderedServiceKeys) do
    local service = services[key]
    if service and typeof(service.Start) == "function" then
        service.Start()
    end
end

print("==================================================")
print("  THE FORGOTTEN FOREST — SERVER BOOTSTRAP READY   ")
print("==================================================")
]=====]

local services = tffServer:FindFirstChild("Services")
services:FindFirstChild("CombatService").Source = [=====[--!strict
--[[
    CombatService.lua
    Server-authoritative combat, weapon hit validation, attack cooldowns,
    stamina consumption, projectile/melee verification, and damage application.
    Implements Master Game Specification Section 6.1 and 6.2.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local WeaponDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.WeaponDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local CombatService = {}
CombatService.__index = CombatService

local _survivalService: any = nil
local _inventoryService: any = nil
local _progressionService: any = nil
local _creatureService: any = nil
local _resourceService: any = nil

-- Player cooldown tracking: [Player] -> last attack os.clock()
local _playerLastAttack: { [Player]: number } = {}

-- Unarmed fallback definition
local UNARMED_DEF: Types.WeaponDefinition = {
    WeaponId = "unarmed",
    DisplayName = "Fists",
    Role = "Unarmed combat",
    BaseDamage = 6,
    Range = 4.5,
    Cooldown = 0.5,
    StaminaCost = 5,
    IsRanged = false,
    Special = "Basic punch",
}

function CombatService.Init(dependencies: { [string]: any })
    print("[CombatService] Initializing CombatService v2.0...")
    _survivalService = dependencies.SurvivalService
    _inventoryService = dependencies.InventoryService
    _progressionService = dependencies.ProgressionService
    _creatureService = dependencies.CreatureService
    _resourceService = dependencies.ResourceService

    -- Connect Client Attack Request
    local attackRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestAttack)
    if attackRemote then
        attackRemote.OnServerEvent:Connect(function(player: Player, targetInstance: Instance?, hitPosition: Vector3?, attackDirection: Vector3?)
            CombatService.ProcessPlayerAttack(player, targetInstance, hitPosition, attackDirection)
        end)
    end
end

function CombatService.Start()
    print("[CombatService] CombatService started with full Player Combat Pipeline.")
    Players.PlayerRemoving:Connect(function(player)
        _playerLastAttack[player] = nil
    end)
end

-- Get currently held weapon or tool definition
function CombatService.GetEquippedWeapon(player: Player): Types.WeaponDefinition
    local char = player.Character
    if char then
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool then
            local def = WeaponDefinitions[tool.Name]
            if def then return def end
        end
    end
    return UNARMED_DEF
end

-- Process player attack request
function CombatService.ProcessPlayerAttack(player: Player, targetInstance: Instance?, hitPosition: Vector3?, attackDirection: Vector3?): boolean
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
    if not root or not humanoid or humanoid.Health <= 0 then
        return false
    end

    -- Verify not downed
    if _survivalService then
        local stats = _survivalService.GetStats(player)
        if stats and stats.IsDowned then return false end
    end

    local weapon = CombatService.GetEquippedWeapon(player)
    local now = os.clock()
    local lastAttack = _playerLastAttack[player] or 0

    -- Cooldown verification
    if (now - lastAttack) < (weapon.Cooldown - 0.05) then
        return false
    end

    -- Stamina verification & consumption
    if _survivalService then
        local currentStats = _survivalService.GetStats(player)
        if currentStats and currentStats.Stamina < weapon.StaminaCost then
            return false
        end
        _survivalService.DrainStamina(player, weapon.StaminaCost)
    end

    _playerLastAttack[player] = now

    local feedbackRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.CombatHitFeedback)

    -- If target is nil, handle as swing / miss
    if not targetInstance then
        if feedbackRemote then
            local missPos = root.Position + root.CFrame.LookVector * weapon.Range
            feedbackRemote:FireClient(player, missPos, 0, false, "miss", "")
        end
        return true
    end

    -- Target resolution: find humanoid or model
    local targetModel = targetInstance:FindFirstAncestorOfClass("Model")
    local targetHumanoid = targetModel and targetModel:FindFirstChildWhichIsA("Humanoid")
    local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart") :: BasePart?

    -- 1. Creature Attack Resolution
    if targetModel and targetHumanoid and targetHumanoid.Health > 0 and targetModel ~= char then
        local targetPos = targetRoot and targetRoot.Position or targetModel:GetPivot().Position
        local dist = (root.Position - targetPos).Magnitude

        -- Range check with server latency buffer
        local maxAllowedRange = weapon.IsRanged and (weapon.Range + 15) or (weapon.Range + 4)
        if dist > maxAllowedRange then
            if feedbackRemote then
                feedbackRemote:FireClient(player, targetPos, 0, false, "miss", targetModel.Name)
            end
            return false
        end

        -- Calculate Damage & Crit
        local damage = weapon.BaseDamage
        local isCrit = math.random() < 0.15
        if isCrit then
            damage = math.floor(damage * 1.5)
        end

        -- Weapon bonuses against specific creature archetypes
        if weapon.WeaponId == "wooden_spear" and targetModel.Name:lower():find("stalker") then
            -- Spear interrupt / stagger
            damage = damage + 4
        elseif weapon.WeaponId == "keeper_blade" and (targetModel.Name:lower():find("guardian") or targetModel.Name:lower():find("mimic")) then
            damage = damage + 8
        end

        targetHumanoid:TakeDamage(damage)

        -- Grant XP
        if _progressionService then
            _progressionService.AddExperience(player, 12)
        end

        -- Fire hit feedback to attacker
        if feedbackRemote then
            feedbackRemote:FireClient(player, targetPos, damage, isCrit, "hit", targetModel.Name)
        end
        return true
    end

    -- 2. Boss Arena Core / Crystal Heart Resolution
    if targetInstance.Name == "ForestGuardianCrystalHeart" or targetInstance:GetAttribute("BossTarget") then
        local heartPos = (targetInstance:IsA("BasePart") and targetInstance.Position) or root.Position
        local dist = (root.Position - heartPos).Magnitude
        if dist <= (weapon.Range + 6) then
            local damage = weapon.BaseDamage
            local isCrit = math.random() < 0.2
            if isCrit then damage = math.floor(damage * 1.5) end

            local currentHp = targetInstance:GetAttribute("Health") or 250
            local newHp = math.max(0, currentHp - damage)
            targetInstance:SetAttribute("Health", newHp)

            local bossRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.BossHealthUpdated)
            if bossRemote then
                bossRemote:FireAllClients(newHp, 250, "Exposed Core")
            end

            if feedbackRemote then
                feedbackRemote:FireClient(player, heartPos, damage, isCrit, "hit", "Forest Guardian")
            end
            return true
        end
    end

    -- 3. Resource Node Chop / Mine with appropriate tool
    if targetInstance:IsA("BasePart") and CollectionService:HasTag(targetInstance, "TFF_ResourceNode") then
        local nodePos = targetInstance.Position
        local dist = (root.Position - nodePos).Magnitude
        if dist <= (weapon.Range + 4) then
            local resType = targetInstance:GetAttribute("ResourceType")
            local effTool = targetInstance:GetAttribute("EffectiveTool")

            if effTool and (weapon.WeaponId:lower():find(effTool:lower()) or weapon.DisplayName:lower():find(effTool:lower())) then
                if _resourceService then
                    local nodeId = targetInstance:GetAttribute("NodeId") or targetInstance.Name
                    _resourceService.TryGather(player, nodeId)
                end
                if feedbackRemote then
                    feedbackRemote:FireClient(player, nodePos, 0, false, "resource", resType or "Resource")
                end
                return true
            else
                if feedbackRemote then
                    feedbackRemote:FireClient(player, nodePos, 0, false, "blocked", "Requires " .. tostring(effTool))
                end
                return false
            end
        end
    end

    -- Fallback miss
    if feedbackRemote then
        local missPos = hitPosition or (root.Position + root.CFrame.LookVector * weapon.Range)
        feedbackRemote:FireClient(player, missPos, 0, false, "miss", "")
    end
    return true
end

-- Validate and apply monster/creature attack to player (server-authoritative)
function CombatService.ValidateAndApplyAttack(attacker: Model, target: Model, damage: number, maxRange: number): boolean
    local attackerRoot = attacker:FindFirstChild("HumanoidRootPart") :: BasePart?
    local targetRoot = target:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not attackerRoot or not targetRoot then return false end

    local dist = (attackerRoot.Position - targetRoot.Position).Magnitude
    if dist > maxRange then
        return false
    end

    local targetPlayer = Players:GetPlayerFromCharacter(target)
    if targetPlayer and _survivalService then
        _survivalService.ApplyDamage(targetPlayer, damage)
        return true
    end

    local targetHumanoid = target:FindFirstChild("Humanoid") :: Humanoid?
    if targetHumanoid then
        targetHumanoid:TakeDamage(damage)
        return true
    end

    return false
end

return CombatService
]=====]
services:FindFirstChild("SurvivalService").Source = [=====[--!strict
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
services:FindFirstChild("EventService").Source = [=====[--!strict
--[[
    EventService.lua
    Server-authoritative World Event Director.
    Coordinates dynamic valley events: Fog Surge, Strange Signal, Crystal Bloom, and Abandoned Caravan.
    Directly fulfills Master Game Specification Section 2.4 and Chapter objectives.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

export type WorldEvent = {
    Id: string,
    Title: string,
    Description: string,
    Duration: number,
    Start: () -> (),
    Cleanup: () -> (),
}

local EventService = {}
EventService.__index = EventService

local _weatherService: any = nil
local _rewardService: any = nil
local _worldService: any = nil

local _activeEvent: WorldEvent? = nil
local _eventCleanupTasks: { () -> () } = {}

function EventService.Init(dependencies: { [string]: any })
    print("[EventService] Initializing EventService v2.0...")
    _weatherService = dependencies.WeatherService
    _rewardService = dependencies.RewardService
    _worldService = dependencies.WorldService
end

function EventService.Start()
    print("[EventService] EventService started. Registering scheduled valley events.")

    -- Periodic world event scheduler (every 5 to 7 minutes)
    task.spawn(function()
        task.wait(120) -- initial grace period after server start
        local eventTypes = { "FogSurge", "StrangeSignal", "CrystalBloom", "AbandonedCaravan" }
        local eventIndex = 1

        while true do
            local eventName = eventTypes[eventIndex]
            EventService.TriggerEvent(eventName)

            eventIndex = (eventIndex % #eventTypes) + 1
            task.wait(320)
        end
    end)
end

function EventService.TriggerEvent(eventName: string)
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)

    -- 1. FOG SURGE EVENT
    if eventName == "FogSurge" then
        if _weatherService then
            _weatherService.TriggerFogSurge(90)
        end
        if eventRemote then
            eventRemote:FireAllClients(
                "FOG SURGE APPROACHING",
                "A dense freezing wall of supernatural mist rolls down the valley! Cold drain x2.5. Retreat to campfires!",
                90
            )
        end

    -- 2. STRANGE SIGNAL EVENT
    elseif eventName == "StrangeSignal" and interactables then
        local signalChest = Instance.new("Part")
        signalChest.Name = "Event_SignalCache"
        signalChest.Size = Vector3.new(4, 3, 3)
        signalChest.CFrame = CFrame.new(210, 16.5, -880)
        signalChest.Color = Color3.fromRGB(0, 240, 180)
        signalChest.Material = Enum.Material.Neon
        signalChest.Anchored = true
        signalChest.CanCollide = true

        local pLight = Instance.new("PointLight")
        pLight.Color = Color3.fromRGB(0, 240, 180)
        pLight.Range = 25
        pLight.Brightness = 3
        pLight.Parent = signalChest

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Salvage Anomalous Signal Cache"
        prompt.ObjectText = "Glowing Keeper Cache"
        prompt.HoldDuration = 1.5
        prompt.MaxActivationDistance = 9
        prompt.Parent = signalChest

        signalChest.Parent = interactables

        prompt.Triggered:Connect(function(player: Player)
            if _rewardService then
                _rewardService.GrantReward(player, "strange_signal_cache", {
                    ancientTokens = 5,
                    forestCoins = 50,
                    items = { { ItemId = "crystal", Quantity = 2 }, { ItemId = "ancient_fragment", Quantity = 1 } }
                })
            end
            signalChest:Destroy()
        end)

        task.delay(180, function()
            if signalChest.Parent then signalChest:Destroy() end
        end)

        if eventRemote then
            eventRemote:FireAllClients(
                "STRANGE SIGNAL DETECTED",
                "An anomalous emerald frequency is pinging from Watcher's Bluff in Whispering Woods!",
                180
            )
        end

    -- 3. CRYSTAL BLOOM EVENT
    elseif eventName == "CrystalBloom" then
        if eventRemote then
            eventRemote:FireAllClients(
                "CRYSTAL GROTTO RESONANCE",
                "The subterranean veins in Crystal Caverns are pulsating with high energy! Mining yield increased!",
                120
            )
        end

    -- 4. ABANDONED CARAVAN EVENT
    elseif eventName == "AbandonedCaravan" and interactables then
        local crate = Instance.new("Part")
        crate.Name = "Event_CaravanCrate"
        crate.Size = Vector3.new(4, 3, 3)
        crate.CFrame = CFrame.new(15, 2, -440)
        crate.Color = Color3.fromRGB(115, 85, 55)
        crate.Material = Enum.Material.WoodPlanks
        crate.Anchored = true
        crate.CanCollide = true

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Scavenge Overturned Crate"
        prompt.ObjectText = "Expedition Supplies"
        prompt.HoldDuration = 1.0
        prompt.MaxActivationDistance = 9
        prompt.Parent = crate
        crate.Parent = interactables

        prompt.Triggered:Connect(function(player: Player)
            if _rewardService then
                _rewardService.GrantReward(player, "caravan_supplies", {
                    forestCoins = 25,
                    items = { { ItemId = "food", Quantity = 4 }, { ItemId = "cloth", Quantity = 3 }, { ItemId = "rope", Quantity = 2 } }
                })
            end
            crate:Destroy()
        end)

        task.delay(180, function()
            if crate.Parent then crate:Destroy() end
        end)

        if eventRemote then
            eventRemote:FireAllClients(
                "ABANDONED CARAVAN SIGHTED",
                "An overturned expedition crate was spotted near the Whispering Woods Creek Ravine!",
                180
            )
        end
    end
end

return EventService
]=====]
services:FindFirstChild("PlayerService").Source = [=====[--!strict
--[[
    PlayerService.lua
    Manages player lifecycle, character spawning, profile synchronization, and safe disconnection.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local StoryDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.StoryDefinitions)
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")

local PlayerService = {}
PlayerService.__index = PlayerService

local _profileService: any = nil
local _worldService: any = nil
local _progressionService: any = nil

local function onPlayerAdded(player: Player)
    print(string.format("[PlayerService] Player joined: %s (%d)", player.Name, player.UserId))

    -- Enforce soft player limit if needed
    if #Players:GetPlayers() > BalanceConfig.MaxPlayers then
        player:Kick("Server capacity reached (Max 12 players). Please join another server.")
        return
    end

    local profile = _profileService.LoadProfile(player)

    -- Character spawning setup
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = 16

        -- Spawn inside Safe Haven spawn location if available
        local worldRoot = game.Workspace:FindFirstChild("TFF_World")
        if worldRoot then
            local spawnFolder = worldRoot:FindFirstChild("SpawnLocations")
            if spawnFolder and #spawnFolder:GetChildren() > 0 then
                local spawnPart = spawnFolder:GetChildren()[1] :: BasePart
                if spawnPart and spawnPart:IsA("BasePart") then
                    character:PivotTo(spawnPart.CFrame + Vector3.new(0, 3, 0))
                end
            end
        end
    end)

    -- Sync initial profile to client
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

local function onPlayerRemoving(player: Player)
    print(string.format("[PlayerService] Player leaving: %s (%d)", player.Name, player.UserId))
    _profileService.UnloadProfile(player)
end

function PlayerService.Init(dependencies: { [string]: any })
    print("[PlayerService] Initializing PlayerService...")
    _profileService = dependencies.ProfileService
    _worldService = dependencies.WorldService
    _progressionService = dependencies.ProgressionService
end

function PlayerService.Start()
    print("[PlayerService] PlayerService started.")
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end

    -- Hook up ProximityPrompts for NPCs and Story Clues
    local dialogRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncDialog)

    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
        local parentInstance = prompt.Parent
        if not parentInstance then return end

        local model = parentInstance:FindFirstAncestorOfClass("Model")

        -- 1. NPC Interaction
        if model and CollectionService:HasTag(model, "TFF_NPC") then
            local npcId = model:GetAttribute("NPCId") or "cartographer"
            local data = StoryDefinitions.Dialogues[npcId]
            if data and dialogRemote then
                dialogRemote:FireClient(player, "NPC", data)
            end

        -- 2. Story Clue Interaction
        elseif parentInstance:IsA("BasePart") and CollectionService:HasTag(parentInstance, "TFF_StoryClue") then
            local clueId = parentInstance:GetAttribute("ClueId") or "safe_haven_orders"
            local data = StoryDefinitions.Clues[clueId]
            if data and dialogRemote then
                dialogRemote:FireClient(player, "Clue", data)
                if _progressionService then
                    _progressionService.AddExperience(player, 25)
                end
            end
        end
    end)
end

return PlayerService
]=====]

local weatherMod = services:FindFirstChild("WeatherService")
if not weatherMod then
    weatherMod = Instance.new("ModuleScript")
    weatherMod.Name = "WeatherService"
    weatherMod.Parent = services
end
weatherMod.Source = [=====[--!strict
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

    Players.PlayerAdded:Connect(function(player)
        local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncWeather)
        if syncRemote then
            syncRemote:FireClient(player, _currentWeather.Name, _currentWeather.WarmthDrainMultiplier, _currentWeather.AtmosphereDensity, _currentWeather.Description)
        end
    end)

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

local bossMod = services:FindFirstChild("BossEncounterService")
if not bossMod then
    bossMod = Instance.new("ModuleScript")
    bossMod.Name = "BossEncounterService"
    bossMod.Parent = services
end
bossMod.Source = [=====[--!strict
--[[
    BossEncounterService.lua
    Server-authoritative multi-phase Boss Combat Director for the Forest Guardian.
    Implements Master Game Specification Section 4.5, 7.4, and Chapter 4 Endgame.
    
    Phases:
    1. Awakening (Teal surge, health sync, ritual initiation)
    2. Root Sweep (Telegraphed ground shockwaves with jump/dodge counterplay)
    3. Guardian Pulse & Root Barrier (Invulnerability shield; players must channel 5 Ancient Seals)
    4. Exposed Core (Vulnerable damage window to strike the pulsing Crystal Heart)
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

export type BossPhase = "Dormant" | "Awakening" | "RootSweep" | "BarrierPhase" | "ExposedCore" | "Defeated"

local BossEncounterService = {}
BossEncounterService.__index = BossEncounterService

local _rewardService: any = nil
local _progressionService: any = nil
local _survivalService: any = nil

local _currentPhase: BossPhase = "Dormant"
local _bossMaxHealth = 250
local _bossCurrentHealth = 250
local _activatedSealsCount = 0
local _phaseTimer = 0
local _arenaCenter = Vector3.new(0, 7.2, -2775)
local _arenaRadius = 110

local function getPlayersInArena(): { Player }
    local inArena: { Player } = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root then
            local dist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(_arenaCenter.X, 0, _arenaCenter.Z)).Magnitude
            if dist <= _arenaRadius then
                table.insert(inArena, player)
            end
        end
    end
    return inArena
end

local function syncBossHealth()
    local bossRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.BossHealthUpdated)
    if bossRemote then
        bossRemote:FireAllClients(_bossCurrentHealth, _bossMaxHealth, _currentPhase)
    end
end

function BossEncounterService.Init(dependencies: { [string]: any })
    print("[BossEncounterService] Initializing BossEncounterService v2.0...")
    _rewardService = dependencies.RewardService
    _progressionService = dependencies.ProgressionService
    _survivalService = dependencies.SurvivalService
end

function BossEncounterService.Start()
    print("[BossEncounterService] BossEncounterService started.")

    -- Connect Ancient Seal channel prompts
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")

    if interactables then
        for i = 1, 5 do
            local seal = interactables:FindFirstChild("AncientSeal_" .. i)
            local prompt = seal and seal:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                prompt.Triggered:Connect(function(player: Player)
                    BossEncounterService.ChannelSeal(player, i)
                end)
            end
        end
    end

    -- Boss director heartbeat loop (runs every 1.0s)
    task.spawn(function()
        while true do
            task.wait(1.0)
            BossEncounterService.Tick()
        end
    end)
end

function BossEncounterService.Tick()
    local playersInArena = getPlayersInArena()

    if _currentPhase == "Dormant" then
        if #playersInArena > 0 then
            BossEncounterService.StartEncounter()
        end

    elseif _currentPhase == "Awakening" then
        _phaseTimer = _phaseTimer - 1
        if _phaseTimer <= 0 then
            BossEncounterService.TransitionTo("RootSweep")
        end

    elseif _currentPhase == "RootSweep" then
        _phaseTimer = _phaseTimer - 1
        -- Periodically spawn telegraphed root sweep wave
        if _phaseTimer % 4 == 0 then
            BossEncounterService.ExecuteRootSweep()
        end
        if _phaseTimer <= 0 then
            BossEncounterService.TransitionTo("BarrierPhase")
        end

    elseif _currentPhase == "BarrierPhase" then
        _phaseTimer = _phaseTimer - 1
        if _activatedSealsCount >= 5 then
            BossEncounterService.TransitionTo("ExposedCore")
        elseif _phaseTimer <= 0 then
            -- Reset seal timer and repeat root sweeps
            BossEncounterService.TransitionTo("RootSweep")
        end

    elseif _currentPhase == "ExposedCore" then
        _phaseTimer = _phaseTimer - 1
        -- Read health directly in case modified by player combat
        local tffWorld = Workspace:FindFirstChild("TFF_World")
        local map = tffWorld and tffWorld:FindFirstChild("Map")
        local heart = map and map:FindFirstChild("ForestGuardianCrystalHeart")
        if heart then
            local hp = heart:GetAttribute("Health")
            if hp then _bossCurrentHealth = hp end
        end

        if _bossCurrentHealth <= 0 then
            BossEncounterService.TransitionTo("Defeated")
        elseif _phaseTimer <= 0 then
            -- Core closes, shield re-engages
            BossEncounterService.TransitionTo("BarrierPhase")
        end

    elseif _currentPhase == "Defeated" then
        _phaseTimer = _phaseTimer - 1
        if _phaseTimer <= 0 then
            -- Reset boss after victory
            _bossCurrentHealth = _bossMaxHealth
            _currentPhase = "Dormant"
            syncBossHealth()
        end
    end
end

function BossEncounterService.StartEncounter()
    _bossCurrentHealth = _bossMaxHealth
    _currentPhase = "Awakening"
    _phaseTimer = 5

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local heart = map and map:FindFirstChild("ForestGuardianCrystalHeart")
    if heart then
        heart:SetAttribute("Health", _bossMaxHealth)
        heart:SetAttribute("BossTarget", true)
    end

    syncBossHealth()

    local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
    if eventRemote then
        eventRemote:FireAllClients(
            "THE FOREST GUARDIAN AWAKENS",
            "Ancient corruption surges through the Elder Tree! Prepare for battle!",
            10
        )
    end
    print("[BossEncounterService] Forest Guardian encounter initiated!")
end

function BossEncounterService.TransitionTo(phase: BossPhase)
    _currentPhase = phase
    print("[BossEncounterService] Phase changed to: " .. phase)

    if phase == "RootSweep" then
        _phaseTimer = 16
        syncBossHealth()

    elseif phase == "BarrierPhase" then
        _phaseTimer = 40
        _activatedSealsCount = 0
        BossEncounterService.ResetSeals()
        syncBossHealth()

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "ROOT BARRIER ENGAGED",
                "The Guardian is shielded! Channel the 5 Ancient Seals to shatter the ward!",
                12
            )
        end

    elseif phase == "ExposedCore" then
        _phaseTimer = 30
        syncBossHealth()

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "CRYSTAL HEART EXPOSED",
                "The ward has shattered! Strike the pulsing Crystal Heart inside the Elder Tree!",
                30
            )
        end

    elseif phase == "Defeated" then
        _phaseTimer = 180
        syncBossHealth()

        -- Distribute grand rewards to all players in arena
        local players = getPlayersInArena()
        for _, player in ipairs(players) do
            if _rewardService then
                _rewardService.GrantReward(player, "boss_victory", {
                    ancientTokens = 20,
                    forestCoins = 200,
                    items = {
                        { ItemId = "keeper_blade", Quantity = 1 },
                        { ItemId = "crystal", Quantity = 4 },
                        { ItemId = "ancient_fragment", Quantity = 3 },
                    }
                })
            end
            if _progressionService then
                _progressionService.AddExperience(player, 150)
            end
        end

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "FOREST GUARDIAN PURIFIED",
                "The ancient corruption has receded. The Great Valley is saved!",
                20
            )
        end
    end
end

-- Execute telegraphed Root Sweep attack
function BossEncounterService.ExecuteRootSweep()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    if not map then return end

    -- Visual telegraph arc
    local sweepPart = Instance.new("Part")
    sweepPart.Name = "BossRootSweepTelegraph"
    sweepPart.Size = Vector3.new(160, 1.5, 12)
    sweepPart.CFrame = CFrame.new(_arenaCenter.X, 7.5, _arenaCenter.Z + math.random(-60, 60))
    sweepPart.Color = Color3.fromRGB(220, 50, 40)
    sweepPart.Material = Enum.Material.Neon
    sweepPart.Transparency = 0.5
    sweepPart.CanCollide = false
    sweepPart.Anchored = true
    sweepPart.Parent = map

    -- After 1.2s telegraph, root erupts and damages players inside the strip
    task.delay(1.2, function()
        if sweepPart.Parent then
            sweepPart.Color = Color3.fromRGB(75, 45, 25)
            sweepPart.Size = Vector3.new(160, 7, 12)
            sweepPart.Transparency = 0.0

            -- Check players within hitbox
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                if root then
                    local pPos = root.Position
                    local sPos = sweepPart.Position
                    if math.abs(pPos.X - sPos.X) < 80 and math.abs(pPos.Z - sPos.Z) < 8 and pPos.Y < (sPos.Y + 8) then
                        if _survivalService then
                            _survivalService.ApplyDamage(player, 22)
                        end
                    end
                end
            end

            task.delay(0.8, function()
                if sweepPart.Parent then sweepPart:Destroy() end
            end)
        end
    end)
end

-- Channel Ancient Seal during Barrier Phase
function BossEncounterService.ChannelSeal(player: Player, sealIndex: number)
    if _currentPhase ~= "BarrierPhase" then return end

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local seal = interactables and interactables:FindFirstChild("AncientSeal_" .. sealIndex)
    if not seal or seal:GetAttribute("Activated") == true then return end

    seal:SetAttribute("Activated", true)
    _activatedSealsCount = _activatedSealsCount + 1

    -- Turn beam bright cyan
    local beam = map and map:FindFirstChild("SealLightBeam_" .. sealIndex)
    if beam and beam:IsA("BasePart") then
        beam.Color = Color3.fromRGB(0, 255, 230)
        beam.Transparency = 0.1
    end

    if _progressionService then
        _progressionService.AddExperience(player, 20)
    end

    print(string.format("[BossEncounterService] Seal %d channeled by %s (%d/5)", sealIndex, player.Name, _activatedSealsCount))

    if _activatedSealsCount >= 5 then
        BossEncounterService.TransitionTo("ExposedCore")
    end
end

function BossEncounterService.ResetSeals()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")

    if interactables then
        for i = 1, 5 do
            local seal = interactables:FindFirstChild("AncientSeal_" .. i)
            if seal then
                seal:SetAttribute("Activated", false)
            end
            local beam = map and map:FindFirstChild("SealLightBeam_" .. i)
            if beam and beam:IsA("BasePart") then
                beam.Color = Color3.fromRGB(0, 180, 160)
                beam.Transparency = 0.6
            end
        end
    end
end

return BossEncounterService
]=====]

return "SYNC 2 SUCCESS: Server services updated in Studio!"
