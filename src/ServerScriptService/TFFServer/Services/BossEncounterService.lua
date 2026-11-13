--!strict
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
