# DEVELOPMENT LOG — THE FORGOTTEN FOREST

## Current Status
- **Current Phase:** Phase 2 — Day/Night and Atmosphere
- **Phase Status:** PASS
- **Next Phase:** Phase 3 — Survival and Movement Systems
- **Last Updated:** 2026-11-12

---

## Phase Checklist

- [x] **Phase 0 — Audit and Project Foundation** (PASS)
- [x] **Phase 1 — Graybox World and Player Foundation** (PASS)
- [x] **Phase 2 — Day/Night and Atmosphere** (PASS)
- [ ] **Phase 3 — Survival and Movement Systems**
- [ ] **Phase 4 — Gathering, Inventory, Crafting and Storage**
- [ ] **Phase 5 — Creature AI and Combat**
- [ ] **Phase 6 — Downed, Revive and Death Penalty**
- [ ] **Phase 7 — Progression, Quests and Persistence**
- [ ] **Phase 8 — Abandoned Village and First Boss**
- [ ] **Phase 9 — UI, Art, Audio and Polish**
- [ ] **Phase 10 — Multiplayer QA and Release Candidate**

---

## Phase 2 Completion Summary

### 1. Implemented Systems
- **TimeCycleService:**
  - Authoritative 20-minute cycle (Morning: 180s, Afternoon: 300s, Sunset: 120s, Night: 420s, Dawn: 180s).
  - Dynamic Lighting transitions via `TweenService` (ClockTime, Brightness, OutdoorAmbient, FogColor, FogStart, FogEnd).
  - Night atmosphere tuned for readability: non-pitch-black visibility (Brightness 0.5, FogEnd 250 studs) preserving path navigation.
  - Periodic client replication and late-join synchronization via `SyncTimeCycle` RemoteEvent.
- **Atmospheric Audio Foundation:**
  - Ambient sound architecture in `SoundService` (`DayAmbience`, `NightAmbience`, `PhaseTransitionChime`).
  - Implemented `AudioController` on client with smooth cross-fading tweening between Day and Night layers and safe asset-loading guards.
- **UI Cycle Display:**
  - Phase indicator and countdown timer synchronized in real-time in `StarterGui.TFF_HUD.MainContainer.CycleIndicator`.

### 2. Studio Verification & Tests
- Automated test `tests/test_phase2_atmosphere.lua` executed in Studio: **PASS**.
- Live In-Studio Playtest run:
  - Cycle synchronization confirmed between server and client.
  - Zero output errors or warnings in Output log.
  - Day/Night audio cross-fade and lighting transitions verified.

---

## Phase 3 Work Plan — Survival and Movement Systems
1. Complete `SurvivalService` integration:
   - Full attribute updates for Health (100), Stamina (100), Warmth (100), Sanity (100).
   - Sprint mechanics (12 stamina/sec drain, 18 stamina/sec regen, 1s delay, Shift key & mobile button).
   - Downed state timer (30s) and revival interaction (4s, restores 35 health).
   - Passive regeneration in Safe Haven (`TFF_SafeZone`).
2. Update HUD bars for real-time attribute display.
3. Automated unit and integration tests for bounds clamping, negative stamina prevention, and revival range.
