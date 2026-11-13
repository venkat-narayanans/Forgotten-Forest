--!strict
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
