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
local _inventoryService: any = nil
local _questService: any = nil

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
    _inventoryService = dependencies.InventoryService
    _questService = dependencies.QuestService
end

function PlayerService.Start()
    print("[PlayerService] PlayerService started.")
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end

    -- Hook up ProximityPrompts for NPCs, Chests, and Story Clues
    local dialogRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncDialog)
    local notificationRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.ShowNotification)

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

        -- 2. Expedition Starter Supply Chest Interaction
        elseif parentInstance.Name == "ExpeditionStarterChest" or (model and model.Name == "ExpeditionStarterChest") then
            local profile = _profileService.GetProfile(player)
            if profile then
                local alreadyClaimed = profile.hasClaimedStarterKit == true
                if not alreadyClaimed then
                    profile.hasClaimedStarterKit = true
                    if _inventoryService then
                        _inventoryService.TryAddItem(player, "torch", 1)
                        _inventoryService.TryAddItem(player, "field_knife", 1)
                        _inventoryService.TryAddItem(player, "warm_clothing", 1)
                        _inventoryService.TryAddItem(player, "healing_potion", 3)
                        _inventoryService.TryAddItem(player, "wood", 8)
                        _inventoryService.TryAddItem(player, "stone", 6)
                        _inventoryService.TryAddItem(player, "cloth", 4)
                        _inventoryService.TryAddItem(player, "herb", 4)
                        _inventoryService.TryAddItem(player, "water", 2)
                    end
                    if _questService then
                        _questService.TryClaimQuestReward(player, "q_starter_kit")
                    end
                    if notificationRemote then
                        notificationRemote:FireClient(player, "STARTER SUPPLIES CLAIMED!", "Equipped with Torch, Field Knife, Explorer's Parka, and Salves! Press [Q] for Quests, [C] for Crafting, [M] for Map.")
                    end
                else
                    -- Ensure they still have at least basic tools
                    if _inventoryService then
                        if _inventoryService.GetItemCount(player, "torch") == 0 then
                            _inventoryService.TryAddItem(player, "torch", 1)
                        end
                        if _inventoryService.GetItemCount(player, "field_knife") == 0 then
                            _inventoryService.TryAddItem(player, "field_knife", 1)
                        end
                    end
                    if notificationRemote then
                        notificationRemote:FireClient(player, "EXPEDITION SUPPLIES READY", "Your Torch, Field Knife, and Explorer's Parka are in your Hotbar and Inventory! Press [C] to Craft, [Q] for Quests.")
                    end
                end
            end

        -- 3. Story Clue Interaction
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
