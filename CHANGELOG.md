# CHANGELOG — THE FORGOTTEN FOREST

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0-rc1] - 2026-11-12

### Added
- **Phase 0 Foundation:** Project directory architecture, version control, 14 modular server services, RemoteRegistry, typed definitions for items, recipes, creatures, and balance configs.
- **Phase 1 Graybox World:** Safe Haven with 6 player spawns, central campfire, crafting workbench, communal storage chest, quest board, boundary lanterns, and safe zone trigger. Whispering Woods with trail, sunken creek, fallen log crossing, giant glowing mushroom clearing, campsite, and overlook bluff.
- **Phase 2 Atmosphere:** 20-minute day/night cycle (Morning, Afternoon, Sunset, Night, Dawn) with dynamic lighting transitions and day/night soundscape cross-fading.
- **Phase 3 Survival & Movement:** Health, Stamina, Warmth, Sanity server tracking, Sprint mechanics, stationary Downed state (30s), and Safe Haven regeneration.
- **Phase 4 Gathering & Crafting:** 12 interactive world resource nodes, server-authoritative gather locking, 20-slot inventory, atomic crafting recipes, and communal shared storage chest.
- **Phase 5 Creature AI:** Stalker hostile state machine with windup telegraph and leash range; Watcher non-damaging atmospheric observer; Mimic template; bounded pathfinding and hostile creature cap (12 max).
- **Phase 6 Death & Revive:** 4-second channelled teammate revival with range and damage interruption; idempotent 20% death resource loss with tool/equipment immunity.
- **Phase 7 Progression & Persistence:** Data-driven quests, dual currencies (Forest Coins, Ancient Tokens), level formula curve, versioned profile schema with safe mock fallback and migration.
- **Phase 8 Village & Boss:** Abandoned Village with ruined watchtower, overgrown well, collapsed house, archive story document, locked gate (Level 3 required), and Forest Guardian Boss Arena with 3 Ancient Seals and 2,500 HP boss template.
- **Phase 9 Polish & Accessibility:** Consistent parchment/slate/amber styling in `StarterGui.TFF_HUD`, Accessibility Settings modal (Reduced Effects, Camera Shake), and 100% part anchoring.
- **Phase 10 QA & Release Candidate:** Master automated regression test suite (`tests/test_master_suite.lua`) passing 100% across all subsystems with clean console output.
