# THE FORGOTTEN FOREST — DEVELOPMENT KIT

**Purpose:** Source-of-truth documentation for autonomous, phase-by-phase development in Roblox Studio using Google Antigravity and the Roblox Studio MCP integration.

## Start here

1. Extract this folder into the root of your game repository.
2. Open the repository in Antigravity.
3. Confirm Roblox Studio is open with the correct place/project and the MCP connection is active.
4. Give Antigravity the instructions in `00_MASTER_AGENT_INSTRUCTIONS.md`.
5. Ask it to begin Phase 0 only. The master instructions then govern all later phases.

## Document precedence

If documents conflict, use this order:
1. `00_MASTER_AGENT_INSTRUCTIONS.md` for agent behavior and safety.
2. `01_GAME_DESIGN_DOCUMENT.md` for player-facing design.
3. `02_TECHNICAL_ARCHITECTURE.md` for implementation boundaries.
4. `03_WORLD_AND_LEVEL_DESIGN.md` and `04_ART_AUDIO_AND_AVATAR_BIBLE.md` for world and presentation.
5. System specifications in `05`–`11`.
6. `12_DEVELOPMENT_ROADMAP_AND_ACCEPTANCE.md` for phase order and completion gates.
7. `13_TESTING_QA_AND_RELEASE.md` for verification.

When an implementation limitation makes a requirement infeasible, do not silently change the design. Record the issue, propose the smallest safe alternative, and request approval only when the change materially affects gameplay, security, persistence, monetization, or scope.

## Important project assumptions

- Platform: Roblox, using Luau and Roblox Studio.
- Server capacity target: 8–12 players; configure `MaxPlayers = 12`.
- Game mode: persistent player progression with shared state inside each running server. Do not imply all Roblox servers share one physical world.
- World: one continuous map per server, with regions unlocked through progression.
- Tone: atmospheric, mysterious, mildly scary; no graphic horror.
- Visuals: stylized low-poly Roblox-compatible world, readable silhouettes, performant geometry.
- First public release scope: Safe Haven, Whispering Woods, Abandoned Village, three standard creatures, one boss, core survival/crafting/progression, persistence, quests and multiplayer.
- All balancing values in the docs are initial defaults, not immutable facts. Keep them in configuration modules and tune through tests.

## Repository layout expected

```text
TheForgottenForest/
├── docs/                         # This documentation set
├── src/
│   ├── ReplicatedStorage/
│   ├── ServerScriptService/
│   ├── ServerStorage/
│   ├── StarterPlayer/
│   ├── StarterGui/
│   └── Workspace/                # Prefer Studio-managed world assets
├── tests/                        # Test plans, test scripts if applicable
├── tools/                        # Optional build/validation scripts
├── README.md
└── CHANGELOG.md
```

Roblox Studio services are not ordinary filesystem folders in every workflow. Use the actual Studio hierarchy and MCP-supported operations. Do not create fake source directories and claim they are running in Studio.
