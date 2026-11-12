--!strict
--[[
    InputController.lua
    Client controller for handling user movement inputs (Sprint toggle/hold),
    desktop keys (1-5 hotbar slots, E interact, F use item), and mobile controls.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local InputController = {}
InputController.__index = InputController

local _isSprinting = false
local _hudController: any = nil
local _player = Players.LocalPlayer

function InputController.Init(dependencies: { [string]: any })
    print("[InputController] Initializing InputController...")
    _hudController = dependencies.HUDController
end

local function getNearestInteractable(maxDist: number): (BasePart?, string?)
    local char = _player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return nil, nil end

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    if not interactables then return nil, nil end

    local nearest: BasePart? = nil
    local minDist = maxDist
    local modalType: string? = nil

    for _, obj in ipairs(interactables:GetChildren()) do
        if obj:IsA("BasePart") then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = obj
                if obj.Name == "Workbench" then
                    modalType = "Crafting"
                elseif obj.Name == "SharedStorageChest" then
                    modalType = "Storage"
                elseif obj.Name == "QuestBoard" then
                    modalType = "Quest"
                elseif obj.Name:find("StoryClue") then
                    modalType = "Lore"
                end
            end
        end
    end
    return nearest, modalType
end

function InputController.Start()
    print("[InputController] InputController started.")

    local sprintRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestSprint)

    local function updateSprint(wantsSprint: boolean)
        if _isSprinting ~= wantsSprint then
            _isSprinting = wantsSprint
            if sprintRemote then
                sprintRemote:FireServer(wantsSprint)
            end
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- Sprint
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            updateSprint(true)

        -- Hotbar selection (Keys 1-5)
        elseif input.KeyCode == Enum.KeyCode.One then
            if _hudController then _hudController.SelectHotbarSlot(1) end
        elseif input.KeyCode == Enum.KeyCode.Two then
            if _hudController then _hudController.SelectHotbarSlot(2) end
        elseif input.KeyCode == Enum.KeyCode.Three then
            if _hudController then _hudController.SelectHotbarSlot(3) end
        elseif input.KeyCode == Enum.KeyCode.Four then
            if _hudController then _hudController.SelectHotbarSlot(4) end
        elseif input.KeyCode == Enum.KeyCode.Five then
            if _hudController then _hudController.SelectHotbarSlot(5) end

        -- Use Active Consumable Item
        elseif input.KeyCode == Enum.KeyCode.F then
            if _hudController then _hudController.UseActiveItem() end

        -- Interact (Workbench, Chest, Quest Board, Lore Clue)
        elseif input.KeyCode == Enum.KeyCode.E then
            local obj, modalType = getNearestInteractable(BalanceConfig.DefaultInteractionRange + 2)
            if obj and modalType and _hudController then
                _hudController.OpenModal(modalType)
            end

        -- Close Modals
        elseif input.KeyCode == Enum.KeyCode.Escape then
            if _hudController then _hudController.CloseAllModals() end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, _gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            updateSprint(false)
        end
    end)
end

return InputController
