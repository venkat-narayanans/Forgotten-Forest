local SSS = game:GetService("ServerScriptService")
local tffServer = SSS:FindFirstChild("TFFServer")
local services = tffServer:FindFirstChild("Services")

local weatherMod = services:FindFirstChild("WeatherService")
if not weatherMod then
    weatherMod = Instance.new("ModuleScript")
    weatherMod.Name = "WeatherService"
    weatherMod.Parent = services
end
weatherMod.Source = [=====[--!strict
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

    Players.PlayerAdded:Connect(function(player)
        local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncWeather)
        if syncRemote then
            syncRemote:FireClient(player, _currentWeather.Name, _currentWeather.WarmthDrainMultiplier, _currentWeather.AtmosphereDensity, _currentWeather.Description)
        end
    end)

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
]=====]

local bossMod = services:FindFirstChild("BossEncounterService")
if not bossMod then
    bossMod = Instance.new("ModuleScript")
    bossMod.Name = "BossEncounterService"
    bossMod.Parent = services
end
bossMod.Source = [=====[--!strict
--[[
    BossEncounterService.lua
    Server-authoritative multi-phase Boss Combat Director for the Forest Guardian.
    Implements Master Game Specification Section 4.5, 7.4, and Chapter 4 Endgame.
    
    Phases:
    1. Awakening (Teal surge, health sync, ritual initiation)
    2. Root Sweep (Telegraphed ground shockwaves with jump/dodge counterplay)
    3. Guardian Pulse & Root Barrier (Invulnerability shield; players must channel 5 Ancient Seals)
    4. Exposed Core (Vulnerable damage window to strike the pulsing Crystal Heart)
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

export type BossPhase = "Dormant" | "Awakening" | "RootSweep" | "BarrierPhase" | "ExposedCore" | "Defeated"

local BossEncounterService = {}
BossEncounterService.__index = BossEncounterService

local _rewardService: any = nil
local _progressionService: any = nil
local _survivalService: any = nil

local _currentPhase: BossPhase = "Dormant"
local _bossMaxHealth = 250
local _bossCurrentHealth = 250
local _activatedSealsCount = 0
local _phaseTimer = 0
local _arenaCenter = Vector3.new(0, 7.2, -2775)
local _arenaRadius = 110

local function getPlayersInArena(): { Player }
    local inArena: { Player } = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root then
            local dist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(_arenaCenter.X, 0, _arenaCenter.Z)).Magnitude
            if dist <= _arenaRadius then
                table.insert(inArena, player)
            end
        end
    end
    return inArena
end

local function syncBossHealth()
    local bossRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.BossHealthUpdated)
    if bossRemote then
        bossRemote:FireAllClients(_bossCurrentHealth, _bossMaxHealth, _currentPhase)
    end
end

function BossEncounterService.Init(dependencies: { [string]: any })
    print("[BossEncounterService] Initializing BossEncounterService v2.0...")
    _rewardService = dependencies.RewardService
    _progressionService = dependencies.ProgressionService
    _survivalService = dependencies.SurvivalService
end

function BossEncounterService.Start()
    print("[BossEncounterService] BossEncounterService started.")

    -- Connect Ancient Seal channel prompts
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")

    if interactables then
        for i = 1, 5 do
            local seal = interactables:FindFirstChild("AncientSeal_" .. i)
            local prompt = seal and seal:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                prompt.Triggered:Connect(function(player: Player)
                    BossEncounterService.ChannelSeal(player, i)
                end)
            end
        end
    end

    -- Boss director heartbeat loop (runs every 1.0s)
    task.spawn(function()
        while true do
            task.wait(1.0)
            BossEncounterService.Tick()
        end
    end)
end

function BossEncounterService.Tick()
    local playersInArena = getPlayersInArena()

    if _currentPhase == "Dormant" then
        if #playersInArena > 0 then
            BossEncounterService.StartEncounter()
        end

    elseif _currentPhase == "Awakening" then
        _phaseTimer = _phaseTimer - 1
        if _phaseTimer <= 0 then
            BossEncounterService.TransitionTo("RootSweep")
        end

    elseif _currentPhase == "RootSweep" then
        _phaseTimer = _phaseTimer - 1
        -- Periodically spawn telegraphed root sweep wave
        if _phaseTimer % 4 == 0 then
            BossEncounterService.ExecuteRootSweep()
        end
        if _phaseTimer <= 0 then
            BossEncounterService.TransitionTo("BarrierPhase")
        end

    elseif _currentPhase == "BarrierPhase" then
        _phaseTimer = _phaseTimer - 1
        if _activatedSealsCount >= 5 then
            BossEncounterService.TransitionTo("ExposedCore")
        elseif _phaseTimer <= 0 then
            -- Reset seal timer and repeat root sweeps
            BossEncounterService.TransitionTo("RootSweep")
        end

    elseif _currentPhase == "ExposedCore" then
        _phaseTimer = _phaseTimer - 1
        -- Read health directly in case modified by player combat
        local tffWorld = Workspace:FindFirstChild("TFF_World")
        local map = tffWorld and tffWorld:FindFirstChild("Map")
        local heart = map and map:FindFirstChild("ForestGuardianCrystalHeart")
        if heart then
            local hp = heart:GetAttribute("Health")
            if hp then _bossCurrentHealth = hp end
        end

        if _bossCurrentHealth <= 0 then
            BossEncounterService.TransitionTo("Defeated")
        elseif _phaseTimer <= 0 then
            -- Core closes, shield re-engages
            BossEncounterService.TransitionTo("BarrierPhase")
        end

    elseif _currentPhase == "Defeated" then
        _phaseTimer = _phaseTimer - 1
        if _phaseTimer <= 0 then
            -- Reset boss after victory
            _bossCurrentHealth = _bossMaxHealth
            _currentPhase = "Dormant"
            syncBossHealth()
        end
    end
end

function BossEncounterService.StartEncounter()
    _bossCurrentHealth = _bossMaxHealth
    _currentPhase = "Awakening"
    _phaseTimer = 5

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local heart = map and map:FindFirstChild("ForestGuardianCrystalHeart")
    if heart then
        heart:SetAttribute("Health", _bossMaxHealth)
        heart:SetAttribute("BossTarget", true)
    end

    syncBossHealth()

    local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
    if eventRemote then
        eventRemote:FireAllClients(
            "THE FOREST GUARDIAN AWAKENS",
            "Ancient corruption surges through the Elder Tree! Prepare for battle!",
            10
        )
    end
    print("[BossEncounterService] Forest Guardian encounter initiated!")
end

function BossEncounterService.TransitionTo(phase: BossPhase)
    _currentPhase = phase
    print("[BossEncounterService] Phase changed to: " .. phase)

    if phase == "RootSweep" then
        _phaseTimer = 16
        syncBossHealth()

    elseif phase == "BarrierPhase" then
        _phaseTimer = 40
        _activatedSealsCount = 0
        BossEncounterService.ResetSeals()
        syncBossHealth()

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "ROOT BARRIER ENGAGED",
                "The Guardian is shielded! Channel the 5 Ancient Seals to shatter the ward!",
                12
            )
        end

    elseif phase == "ExposedCore" then
        _phaseTimer = 30
        syncBossHealth()

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "CRYSTAL HEART EXPOSED",
                "The ward has shattered! Strike the pulsing Crystal Heart inside the Elder Tree!",
                30
            )
        end

    elseif phase == "Defeated" then
        _phaseTimer = 180
        syncBossHealth()

        -- Distribute grand rewards to all players in arena
        local players = getPlayersInArena()
        for _, player in ipairs(players) do
            if _rewardService then
                _rewardService.GrantReward(player, "boss_victory", {
                    ancientTokens = 20,
                    forestCoins = 200,
                    items = {
                        { ItemId = "keeper_blade", Quantity = 1 },
                        { ItemId = "crystal", Quantity = 4 },
                        { ItemId = "ancient_fragment", Quantity = 3 },
                    }
                })
            end
            if _progressionService then
                _progressionService.AddExperience(player, 150)
            end
        end

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "FOREST GUARDIAN PURIFIED",
                "The ancient corruption has receded. The Great Valley is saved!",
                20
            )
        end
    end
