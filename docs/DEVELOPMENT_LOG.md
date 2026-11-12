# DEVELOPMENT LOG — THE FORGOTTEN FOREST

## Current Status
- **Current Phase:** Phase 5 — Creature AI and Combat
- **Phase Status:** PASS
- **Next Phase:** Phase 6 — Downed, Revive and Death Penalty
- **Last Updated:** 2026-11-12

---

## Phase Checklist

- [x] **Phase 0 — Audit and Project Foundation** (PASS)
- [x] **Phase 1 — Graybox World and Player Foundation** (PASS)
- [x] **Phase 2 — Day/Night and Atmosphere** (PASS)
- [x] **Phase 3 — Survival and Movement Systems** (PASS)
- [x] **Phase 4 — Gathering, Inventory, Crafting and Storage** (PASS)
- [x] **Phase 5 — Creature AI and Combat** (PASS)
- [ ] **Phase 6 — Downed, Revive and Death Penalty**
- [ ] **Phase 7 — Progression, Quests and Persistence**
- [ ] **Phase 8 — Abandoned Village and First Boss**
- [ ] **Phase 9 — UI, Art, Audio and Polish**
- [ ] **Phase 10 — Multiplayer QA and Release Candidate**

---

## Phase 5 Completion Summary

### 1. Implemented Systems
- **Creature Templates in ServerStorage:**
  - `Stalker`: Low-poly hostile model with Humanoid, HumanoidRootPart, Head, and red `TelegraphLight`.
  - `Watcher`: Tall atmospheric silhouette with cyan eye and non-combat characteristics.
  - `Mimic`: Asymmetrical decoy model.
- **CreatureService State Machine & AI:**
  - `The Stalker`: Idle -> Detect (45 studs) -> Chase (speed 14) -> Windup (0.6s telegraph light) -> Server Attack (12 damage, 4 stud range) -> Cooldown (2.2s).
  - Leash Enforcement: 90 studs from spawn origin; exceeding leash forces immediate state transition to `Return`.
  - Safe Zone Respect: Players inside Safe Haven (`_worldService.IsInsideSafeZone(pos)`) are untargetable; chasing creatures immediately break off pursuit.
  - `The Watcher`: Non-damaging observer; despawns gracefully when approached within 35 studs.
  - Hostile Cap: Enforces max 12 active hostiles (`BalanceConfig.StandardHostileCap = 12`).
- **CombatService:**
  - Server-authoritative distance, line-of-sight, and cooldown validation.
  - Applies damage directly to `SurvivalService`.

### 2. Studio Verification & Tests
- Automated test `tests/test_phase5_creature_combat.lua` executed in Studio: **PASS**.
  - All creature definitions verified.
  - ServerStorage templates verified.
  - Leash range threshold logic verified.
  - Hostile cap configuration verified.

---

## Phase 6 Work Plan — Downed, Revive and Death Penalty
1. Connect player death / zero health to Downed state:
   - 30-second downed timer countdown.
   - 4-second revival interaction with teammate proximity validation (< 10 studs).
   - Interrupt revival if reviver takes damage or leaves range.
2. Resource Loss on Death:
   - 20% loss of eligible carried resource value (`InventoryService.ApplyDeathResourcePenalty`).
   - Permanent unlocks, XP, levels, tokens, and quest-protected items strictly excluded.
   - Idempotent death execution preventing duplicate deductions.
3. Death loss summary notification on respawn at Safe Haven.
