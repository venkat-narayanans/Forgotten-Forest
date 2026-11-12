# DEVELOPMENT LOG — THE FORGOTTEN FOREST

## Current Status
- **Current Phase:** Phase 4 — Gathering, Inventory, Crafting and Storage
- **Phase Status:** PASS
- **Next Phase:** Phase 5 — Creature AI and Combat
- **Last Updated:** 2026-11-12

---

## Phase Checklist

- [x] **Phase 0 — Audit and Project Foundation** (PASS)
- [x] **Phase 1 — Graybox World and Player Foundation** (PASS)
- [x] **Phase 2 — Day/Night and Atmosphere** (PASS)
- [x] **Phase 3 — Survival and Movement Systems** (PASS)
- [x] **Phase 4 — Gathering, Inventory, Crafting and Storage** (PASS)
- [ ] **Phase 5 — Creature AI and Combat**
- [ ] **Phase 6 — Downed, Revive and Death Penalty**
- [ ] **Phase 7 — Progression, Quests and Persistence**
- [ ] **Phase 8 — Abandoned Village and First Boss**
- [ ] **Phase 9 — UI, Art, Audio and Polish**
- [ ] **Phase 10 — Multiplayer QA and Release Candidate**

---

## Phase 4 Completion Summary

### 1. Implemented Systems
- **ResourceService & World Harvesting:**
  - Automated detection and registration of all 12 world resource nodes in Whispering Woods.
  - Native integration with `ProximityPromptService.PromptTriggered` on the server (zero client trust).
  - Atomic node depletion locking (`RemainingYield -= 1`), preventing duplicate final yields across concurrent players.
  - Node exhaustion visuals (semi-transparency and prompt disabled during 180s respawn period).
- **InventoryService:**
  - 20-slot personal capacity with item category and stack limit enforcement (`StackLimit` per item).
  - Strict negative balance prevention: requests to remove more than owned are rejected without altering state.
  - Safe full-inventory handling: prevents item loss or silent overwrites.
- **CraftingService:**
  - Validates recipes, level requirements, ingredient counts, and workbench proximity.
  - Atomic transactions: ingredients deducted and outputs granted atomically. In the event of full inventory, ingredients are restored without loss.
- **Shared Safe Haven Storage:**
  - Communal chest pool in Safe Haven supporting atomic deposit and withdrawal transactions.
  - Overdraw attempts rejected; cannot withdraw below 0.

### 2. Studio Verification & Tests
- Automated test `tests/test_phase4_crafting_inventory.lua` executed in Studio: **PASS**.
  - No duplicate final node yield under concurrent simulated requests.
  - Inventory removal cannot create negative balances.
  - Crafting atomicity verified with ingredient consumption and output delivery.
  - Shared storage overdraw rejected and verified non-negative.

---

## Phase 5 Work Plan — Creature AI and Combat
1. Implement creature state machines:
   - `The Stalker`: Patrol, Detect (45 studs), Investigate, Chase (speed 14), Windup (0.6s telegraph), Attack (12 damage, 4 stud range), Leash (90 studs).
   - `The Watcher`: Distant observation, non-combat atmospheric presence, relocation upon approach.
   - `The Mimic`: Distant false cues, asymmetric model, non-impersonating behaviour.
2. Implement creature spawn templates in `ServerStorage.TFF.Templates.Creatures`.
3. Bounded PathfindingService integration with rate-limited repathing and stuck detection.
4. Server-authoritative hit validation and damage attribution in `CombatService`.
5. Active hostile creature cap enforcement (max 8–12 standard enemies).
