--!strict
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
local PlayerService = require(ServicesFolder.PlayerService)

local services = {
    ProfileService = ProfileService,
    WorldService = WorldService,
    TimeCycleService = TimeCycleService,
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
    PlayerService = PlayerService,
}

local orderedServiceKeys = {
    "WorldService",
    "ProfileService",
    "ProgressionService",
    "RewardService",
    "InventoryService",
    "SurvivalService",
    "TimeCycleService",
    "ResourceService",
    "CraftingService",
    "CombatService",
    "CreatureService",
    "EventService",
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
