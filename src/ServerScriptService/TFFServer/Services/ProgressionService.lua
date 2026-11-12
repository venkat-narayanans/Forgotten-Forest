--!strict
--[[
    ProgressionService.lua
    Manages XP gain, level thresholds, and currency balances.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

local ProgressionService = {}
ProgressionService.__index = ProgressionService

local _profileService: any = nil

local function getXPForNextLevel(currentLevel: number): number
    return math.floor(100 * (currentLevel ^ 1.5))
end

function ProgressionService.Init(dependencies: { [string]: any })
    print("[ProgressionService] Initializing ProgressionService...")
    _profileService = dependencies.ProfileService
end

function ProgressionService.Start()
    print("[ProgressionService] ProgressionService started.")
end

function ProgressionService.GrantXP(player: Player, amount: number, reason: string)
    if amount <= 0 then return end
    local profile = _profileService.GetProfile(player)
    if not profile then return end

    profile.xp += amount
    print(string.format("[ProgressionService] Granted %d XP to %s for: %s", amount, player.Name, reason))

    -- Check for level ups
    local needed = getXPForNextLevel(profile.level)
    while profile.xp >= needed do
        profile.xp -= needed
        profile.level += 1
        print(string.format("[ProgressionService] %s leveled up to Level %d!", player.Name, profile.level))
        needed = getXPForNextLevel(profile.level)
    end

    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

function ProgressionService.GrantCurrency(player: Player, currencyType: "ForestCoins" | "AncientTokens", amount: number)
    if amount <= 0 then return end
    local profile = _profileService.GetProfile(player)
    if not profile then return end

    if currencyType == "ForestCoins" then
        profile.forestCoins += amount
    elseif currencyType == "AncientTokens" then
        profile.ancientTokens += amount
    end

    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

return ProgressionService
