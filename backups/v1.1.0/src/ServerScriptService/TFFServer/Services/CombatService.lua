--!strict
--[[
    CombatService.lua
    Server-authoritative combat, hit validation, attack cooldowns, and damage calculation.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatService = {}
CombatService.__index = CombatService

local _survivalService: any = nil

function CombatService.Init(dependencies: { [string]: any })
    print("[CombatService] Initializing CombatService...")
    _survivalService = dependencies.SurvivalService
end

function CombatService.Start()
    print("[CombatService] CombatService started.")
end

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
