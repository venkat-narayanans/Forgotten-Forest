--!strict
--[[
    AudioController.lua
    Client controller for ambient soundscapes, cross-fades between Day and Night,
    and atmospheric sound cues.
]]

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

local AudioController = {}
AudioController.__index = AudioController

local _currentPhase = "Morning"

local function safePlay(sound: Sound)
    if sound and sound.SoundId ~= "" then
        pcall(function()
            sound:Play()
        end)
    end
end

function AudioController.Init(_dependencies: { [string]: any })
    print("[AudioController] Initializing AudioController...")
end

function AudioController.Start()
    print("[AudioController] AudioController started.")

    local daySound = SoundService:WaitForChild("DayAmbience") :: Sound
    local nightSound = SoundService:WaitForChild("NightAmbience") :: Sound
    local chime = SoundService:WaitForChild("PhaseTransitionChime") :: Sound

    safePlay(daySound)
    safePlay(nightSound)

    local syncCycleRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncTimeCycle)
    if syncCycleRemote then
        syncCycleRemote.OnClientEvent:Connect(function(phase: string, _timeRemaining: number, _clockTime: number)
            if phase ~= _currentPhase then
                _currentPhase = phase
                safePlay(chime)

                local isNightTime = (phase == "Night" or phase == "Sunset")
                local targetDayVol = isNightTime and 0.05 or 0.3
                local targetNightVol = isNightTime and 0.35 or 0.0

                local tweenDay = TweenService:Create(daySound, TweenInfo.new(5.0), { Volume = targetDayVol })
                local tweenNight = TweenService:Create(nightSound, TweenInfo.new(5.0), { Volume = targetNightVol })

                tweenDay:Play()
                tweenNight:Play()
            end
        end)
    end
end

return AudioController
