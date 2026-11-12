--!strict
--[[
    CreatureDefinitions.lua
    Data-driven definitions for Watcher, Stalker, Mimic, and Forest Guardian.
]]

local Types = require(script.Parent.Parent.Types.Types)

local CreatureDefinitions: { [string]: Types.CreatureDefinition } = {
    watcher = {
        Id = "watcher",
        DisplayName = "The Watcher",
        MaxHealth = 1,
        ChaseSpeed = 0,
        PatrolSpeed = 0,
        DetectionRadius = 60,
        AttackRange = 0,
        AttackDamage = 0,
        AttackCooldown = 999,
        WindupDuration = 0,
        LeashRange = 0,
        States = { "Dormant", "Idle", "Despawn" },
    },
    stalker = {
        Id = "stalker",
        DisplayName = "The Stalker",
        MaxHealth = 100,
        ChaseSpeed = 14,
        PatrolSpeed = 8,
        DetectionRadius = 45,
        AttackRange = 4,
        AttackDamage = 12,
        AttackCooldown = 2.2,
        WindupDuration = 0.6,
        LeashRange = 90,
        States = { "Idle", "Patrol", "Investigate", "Chase", "Windup", "Attack", "Recover", "Return" },
    },
    mimic = {
        Id = "mimic",
        DisplayName = "The Mimic",
        MaxHealth = 140,
        ChaseSpeed = 16,
        PatrolSpeed = 6,
        DetectionRadius = 35,
        AttackRange = 5,
        AttackDamage = 18,
        AttackCooldown = 3.0,
        WindupDuration = 0.8,
        LeashRange = 80,
        States = { "Idle", "Patrol", "Chase", "Windup", "Attack", "Recover", "Return" },
    },
    forest_guardian = {
        Id = "forest_guardian",
        DisplayName = "Forest Guardian",
        MaxHealth = 2500,
        ChaseSpeed = 10,
        PatrolSpeed = 6,
        DetectionRadius = 120,
        AttackRange = 15,
        AttackDamage = 25,
        AttackCooldown = 4.0,
        WindupDuration = 1.2,
        LeashRange = 150,
        States = { "Dormant", "Idle", "Windup", "Attack", "Recover", "Stagger" },
    },
}

return CreatureDefinitions
