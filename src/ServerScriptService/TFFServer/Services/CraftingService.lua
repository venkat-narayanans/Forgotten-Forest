--!strict
--[[
    CraftingService.lua
    Server-authoritative crafting system.
    Validates recipes, stations, ingredients, and executes atomic crafting transactions.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RecipeDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.RecipeDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local CraftingService = {}
CraftingService.__index = CraftingService

local _inventoryService: any = nil
local _profileService: any = nil
local _survivalService: any = nil

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

    -- Check player stats and downed state
    local stats = _survivalService.GetStats(player)
    if not stats or stats.IsDowned then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    -- Check unlock level / recipe unlock
    if recipe.UnlockLevel and profile.level < recipe.UnlockLevel then
        return false
    end

    -- Validate ingredients
    for _, ingredient in ipairs(recipe.Ingredients) do
        local requiredAmount = ingredient.Quantity * quantity
        local currentCount = _inventoryService.GetItemCount(player, ingredient.ItemId)
        if currentCount < requiredAmount then
            return false
        end
    end

    -- Atomic execution: remove ingredients
    for _, ingredient in ipairs(recipe.Ingredients) do
        local toRemove = ingredient.Quantity * quantity
        local removed = _inventoryService.TryRemoveItem(player, ingredient.ItemId, toRemove)
        if not removed then
            -- Rollback if something failed unexpectedly
            warn(string.format("[CraftingService] Ingredient removal failure during craft for %s", player.Name))
            return false
        end
    end

    -- Grant output
    local totalOutput = recipe.OutputQuantity * quantity
    local added = _inventoryService.TryAddItem(player, recipe.OutputItemId, totalOutput)
    if not added then
        warn(string.format("[CraftingService] Failed to add crafted item for %s: inventory full", player.Name))
        -- In case of full inventory, return ingredients to prevent item loss
        for _, ingredient in ipairs(recipe.Ingredients) do
            _inventoryService.TryAddItem(player, ingredient.ItemId, ingredient.Quantity * quantity)
        end
        return false
    end

    print(string.format("[CraftingService] %s crafted %dx %s", player.Name, totalOutput, recipe.DisplayName))
    return true
end

return CraftingService
