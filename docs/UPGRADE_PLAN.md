# THE FORGOTTEN FOREST — MASTER UPGRADE PLAN (v2.0)
**Date:** 2026-11-13  
**Target Specification:** `The_Forgotten_Forest_Master_Game_Specification.md`  
**Execution Strategy:** Multi-Phase Continuous Autonomous Upgrade

---

## Task Breakdown & Dependency Graph

```mermaid
flowchart TD
    subgraph Phase A: Grand World Expansion
        A1["Design 3,200+ Stud Continuous Valley"] --> A2["Expand Safe Haven (350x350)"]
        A2 --> A3["Expand Whispering Woods (900x900)"]
        A3 --> A4["Expand Abandoned Village (650x650)"]
        A4 --> A5["Build Crystal Caverns (600x600)"]
        A5 --> A6["Build Ancient Grounds (700x700)"]
        A6 --> A7["Natural Boundaries & Traversal Routes"]
    end

    subgraph Phase B: Player Combat & Weapons
        B1["WeaponDefinitions.lua"] --> B2["Physical Weapon Templates"]
        B2 --> B3["CombatService: RequestAttack Server Validation"]
        B3 --> B4["Client Weapon Input & Hit Feedback"]
        B4 --> B5["Hunting Bow Arrow Trajectory"]
    end

    subgraph Phase C: Interactive NPCs & Story
        C1["The Cartographer (Safe Haven Map Table)"] --> C4["Dialogue & Quest Hooks"]
        C2["Mara, the Field Medic (Medical Tent)"] --> C4
        C3["The Old Keeper (Village Clock Tower)"] --> C4
        C4 --> C5["6 Dispersed Keeper Journals & Clues"]
    end

    subgraph Phase D: Weather & Dynamic Events
        D1["WeatherService (Rain, Fog, Fog Surge)"] --> D3["Warmth & Atmosphere Coupling"]
        D2["EventService (Strange Signal, Crystal Bloom)"] --> D4["Server Broadcasts & Rewards"]
    end

    subgraph Phase E: Navigation & World Map UI
        E1["Interactive Map Screen (Key 'M')"] --> E2["Fog-of-War & Landmark Markers"]
    end

    subgraph Phase F: Forest Guardian Multi-Phase Encounter
        F1["Awakening Phase"] --> F2["Root Sweep Telegraphs"]
        F2 --> F3["Root Anchors & Ancient Seals Mechanism"]
        F3 --> F4["Exposed Crystal Heart Vulnerability"]
    end

    subgraph Phase G: Verification & QA
        G1["Master Regression Test Suite v2.0"] --> G2["In-Studio Live Simulation QA"]
        G2 --> G3["Documentation & Git Release Checkpoint"]
    end

    Phase A --> Phase B
    Phase A --> Phase C
    Phase A --> Phase D
    Phase B --> Phase F
    Phase C --> Phase E
    Phase D --> Phase F
    Phase E --> Phase G
    Phase F --> Phase G
```

---

## Detailed Phase Tasks

### Phase A: Grand World Expansion (Top Priority)
- **Current State:** 251 × 824 studs total bounds, 38-second travel time, essentially flat.
- **Desired State:** 3,200+ studs continuous explorable valley, natural boundaries (cliffs, ravines, rivers), 8–12 minute travel time, 5 distinct connected regions.
- **Regions:**
  1. *Safe Haven:* 350 × 350 studs (`Z = 100 to -250`)
  2. *Whispering Woods:* 900 × 900 studs (`Z = -250 to -1150`) with Split Oak landmark, Silent Pond, and Scout Camp.
  3. *Abandoned Village:* 650 × 650 studs (`Z = -1150 to -1800`) with Clock Tower, multi-lane streets, and Well passage.
  4. *Crystal Caverns:* 600 × 600 studs (`Z = -1800 to -2400`) with mountain gorge, bridges, and glowing crystal stalactites.
  5. *Ancient Grounds:* 700 × 700 studs (`Z = -2400 to -3100`) with megaliths, ancient mechanisms, and Elder Heartwood Tree.
- **Test Plan:** Scripted player travel time measurement from Safe Haven spawn to Ancient Grounds core at walk speed 16 studs/s.
- **Acceptance Criteria:** Total world Z-span >= 3,000 studs; travel time >= 8 minutes; 100% parts anchored; 0 holes in main terrain routes.

### Phase B: Player Combat & Weapons System
- **Current State:** Creature-to-player attack only; player has no way to strike or damage creatures.
- **Desired State:** Full player defensive combat: Field Knife, Wooden Spear, Hatchet, Keeper Blade, Hunting Bow with projectile trajectory, Flare Launcher, Pickaxe.
- **Components:** `WeaponDefinitions.lua`, `CombatService.RequestAttack`, client attack input (LMB/Touch), hit spark particles, floating damage numbers, and creature take-damage logic.
- **Test Plan:** Unit test verifying server hitbox, range, cooldown validation, and damage deduction on Stalker/Mimic.
- **Acceptance Criteria:** Client attack request damages creature only when in range and off cooldown; invalid requests rejected; audio and damage numbers display.

### Phase C: Interactive NPCs & Story Clue Network
- **Current State:** 0 interactive NPCs; 1 story clue.
- **Desired State:** The Cartographer, Mara the Field Medic, and The Old Keeper with proximity prompts, dialogue modals, and 6 scattered Keeper journals.
- **Test Plan:** Automated proximity prompt check and dialogue trigger test.
- **Acceptance Criteria:** Approaching each NPC opens their respective UI; reading clues updates the journal.

### Phase D: Weather & Dynamic World Events
- **Current State:** Only day/night lighting exists.
- **Desired State:** `WeatherService.lua` (Clear, Light Rain, Heavy Rain, Dense Fog, Fog Surge) dynamically altering Warmth decay and Atmosphere. `EventService.lua` running rotating events.
- **Test Plan:** Automated weather cycle transitions and event broadcast verification.
- **Acceptance Criteria:** Rain triggers droplet particles and accelerates Warmth loss; fog adjusts Atmosphere density; events reward participants.

### Phase E: Interactive World Map UI (Key 'M')
- **Current State:** No map screen exists.
- **Desired State:** Full-screen stylized map showing discovered regions, Safe Haven beacon, landmarks, and player marker.
- **Test Plan:** Press 'M' / click Map button, verify visibility toggle.
- **Acceptance Criteria:** Responsive across PC, mobile, and gamepad.

### Phase F: Multi-Phase Forest Guardian Boss Encounter
- **Current State:** Boss is an idle template in ServerStorage.
- **Desired State:** Interactive combat encounter with Root Sweep telegraphs, Guardian Pulse safe zones, Root Anchors puzzle, and Exposed Core damage window.
- **Test Plan:** Trigger boss encounter, cycle phases, verify damage windows.
- **Acceptance Criteria:** Boss attacks are telegraphed; phase transitions synchronize across all clients.

### Phase G: Master Regression QA & Release Checkpoint
- **Current State:** v1.1.0 baseline passed.
- **Desired State:** v2.0.0 master test suite passed with 100% coverage, 0 errors, 0 warnings.
- **Acceptance Criteria:** `test_master_suite.lua` 100% PASS; clean console in live simulation; Git tag `v2.0.0-grand-valley`.
