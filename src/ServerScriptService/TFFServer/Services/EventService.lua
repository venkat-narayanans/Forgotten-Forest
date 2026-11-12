--!strict
--[[
    EventService.lua
    Server-side world event director (Strange Signal, Fog Surge, Crystal Bloom, etc.).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local EventService = {}
EventService.__index = EventService

local _timeCycleService: any = nil
local _worldService: any = nil
local _rewardService: any = nil

function EventService.Init(dependencies: { [string]: any })
    print("[EventService] Initializing EventService...")
    _timeCycleService = dependencies.TimeCycleService
    _worldService = dependencies.WorldService
    _rewardService = dependencies.RewardService
end

function EventService.Start()
    print("[EventService] EventService started.")
end

return EventService