end

-- Execute telegraphed Root Sweep attack
function BossEncounterService.ExecuteRootSweep()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    if not map then return end

    -- Visual telegraph arc
    local sweepPart = Instance.new("Part")
    sweepPart.Name = "BossRootSweepTelegraph"
    sweepPart.Size = Vector3.new(160, 1.5, 12)
    sweepPart.CFrame = CFrame.new(_arenaCenter.X, 7.5, _arenaCenter.Z + math.random(-60, 60))
    sweepPart.Color = Color3.fromRGB(220, 50, 40)
    sweepPart.Material = Enum.Material.Neon
    sweepPart.Transparency = 0.5
    sweepPart.CanCollide = false
    sweepPart.Anchored = true
    sweepPart.Parent = map

    -- After 1.2s telegraph, root erupts and damages players inside the strip
    task.delay(1.2, function()
        if sweepPart.Parent then
            sweepPart.Color = Color3.fromRGB(75, 45, 25)
            sweepPart.Size = Vector3.new(160, 7, 12)
            sweepPart.Transparency = 0.0

            -- Check players within hitbox
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                if root then
                    local pPos = root.Position
                    local sPos = sweepPart.Position
                    if math.abs(pPos.X - sPos.X) < 80 and math.abs(pPos.Z - sPos.Z) < 8 and pPos.Y < (sPos.Y + 8) then
                        if _survivalService then
                            _survivalService.ApplyDamage(player, 22)
                        end
                    end
                end
            end

            task.delay(0.8, function()
                if sweepPart.Parent then sweepPart:Destroy() end
            end)
        end
    end)
