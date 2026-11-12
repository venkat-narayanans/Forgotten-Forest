--!strict
--[[
    Bootstrap.client.lua
    Client master entry point for The Forgotten Forest.
    Initializes client controllers in deterministic order.
]]

print("==================================================")
print("  THE FORGOTTEN FOREST — CLIENT INITIALIZATION   ")
print("==================================================")

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local ControllersFolder = script.Parent:WaitForChild("Controllers")

local InputController = require(ControllersFolder:WaitForChild("InputController"))
local HUDController = require(ControllersFolder:WaitForChild("HUDController"))

local controllers = {
    InputController = InputController,
    HUDController = HUDController,
}

local orderedKeys = {
    "InputController",
    "HUDController",
}

for _, key in ipairs(orderedKeys) do
    local ctrl = controllers[key]
    if ctrl and typeof(ctrl.Init) == "function" then
        ctrl.Init(controllers)
    end
end

for _, key in ipairs(orderedKeys) do
    local ctrl = controllers[key]
    if ctrl and typeof(ctrl.Start) == "function" then
        ctrl.Start()
    end
end

print("==================================================")
print("  THE FORGOTTEN FOREST — CLIENT BOOTSTRAP READY   ")
print("==================================================")
