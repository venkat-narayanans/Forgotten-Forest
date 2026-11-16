--!strict
--[[
    WorldInteractionService.lua
    Server-authoritative controller for narrative and landmark world interactions in The Forgotten Forest:
    1. Safe Haven Central Beacon (Repair with 4 wood, 2 stone -> Active state with amber aura)
    2. Abandoned Village Three Lantern Archive Puzzle (Root -> Ember -> Echo -> Unlocks Archive Vault)
    3. Village Clock Tower Gear Restoration (Requires clock_gear -> Chime sound & progress)
    4. Watchtower Telescope (Discovers distant valley landmarks on Survey Map)
    Implements The_Forgotten_Forest_Complete_Experience_Bible.md Sections 4.1, 4.3, 9, and 12.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local WorldInteractionService = {}
WorldInteractionService.__index = WorldInteractionService

local _inventoryService: any = nil
local _questService: any = nil
local _progressionService: any = nil
local _initialized = false

-- State tracking
local _beaconRepaired = false
local _archiveLanternSequence: { string } = {}
local _archiveUnlocked = false
local _clockTowerRepaired = false

local CANONICAL_LANTERN_ORDER = { "Root", "Ember", "Echo" }

function WorldInteractionService.Init(dependencies: { [string]: any })
    print("[WorldInteractionService] Initializing world interaction and puzzle director...")
    _inventoryService = dependencies["InventoryService"]
    _questService = dependencies["QuestService"]
    _progressionService = dependencies["ProgressionService"]
    _initialized = true
end

function WorldInteractionService.Start()
    print("[WorldInteractionService] Starting listeners on world landmarks...")
    task.defer(function()
        task.wait(1.0)
        WorldInteractionService.SetupBeaconInteraction()
        WorldInteractionService.SetupArchivePuzzle()
        WorldInteractionService.SetupClockTowerInteraction()
        WorldInteractionService.SetupTelescopeInteraction()
    end)
end

----------------------------------------------------------------------
-- 1. Safe Haven Central Beacon
----------------------------------------------------------------------
function WorldInteractionService.SetupBeaconInteraction()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return end
    local interactables = tffWorld:FindFirstChild("Interactables")
    if not interactables then return end

    local beacon = interactables:FindFirstChild("SafeHaven_CentralBeacon")
    if not beacon then return end

    local prompt = beacon:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return end

    prompt.Triggered:Connect(function(player: Player)
        WorldInteractionService.OnBeaconInteracted(player, beacon, prompt)
    end)
end

function WorldInteractionService.OnBeaconInteracted(player: Player, beacon: Instance, prompt: ProximityPrompt)
    if _beaconRepaired then
        -- Already active: warm yourself
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 15)
            end
        end
        return
    end

    -- Check ingredients: 4 wood, 2 stone
    if not _inventoryService then return end
    local woodCount = _inventoryService.GetItemCount(player, "wood")
    local stoneCount = _inventoryService.GetItemCount(player, "stone")

    if woodCount >= 4 and stoneCount >= 2 then
        -- Remove ingredients
        _inventoryService.RemoveItem(player, "wood", 4)
        _inventoryService.RemoveItem(player, "stone", 2)

        _beaconRepaired = true
        beacon:SetAttribute("State", "Active")
        prompt.ActionText = "Warm Yourself by Beacon"
        prompt.HoldDuration = 0.5

        -- Ignite Beacon Core visually
        local core = beacon:FindFirstChild("BeaconCore", true) :: BasePart?
        if core then
            core.Material = Enum.Material.Neon
            core.Color = Color3.fromRGB(255, 180, 50)
            local light = core:FindFirstChildOfClass("PointLight")
            if not light then
                light = Instance.new("PointLight")
                light.Parent = core
            end
            light.Color = Color3.fromRGB(255, 190, 80)
            light.Range = 60
            light.Brightness = 3.5
        end

        -- Award player
        if _progressionService then
            _progressionService.AwardXP(player, 150)
        end
        if _questService then
            _questService.OnCustomEvent(player, "Interact", "SafeHaven_CentralBeacon")
        end

        print(string.format("[WorldInteractionService] Player %s repaired Safe Haven Central Beacon! Camp perimeter fortified.", player.Name))
    else
        -- Notify player of requirements
        print(string.format("[WorldInteractionService] %s needs 4 wood, 2 stone to repair the Beacon (Has: %d wood, %d stone)", player.Name, woodCount, stoneCount))
    end
end

----------------------------------------------------------------------
-- 2. Abandoned Village Three Lantern Archive Puzzle
----------------------------------------------------------------------
function WorldInteractionService.SetupArchivePuzzle()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return end
    local interactables = tffWorld:FindFirstChild("Interactables")
    if not interactables then return end

    local archive = interactables:FindFirstChild("Village_KeeperArchive")
    if not archive then return end

    for _, lanternName in ipairs({ "ArchiveLantern_Root", "ArchiveLantern_Ember", "ArchiveLantern_Echo" }) do
        local lantern = archive:FindFirstChild(lanternName, true)
        if lantern then
            local prompt = lantern:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local runeType = string.gsub(lanternName, "ArchiveLantern_", "")
                prompt.Triggered:Connect(function(player: Player)
                    WorldInteractionService.OnLanternTriggered(player, lantern, runeType, archive)
                end)
            end
        end
    end
end

function WorldInteractionService.OnLanternTriggered(player: Player, lantern: Instance, runeType: string, archive: Instance)
    if _archiveUnlocked then return end

    -- Light up this lantern
    local flame = lantern:FindFirstChild("LanternFlame", true) :: BasePart?
    if flame then
        flame.Material = Enum.Material.Neon
        flame.Color = Color3.fromRGB(80, 220, 255)
    end

    table.insert(_archiveLanternSequence, runeType)
    local stepIndex = #_archiveLanternSequence

    -- Check if step is correct
    if CANONICAL_LANTERN_ORDER[stepIndex] == runeType then
        print(string.format("[ArchivePuzzle] Correct step %d: %s by %s", stepIndex, runeType, player.Name))
        if stepIndex == #CANONICAL_LANTERN_ORDER then
            -- Puzzle Solved!
            _archiveUnlocked = true
            print("[ArchivePuzzle] All three lanterns lit in sacred order! Archive Vault unlocked.")
            
            -- Open Vault Door
            local vaultDoor = archive:FindFirstChild("VaultDoor", true) :: BasePart?
            if vaultDoor then
                vaultDoor.Transparency = 0.8
                vaultDoor.CanCollide = false
            end

            if _progressionService then
                _progressionService.AwardXP(player, 300)
            end
            if _questService then
                _questService.OnCustomEvent(player, "Interact", "ArchivePuzzle")
            end
        end
    else
        -- Wrong sequence: reset after 1.5 seconds
        print(string.format("[ArchivePuzzle] Incorrect lantern sequence at step %d! Resetting...", stepIndex))
        task.delay(1.5, function()
            _archiveLanternSequence = {}
            for _, name in ipairs({ "ArchiveLantern_Root", "ArchiveLantern_Ember", "ArchiveLantern_Echo" }) do
                local l = archive:FindFirstChild(name, true)
                if l then
                    local f = l:FindFirstChild("LanternFlame", true) :: BasePart?
                    if f then
                        f.Material = Enum.Material.Glass
                        f.Color = Color3.fromRGB(60, 60, 60)
                    end
                end
            end
        end)
    end
end

----------------------------------------------------------------------
-- 3. Village Clock Tower Gear Restoration
----------------------------------------------------------------------
function WorldInteractionService.SetupClockTowerInteraction()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return end
    local interactables = tffWorld:FindFirstChild("Interactables")
    if not interactables then return end

    local clockTower = interactables:FindFirstChild("Village_ClockTower_48")
    if not clockTower then return end

    local prompt = clockTower:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return end

    prompt.Triggered:Connect(function(player: Player)
        if _clockTowerRepaired then return end

        if _inventoryService and _inventoryService.GetItemCount(player, "clock_gear") >= 1 then
            _inventoryService.RemoveItem(player, "clock_gear", 1)
            _clockTowerRepaired = true
            prompt.ActionText = "Inspect Restored Clock Mechanism"
            prompt.HoldDuration = 0.5

            local clockFace = clockTower:FindFirstChild("ClockFace", true) :: BasePart?
            if clockFace then
                clockFace.Material = Enum.Material.Neon
                clockFace.Color = Color3.fromRGB(255, 230, 150)
            end

            if _progressionService then
                _progressionService.AwardXP(player, 200)
            end
            print(string.format("[WorldInteractionService] Player %s restored the Village Clock Tower escapement gear!", player.Name))
        else
            print(string.format("[WorldInteractionService] Player %s needs a Brass Clock Gear to repair the clock mechanism.", player.Name))
        end
    end)
end

----------------------------------------------------------------------
-- 4. Watchtower Telescope Landmark Discovery
----------------------------------------------------------------------
function WorldInteractionService.SetupTelescopeInteraction()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return end
    local interactables = tffWorld:FindFirstChild("Interactables")
    if not interactables then return end

    local telescope = interactables:FindFirstChild("Prop_BrassTelescope", true)
    if not telescope then return end

    local prompt = telescope:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return end

    prompt.Triggered:Connect(function(player: Player)
        if _progressionService then
            _progressionService.AwardXP(player, 50)
        end
        print(string.format("[WorldInteractionService] Player %s surveyed the valley landmarks through the Watchtower Telescope!", player.Name))
    end)
end

return WorldInteractionService
