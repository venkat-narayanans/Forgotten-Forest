--!strict
--[[
    MovementConfig.lua
    Movement speeds, stamina rates, and key controls.
]]

local MovementConfig = {
    WalkSpeed = 16,
    SprintSpeed = 22,
    JumpPower = 50,

    -- Stamina consumption & recovery
    MaxStamina = 100,
    SprintDrainRate = 12,     -- stamina points per second
    StaminaRegenRate = 18,    -- stamina points per second
    RegenDelayAfterSprint = 1.0, -- seconds of idle before regen kicks in
    MinStaminaToStartSprint = 10,

    -- Downed movement
    DownedWalkSpeed = 0, -- Stationary downed state as per spec recommendation
}

return MovementConfig