end

-- Channel Ancient Seal during Barrier Phase
function BossEncounterService.ChannelSeal(player: Player, sealIndex: number)
    if _currentPhase ~= "BarrierPhase" then return end

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local seal = interactables and interactables:FindFirstChild("AncientSeal_" .. sealIndex)
    if not seal or seal:GetAttribute("Activated") == true then return end

    seal:SetAttribute("Activated", true)
    _activatedSealsCount = _activatedSealsCount + 1

    -- Turn beam bright cyan
    local beam = map and map:FindFirstChild("SealLightBeam_" .. sealIndex)
    if beam and beam:IsA("BasePart") then
        beam.Color = Color3.fromRGB(0, 255, 230)
        beam.Transparency = 0.1
    end

    if _progressionService then
        _progressionService.AddExperience(player, 20)
    end

    print(string.format("[BossEncounterService] Seal %d channeled by %s (%d/5)", sealIndex, player.Name, _activatedSealsCount))

    if _activatedSealsCount >= 5 then
        BossEncounterService.TransitionTo("ExposedCore")
    end
end

function BossEncounterService.ResetSeals()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")

    if interactables then
        for i = 1, 5 do
            local seal = interactables:FindFirstChild("AncientSeal_" .. i)
            if seal then
                seal:SetAttribute("Activated", false)
            end
            local beam = map and map:FindFirstChild("SealLightBeam_" .. i)
            if beam and beam:IsA("BasePart") then
                beam.Color = Color3.fromRGB(0, 180, 160)
                beam.Transparency = 0.6
            end
        end
    end
end

return BossEncounterService
]=====]

