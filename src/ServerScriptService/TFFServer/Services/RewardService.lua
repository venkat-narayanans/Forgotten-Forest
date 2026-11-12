--!strict
--[[
    RewardService.lua
    Coordinates participation-based encounter and dawn cycle rewards.
    Guarantees reward idempotency and fair contribution attribution.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

local RewardService = {}
RewardService.__index = RewardService

local _progressionService: any = nil
local _inventoryService: any = nil

local _processedTransactions: { [string]: boolean } = {}

function RewardService.Init(dependencies: { [string]: any })
    print("[RewardService] Initializing RewardService...")
    _progressionService = dependencies.ProgressionService
    _inventoryService = dependencies.InventoryService
end

function RewardService.Start()
    print("[RewardService] RewardService started.")
end

function RewardService.GrantIdempotentReward(player: Player, transactionId: string, xp: number, coins: number, items: { [string]: number }?): boolean
    if _processedTransactions[transactionId] then
        warn(string.format("[RewardService] Duplicate reward transaction rejected: %s", transactionId))
        return false
    end

    _processedTransactions[transactionId] = true

    if xp > 0 then
        _progressionService.GrantXP(player, xp, "Reward: " .. transactionId)
    end
    if coins > 0 then
        _progressionService.GrantCurrency(player, "ForestCoins", coins)
    end
    if items then
        for itemId, qty in pairs(items) do
            _inventoryService.TryAddItem(player, itemId, qty)
        end
    end

    return true
end

return RewardService
