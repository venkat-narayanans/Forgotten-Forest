--!strict
--[[
    CreatureService.lua
    Manages creature spawning, bounded pathfinding, active NPC caps, and state machines.
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreatureDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.CreatureDefinitions)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local CreatureService = {}
CreatureService.__index = CreatureService

local _combatService: any = nil
local _worldService: any = nil
local _activeCreatures: { [Model]: string } = {}

function CreatureService.Init(dependencies: { [string]: any })
    print("[CreatureService] Initializing CreatureService...")
    _combatService = dependencies.CombatService
    _worldService = dependencies.WorldService
end

function CreatureService.Start()
    print("[CreatureService] CreatureService started.")
end

function CreatureService.GetActiveCreatureCount(): number
    local count = 0
    for _ in pairs(_activeCreatures) do
        count += 1
    end
    return count
end

return CreatureService
