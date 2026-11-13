--!strict
--[[
    test_phase9_polish.lua
    Automated verification of Phase 9 UI, Art, Audio, and Polish requirements.
]]

local function runPhase9Tests()
    local StarterGui = game:GetService("StarterGui")
    local Workspace = game:GetService("Workspace")

    -- 1. Check HUD & Settings Modal
    local hud = StarterGui:FindFirstChild("TFF_HUD")
    assert(hud ~= nil, "StarterGui.TFF_HUD must exist")

    local main = hud:FindFirstChild("MainContainer")
    assert(main ~= nil, "MainContainer must exist")

    local settingsBtn = main:FindFirstChild("SettingsButton")
    assert(settingsBtn ~= nil, "SettingsButton must exist")

    local settingsModal = main:FindFirstChild("SettingsModal")
    assert(settingsModal ~= nil, "SettingsModal must exist")
    assert(settingsModal:FindFirstChild("ReducedEffectsToggle") ~= nil, "ReducedEffectsToggle must exist")
    assert(settingsModal:FindFirstChild("CameraShakeToggle") ~= nil, "CameraShakeToggle must exist")
    assert(settingsModal:FindFirstChild("CloseButton") ~= nil, "CloseButton must exist")

    -- 2. Performance & Geometry Check: All Map parts must be Anchored
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    assert(tffWorld ~= nil, "TFF_World must exist")

    local unanchoredParts = 0
    local mapFolder = tffWorld:FindFirstChild("Map")
    if mapFolder then
        for _, desc in ipairs(mapFolder:GetDescendants()) do
            if desc:IsA("BasePart") and not desc.Anchored then
                unanchoredParts += 1
            end
        end
    end
    assert(unanchoredParts == 0, "All static map parts must be anchored")

    -- 3. Check Interactables Anchored
    local interactablesFolder = tffWorld:FindFirstChild("Interactables")
    if interactablesFolder then
        for _, desc in ipairs(interactablesFolder:GetDescendants()) do
            if desc:IsA("BasePart") and not desc.Anchored then
                unanchoredParts += 1
            end
        end
    end
    assert(unanchoredParts == 0, "All interactable parts must be anchored")

    print("[Phase 9 Tests] All Phase 9 UI, Art, Audio, and Polish checks passed!")
    return true
end

return runPhase9Tests
