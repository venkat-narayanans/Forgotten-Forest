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

return "SYNC 2A SUCCESS: Bootstrap, CombatService, SurvivalService updated!"
