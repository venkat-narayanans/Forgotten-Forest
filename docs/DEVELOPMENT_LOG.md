# DEVELOPMENT LOG — THE FORGOTTEN FOREST

## Current Status
- **Current Phase:** Phase 6 — Downed, Revive and Death Penalty
- **Phase Status:** PASS
- **Next Phase:** Phase 7 — Progression, Quests and Persistence
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
- [ ] **Phase 7 — Progression, Quests and Persistence**
- [ ] **Phase 8 — Abandoned Village and First Boss**
- [ ] **Phase 9 — UI, Art, Audio and Polish**
- [ ] **Phase 10 — Multiplayer QA and Release Candidate**

---

## Phase 6 Completion Summary

### 1. Implemented Systems
- **Timed Revival Interaction:**
  - 4-second channelled revival interaction (`_activeRevives` table in `SurvivalService`).
  - Proximity check: reviver must remain within 10 studs of target.
  - Damage interruption: taking damage immediately breaks the revival channel.
  - Successful revival restores 35 Health and clears the Downed state.
- **Idempotent Death & Resource Penalty:**
  - Idempotency guard (`_isProcessingDeath`) prevents duplicate penalty deductions.
  - Exactly 20% of carried eligible resources lost upon expiration of 30-second downed timer.
  - Tools, equipment, permanent progression, and protected items strictly preserved.
  - Clear summary notification dispatched to the player on Safe Haven respawn.

### 2. Studio Verification & Tests
- Automated test `tests/test_phase6_death_revive.lua` executed in Studio: **PASS**.
  - Verified 20% loss calculation on resources with stack rounding.
  - Verified immunity of tools and equipment from death penalty.
  - Verified revive distance and damage interruption logic.
  - Verified idempotency guard against rapid multiple death calls.

---

## Phase 7 Work Plan — Progression, Quests and Persistence
1. Verify `ProgressionService` level progression curves, XP grants, Forest Coins, and Ancient Tokens.
2. Verify `QuestService` data-driven quest completions, objective validation, and idempotent reward grants.
3. Verify `ProfileService` DataStore save/load, schema migration, and session lock resilience.
4. Add Quest UI view or board interaction to `TFF_HUD`.
