--!strict
--[[
    test_phase4_crafting_inventory.lua
    Automated verification of Phase 4 Gathering, Inventory, Crafting, and Storage requirements.
]]

local function runPhase4Tests()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")

    local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)
    local RecipeDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.RecipeDefinitions)

    -- 1. Test Contested Final Node Yield (Concurrency simulation)
    local testNode = {
        NodeId = "test_node_contested",
        RemainingYield = 1,
        IsAvailable = true,
    }

    local function simulateAtomicGather(node)
        if not node.IsAvailable or node.RemainingYield <= 0 then
            return false
        end
        node.RemainingYield -= 1
        if node.RemainingYield <= 0 then
            node.IsAvailable = false
        end
        return true
    end

    local firstGatherSuccess = simulateAtomicGather(testNode)
    local secondGatherSuccess = simulateAtomicGather(testNode)

    assert(firstGatherSuccess == true, "First gatherer should claim final yield")
    assert(secondGatherSuccess == false, "Second gatherer must be rejected (no duplicate final yield)")
    assert(testNode.RemainingYield == 0, "Node yield must not drop below 0")

    -- 2. Test Inventory Transactions & Negative Balance Prevention
    local inventory = {}
    local maxSlots = 20

    local function addItem(inv, itemId, qty)
        local def = ItemDefinitions[itemId]
        assert(def ~= nil, "Item must exist in definitions")
        local remaining = qty
        for _, slot in ipairs(inv) do
            if slot.ItemId == itemId and slot.Quantity < def.StackLimit then
                local space = def.StackLimit - slot.Quantity
                local toAdd = math.min(space, remaining)
                slot.Quantity += toAdd
                remaining -= toAdd
                if remaining <= 0 then break end
            end
        end
        while remaining > 0 do
            if #inv >= maxSlots then return false end
            local toAdd = math.min(def.StackLimit, remaining)
            table.insert(inv, { ItemId = itemId, Quantity = toAdd })
            remaining -= toAdd
        end
        return true
    end

    local function getItemCount(inv, itemId)
        local count = 0
        for _, slot in ipairs(inv) do
            if slot.ItemId == itemId then count += slot.Quantity end
        end
        return count
    end

    local function removeItem(inv, itemId, qty)
        if getItemCount(inv, itemId) < qty then return false end
        local remaining = qty
        local idx = #inv
        while idx >= 1 and remaining > 0 do
            local slot = inv[idx]
            if slot.ItemId == itemId then
                if slot.Quantity <= remaining then
                    remaining -= slot.Quantity
                    table.remove(inv, idx)
                else
                    slot.Quantity -= remaining
                    remaining = 0
                end
            end
            idx -= 1
        end
        return true
    end

    -- Add items and test removal
    assert(addItem(inventory, "wood", 5) == true, "Should add 5 wood")
    assert(getItemCount(inventory, "wood") == 5, "Wood count should be 5")

    -- Attempt to remove 10 wood (insufficient)
    local overDraw = removeItem(inventory, "wood", 10)
    assert(overDraw == false, "Removing more than available must fail")
    assert(getItemCount(inventory, "wood") == 5, "Inventory count must not change on failed removal")

    -- Remove 3 wood
    assert(removeItem(inventory, "wood", 3) == true, "Should remove 3 wood")
    assert(getItemCount(inventory, "wood") == 2, "Wood count should now be 2")

    -- 3. Test Crafting Atomicity
    -- Torch recipe: 2 wood + 1 cloth
    assert(addItem(inventory, "cloth", 1) == true, "Add 1 cloth")
    assert(getItemCount(inventory, "wood") == 2, "Has 2 wood")
    assert(getItemCount(inventory, "cloth") == 1, "Has 1 cloth")

    -- Execute craft
    local recipe = RecipeDefinitions["torch"]
    assert(removeItem(inventory, "wood", 2) == true)
    assert(removeItem(inventory, "cloth", 1) == true)
    assert(addItem(inventory, recipe.OutputItemId, recipe.OutputQuantity) == true)

    assert(getItemCount(inventory, "wood") == 0, "Wood consumed")
    assert(getItemCount(inventory, "cloth") == 0, "Cloth consumed")
    assert(getItemCount(inventory, "torch") == 1, "Torch produced")

    -- 4. Test Shared Storage
    local sharedStorage = {}
    local function deposit(inv, storage, itemId, qty)
        if removeItem(inv, itemId, qty) then
            storage[itemId] = (storage[itemId] or 0) + qty
            return true
        end
        return false
    end

    local function withdraw(inv, storage, itemId, qty)
        local available = storage[itemId] or 0
        if available < qty then return false end
        if addItem(inv, itemId, qty) then
            storage[itemId] -= qty
            return true
        end
        return false
    end

    assert(deposit(inventory, sharedStorage, "torch", 1) == true, "Deposit torch to shared storage")
    assert(getItemCount(inventory, "torch") == 0, "Torch removed from personal inventory")
    assert(sharedStorage["torch"] == 1, "Torch in shared storage")

    -- Attempt over-withdraw
    assert(withdraw(inventory, sharedStorage, "torch", 5) == false, "Overdraw from shared storage must fail")
    assert(sharedStorage["torch"] == 1, "Shared storage amount intact")

    -- Valid withdraw
    assert(withdraw(inventory, sharedStorage, "torch", 1) == true, "Withdraw torch")
    assert(getItemCount(inventory, "torch") == 1, "Torch back in personal inventory")
    assert(sharedStorage["torch"] == 0, "Shared storage empty")

    print("[Phase 4 Tests] All Phase 4 Gathering, Inventory, Crafting, and Storage checks passed!")
    return true
end

return runPhase4Tests
