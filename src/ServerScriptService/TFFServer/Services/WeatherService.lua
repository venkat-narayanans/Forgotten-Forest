--!strict
--[[
    WeatherService.lua
    Server-authoritative weather simulation and atmosphere synchronization.
    Supports Clear, Light Rain, Heavy Rain, Dense Fog, and supernatural Fog Surge.
    Affects Warmth and Sanity decay rates per Master Game Specification Section 9.
]]

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

export type WeatherState = "Clear" | "Light Rain" | "Heavy Rain" | "Dense Fog" | "Fog Surge"

export type WeatherProfile = {
    Name: WeatherState,
    WarmthDrainMultiplier: number,
    SanityDrainMultiplier: number,
    AtmosphereDensity: number,
    AtmosphereHaze: number,
    AtmosphereColor: Color3,
    Description: string,
}

local WEATHER_PROFILES: { [WeatherState]: WeatherProfile } = {
    ["Clear"] = {
        Name = "Clear",
        WarmthDrainMultiplier = 1.0,
        SanityDrainMultiplier = 1.0,
        AtmosphereDensity = 0.28,
        AtmosphereHaze = 0.5,
        AtmosphereColor = Color3.fromRGB(195, 215, 235),
        Description = "Gentle forest breeze with mild temperatures.",
    },
    ["Light Rain"] = {
        Name = "Light Rain",
        WarmthDrainMultiplier = 1.35,
        SanityDrainMultiplier = 1.15,
        AtmosphereDensity = 0.45,
        AtmosphereHaze = 1.2,
        AtmosphereColor = Color3.fromRGB(145, 165, 185),
        Description = "Chilly drizzle dampens coats and steadily accelerates warmth loss.",
    },
    ["Heavy Rain"] = {
        Name = "Heavy Rain",
        WarmthDrainMultiplier = 1.85,
        SanityDrainMultiplier = 1.35,
        AtmosphereDensity = 0.65,
        AtmosphereHaze = 2.5,
        AtmosphereColor = Color3.fromRGB(115, 130, 150),
        Description = "Torrential downpour with gusting winds. Keep fires burning.",
    },
    ["Dense Fog"] = {
        Name = "Dense Fog",
        WarmthDrainMultiplier = 1.5,
        SanityDrainMultiplier = 1.7,
        AtmosphereDensity = 0.80,
        AtmosphereHaze = 3.5,
        AtmosphereColor = Color3.fromRGB(120, 140, 145),
        Description = "Thick, damp mist blankets the valley floor, muffling sound and clouding the mind.",
    },
    ["Fog Surge"] = {
        Name = "Fog Surge",
        WarmthDrainMultiplier = 2.5,
        SanityDrainMultiplier = 2.3,
        AtmosphereDensity = 0.92,
        AtmosphereHaze = 6.0,
        AtmosphereColor = Color3.fromRGB(80, 125, 130),
        Description = "SUPERNATURAL FOG SURGE: Freezing shadows envelop the valley. Return to Safe Haven immediately!",
    },
}

local WeatherService = {}
WeatherService.__index = WeatherService

local _currentWeather: WeatherProfile = WEATHER_PROFILES["Clear"]
local _atmosphere: Atmosphere? = nil
local _isSurgeActive = false

local function ensureAtmosphere(): Atmosphere
    local atmos = Lighting:FindFirstChildWhichIsA("Atmosphere")
    if not atmos then
        atmos = Instance.new("Atmosphere")
        atmos.Name = "ValleyAtmosphere"
        atmos.Parent = Lighting
    end
    return atmos
end

function WeatherService.Init(_dependencies: { [string]: any })
    print("[WeatherService] Initializing WeatherService...")
    _atmosphere = ensureAtmosphere()
end

function WeatherService.Start()
    print("[WeatherService] WeatherService started.")
    WeatherService.SetWeather("Clear")

    local function syncPlayer(player: Player)
        local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncWeather)
        if syncRemote then
            syncRemote:FireClient(player, _currentWeather.Name, _currentWeather.WarmthDrainMultiplier, _currentWeather.AtmosphereDensity, _currentWeather.Description)
        end
    end
    Players.PlayerAdded:Connect(syncPlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(syncPlayer, player)
    end

    -- Dynamic weather transition cycle (every 180 - 240 seconds if not in active Fog Surge)
    task.spawn(function()
        local weatherSequence: { WeatherState } = { "Clear", "Light Rain", "Dense Fog", "Clear", "Heavy Rain", "Dense Fog" }
        local seqIdx = 1
        while true do
            task.wait(200)
            if not _isSurgeActive then
                seqIdx = (seqIdx % #weatherSequence) + 1
                WeatherService.SetWeather(weatherSequence[seqIdx])
            end
        end
    end)
end

function WeatherService.SetWeather(weatherName: WeatherState)
    local profile = WEATHER_PROFILES[weatherName]
    if not profile then return end

    _currentWeather = profile

    -- Apply to server Lighting
    if _atmosphere then
        _atmosphere.Density = profile.AtmosphereDensity
        _atmosphere.Haze = profile.AtmosphereHaze
        _atmosphere.Color = profile.AtmosphereColor
    end

    -- Broadcast to clients
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncWeather)
    if syncRemote then
        syncRemote:FireAllClients(profile.Name, profile.WarmthDrainMultiplier, profile.AtmosphereDensity, profile.Description)
    end

    print(string.format("[WeatherService] Weather changed to %s (Warmth Multiplier: %.2fx, Fog: %.2f)", profile.Name, profile.WarmthDrainMultiplier, profile.AtmosphereDensity))
end

function WeatherService.TriggerFogSurge(durationSeconds: number)
    _isSurgeActive = true
    WeatherService.SetWeather("Fog Surge")

    task.delay(durationSeconds or 90, function()
        _isSurgeActive = false
        WeatherService.SetWeather("Dense Fog")
    end)
end

function WeatherService.GetCurrentWeather(): WeatherProfile
    return _currentWeather
end

function WeatherService.GetWarmthMultiplier(): number
    return _currentWeather.WarmthDrainMultiplier
end

function WeatherService.GetSanityMultiplier(): number
    return _currentWeather.SanityDrainMultiplier
end

return WeatherService
