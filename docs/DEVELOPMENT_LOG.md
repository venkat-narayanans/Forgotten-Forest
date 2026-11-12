# DEVELOPMENT LOG — THE FORGOTTEN FOREST

## Current Status
- **Current Phase:** Phase 7 — Progression, Quests and Persistence
- **Phase Status:** PASS
- **Next Phase:** Phase 8 — Abandoned Village and First Boss
- **Last Updated:** 2026-11-12

---

## Phase Checklist

- [x] **Phase 0 — Audit and Project Foundation** (PASS)
- [x] **Phase 1 — Graybox World and Player Foundation** (PASS)
- [x] **Phase 2 — Day/Night and Atmosphere** (PASS)
- [x] **Phase 3 — Survival and Movement Systems** (PASS)
- [x] **Phase 4 — Gathering, Inventory, Crafting and Storage** (PASS)
- [x] **Phase 5 — Creature AI and Combat** (PASS)
- [x] **Phase 6 — Downed, Revive and Death Penalty** (PASS)
- [x] **Phase 7 — Progression, Quests and Persistence** (PASS)
- [ ] **Phase 8 — Abandoned Village and First Boss**
- [ ] **Phase 9 — UI, Art, Audio and Polish**
- [ ] **Phase 10 — Multiplayer QA and Release Candidate**

---

## Phase 7 Completion Summary

### 1. Implemented Systems
- **Progression & Currencies:**
  - Dynamic XP curve calculation: `getXPForNextLevel(level) = floor(100 * (level ^ 1.5))`.
  - Level-up handling with leftover XP roll-over.
  - Tracking of dual currencies: `Forest Coins` (standard gameplay/crafting reward) and `Ancient Tokens` (rare exploration/boss reward).
- **Quest System:**
  - 4 data-driven starting quests: `First Steps`, `Preparing for Sunset`, `Comrades in the Mist`, `Echoes of the Past`.
  - Non-repeatable quests cannot be claimed twice (`isRepeatable` check).
  - Rewards distributed atomically through ProgressionService and InventoryService.
- **Persistence & Migration:**
  - Versioned profile schema (`schemaVersion = 1`).
  - Schema migration tested: safely backfills missing attributes on legacy structures without data loss.
  - Safe MockDataStore integration ensures Studio testing does not corrupt or wipe profile data.
  - Rejoin persistence verified: levels, currencies, and quest progress survive simulated disconnects and reconnects.

### 2. Studio Verification & Tests
- Automated test `tests/test_phase7_progression_persistence.lua` executed in Studio: **PASS**.
  - XP leveling curve verified.
  - Dual currency tracking verified.
  - Quest reward idempotency verified.
  - Profile schema migration verified.
  - Rejoin persistence verified.

---

## Phase 8 Work Plan — Abandoned Village and First Boss
1. Build Abandoned Village environment across the Old Stone Bridge:
   - Village square, ruined watchtower, collapsed houses, well.
   - Unlock gate checking level milestone (Level 3 required).
   - Discovery clues and environmental story items.
2. Build Forest Guardian Boss Arena:
   - Ancient roots, stone pillars, circular arena.
   - Forest Guardian boss model template with 2,500 aggregate HP.
   - Boss phases: Root Sweep ground attack, Seed Burst telegraph, Ancient Seals activation.
   - Participation-based reward distribution via `RewardService`.
