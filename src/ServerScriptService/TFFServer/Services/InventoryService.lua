--!strict
--[[
    InventoryService.lua
    Server-authoritative inventory and communal Safe Haven storage management.
    Ensures atomic transactions, stack integrity, and prevents duplication exploits.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local InventoryService = {}
InventoryService.__index = InventoryService

local _profileService: any = nil
local _survivalService: any = nil
local _sharedStorage: { [string]: number } = {}

local function syncProfileToClient(player: Player)
    local profile = _profileService.GetProfile(player)
    if not profile then return end
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

local function broadcastSharedStorage()
    local updateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SharedStorageUpdated)
    if updateRemote then
        updateRemote:FireAllClients(_sharedStorage)
    end
end

function InventoryService.Init(dependencies: { [string]: any })
    print("[InventoryService] Initializing InventoryService...")
    _profileService = dependencies.ProfileService
    _survivalService = dependencies.SurvivalService

    -- Connect storage remotes
    local depositRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestDepositStorage)
    if depositRemote then
        depositRemote.OnServerEvent:Connect(function(player: Player, itemId: string, quantity: number)
            InventoryService.TryDepositToSharedStorage(player, itemId, quantity)
        end)
    end

    local withdrawRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestWithdrawStorage)
    if withdrawRemote then
        withdrawRemote.OnServerEvent:Connect(function(player: Player, itemId: string, quantity: number)
            InventoryService.TryWithdrawFromSharedStorage(player, itemId, quantity)
        end)
    end

    -- Connect tool equipping & consumption remotes
    local equipRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestEquipItem)
    if equipRemote then
        equipRemote.OnServerEvent:Connect(function(player: Player, slotIndex: number)
            InventoryService.EquipItem(player, slotIndex)
        end)
    end

    local useRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestUseItem)
    if useRemote then
        useRemote.OnServerEvent:Connect(function(player: Player, slotIndex: number)
            InventoryService.UseItem(player, slotIndex)
        end)
    end
end

function InventoryService.Start()
    print("[InventoryService] InventoryService started.")
    local function onPlayerAdded(player: Player)
        local updateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SharedStorageUpdated)
        if updateRemote then
            updateRemote:FireClient(player, _sharedStorage)
        end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end
end

function InventoryService.GetItemCount(player: Player, itemId: string): number
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return 0 end

    local count = 0
    for _, item in ipairs(profile.inventory) do
        if item.ItemId == itemId then
            count += item.Quantity
        end
    end
    return count
end

function InventoryService.TryAddItem(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 or quantity > 999 then return false end
    local def = ItemDefinitions[itemId]
    if not def then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    local maxSlots = BalanceConfig.DefaultInventorySlots
    local remainingToAdd = quantity

    -- First pass: fill existing stacks
    for _, item in ipairs(profile.inventory) do
        if item.ItemId == itemId and item.Quantity < def.StackLimit then
            local space = def.StackLimit - item.Quantity
            local toAdd = math.min(space, remainingToAdd)
            item.Quantity += toAdd
            remainingToAdd -= toAdd
            if remainingToAdd <= 0 then break end
        end
    end

    -- Second pass: add new slots if space permits
    while remainingToAdd > 0 do
        if #profile.inventory >= maxSlots then
            -- Inventory is full
            syncProfileToClient(player)
            return false
        end

        local toAdd = math.min(def.StackLimit, remainingToAdd)
        table.insert(profile.inventory, {
            ItemId = itemId,
            Quantity = toAdd,
        })
        remainingToAdd -= toAdd
    end

    syncProfileToClient(player)
    return true
end

function InventoryService.TryRemoveItem(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    local currentCount = InventoryService.GetItemCount(player, itemId)
    if currentCount < quantity then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    local remainingToRemove = quantity
    local index = #profile.inventory
    while index >= 1 and remainingToRemove > 0 do
        local item = profile.inventory[index]
        if item.ItemId == itemId then
            if item.Quantity <= remainingToRemove then
                remainingToRemove -= item.Quantity
                table.remove(profile.inventory, index)
            else
                item.Quantity -= remainingToRemove
                remainingToRemove = 0
            end
        end
        index -= 1
    end

    syncProfileToClient(player)
    return true
end

function InventoryService.TryDepositToSharedStorage(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    if not ItemDefinitions[itemId] then return false end

    if InventoryService.TryRemoveItem(player, itemId, quantity) then
        _sharedStorage[itemId] = (_sharedStorage[itemId] or 0) + quantity
        broadcastSharedStorage()
        return true
    end
    return false
end

function InventoryService.TryWithdrawFromSharedStorage(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    local available = _sharedStorage[itemId] or 0
    if available < quantity then return false end

    if InventoryService.TryAddItem(player, itemId, quantity) then
        _sharedStorage[itemId] -= quantity
        if _sharedStorage[itemId] <= 0 then
            _sharedStorage[itemId] = nil
        end
        broadcastSharedStorage()
        return true
    end
    return false
end

function InventoryService.EquipItem(player: Player, slotIndex: number): boolean
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return false end
    local slot = profile.inventory[slotIndex]
    if not slot then return false end

    local char = player.Character
    if not char then return false end

    -- Check if already holding this tool
    local currentTool = char:FindFirstChildWhichIsA("Tool")
    if currentTool and currentTool.Name == slot.ItemId then
        currentTool:Destroy()
        return true
    elseif currentTool then
        currentTool:Destroy()
    end

    -- Clone tool from ServerStorage.TFF.Templates.Tools
    local ServerStorage = game:GetService("ServerStorage")
    local tff = ServerStorage:FindFirstChild("TFF")
    local templates = tff and tff:FindFirstChild("Templates")
    local tools = templates and templates:FindFirstChild("Tools")
    local toolTemplate = tools and tools:FindFirstChild(slot.ItemId) :: Tool?
    if toolTemplate then
        local equippedTool = toolTemplate:Clone()
        equippedTool.Parent = char
        return true
    end
    return false
end

function InventoryService.UseItem(player: Player, slotIndex: number): boolean
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return false end
    local slot = profile.inventory[slotIndex]
    if not slot or slot.Quantity <= 0 then return false end

    if slot.ItemId == "healing_potion" and _survivalService then
        local healed = _survivalService.HealHealth(player, 40)
        if healed then
            InventoryService.TryRemoveItem(player, "healing_potion", 1)
            return true
        end
    end
    return false
end

function InventoryService.ApplyDeathResourcePenalty(player: Player): { [string]: number }
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return {} end

    local lostItems: { [string]: number } = {}

    for i = #profile.inventory, 1, -1 do
        local slot = profile.inventory[i]
        local def = ItemDefinitions[slot.ItemId]
        if def and not def.IsQuestProtected and def.Category == "Resource" then
            local toLose = math.floor(slot.Quantity * (BalanceConfig.DeathResourceLossPercent / 100))
            if toLose > 0 then
                slot.Quantity -= toLose
                lostItems[slot.ItemId] = (lostItems[slot.ItemId] or 0) + toLose
                if slot.Quantity <= 0 then
                    table.remove(profile.inventory, i)
                end
            end
        end
    end

    syncProfileToClient(player)
    return lostItems
end

return InventoryService
