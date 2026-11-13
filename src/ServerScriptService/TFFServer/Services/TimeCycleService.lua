--!strict
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
