--!strict
--[[
    ResourceService.lua
    Server-authoritative resource gathering and node lifecycle management.
    Prevents duplicate node harvest exploits and validates interaction distances.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)

local ResourceService = {}
ResourceService.__index = ResourceService

local _inventoryService: any = nil
local _progressionService: any = nil
local _survivalService: any = nil
local _worldService: any = nil

type ActiveNode = {
    NodeId: string,
    ItemId: string,
    RemainingYield: number,
    GatherDuration: number,
    RespawnDuration: number,
    Position: Vector3,
    IsAvailable: boolean,
}

local _registeredNodes: { [string]: ActiveNode } = {}

function ResourceService.Init(dependencies: { [string]: any })
    print("[ResourceService] Initializing ResourceService...")
    _inventoryService = dependencies.InventoryService
    _progressionService = dependencies.ProgressionService
    _survivalService = dependencies.SurvivalService
    _worldService = dependencies.WorldService

    local gatherRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestGather)
    if gatherRemote then
        gatherRemote.OnServerEvent:Connect(function(player: Player, nodeId: string)
            ResourceService.TryGather(player, nodeId)
        end)
    end
end

function ResourceService.Start()
    print("[ResourceService] ResourceService started.")
end

function ResourceService.RegisterNode(nodeId: string, itemId: string, initialYield: number, position: Vector3, respawnDuration: number)
    _registeredNodes[nodeId] = {
        NodeId = nodeId,
        ItemId = itemId,
        RemainingYield = initialYield,
        GatherDuration = 1.5,
        RespawnDuration = respawnDuration or 180,
        Position = position,
        IsAvailable = true,
    }
end

function ResourceService.TryGather(player: Player, nodeId: string): boolean
    local node = _registeredNodes[nodeId]
    if not node or not node.IsAvailable or node.RemainingYield <= 0 then
        return false
    end

    local stats = _survivalService.GetStats(player)
    if not stats or stats.IsDowned then return false end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return false end

    -- Validate distance
    local dist = (root.Position - node.Position).Magnitude
    if dist > BalanceConfig.DefaultInteractionRange + 2 then
        return false
    end

    -- Atomic reserve
    node.RemainingYield -= 1
    if node.RemainingYield <= 0 then
        node.IsAvailable = false
        -- Schedule respawn
        task.delay(node.RespawnDuration, function()
            node.RemainingYield = 3
            node.IsAvailable = true
        end)
    end

    -- Grant resource
    local added = _inventoryService.TryAddItem(player, node.ItemId, 1)
    if added then
        _progressionService.GrantXP(player, 5, "Gathering " .. node.ItemId)
        return true
    end
    return false
end

return ResourceService
