# TECHNICAL ARCHITECTURE

## 1. Architecture principles

- Server-authoritative simulation.
- Modular Luau code with explicit interfaces.
- Data-driven content and balance.
- Minimal third-party dependencies.
- Clear separation of client presentation and server rules.
- Defensive persistence and remote validation.
- Performance appropriate for 8–12 players and mobile devices.

## 2. Roblox services and ownership

### ReplicatedStorage
Contains safe-to-replicate modules, shared type definitions, item/creature/recipe definitions, configuration and RemoteEvents/RemoteFunctions.

Suggested:
```text
ReplicatedStorage
└── TFF
    ├── Shared
    │   ├── Config
    │   ├── Definitions
    │   ├── Types
    │   └── Util
    └── Remotes
```

### ServerScriptService
Server-only service modules and bootstrap:
```text
ServerScriptService
└── TFFServer
    ├── Bootstrap.server.lua
    ├── Services
    │   ├── PlayerService
    │   ├── ProfileService
    │   ├── WorldService
    │   ├── TimeCycleService
    │   ├── SurvivalService
    │   ├── ResourceService
    │   ├── InventoryService
    │   ├── CraftingService
    │   ├── CombatService
    │   ├── CreatureService
    │   ├── QuestService
    │   ├── ProgressionService
    │   ├── EventService
    │   └── RewardService
    └── Systems
```

### ServerStorage
Creature templates, server-only assets, loot tables and templates not needed by clients.

### StarterPlayer
Client controllers:
- InputController
- CameraController
- InteractionController
- HUDController
- InventoryController
- AudioController
- EffectsController
- AccessibilityController

### StarterGui
ScreenGui and UI templates. Keep UI code in controllers/modules rather than giant LocalScripts.

### Workspace
World geometry and tagged interactables. Use clear folders:
- Map
- Regions
- ResourceNodes
- Interactables
- CreatureSpawns
- SafeZones
- SpawnLocations
- TemporaryStructures

## 3. Dependency direction

- Shared definitions must not depend on server or client services.
- Client controllers may depend on shared modules and communicate through remotes.
- Server services may depend on shared definitions and other server services through explicit initialization.
- Server code must not require client code.
- Avoid circular requires.
- Bootstrap services in a deterministic order with clear startup/shutdown methods.

## 4. Remote API design

Create a remote registry and document every remote.

Examples:
- `RequestGather(resourceId)` — server validates distance, node state, tool, cooldown and yield.
- `RequestCraft(recipeId, quantity)` — server validates recipe, station, materials, capacity and cooldown.
- `RequestRevive(targetUserId)` — server validates target state, distance, line of sight if used, cooldown and interruption.
- `RequestInteract(interactableId)` — server validates ownership/state/distance.
- Server-to-client events: inventory update, world phase, quest update, notification, creature warning.

Rules:
- Never accept client-supplied reward amounts, damage amounts, item definitions or prices.
- Prefer server-resolved Instance references or opaque IDs that map to server-known objects.
- Validate all argument types and lengths.
- Validate player state, distance and action rate.
- Add per-player rate limits.
- Return safe, structured failure codes; do not expose internal stack traces.
- Do not create a generic “execute action” remote.

## 5. World interaction model

Use CollectionService tags and Attributes for interactables:
- `TFF_ResourceNode`
- `TFF_Interactable`
- `TFF_CreatureSpawn`
- `TFF_SafeZone`
- `TFF_QuestLocation`

Attributes should be typed and validated. Avoid relying on object names alone as security identifiers.

## 6. Data-driven definitions

Use shared definition modules for:
- Items
- Recipes
- Creatures
- Quests
- Regions
- Events
- Loot tables
- Balance configuration

Definition validation should run at server startup. Fail fast in development if required fields are missing or invalid.

## 7. Recommended module contracts

Each service should expose:
- `Init(dependencies)`
- `Start()`
- `Stop()` where needed
- narrow public methods
- internal state not exposed to clients

Example:
- InventoryService: `GetSnapshot(player)`, `TryAddItem(player, itemId, amount)`, `TryRemoveItem(player, itemId, amount)`, `TryTransferToStorage(...)`.
- ResourceService: `TryGather(player, nodeId)`.
- CraftingService: `TryCraft(player, recipeId, amount)`.
- ProgressionService: `GrantXP(player, amount, reason)`.
- CreatureService: `SpawnCreature(definitionId, spawnPoint)`.

Do not expose arbitrary setters that bypass validation.

## 8. Physics and network ownership

- Static map geometry anchored.
- Dynamic gameplay objects use server ownership when exploit-sensitive.
- Do not network-own critical loot, traps or boss mechanisms to a client.
- Use Roblox default character controller unless a documented gameplay requirement demands custom movement.
- Use collision groups for players, creatures, triggers and non-colliding decoration.
- Keep server-side hit validation for combat.
- Use server-validated distance and state checks.
- Avoid physics-driven solutions for systems better implemented as state/logic.
- Ensure client effects do not determine actual gameplay outcomes.

## 9. NPC navigation

Use PathfindingService for creatures that need navigation.
- Recompute paths on target change, obstruction or a bounded interval, not every frame.
- Limit simultaneous path computations.
- Add stuck detection and retry limits.
- Use local steering/simple movement for short, predictable movement where appropriate.
- Set creature patrol regions and leash ranges.
- If navigation fails, creature should safely disengage or return to spawn rather than teleporting unfairly.

## 10. Persistence architecture

Use DataStoreService for player profiles. A profile schema is defined in `10_PERSISTENCE_AND_DATA.md`.

- Load before enabling gameplay actions that depend on saved data.
- If load fails, do not silently create an empty profile and overwrite existing data.
- Use session locking or a robust single-session ownership mechanism.
- Save with `UpdateAsync` where atomic update semantics are needed.
- Retry transient errors with exponential backoff and jitter.
- Respect Roblox request budgets.
- Save periodically and on player exit.
- BindToClose must attempt bounded saves.
- Make reward grants idempotent where feasible.
- Log failures without logging private data.

## 11. Cross-server state

First release:
- Each server runs its own day/night cycle and local events.
- Player progression persists across servers.
- No requirement for every server to share exact resource depletion or creature state.

Later:
- MessagingService can announce global event changes.
- MemoryStoreService can coordinate temporary event locks/queues.
- DataStoreService can store durable global milestones.
- Design for message loss, duplicates and throttling. Messaging is not a durable event log.

## 12. Performance budgets

Initial targets to validate, not promises:
- 8–12 players per server.
- Aim for stable 30+ FPS on supported lower/mid-range mobile devices.
- Keep active hostile creatures bounded; start with a target cap of 8–12 standard enemies and one boss encounter, then profile.
- Avoid excessive particle emitters and transparent layers.
- Use StreamingEnabled and test streaming boundaries.
- Avoid large numbers of unanchored parts.
- Avoid per-frame server loops for routine checks.
- Use task scheduling and event-driven state changes.
- Profile with Roblox MicroProfiler and Developer Console.

## 13. Error handling and observability

- Structured server warnings with service and action identifiers.
- Do not print every frame or every heartbeat.
- Log failed DataStore operations and remote validation failures with rate limiting.
- Development-only diagnostics must be disabled or restricted in production.
- Maintain a known-issues list and reproduction steps.
