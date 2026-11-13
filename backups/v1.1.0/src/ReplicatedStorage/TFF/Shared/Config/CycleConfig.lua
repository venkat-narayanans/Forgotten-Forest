--!strict
--[[
    CycleConfig.lua
    World day/night cycle durations and phase definitions.
]]

local CycleConfig = {
    -- Total cycle: 1,200 seconds (20 minutes)
    PhaseDurations = {
        Morning = 180,    -- 3 minutes
        Afternoon = 300,  -- 5 minutes
        Sunset = 120,     -- 2 minutes
        Night = 420,      -- 7 minutes
        Dawn = 180,       -- 3 minutes
    },

    PhaseOrder = {
        "Morning",
        "Afternoon",
        "Sunset",
        "Night",
        "Dawn",
    },

    -- Lighting targets per phase
    LightingProfiles = {
        Morning = {
            ClockTime = 8.0,
            Brightness = 2.2,
            OutdoorAmbient = Color3.fromRGB(130, 140, 130),
            FogColor = Color3.fromRGB(180, 195, 185),
            FogStart = 50,
            FogEnd = 400,
        },
        Afternoon = {
            ClockTime = 14.0,
            Brightness = 2.5,
            OutdoorAmbient = Color3.fromRGB(140, 140, 130),
            FogColor = Color3.fromRGB(190, 200, 190),
            FogStart = 80,
            FogEnd = 500,
        },
        Sunset = {
            ClockTime = 18.2,
            Brightness = 1.5,
            OutdoorAmbient = Color3.fromRGB(180, 110, 80),
            FogColor = Color3.fromRGB(195, 120, 90),
            FogStart = 40,
            FogEnd = 350,
        },
        Night = {
            ClockTime = 23.5,
            Brightness = 0.5,
            OutdoorAmbient = Color3.fromRGB(25, 38, 60), -- Deep blue palette `#17263C`
            FogColor = Color3.fromRGB(23, 38, 60),
            FogStart = 20,
            FogEnd = 250,
        },
        Dawn = {
            ClockTime = 5.8,
            Brightness = 1.2,
            OutdoorAmbient = Color3.fromRGB(150, 130, 110),
            FogColor = Color3.fromRGB(170, 150, 130),
            FogStart = 40,
            FogEnd = 300,
        },
    },
}

return CycleConfig
