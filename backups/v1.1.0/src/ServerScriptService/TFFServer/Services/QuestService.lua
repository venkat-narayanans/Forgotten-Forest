--!strict
--[[
    QuestService.lua
    Server-authoritative quest management and idempotent completion tracking.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.QuestDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

local QuestService = {}
QuestService.__index = QuestService

local _profileService: any = nil
local _progressionService: any = nil
local _inventoryService: any = nil

function QuestService.Init(dependencies: { [string]: any })
    print("[QuestService] Initializing QuestService...")
    _profileService = dependencies.ProfileService
    _progressionService = dependencies.ProgressionService
    _inventoryService = dependencies.InventoryService

    local claimRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestClaimQuest)
    if claimRemote then
        claimRemote.OnServerEvent:Connect(function(player: Player, questId: string)
            QuestService.TryClaimQuestReward(player, questId)
        end)
    end
end

function QuestService.Start()
    print("[QuestService] QuestService started.")
end

function QuestService.TryClaimQuestReward(player: Player, questId: string): boolean
    local def = QuestDefinitions[questId]
    if not def then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    -- Check idempotency: cannot complete non-repeatable quest twice
    if not def.IsRepeatable and profile.completedQuests[questId] then
        return false
    end

    -- Mark completed
    profile.completedQuests[questId] = true

    -- Grant rewards
    if def.Rewards.XP > 0 then
        _progressionService.GrantXP(player, def.Rewards.XP, "Quest: " .. def.Title)
    end
    if def.Rewards.ForestCoins > 0 then
        _progressionService.GrantCurrency(player, "ForestCoins", def.Rewards.ForestCoins)
    end
    if def.Rewards.AncientTokens > 0 then
        _progressionService.GrantCurrency(player, "AncientTokens", def.Rewards.AncientTokens)
    end
    if def.Rewards.Items then
        for itemId, qty in pairs(def.Rewards.Items) do
            _inventoryService.TryAddItem(player, itemId, qty)
        end
    end

    local questUpdateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.QuestUpdated)
    if questUpdateRemote then
        questUpdateRemote:FireClient(player, profile.activeQuests, profile.completedQuests)
    end

    return true
end

return QuestService
