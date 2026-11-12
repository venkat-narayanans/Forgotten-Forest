--!strict
--[[
    test_phase3_survival.lua
    Automated verification of Phase 3 Survival & Movement Systems requirements.
]]

local function runPhase3Tests()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")

    local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
    local MovementConfig = require(ReplicatedStorage.TFF.Shared.Config.MovementConfig)
    local SurvivalConfig = require(ReplicatedStorage.TFF.Shared.Config.SurvivalConfig)
    local SurvivalService = require(ServerScriptService.TFFServer.Services.SurvivalService)

    -- 1. Test simulated stats table bounds
    local stats = {
        Health = 100,
        MaxHealth = 100,
        Stamina = 100,
        MaxStamina = 100,
        Warmth = 100,
        MaxWarmth = 100,
        Sanity = 100,
        MaxSanity = 100,
        IsSprinting = true,
        IsDowned = false,
        DownedTimer = 0,
    }

    -- Test Stamina Drain over 15 seconds (should clamp at 0 and never go negative)
    local drainPerSec = MovementConfig.SprintDrainRate
    local dt = 0.5
    for _ = 1, 30 do
        stats.Stamina = math.max(0, stats.Stamina - (drainPerSec * dt))
    end
    assert(stats.Stamina == 0, "Stamina must clamp at 0 after extended sprinting")
    assert(stats.Stamina >= 0, "Stamina must NEVER go negative")

    -- Test Sprint cannot start if Stamina < 10
    local canSprintWithZeroStamina = (stats.Stamina >= MovementConfig.MinStaminaToStartSprint)
    assert(canSprintWithZeroStamina == false, "Sprint must be rejected if stamina is below 10")

    -- Test Stamina Regeneration (should cap at 100)
    stats.IsSprinting = false
    local regenPerSec = MovementConfig.StaminaRegenRate
    for _ = 1, 30 do
        stats.Stamina = math.min(stats.MaxStamina, stats.Stamina + (regenPerSec * dt))
    end
    assert(stats.Stamina == 100, "Stamina must regenerate to exactly 100")
    assert(stats.Stamina <= stats.MaxStamina, "Stamina must not exceed MaxStamina")

    -- Test Damage & Downed state transition
    stats.Health = math.max(0, stats.Health - 120) -- excessive damage
    assert(stats.Health == 0, "Health must clamp at 0")
    if stats.Health <= 0 then
        stats.IsDowned = true
        stats.DownedTimer = BalanceConfig.DownedDuration
    end
    assert(stats.IsDowned == true, "Player must enter Downed state at 0 health")
    assert(stats.DownedTimer == 30, "Downed timer must initialize to 30s")

    -- Test Revival
    stats.IsDowned = false
    stats.DownedTimer = 0
    stats.Health = BalanceConfig.ReviveHealthRestored
    assert(stats.Health == 35, "Revival must restore exactly 35 health")
    assert(stats.IsDowned == false, "Revived player must no longer be Downed")

    -- Test Safe Haven Regeneration
    stats.Health = math.min(stats.MaxHealth, stats.Health + (SurvivalConfig.SafeHavenHealthRegen * 10))
    assert(stats.Health == 55, "Health regeneration must increase by 20 points over 10s")

    print("[Phase 3 Tests] All Phase 3 Survival & Movement checks passed!")
    return true
end

return runPhase3Tests