services:FindFirstChild("EventService").Source = [=====[--!strict
--[[
    EventService.lua
    Server-authoritative World Event Director.
    Coordinates dynamic valley events: Fog Surge, Strange Signal, Crystal Bloom, and Abandoned Caravan.
    Directly fulfills Master Game Specification Section 2.4 and Chapter objectives.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

export type WorldEvent = {
    Id: string,
    Title: string,
    Description: string,
    Duration: number,
    Start: () -> (),
    Cleanup: () -> (),
}

local EventService = {}
EventService.__index = EventService

local _weatherService: any = nil
local _rewardService: any = nil
local _worldService: any = nil

local _activeEvent: WorldEvent? = nil
local _eventCleanupTasks: { () -> () } = {}

function EventService.Init(dependencies: { [string]: any })
    print("[EventService] Initializing EventService v2.0...")
    _weatherService = dependencies.WeatherService
    _rewardService = dependencies.RewardService
    _worldService = dependencies.WorldService
end

function EventService.Start()
    print("[EventService] EventService started. Registering scheduled valley events.")

    -- Periodic world event scheduler (every 5 to 7 minutes)
    task.spawn(function()
        task.wait(120) -- initial grace period after server start
        local eventTypes = { "FogSurge", "StrangeSignal", "CrystalBloom", "AbandonedCaravan" }
        local eventIndex = 1

        while true do
            local eventName = eventTypes[eventIndex]
            EventService.TriggerEvent(eventName)

            eventIndex = (eventIndex % #eventTypes) + 1
            task.wait(320)
        end
    end)
end

function EventService.TriggerEvent(eventName: string)
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)

    -- 1. FOG SURGE EVENT
    if eventName == "FogSurge" then
        if _weatherService then
            _weatherService.TriggerFogSurge(90)
        end
        if eventRemote then
            eventRemote:FireAllClients(
                "FOG SURGE APPROACHING",
                "A dense freezing wall of supernatural mist rolls down the valley! Cold drain x2.5. Retreat to campfires!",
                90
            )
        end

    -- 2. STRANGE SIGNAL EVENT
    elseif eventName == "StrangeSignal" and interactables then
        local signalChest = Instance.new("Part")
        signalChest.Name = "Event_SignalCache"
        signalChest.Size = Vector3.new(4, 3, 3)
        signalChest.CFrame = CFrame.new(210, 16.5, -880)
        signalChest.Color = Color3.fromRGB(0, 240, 180)
        signalChest.Material = Enum.Material.Neon
        signalChest.Anchored = true
        signalChest.CanCollide = true

        local pLight = Instance.new("PointLight")
        pLight.Color = Color3.fromRGB(0, 240, 180)
        pLight.Range = 25
        pLight.Brightness = 3
        pLight.Parent = signalChest

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Salvage Anomalous Signal Cache"
        prompt.ObjectText = "Glowing Keeper Cache"
        prompt.HoldDuration = 1.5
        prompt.MaxActivationDistance = 9
        prompt.Parent = signalChest

        signalChest.Parent = interactables

        prompt.Triggered:Connect(function(player: Player)
            if _rewardService then
                _rewardService.GrantReward(player, "strange_signal_cache", {
                    ancientTokens = 5,
                    forestCoins = 50,
                    items = { { ItemId = "crystal", Quantity = 2 }, { ItemId = "ancient_fragment", Quantity = 1 } }
                })
            end
            signalChest:Destroy()
        end)

        task.delay(180, function()
            if signalChest.Parent then signalChest:Destroy() end
        end)

        if eventRemote then
            eventRemote:FireAllClients(
                "STRANGE SIGNAL DETECTED",
                "An anomalous emerald frequency is pinging from Watcher's Bluff in Whispering Woods!",
                180
            )
        end

    -- 3. CRYSTAL BLOOM EVENT
    elseif eventName == "CrystalBloom" then
        if eventRemote then
            eventRemote:FireAllClients(
                "CRYSTAL GROTTO RESONANCE",
                "The subterranean veins in Crystal Caverns are pulsating with high energy! Mining yield increased!",
                120
            )
        end

    -- 4. ABANDONED CARAVAN EVENT
    elseif eventName == "AbandonedCaravan" and interactables then
        local crate = Instance.new("Part")
        crate.Name = "Event_CaravanCrate"
        crate.Size = Vector3.new(4, 3, 3)
        crate.CFrame = CFrame.new(15, 2, -440)
        crate.Color = Color3.fromRGB(115, 85, 55)
        crate.Material = Enum.Material.WoodPlanks
        crate.Anchored = true
        crate.CanCollide = true

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Scavenge Overturned Crate"
        prompt.ObjectText = "Expedition Supplies"
        prompt.HoldDuration = 1.0
        prompt.MaxActivationDistance = 9
        prompt.Parent = crate
        crate.Parent = interactables

        prompt.Triggered:Connect(function(player: Player)
            if _rewardService then
                _rewardService.GrantReward(player, "caravan_supplies", {
                    forestCoins = 25,
                    items = { { ItemId = "food", Quantity = 4 }, { ItemId = "cloth", Quantity = 3 }, { ItemId = "rope", Quantity = 2 } }
                })
            end
            crate:Destroy()
        end)

        task.delay(180, function()
            if crate.Parent then crate:Destroy() end
        end)

        if eventRemote then
            eventRemote:FireAllClients(
                "ABANDONED CARAVAN SIGHTED",
                "An overturned expedition crate was spotted near the Whispering Woods Creek Ravine!",
                180
            )
        end
    end
end

return EventService
]=====]
services:FindFirstChild("PlayerService").Source = [=====[--!strict
--[[
    PlayerService.lua
    Manages player lifecycle, character spawning, profile synchronization, and safe disconnection.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local StoryDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.StoryDefinitions)
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")

local PlayerService = {}
PlayerService.__index = PlayerService

local _profileService: any = nil
local _worldService: any = nil
local _progressionService: any = nil

local function onPlayerAdded(player: Player)
    print(string.format("[PlayerService] Player joined: %s (%d)", player.Name, player.UserId))

    -- Enforce soft player limit if needed
    if #Players:GetPlayers() > BalanceConfig.MaxPlayers then
        player:Kick("Server capacity reached (Max 12 players). Please join another server.")
        return
    end

    local profile = _profileService.LoadProfile(player)

    -- Character spawning setup
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = 16

        -- Spawn inside Safe Haven spawn location if available
        local worldRoot = game.Workspace:FindFirstChild("TFF_World")
        if worldRoot then
            local spawnFolder = worldRoot:FindFirstChild("SpawnLocations")
            if spawnFolder and #spawnFolder:GetChildren() > 0 then
                local spawnPart = spawnFolder:GetChildren()[1] :: BasePart
                if spawnPart and spawnPart:IsA("BasePart") then
                    character:PivotTo(spawnPart.CFrame + Vector3.new(0, 3, 0))
                end
            end
        end
    end)

    -- Sync initial profile to client
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

local function onPlayerRemoving(player: Player)
    print(string.format("[PlayerService] Player leaving: %s (%d)", player.Name, player.UserId))
    _profileService.UnloadProfile(player)
end

function PlayerService.Init(dependencies: { [string]: any })
    print("[PlayerService] Initializing PlayerService...")
    _profileService = dependencies.ProfileService
    _worldService = dependencies.WorldService
    _progressionService = dependencies.ProgressionService
end

function PlayerService.Start()
    print("[PlayerService] PlayerService started.")
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end

    -- Hook up ProximityPrompts for NPCs and Story Clues
    local dialogRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncDialog)

    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
        local parentInstance = prompt.Parent
        if not parentInstance then return end

        local model = parentInstance:FindFirstAncestorOfClass("Model")

        -- 1. NPC Interaction
        if model and CollectionService:HasTag(model, "TFF_NPC") then
            local npcId = model:GetAttribute("NPCId") or "cartographer"
            local data = StoryDefinitions.Dialogues[npcId]
            if data and dialogRemote then
                dialogRemote:FireClient(player, "NPC", data)
            end

        -- 2. Story Clue Interaction
        elseif parentInstance:IsA("BasePart") and CollectionService:HasTag(parentInstance, "TFF_StoryClue") then
            local clueId = parentInstance:GetAttribute("ClueId") or "safe_haven_orders"
            local data = StoryDefinitions.Clues[clueId]
            if data and dialogRemote then
                dialogRemote:FireClient(player, "Clue", data)
                if _progressionService then
                    _progressionService.AddExperience(player, 25)
                end
            end
        end
    end)
end

return PlayerService
]=====]

return "SYNC 2B SUCCESS: WeatherService, EventService, BossEncounterService, PlayerService updated!"
