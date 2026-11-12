--!strict
--[[
    HUDController.lua
    Client controller for managing HUD updates, status bars, cycle phase,
    region banners, and mobile touch sprint input.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local HUDController = {}
HUDController.__index = HUDController

local _player = Players.LocalPlayer
local _screenGui: ScreenGui? = nil
local _currentRegionName = "Safe Haven"

local function formatTimer(seconds: number): string
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

function HUDController.Init(_dependencies: { [string]: any })
    print("[HUDController] Initializing HUDController...")
end

function HUDController.Start()
    print("[HUDController] HUDController started.")

    local playerGui = _player:WaitForChild("PlayerGui")
    _screenGui = playerGui:WaitForChild("TFF_HUD") :: ScreenGui

    local mainContainer = _screenGui:WaitForChild("MainContainer") :: Frame
    local statusBars = mainContainer:WaitForChild("StatusBars") :: Frame
    local healthBg = statusBars:WaitForChild("HealthBackground") :: Frame
    local healthFill = healthBg:WaitForChild("Fill") :: Frame
    local healthLabel = healthBg:WaitForChild("HealthLabel") :: TextLabel

    local staminaBg = statusBars:WaitForChild("StaminaBackground") :: Frame
    local staminaFill = staminaBg:WaitForChild("Fill") :: Frame

    local cycleIndicator = mainContainer:WaitForChild("CycleIndicator") :: Frame
    local phaseLabel = cycleIndicator:WaitForChild("PhaseLabel") :: TextLabel
    local timerLabel = cycleIndicator:WaitForChild("TimerLabel") :: TextLabel

    local regionBanner = mainContainer:WaitForChild("RegionBanner") :: TextLabel
    local mobileSprint = mainContainer:WaitForChild("MobileSprintButton") :: TextButton

    -- Configure mobile sprint button visibility
    if not UserInputService.TouchEnabled then
        mobileSprint.Visible = false
    else
        mobileSprint.Visible = true
        local isSprinting = false
        local sprintRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestSprint)

        mobileSprint.MouseButton1Down:Connect(function()
            isSprinting = not isSprinting
            mobileSprint.BackgroundTransparency = isSprinting and 0.1 or 0.3
            if sprintRemote then
                sprintRemote:FireServer(isSprinting)
            end
        end)
    end

    -- Hook up Stats sync
    local syncStatsRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncStats)
    if syncStatsRemote then
        syncStatsRemote.OnClientEvent:Connect(function(stats: Types.PlayerStats)
            local healthRatio = math.clamp(stats.Health / stats.MaxHealth, 0, 1)
            healthFill.Size = UDim2.new(healthRatio, 0, 1, 0)
            healthLabel.Text = string.format("HEALTH: %d/%d", math.ceil(stats.Health), math.ceil(stats.MaxHealth))

            local staminaRatio = math.clamp(stats.Stamina / stats.MaxStamina, 0, 1)
            staminaFill.Size = UDim2.new(staminaRatio, 0, 1, 0)
        end)
    end

    -- Hook up Cycle sync
    local syncCycleRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncTimeCycle)
    if syncCycleRemote then
        syncCycleRemote.OnClientEvent:Connect(function(phase: string, timeRemaining: number, _clockTime: number)
            phaseLabel.Text = string.upper(phase)
            timerLabel.Text = string.format("Time Remaining: %s", formatTimer(timeRemaining))
        end)
    end

    -- Hook up Downed state banner
    local downedRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.DownedStateChanged)
    if downedRemote then
        downedRemote.OnClientEvent:Connect(function(userId: number, isDowned: boolean, duration: number)
            if userId == _player.UserId then
                if isDowned then
                    regionBanner.Text = "YOU ARE DOWNED! HOLD OUT FOR REVIVAL..."
                    regionBanner.TextColor3 = Color3.fromRGB(255, 80, 80)
                else
                    regionBanner.Text = _currentRegionName
                    regionBanner.TextColor3 = Color3.fromRGB(235, 225, 205)
                end
            end
        end)
    end

    -- Region detection loop (checks player position against regions)
    task.spawn(function()
        while true do
            task.wait(1)
            local char = _player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
            if root then
                local pos = root.Position
                local detected = "Safe Haven"
                if pos.Z < -80 then
                    detected = "Whispering Woods"
                end

                if detected ~= _currentRegionName then
                    _currentRegionName = detected
                    regionBanner.Text = string.upper(detected)
                    regionBanner.TextTransparency = 0
                    local tween = TweenService:Create(regionBanner, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        TextTransparency = 0.2
                    })
                    tween:Play()
                end
            end
        end
    end)
end

return HUDController
