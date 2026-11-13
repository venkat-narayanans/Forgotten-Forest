--!strict
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
