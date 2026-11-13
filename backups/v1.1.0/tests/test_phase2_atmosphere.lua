--!strict
--[[
    test_phase2_atmosphere.lua
    Automated verification of Phase 2 Day/Night & Atmosphere requirements.
]]

local function runPhase2Tests()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")
    local SoundService = game:GetService("SoundService")

    local CycleConfig = require(ReplicatedStorage.TFF.Shared.Config.CycleConfig)
    assert(CycleConfig.PhaseDurations.Night == 420, "Night phase duration must be 420s (7 min)")
    assert(CycleConfig.PhaseDurations.Morning == 180, "Morning phase duration must be 180s (3 min)")
    assert(CycleConfig.PhaseDurations.Sunset == 120, "Sunset phase duration must be 120s (2 min)")

    -- Check Night lighting profile readability
    local nightProfile = CycleConfig.LightingProfiles.Night
    assert(nightProfile ~= nil, "Night profile must exist")
    assert(nightProfile.Brightness >= 0.4, "Night must not be pitch black (Brightness >= 0.4)")
    assert(nightProfile.FogEnd >= 200, "FogEnd must be >= 200 studs for navigation")

    -- Check Audio Placeholders
    assert(SoundService:FindFirstChild("DayAmbience") ~= nil, "DayAmbience sound must exist")
    assert(SoundService:FindFirstChild("NightAmbience") ~= nil, "NightAmbience sound must exist")
    assert(SoundService:FindFirstChild("PhaseTransitionChime") ~= nil, "PhaseTransitionChime sound must exist")

    -- Check Service initialization
    local TimeCycleService = require(ServerScriptService.TFFServer.Services.TimeCycleService)
    local curPhase = TimeCycleService.GetCurrentPhase()
    assert(curPhase ~= nil, "Current phase must be readable from server")

    print("[Phase 2 Tests] All Phase 2 Day/Night & Atmosphere checks passed!")
    return true
end

return runPhase2Tests
