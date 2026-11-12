# DEVELOPMENT LOG — THE FORGOTTEN FOREST

## Current Status
- **Phase:** Phase 0 — Audit and Project Foundation
- **Phase Status:** PASS
- **Next Phase:** Phase 1 — Graybox World and Player Foundation
- **Last Updated:** 2026-11-12

---

## Phase Checklist

- [x] **Phase 0 — Audit and Project Foundation** (PASS)
- [ ] **Phase 1 — Graybox World and Player Foundation**
- [ ] **Phase 2 — Day/Night and Atmosphere**
- [ ] **Phase 3 — Survival and Movement Systems**
- [ ] **Phase 4 — Gathering, Inventory, Crafting and Storage**
- [ ] **Phase 5 — Creature AI and Combat**
- [ ] **Phase 6 — Downed, Revive and Death Penalty**
- [ ] **Phase 7 — Progression, Quests and Persistence**
- [ ] **Phase 8 — Abandoned Village and First Boss**
- [ ] **Phase 9 — UI, Art, Audio and Polish**
- [ ] **Phase 10 — Multiplayer QA and Release Candidate**

---

## Phase 0 Completion Summary

### 1. Implemented Systems
- Established project layout: `docs/`, `src/`, `tests/`, `tools/`.
- Initialized Git repository and created initial foundation checkpoint commit.
- Created `IMPLEMENTATION_AUDIT.md`, `DEVELOPMENT_LOG.md`, `CHANGELOG.md`, `KNOWN_ISSUES.md`.
- Implemented Shared Configuration modules:
  - `BalanceConfig` (`MaxPlayers = 12`, health, stamina, interaction range, revive constants)
  - `MovementConfig` (WalkSpeed 16, SprintSpeed 22, stamina drain 12/s, regen 18/s)
  - `CycleConfig` (20-min cycle: Morning 180s, Afternoon 300s, Sunset 120s, Night 420s, Dawn 180s; lighting profiles)
  - `SurvivalConfig` (Warmth, sanity thresholds, Safe Haven health/sanity regen)
- Implemented Shared Data-Driven Definitions:
  - `ItemDefinitions` (12 resources + 7 crafted items)
  - `RecipeDefinitions` (Torch, Healing Potion, Barricade, Trap, Lantern, Warm Clothing, Basic Tool)
  - `CreatureDefinitions` (The Watcher, The Stalker, The Mimic, Forest Guardian)
  - `QuestDefinitions` (First Steps, Preparing for Sunset, Comrades in the Mist, Echoes of the Past)
- Implemented Networking Layer:
  - `RemoteRegistry` (Dynamic registration of 15 RemoteEvents and RemoteFunctions)
  - `Signal` (Typed event dispatcher)
- Implemented 14 Core Server Services in `ServerScriptService.TFFServer.Services`:
  - `WorldService`, `ProfileService`, `PlayerService`, `TimeCycleService`, `SurvivalService`, `InventoryService`, `CraftingService`, `CombatService`, `CreatureService`, `ResourceService`, `QuestService`, `ProgressionService`, `RewardService`, `EventService`
- Implemented Master Server `Bootstrap` script.
- Implemented Client Controllers in `StarterPlayerScripts.TFFClient.Controllers`:
  - `InputController`, `HUDController`, and master client `Bootstrap`.

### 2. Studio Verification & Tests
- Static Luau require verification test: **100% Pass** (all configs, definitions, services, and controllers required cleanly).
- Automated test script: `tests/test_phase0_foundation.lua` executed in Studio: **PASS**.
- Live In-Studio Playtest run:
  - Server bootstrap initialized all 14 services in order.
  - Player joined and profile loaded in safe MockDataStore mode.
  - Client bootstrap initialized `InputController` and `HUDController`.
  - Zero runtime errors or warnings in Output log.

### 3. MCP Limitations & Known Issues
- `Players.MaxPlayers` property is read-only at runtime in unpublished places; soft-limit is enforced in `PlayerService` and configured in `BalanceConfig.MaxPlayers = 12`.
- Direct multi-client launching requires manual Studio UI multi-client run; documented in `docs/KNOWN_ISSUES.md`.

---

## Phase 1 Work Plan — Graybox World and Player Foundation
1. Build Safe Haven graybox geometry:
   - Central spawn plaza (open layout for 8–12 players)
   - Campfire focal point
   - Workbench / crafting area
   - Shared storage chest
   - Quest board
   - Boundary markers and server-enforced SafeZone trigger part
2. Build Whispering Woods compact graybox:
   - Forest entrance and main trail
   - Fallen log crossing and creek bend
   - Resource node placements
   - Locked Old Stone Bridge path toward Abandoned Village
3. Setup Region tags and CollectionService attributes (`TFF_SafeZone`, `TFF_Region`).
4. Validate player spawning, collision, camera, jumping, and mobile control compatibility.
