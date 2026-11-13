--!strict
--[[
    ProfileService.lua
    Server-authoritative persistence provider for player profiles.
    Includes mock fallback for studio offline environments and safe migration logic.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("TFF"):WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("Types"))

local ProfileService = {}
ProfileService.__index = ProfileService

local SCHEMA_VERSION = 1
local DATA_STORE_NAME = "TFF_PlayerData_v1"

local _dataStore: GlobalDataStore? = nil
local _activeProfiles: { [number]: Types.PlayerProfile } = {}
local _mockStore: { [string]: Types.PlayerProfile } = {}
local _isMock = false

local function createDefaultProfile(): Types.PlayerProfile
    return {
        schemaVersion = SCHEMA_VERSION,
        level = 1,
        xp = 0,
        forestCoins = 50,
        ancientTokens = 0,
        inventory = {
            { ItemId = "torch", Quantity = 1 },
            { ItemId = "field_knife", Quantity = 1 },
            { ItemId = "warm_clothing", Quantity = 1 },
            { ItemId = "healing_potion", Quantity = 3 },
            { ItemId = "wood", Quantity = 8 },
            { ItemId = "stone", Quantity = 6 },
            { ItemId = "cloth", Quantity = 4 },
            { ItemId = "herb", Quantity = 4 },
            { ItemId = "water", Quantity = 2 },
        },
        equipment = {
            mainHand = "field_knife",
            body = "warm_clothing",
        },
        unlockedRecipes = {
            torch = true,
            healing_potion = true,
            basic_tool = true,
            field_knife = true,
            wooden_spear = true,
            arrow = true,
            warm_clothing = true,
        },
        completedQuests = {},
        activeQuests = {
            q_starter_kit = { progress = 1, completed = false },
            q_first_steps = { progress = 0, completed = false },
        },
        achievements = {},
        discoveries = { ["Safe Haven"] = true },
        cosmetics = {},
        settings = {
            reducedEffects = false,
            cameraShake = true,
        },
        lastSaveUnix = os.time(),
    }
end

local function migrateProfile(data: any): Types.PlayerProfile
    if typeof(data) ~= "table" then
        return createDefaultProfile()
    end

    local profile = data :: Types.PlayerProfile
    if not profile.schemaVersion or profile.schemaVersion < 1 then
        profile.schemaVersion = 1
    end
    if not profile.inventory then profile.inventory = {} end
    if #profile.inventory == 0 then
        -- Guarantee starter equipment is provided
        profile.inventory = {
            { ItemId = "torch", Quantity = 1 },
            { ItemId = "field_knife", Quantity = 1 },
            { ItemId = "warm_clothing", Quantity = 1 },
            { ItemId = "healing_potion", Quantity = 3 },
            { ItemId = "wood", Quantity = 8 },
            { ItemId = "stone", Quantity = 6 },
            { ItemId = "cloth", Quantity = 4 },
            { ItemId = "herb", Quantity = 4 },
            { ItemId = "water", Quantity = 2 },
        }
    end
    if not profile.equipment or not next(profile.equipment) then
        profile.equipment = { mainHand = "field_knife", body = "warm_clothing" }
    end
    if not profile.unlockedRecipes then
        profile.unlockedRecipes = {
            torch = true,
            healing_potion = true,
            basic_tool = true,
            field_knife = true,
            wooden_spear = true,
            arrow = true,
            warm_clothing = true,
        }
    else
        profile.unlockedRecipes.torch = true
        profile.unlockedRecipes.healing_potion = true
        profile.unlockedRecipes.basic_tool = true
        profile.unlockedRecipes.field_knife = true
        profile.unlockedRecipes.wooden_spear = true
        profile.unlockedRecipes.arrow = true
        profile.unlockedRecipes.warm_clothing = true
    end
    if not profile.completedQuests then profile.completedQuests = {} end
    if not profile.activeQuests or not next(profile.activeQuests) then
        profile.activeQuests = {
            q_starter_kit = { progress = 1, completed = false },
            q_first_steps = { progress = 0, completed = false },
        }
    end
    if not profile.achievements then profile.achievements = {} end
    if not profile.discoveries then profile.discoveries = { ["Safe Haven"] = true } end
    if not profile.cosmetics then profile.cosmetics = {} end
    if not profile.settings then
        profile.settings = { reducedEffects = false, cameraShake = true }
    end
    profile.lastSaveUnix = os.time()

    return profile
end

function ProfileService.Init(_dependencies: { [string]: any })
    print("[ProfileService] Initializing ProfileService...")

    local success, store = pcall(function()
        return DataStoreService:GetDataStore(DATA_STORE_NAME)
    end)

    if success and store then
        _dataStore = store
        _isMock = false
        print("[ProfileService] Live DataStore connected.")
    else
        _isMock = true
        warn("[ProfileService] DataStoreService unavailable. Operating in safe MockDataStore mode.")
    end
end

function ProfileService.Start()
    print("[ProfileService] ProfileService started.")
end

function ProfileService.LoadProfile(player: Player): Types.PlayerProfile
    local userId = player.UserId
    local key = "Player_" .. tostring(userId)

    if _isMock or not _dataStore then
        local existing = _mockStore[key]
        if existing then
            _activeProfiles[userId] = existing
            return existing
        else
            local newProfile = createDefaultProfile()
            _mockStore[key] = newProfile
            _activeProfiles[userId] = newProfile
            return newProfile
        end
    end

    local success, result = pcall(function()
        return _dataStore:GetAsync(key)
    end)

    if success and result then
        local migrated = migrateProfile(result)
        _activeProfiles[userId] = migrated
        return migrated
    elseif success and result == nil then
        local newProfile = createDefaultProfile()
        _activeProfiles[userId] = newProfile
        return newProfile
    else
        warn(string.format("[ProfileService] Failed to load data for user %d: %s. Using safe temporary fallback.", userId, tostring(result)))
        local fallback = createDefaultProfile()
        _activeProfiles[userId] = fallback
        return fallback
    end
end

function ProfileService.GetProfile(player: Player): Types.PlayerProfile?
    return _activeProfiles[player.UserId]
end

function ProfileService.SaveProfile(player: Player): boolean
    local userId = player.UserId
    local profile = _activeProfiles[userId]
    if not profile then return false end

    profile.lastSaveUnix = os.time()
    local key = "Player_" .. tostring(userId)

    if _isMock or not _dataStore then
        _mockStore[key] = profile
        return true
    end

    local success, err = pcall(function()
        _dataStore:UpdateAsync(key, function(oldData)
            return profile
        end)
    end)

    if not success then
        warn(string.format("[ProfileService] Save failure for user %d: %s", userId, tostring(err)))
        return false
    end
    return true
end

function ProfileService.UnloadProfile(player: Player)
    ProfileService.SaveProfile(player)
    _activeProfiles[player.UserId] = nil
end

return ProfileService
