--!strict
--[[
    CreatureService.lua
    Server-authoritative creature AI, bounded pathfinding, state machines,
    and encounter director for The Stalker, The Watcher, and The Mimic.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreatureDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.CreatureDefinitions)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local CreatureService = {}
CreatureService.__index = CreatureService

local _combatService: any = nil
local _worldService: any = nil
local _survivalService: any = nil

type CreatureInstance = {
    Model: Model,
    CreatureId: string,
    State: string,
    SpawnPosition: Vector3,
    CurrentTarget: Player?,
    LastAttackTime: number,
    LastRepathTime: number,
    LeashRange: number,
    DetectionRadius: number,
    AttackRange: number,
    Damage: number,
    WindupTime: number,
    Cooldown: number,
}

local _activeCreatures: { [Model]: CreatureInstance } = {}
local _templatesFolder: Folder? = nil

local function getNearestEligiblePlayer(position: Vector3, maxRadius: number): (Player?, number)
    local nearest: Player? = nil
    local minDist = maxRadius

    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?

        if root and humanoid and humanoid.Health > 0 then
            -- Skip players inside Safe Haven
            if not _worldService or not _worldService.IsInsideSafeZone(root.Position) then
                local dist = (root.Position - position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest, minDist
end

function CreatureService.Init(dependencies: { [string]: any })
    print("[CreatureService] Initializing CreatureService...")
    _combatService = dependencies.CombatService
    _worldService = dependencies.WorldService
    _survivalService = dependencies.SurvivalService

    local tffStorage = ServerStorage:WaitForChild("TFF")
    local templates = tffStorage:WaitForChild("Templates")
    _templatesFolder = templates:WaitForChild("Creatures") :: Folder
end

function CreatureService.Start()
    print("[CreatureService] CreatureService started.")

    -- Spawn initial Stalkers and Watcher in Whispering Woods
    task.defer(function()
        CreatureService.SpawnCreature("stalker", Vector3.new(-35, 2, -210))
        CreatureService.SpawnCreature("stalker", Vector3.new(45, 2, -250))
        CreatureService.SpawnCreature("watcher", Vector3.new(-80, 16, -290))
    end)

    -- AI State Machine simulation loop (runs every 0.3s)
    task.spawn(function()
        local dt = 0.3
        while true do
            task.wait(dt)
            local now = os.clock()

            for model, inst in pairs(_activeCreatures) do
                local root = model.PrimaryPart
                local humanoid = model:FindFirstChildWhichIsA("Humanoid")

                if not root or not humanoid or humanoid.Health <= 0 then
                    _activeCreatures[model] = nil
                    model:Destroy()
                else
                    local pos = root.Position

                    -- ==========================================
                    -- THE STALKER AI
                    -- ==========================================
                    if inst.CreatureId == "stalker" then
                        -- Check distance to spawn point (leash enforcement)
                        local distToSpawn = (pos - inst.SpawnPosition).Magnitude
                        if distToSpawn > inst.LeashRange then
                            inst.State = "Return"
                            inst.CurrentTarget = nil
                        end

                        if inst.State == "Idle" or inst.State == "Patrol" then
                            local player, dist = getNearestEligiblePlayer(pos, inst.DetectionRadius)
                            if player then
                                inst.CurrentTarget = player
                                inst.State = "Chase"
                            end

                        elseif inst.State == "Chase" then
                            local target = inst.CurrentTarget
                            local targetChar = target and target.Character
                            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart") :: BasePart?

                            if not targetRoot or (_worldService and _worldService.IsInsideSafeZone(targetRoot.Position)) then
                                inst.State = "Return"
                                inst.CurrentTarget = nil
                            else
                                local distToTarget = (targetRoot.Position - pos).Magnitude
                                if distToTarget > inst.DetectionRadius * 1.5 then
                                    inst.State = "Return"
                                    inst.CurrentTarget = nil
                                elseif distToTarget <= inst.AttackRange and (now - inst.LastAttackTime) >= inst.Cooldown then
                                    inst.State = "Windup"
                                    inst.LastAttackTime = now

                                    -- Visual telegraph cue: activate red telegraph light
                                    local head = model:FindFirstChild("Head")
                                    local light = head and head:FindFirstChild("TelegraphLight") :: PointLight?
                                    if light then light.Brightness = 3 end

                                    -- Windup timer before hit
                                    task.delay(inst.WindupTime, function()
                                        if model.Parent and inst.State == "Windup" then
                                            if light then light.Brightness = 0 end
                                            -- Execute attack
                                            local currentTargetChar = inst.CurrentTarget and inst.CurrentTarget.Character
                                            if currentTargetChar and _combatService then
                                                _combatService.ValidateAndApplyAttack(model, currentTargetChar, inst.Damage, inst.AttackRange + 3)
                                            end
                                            inst.State = "Chase"
                                        end
                                    end)
                                else
                                    -- Move towards target
                                    if (now - inst.LastRepathTime) >= 0.8 then
                                        inst.LastRepathTime = now
                                        humanoid:MoveTo(targetRoot.Position)
                                    end
                                end
                            end

                        elseif inst.State == "Return" then
                            humanoid:MoveTo(inst.SpawnPosition)
                            if (pos - inst.SpawnPosition).Magnitude <= 5 then
                                inst.State = "Idle"
                            end
                        end

                    -- ==========================================
                    -- THE WATCHER AI (Atmospheric Observer)
                    -- ==========================================
                    elseif inst.CreatureId == "watcher" then
                        local player, dist = getNearestEligiblePlayer(pos, 35)
                        if player and dist < 35 then
                            -- Player came too close -> Watcher fades / relocates
                            inst.State = "Despawn"
                            _activeCreatures[model] = nil
                            model:Destroy()
                            -- Respawns later at overlook
                            task.delay(120, function()
                                CreatureService.SpawnCreature("watcher", inst.SpawnPosition)
                            end)
                        end
                    end
                end
            end
        end
    end)
end

function CreatureService.SpawnCreature(definitionId: string, spawnPosition: Vector3): Model?
    local count = CreatureService.GetActiveCreatureCount()
    if count >= BalanceConfig.StandardHostileCap then
        warn(string.format("[CreatureService] Active creature cap reached (%d/%d). Cannot spawn %s", count, BalanceConfig.StandardHostileCap, definitionId))
        return nil
    end

    local def = CreatureDefinitions[definitionId]
    if not def or not _templatesFolder then return nil end

    local template = _templatesFolder:FindFirstChild(def.DisplayName) or _templatesFolder:FindFirstChild(def.Id:sub(1, 1):upper() .. def.Id:sub(2))
    if not template or not template:IsA("Model") then
        template = _templatesFolder:FindFirstChild("Stalker") :: Model?
    end
    if not template then return nil end

    local clone = template:Clone()
    clone:PivotTo(CFrame.new(spawnPosition))
    clone.Parent = game.Workspace:WaitForChild("TFF_World"):WaitForChild("CreatureSpawns")

    local inst: CreatureInstance = {
        Model = clone,
        CreatureId = definitionId,
        State = "Idle",
        SpawnPosition = spawnPosition,
        CurrentTarget = nil,
        LastAttackTime = 0,
        LastRepathTime = 0,
        LeashRange = def.LeashRange,
        DetectionRadius = def.DetectionRadius,
        AttackRange = def.AttackRange,
        Damage = def.AttackDamage,
        WindupTime = def.WindupDuration,
        Cooldown = def.AttackCooldown,
    }

    _activeCreatures[clone] = inst
    print(string.format("[CreatureService] Spawned %s at %s (Active: %d)", def.DisplayName, tostring(spawnPosition), count + 1))
    return clone
end

function CreatureService.GetActiveCreatureCount(): number
    local count = 0
    for _ in pairs(_activeCreatures) do
        count += 1
    end
    return count
end

function CreatureService.GetCreatureInstance(model: Model): CreatureInstance?
    return _activeCreatures[model]
end

return CreatureService
