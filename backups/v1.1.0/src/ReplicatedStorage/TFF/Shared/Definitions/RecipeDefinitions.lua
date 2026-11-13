--!strict
--[[
    RecipeDefinitions.lua
    Data-driven crafting recipe definitions for The Forgotten Forest.
]]

local Types = require(script.Parent.Parent.Types.Types)

local RecipeDefinitions: { [string]: Types.RecipeDefinition } = {
    torch = {
        RecipeId = "torch",
        DisplayName = "Traveler's Torch",
        Description = "Craft a simple torch from timber and fiber.",
        OutputItemId = "torch",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 2 },
            { ItemId = "cloth", Quantity = 1 },
        },
        StationRequired = nil, -- Can be crafted anywhere
        CraftDuration = 2.0,
        UnlockLevel = 1,
    },
    healing_potion = {
        RecipeId = "healing_potion",
        DisplayName = "Herbal Salve",
        Description = "Brew wild herbs with fresh spring water.",
        OutputItemId = "healing_potion",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "herb", Quantity = 2 },
            { ItemId = "water", Quantity = 1 },
        },
        StationRequired = nil,
        CraftDuration = 3.0,
        UnlockLevel = 1,
    },
    wooden_barricade = {
        RecipeId = "wooden_barricade",
        DisplayName = "Wooden Barricade",
        Description = "Fasten timber logs into a defensive barrier.",
        OutputItemId = "wooden_barricade",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 5 },
        },
        StationRequired = "Workbench",
        CraftDuration = 4.0,
        UnlockLevel = 2,
    },
    basic_trap = {
        RecipeId = "basic_trap",
        DisplayName = "Snare Trap",
        Description = "Rig wood and rope into a creature trap.",
        OutputItemId = "basic_trap",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 3 },
            { ItemId = "rope", Quantity = 2 },
        },
        StationRequired = "Workbench",
        CraftDuration = 3.5,
        UnlockLevel = 2,
    },
    advanced_lantern = {
        RecipeId = "advanced_lantern",
        DisplayName = "Aether Lantern",
        Description = "Assemble rare luminescent crystals with scrap metal framing.",
        OutputItemId = "advanced_lantern",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "crystal", Quantity = 2 },
            { ItemId = "metal_scrap", Quantity = 3 },
        },
        StationRequired = "Workbench",
        CraftDuration = 5.0,
        UnlockLevel = 4,
    },
    warm_clothing = {
        RecipeId = "warm_clothing",
        DisplayName = "Explorer's Parka",
        Description = "Tailor pelts and woven fiber into cold-weather protection.",
        OutputItemId = "warm_clothing",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "cloth", Quantity = 3 },
            { ItemId = "animal_material", Quantity = 2 },
        },
        StationRequired = "Workbench",
        CraftDuration = 4.0,
        UnlockLevel = 3,
    },
    basic_tool = {
        RecipeId = "basic_tool",
        DisplayName = "Carved Hatchet",
        Description = "Affix a shaped river stone to a carved wooden handle.",
        OutputItemId = "basic_tool",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 2 },
            { ItemId = "stone", Quantity = 2 },
        },
        StationRequired = nil,
        CraftDuration = 2.5,
        UnlockLevel = 1,
    },
}

return RecipeDefinitions
