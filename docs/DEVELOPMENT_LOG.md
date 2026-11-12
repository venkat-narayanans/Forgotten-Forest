# DEVELOPMENT LOG — THE FORGOTTEN FOREST

## Current Status
- **Current Phase:** Phase 3 — Survival and Movement Systems
- **Phase Status:** PASS
- **Next Phase:** Phase 4 — Gathering, Inventory, Crafting and Storage
- **Last Updated:** 2026-11-12

---

## Phase Checklist

- [x] **Phase 0 — Audit and Project Foundation** (PASS)
- [x] **Phase 1 — Graybox World and Player Foundation** (PASS)
- [x] **Phase 2 — Day/Night and Atmosphere** (PASS)
- [x] **Phase 3 — Survival and Movement Systems** (PASS)
- [ ] **Phase 4 — Gathering, Inventory, Crafting and Storage**
- [ ] **Phase 5 — Creature AI and Combat**
- [ ] **Phase 6 — Downed, Revive and Death Penalty**
- [ ] **Phase 7 — Progression, Quests and Persistence**
- [ ] **Phase 8 — Abandoned Village and First Boss**
- [ ] **Phase 9 — UI, Art, Audio and Polish**
- [ ] **Phase 10 — Multiplayer QA and Release Candidate**

---

## Phase 3 Completion Summary

### 1. Implemented Systems
- **Survival Attribute Dynamics:**
  - Full server-authoritative tracking for Health (100), Stamina (100), Warmth (100), and Sanity (100).
  - Stamina Drain: 12 stamina/sec while sprinting, strictly clamped at 0 (cannot go negative).
  - Sprint Gate: Sprinting blocked if stamina is below 10.
  - Stamina Regen: 18 stamina/sec after 1.0s recovery delay, capped at 100.
  - Safe Haven Regeneration: +2 Health/sec and +3 Sanity/sec inside `TFF_SafeZone`.
- **Movement & Downed Controls:**
  - WalkSpeed set to 16 studs/sec (default), 22 studs/sec (sprint).
  - Downed state triggered when Health hits 0; player is set to stationary (WalkSpeed 0) with a 30s timer.
  - Teammate revival flow verified (restores 35 Health and clears Downed state).
- **HUD Extension:**
  - Expanded `StarterGui.TFF_HUD.MainContainer.StatusBars` to display real-time Health, Stamina, Warmth, and Sanity meters.
  - Desktop (Shift) and Mobile touch sprint button support verified.

### 2. Studio Verification & Tests
- Automated test `tests/test_phase3_survival.lua` executed in Studio: **PASS**.
- Verified all attribute values remain strictly clamped within bounds `[0, Max]`.
- Verified live playtest Output log remains completely error-free.

---

## Phase 4 Work Plan — Gathering, Inventory, Crafting and Storage
1. Connect `ResourceService` to `ProximityPrompt` on all 12 world resource nodes.
2. Implement server-side gather lock preventing contested harvest exploits.
3. Verify `InventoryService` personal inventory management (20 slots, stack limits, atomic item manipulation).
4. Verify `CraftingService` recipe consumption and atomic output delivery (Torch, Healing Potion, Hatchet, Barricades).
5. Verify `SharedStorageChest` communal deposit and withdrawal transactions with negative balance protection.
6. Connect Inventory and Crafting UI views in `StarterGui.TFF_HUD`.
