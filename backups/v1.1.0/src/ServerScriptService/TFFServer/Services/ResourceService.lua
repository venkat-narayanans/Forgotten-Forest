--!strict
--[[
    ResourceService.lua
    Server-authoritative resource gathering and node lifecycle management.
    Prevents duplicate node harvest exploits, verifies distance, and manages respawn timers.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")

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
    Part: BasePart?,
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

    -- Connect remote request for headless/scripted gather calls
    local gatherRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestGather)
    if gatherRemote then
        gatherRemote.OnServerEvent:Connect(function(player: Player, nodeId: string)
            ResourceService.TryGather(player, nodeId)
        end)
    end
end

function ResourceService.Start()
    print("[ResourceService] ResourceService started.")

    -- Register existing world resource nodes
    local worldRoot = game.Workspace:FindFirstChild("TFF_World")
    local nodesFolder = worldRoot and worldRoot:FindFirstChild("ResourceNodes")
    if nodesFolder then
        for _, part in ipairs(nodesFolder:GetChildren()) do
            if part:IsA("BasePart") and CollectionService:HasTag(part, "TFF_ResourceNode") then
                local nodeId = part:GetAttribute("NodeId") or part.Name
                local itemId = part:GetAttribute("ItemId") or "wood"
                local initialYield = part:GetAttribute("InitialYield") or 3
                ResourceService.RegisterNode(nodeId, itemId, initialYield, part.Position, 180, part)
            end
        end
    end

    -- Server-side proximity prompt handling
    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
        local parentPart = prompt.Parent :: BasePart?
        if parentPart and CollectionService:HasTag(parentPart, "TFF_ResourceNode") then
            local nodeId = parentPart:GetAttribute("NodeId") or parentPart.Name
            ResourceService.TryGather(player, nodeId)
        end
    end)
end

function ResourceService.RegisterNode(nodeId: string, itemId: string, initialYield: number, position: Vector3, respawnDuration: number, part: BasePart?)
    _registeredNodes[nodeId] = {
        NodeId = nodeId,
        ItemId = itemId,
        Part = part,
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

    local dist = (root.Position - node.Position).Magnitude
    if dist > BalanceConfig.DefaultInteractionRange + 2 then
        return false
    end

    -- Atomic reservation
    node.RemainingYield -= 1
    local isDepleted = (node.RemainingYield <= 0)
    if isDepleted then
        node.IsAvailable = false
        if node.Part then
            node.Part.Transparency = 0.8
            local prompt = node.Part:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then prompt.Enabled = false end
        end

        task.delay(node.RespawnDuration, function()
            node.RemainingYield = 3
            node.IsAvailable = true
            if node.Part then
                node.Part.Transparency = 0
                local prompt = node.Part:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then prompt.Enabled = true end
            end
        end)
    end

    -- Grant resource through InventoryService
    local added = _inventoryService.TryAddItem(player, node.ItemId, 1)
    if added then
        _progressionService.GrantXP(player, 5, "Gathering " .. node.ItemId)
        return true
    else
        -- If inventory is full, return node yield
        if isDepleted then
            node.RemainingYield = 1
            node.IsAvailable = true
            if node.Part then
                node.Part.Transparency = 0
                local prompt = node.Part:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then prompt.Enabled = true end
            end
        else
            node.RemainingYield += 1
        end
        return false
    end
end

function ResourceService.GetNodeState(nodeId: string): ActiveNode?
    return _registeredNodes[nodeId]
end

return ResourceService
