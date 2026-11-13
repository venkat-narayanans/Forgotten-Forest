--!strict
--[[
    CraftingService.lua
    Server-authoritative crafting system.
    Validates recipes, workbench station proximity, ingredients, and executes atomic transactions.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RecipeDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.RecipeDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local CraftingService = {}
CraftingService.__index = CraftingService

local _inventoryService: any = nil
local _profileService: any = nil
local _survivalService: any = nil

local function isNearStation(player: Player, stationName: string): boolean
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return false end

    for _, inst in ipairs(CollectionService:GetTagged("TFF_Interactable")) do
        if inst:IsA("BasePart") and inst:GetAttribute("Station") == stationName then
            local dist = (root.Position - inst.Position).Magnitude
            if dist <= BalanceConfig.DefaultInteractionRange + 4 then
                return true
            end
        end
    end
    return false
end

function CraftingService.Init(dependencies: { [string]: any })
    print("[CraftingService] Initializing CraftingService...")
    _inventoryService = dependencies.InventoryService
    _profileService = dependencies.ProfileService
    _survivalService = dependencies.SurvivalService

    local craftRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestCraft)
    if craftRemote then
        craftRemote.OnServerEvent:Connect(function(player: Player, recipeId: string, quantity: number)
            CraftingService.TryCraft(player, recipeId, quantity or 1)
        end)
    end
end

function CraftingService.Start()
    print("[CraftingService] CraftingService started.")
end

function CraftingService.TryCraft(player: Player, recipeId: string, quantity: number): boolean
    if quantity <= 0 or quantity > 10 then return false end
    local recipe = RecipeDefinitions[recipeId]
    if not recipe then return false end

    local stats = _survivalService.GetStats(player)
    if not stats or stats.IsDowned then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    if recipe.UnlockLevel and profile.level < recipe.UnlockLevel then
        return false
    end

    -- Station proximity validation
    if recipe.StationRequired and not isNearStation(player, recipe.StationRequired) then
        warn(string.format("[CraftingService] %s tried to craft %s without being near %s", player.Name, recipeId, recipe.StationRequired))
        return false
    end

    -- Ingredient validation
    for _, ingredient in ipairs(recipe.Ingredients) do
        local requiredAmount = ingredient.Quantity * quantity
        local currentCount = _inventoryService.GetItemCount(player, ingredient.ItemId)
        if currentCount < requiredAmount then
            return false
        end
    end

    -- Atomic deduction
    for _, ingredient in ipairs(recipe.Ingredients) do
        local toRemove = ingredient.Quantity * quantity
        local removed = _inventoryService.TryRemoveItem(player, ingredient.ItemId, toRemove)
        if not removed then
            return false
        end
    end

    -- Atomic output grant
    local totalOutput = recipe.OutputQuantity * quantity
    local added = _inventoryService.TryAddItem(player, recipe.OutputItemId, totalOutput)
    if not added then
        -- Rollback ingredients if inventory full
        for _, ingredient in ipairs(recipe.Ingredients) do
            _inventoryService.TryAddItem(player, ingredient.ItemId, ingredient.Quantity * quantity)
        end
        return false
    end

    print(string.format("[CraftingService] %s crafted %dx %s", player.Name, totalOutput, recipe.DisplayName))
    return true
end

return CraftingService
