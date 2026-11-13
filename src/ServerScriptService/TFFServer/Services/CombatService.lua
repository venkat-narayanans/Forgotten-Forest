--!strict
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
