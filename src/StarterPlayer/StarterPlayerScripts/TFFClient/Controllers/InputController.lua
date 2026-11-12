--!strict
--[[
    InputController.lua
    Client controller for handling user movement inputs (Sprint toggle/hold),
    desktop keys, mobile touch prompts, and gamepad bindings.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

local InputController = {}
InputController.__index = InputController

local _isSprinting = false

function InputController.Init(_dependencies: { [string]: any })
    print("[InputController] Initializing InputController...")
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
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            updateSprint(true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, _gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            updateSprint(false)
        end
    end)
end

return InputController
