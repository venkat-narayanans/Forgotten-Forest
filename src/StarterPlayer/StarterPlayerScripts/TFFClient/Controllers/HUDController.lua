--!strict
--[[
    HUDController.lua
    Client controller for managing HUD updates, status bars, and cycle phase display.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local HUDController = {}
HUDController.__index = HUDController

local _player = Players.LocalPlayer

function HUDController.Init(_dependencies: { [string]: any })
    print("[HUDController] Initializing HUDController...")
end

function HUDController.Start()
    print("[HUDController] HUDController started.")

    local syncStatsRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncStats)
    if syncStatsRemote then
        syncStatsRemote.OnClientEvent:Connect(function(stats: Types.PlayerStats)
            -- Handled by HUD display view updates in later phases
        end)
    end

    local syncCycleRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncTimeCycle)
    if syncCycleRemote then
        syncCycleRemote.OnClientEvent:Connect(function(phase: string, timeRemaining: number, _clockTime: number)
            -- Handled by Cycle UI banner
        end)
    end

    local syncProfileRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncProfileRemote then
        syncProfileRemote.OnClientEvent:Connect(function(profile: Types.PlayerProfile)
            -- Handled by Inventory and Profile UI
        end)
    end
end

return HUDController
