# DEVELOPMENT ROADMAP AND ACCEPTANCE GATES

## Execution model

Work phase-by-phase. Do not begin a dependent phase until the previous phase gate passes. Each phase should deliver a playable or verifiable vertical slice. The agent may continue without asking for a new prompt, but must record blockers honestly.

## Phase 0 — Audit and project foundation

Tasks:
- inspect repository and Studio place;
- verify Roblox MCP tools;
- establish folder/service hierarchy;
- establish naming conventions;
- create shared config and definition modules;
- set MaxPlayers to 12 where project settings permit;
- create development log, known issues and changelog;
- create Git checkpoint if available.

Acceptance:
- no destructive changes;
- project structure documented;
- bootstrap runs without errors;
- all modules load;
- MCP limitations documented.

## Phase 1 — Graybox world and player foundation

Tasks:
- build Safe Haven graybox;
- build compact Whispering Woods graybox;
- connect paths;
- add spawn and safe-zone;
- preserve standard Roblox avatar;
- test movement, camera, jumping and mobile controls;
- add simple region labels.

Acceptance:
- players spawn safely;
- 8–12-player layout has adequate space;
- paths are navigable;
- no major collision traps;
- safe zone enforced by server;
- mobile controls remain usable.

## Phase 2 — Day/night and atmosphere

Tasks:
- TimeCycleService;
- phase replication;
- Lighting transitions;
- UI phase indicator;
- ambient audio placeholders;
- late-join synchronization.

Acceptance:
- cycle completes in configured time;
- late joiners see correct phase;
- server controls phase;
- transitions do not cause errors;
- night remains navigable.

## Phase 3 — Survival and movement systems

Tasks:
- health/stamina/warmth/sanity;
- sprint controls;
- safe recovery;
- downed state;
- HUD;
- configurable tuning.

Acceptance:
- stats stay within bounds;
- stamina cannot go negative;
- UI matches server state;
- sanity effects remain non-disabling;
- desktop and mobile controls work.

## Phase 4 — Gathering, inventory, crafting and storage

Tasks:
- item definitions;
- resource nodes;
- server gather validation;
- inventory;
- recipes;
- crafting stations;
- shared session storage.

Acceptance:
- no duplicate final node yield;
- no negative inventory;
- crafting transaction is atomic;
- full inventory handled safely;
- invalid remote requests rejected.

## Phase 5 — Creature AI and combat

Tasks:
- AI state machine;
- Stalker;
- Watcher;
- Mimic;
- attack telegraphs;
- server damage;
- creature director;
- bounded pathfinding.

Acceptance:
- AI states transition reliably;
- pathfinding failure is safe;
- damage is server-authoritative;
- creature caps enforced;
- no unavoidable spawn attacks.

## Phase 6 — Downed, revive and death penalty

Tasks:
- revive interaction;
- timer;
- respawn;
- resource-loss calculation;
- loss summary;
- idempotency.

Acceptance:
- revive range and duration enforced;
- interruption works;
- death penalty applied once;
- permanent progression preserved;
- protected items preserved.

## Phase 7 — Progression, quests and persistence

Tasks:
- XP/levels;
- Forest Coins and Ancient Tokens;
- quest definitions;
- achievements;
- profile schema;
- load/save/retry/session lock;
- migration tests.

Acceptance:
- progress survives rejoin;
- DataStore failure does not overwrite valid data;
- rewards cannot be claimed twice;
- schema migration tests pass;
- real DataStore test uses a separate test experience.

## Phase 8 — Abandoned Village and first boss

Tasks:
- unlock gate;
- village graybox/final art;
- story clues;
- environmental puzzle;
- Forest Guardian arena;
- boss phases and reward.

Acceptance:
- region unlock works;
- clues are discoverable;
- boss attacks are readable and avoidable;
- rewards are participation-based and idempotent;
- performance remains acceptable.

## Phase 9 — UI, art, audio and polish

Tasks:
- replace graybox visuals with approved low-poly assets;
- final HUD/menu styling;
- soundscape;
- animations;
- effects;
- accessibility settings;
- mobile layout polish.

Acceptance:
- no placeholder UI in critical flow;
- visual language consistent;
- no copyrighted/unapproved assets;
- reduced effects work;
- performance budget rechecked.

## Phase 10 — Multiplayer QA and release candidate

Tasks:
- test with multiple clients;
- test 8–12 player load where possible;
- test join/leave during events;
- test data save and shutdown;
- exploit-oriented remote tests;
- mobile test;
- performance profile;
- bug triage;
- release-readiness report.

Acceptance:
- no known critical data-loss or exploit issue;
- core loop playable end-to-end;
- no critical output errors;
- persistence verified in test environment;
- real multi-client testing completed or explicitly marked BLOCKED;
- owner approves publishing.

## Phase completion format

For each phase record:
- Status: NOT STARTED / IN PROGRESS / PASS / FAIL / BLOCKED.
- Implemented systems.
- Files and Studio instances changed.
- Tests run.
- Actual evidence/results.
- Known issues.
- Next phase dependencies.

Never mark PASS based only on code generation.
