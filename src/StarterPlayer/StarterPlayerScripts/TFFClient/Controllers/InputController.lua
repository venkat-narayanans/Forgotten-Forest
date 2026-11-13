--!strict
--[[
    InputController.lua
    Client controller for handling user movement inputs (Sprint toggle/hold),
    desktop hotkeys (1-5 hotbar slots, E interact, F use item, C crafting, Q quests, M map, B storage),
    ProximityPrompt integration, and mobile controls.
]]

local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
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

    -- Hook up ProximityPrompt interactions on client for instant UI response
    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, playerWhoTriggered: Player)
        if playerWhoTriggered ~= _player then return end
        local parentInstance = prompt.Parent
        if not parentInstance then return end

        local model = parentInstance:FindFirstAncestorOfClass("Model")
        local name = parentInstance.Name
        if model and (model.Name == "ExpeditionStarterChest" or model.Name == "NPC_medic" or model.Name == "NPC_cartographer" or model.Name == "NPC_old_keeper") then
            name = model.Name
        end

        if name == "QuestBoard" then
            if _hudController then _hudController.OpenModal("Quest") end
        elseif name == "Workbench" then
            if _hudController then _hudController.OpenModal("Crafting") end
        elseif name == "SharedStorageChest" then
            if _hudController then _hudController.OpenModal("Storage") end
        elseif name == "ExpeditionStarterChest" then
            if _hudController then
                _hudController.RefreshCraftingModal()
                _hudController.UpdateObjectiveTracker("q_starter_kit")
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        -- Ignore hotkeys only if player is actively typing in a TextBox
        if gameProcessed and UserInputService:GetFocusedTextBox() then return end

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

        -- Direct Hotkey for Crafting Modal (Key 'C')
        elseif input.KeyCode == Enum.KeyCode.C then
            if _hudController then _hudController.ToggleModal("Crafting") end

        -- Direct Hotkey for Quest Log / Notice Board (Key 'Q' or 'J')
        elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.J then
            if _hudController then _hudController.ToggleModal("Quest") end

        -- Direct Hotkey for Storage (Key 'B' for Backpack/Storage)
        elseif input.KeyCode == Enum.KeyCode.B then
            if _hudController then _hudController.ToggleModal("Storage") end

        -- Interactive Map Screen (Key 'M' or Gamepad Select)
        elseif input.KeyCode == Enum.KeyCode.M or input.KeyCode == Enum.KeyCode.ButtonSelect then
            if _hudController then _hudController.ToggleModal("Map") end

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

        -- Weapon Attack / Tool Action (LMB click)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if gameProcessed then return end
            local mousePos = UserInputService:GetMouseLocation()
            local camera = Workspace.CurrentCamera
            if camera then
                local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                local raycastParams = RaycastParams.new()
                if _player.Character then
                    raycastParams.FilterDescendantsInstances = { _player.Character }
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                end
                local result = Workspace:Raycast(ray.Origin, ray.Direction * 150, raycastParams)
                local targetInstance = result and result.Instance
                local hitPos = result and result.Position
                local attackRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestAttack)
                if attackRemote then
                    attackRemote:FireServer(targetInstance, hitPos, ray.Direction)
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, _gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            updateSprint(false)
        end
    end)
end

return InputController
