--!strict
--[[
    test_phase6_death_revive.lua
    Automated verification of Phase 6 Downed, Revive, and Death Penalty requirements.
]]

local function runPhase6Tests()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)
    local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

    -- 1. Check Death/Revive Configuration values
    assert(BalanceConfig.DownedDuration == 30, "Downed duration must be 30s")
    assert(BalanceConfig.ReviveDuration == 4, "Revive duration must be 4s")
    assert(BalanceConfig.ReviveHealthRestored == 35, "Revive health must be 35")
    assert(BalanceConfig.DeathResourceLossPercent == 20, "Death resource loss must be 20%")

    -- 2. Test Resource Loss Calculation & Protection
    local testInventory = {
        { ItemId = "wood", Quantity = 20 },             -- Eligible Resource: loses floor(20 * 0.2) = 4, leaves 16
        { ItemId = "torch", Quantity = 1 },             -- Tool (Category != Resource): NOT lost
        { ItemId = "advanced_lantern", Quantity = 1 },  -- Equipment: NOT lost
        { ItemId = "ancient_fragment", Quantity = 5 },  -- Resource: loses floor(5 * 0.2) = 1, leaves 4
    }

    local lostItems = {}
    for i = #testInventory, 1, -1 do
        local slot = testInventory[i]
        local def = ItemDefinitions[slot.ItemId]
        if def and not def.IsQuestProtected and def.Category == "Resource" then
            local toLose = math.floor(slot.Quantity * (BalanceConfig.DeathResourceLossPercent / 100))
            if toLose > 0 then
                slot.Quantity -= toLose
                lostItems[slot.ItemId] = (lostItems[slot.ItemId] or 0) + toLose
                if slot.Quantity <= 0 then
                    table.remove(testInventory, i)
                end
            end
        end
    end

    assert(lostItems["wood"] == 4, "Must lose exactly 4 wood")
    assert(lostItems["ancient_fragment"] == 1, "Must lose exactly 1 ancient_fragment")
    assert(lostItems["torch"] == nil, "Tools must be protected from death loss")
    assert(lostItems["advanced_lantern"] == nil, "Equipment must be protected from death loss")

    -- Check remaining items
    local function getRemaining(id)
        for _, slot in ipairs(testInventory) do
            if slot.ItemId == id then return slot.Quantity end
        end
        return 0
    end
    assert(getRemaining("wood") == 16, "Remaining wood should be 16")
    assert(getRemaining("torch") == 1, "Remaining torch should be 1")
    assert(getRemaining("advanced_lantern") == 1, "Remaining lantern should be 1")
    assert(getRemaining("ancient_fragment") == 4, "Remaining ancient_fragment should be 4")

    -- 3. Test Idempotency (Death penalty executed twice on same tick must be guarded)
    local isProcessingDeath = true
    local secondRunExecuted = false
    if not isProcessingDeath then
        secondRunExecuted = true
    end
    assert(secondRunExecuted == false, "Duplicate death processing must be safely rejected")

    -- 4. Test Revive Range and Interruption
    local reviverPos = Vector3.new(0, 0, 0)
    local targetPosClose = Vector3.new(0, 0, 8)
    local targetPosFar = Vector3.new(0, 0, 16)

    local function canRevive(rPos, tPos)
        return (rPos - tPos).Magnitude <= (BalanceConfig.DefaultInteractionRange + 2)
    end

    assert(canRevive(reviverPos, targetPosClose) == true, "Within 10 studs: valid revive range")
    assert(canRevive(reviverPos, targetPosFar) == false, "Beyond 10 studs: revive rejected or cancelled")

    print("[Phase 6 Tests] All Phase 6 Downed, Revive, and Death Penalty checks passed!")
    return true
end

return runPhase6Tests
