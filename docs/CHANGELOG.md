# CHANGELOG — THE FORGOTTEN FOREST

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.1.0] - 2026-11-13 — FTUE Onboarding, Starter Kit & NPC Overhaul

### Added
- **Expedition Starter Supply Chest (`ExpeditionStarterChest`):**
  - Positioned along the open cobblestone path in Safe Haven (`Vector3(5, 1.2, -16)`) with iron bands, glowing gold latch, amber PointLight, and `BillboardGui` nameplate.
  - Grants new and under-equipped players starting supplies: `torch`, `field_knife`, `warm_clothing`, 3x `healing_potion`, `wood` (8x), `stone` (6x), `cloth` (4x), `herb` (4x), and `water` (2x).
  - Automatically completes `q_starter_kit` upon interaction.
- **Detailed Low-Poly NPCs & Open-Air Pavilions:**
  - Removed solid bounding blocks encasing Mara and Alden.
  - Built open timber pavilions with corner pillars, wooden crossbeams, and hanging lanterns (`Y = 12` clearance).
  - Sculpted custom low-poly Humanoid models:
    - *Alden (`NPC_cartographer`):* Explorer fedora with gold band, wire spectacles, mustache, explorer coat, harness, map cylinder backpack, and drafting desk.
    - *Mara (`NPC_medic`):* Field medic beret, auburn ponytail, white tunic with red cross armband, satchel, and apothecary table with neon potion vials.
    - *The Old Keeper (`NPC_old_keeper`):* Relocated to open village plaza at `Vector3(70, 3, -1458)` with cowl, flowing silver beard, runic eyes, and glowing staff.
- **Safe Haven Practice Resource Gathering Grounds:**
  - Added 14 safe practice resource nodes inside the outpost walls (4 Driftwood logs, 4 River stone piles, 4 Herb bushes, 2 Water wells) tagged for risk-free gathering practice.
- **Crafting Instructional Guide & Live Material Readiness:**
  - Added `CraftingGuideBanner` to `CraftingModal` explaining crafting mechanics.
  - Live inventory tracking in `HUDController.lua`: displays green `(Ready)` badges when ingredients are met and coral-red deficit counts (`Need X`) when missing.
  - Contextual `CraftButton` displaying `[ CRAFT ]` or `[ NEED MATERIALS ]`.
- **Quest System & On-Screen Active Objective Tracker:**
  - Fixed client `ProximityPrompt` input consumption by listening on `ProximityPromptService.PromptTriggered`.
  - Added dedicated `[Q] QUESTS` and `[C] CRAFT` HUD buttons mapped to keys `Q`, `J`, and `C`.
  - Rebuilt `QuestModal` with `QuestList` displaying styled quest cards for all 7 game quests.
  - Added persistent top-left on-screen `ObjectiveTracker` guiding players step-by-step from Safe Haven through the Forest Guardian encounter.

### Changed
- `ProfileService.lua`: `createDefaultProfile` now initializes new players with torch, field knife, warm clothing, potions, and crafting supplies.
- `StoryDefinitions.lua`: Captain Roderick's orders updated to explicitly guide players to the starter chest, quest log, and practice nodes.
- `PlayerService.lua`: Added chest interaction handler and quest state synchronization.

## [2.0.0] - 2026-11-13 — The Grand Valley Master Specification Edition

### Added
- **Grand Continuous Valley World Overhaul (3,370+ studs span):**
  - Expanded map scale from ~800 studs to 3,370 studs along Z-axis (`Z: +165.0 to -3205.0`, `X: [-430, 430]`, span 860 studs, `Y: [-26.4, 157.9]`, span 184 studs of natural verticality).
  - 1,186 total anchored parts in `workspace.TFF_World` (100% anchored, 0 unanchored).
  - Five distinct continuous zones with registered volume triggers in `workspace.TFF_World.Zones`:
    1. *Safe Haven Hub* (`Z = +100 to -250`): Central beacon structure, medical tent, cartographer table, workbenches, storage chests.
    2. *Whispering Woods* (`Z = -250 to -1150`): Winding trail, 650-stud creek ravine with log crossing, Split Oak landmark, Silent Pond, Scout Camp, Fairy Mushroom Ring, Watcher's Bluff, 140+ trees & boulders.
    3. *Abandoned Village* (`Z = -1150 to -1800`): Arched stone bridge, fortified gate, overgrown well square, 48-stud ruined clock tower, 6 ruined buildings (Town Archive, Blacksmith, Cottages 1-3, Keeper Hall).
    4. *Crystal Caverns* (`Z = -1800 to -2400`): Mountain gorge gateway, subterranean vault, 20 glowing neon giant crystals with point lights, 20 tagged harvestable crystal ore nodes.
    5. *Ancient Grounds & Boss Arena* (`Z = -2400 to -3150`): Basalt plateau, 220-stud circular stone boss arena, 8 megaliths with teal runic inscriptions, 5 Ancient Seals with plinths and light beams, Colossal Elder Heartwood Tree, pulsing Crystal Heart (`ForestGuardianCrystalHeart`).
- **Complete Weapons & Combat Pipeline:**
  - `WeaponDefinitions.lua` data catalog implementing all 7 specification weapons: Field Knife (12 dmg, 0.55s cd), Wooden Spear (18 dmg, 9-stud reach, interrupt capability), Forged Hatchet (20 dmg, wood bonus), Keeper Blade (28 dmg, high stagger), Hunting Bow (22 dmg, ranged physics), Flare Launcher (5 direct dmg, disruption/light), Pickaxe (15 dmg, mining).
  - 7 physical tool templates in `ServerStorage.TFF.Templates.Tools` (12 total templates).
  - Server-authoritative combat pipeline in `CombatService.lua`: client attack request validation, server cooldown enforcement, stamina drain via `SurvivalService.DrainStamina`, target reach validation, creature damage, boss core damage, tool effective gathering, and floating combat hit feedback.
  - Client mouse click/tap attack raycasting binding in `InputController.lua`.
- **Interactive NPCs & Story Clue Network:**
  - 3 Interactive low-poly NPC models in `workspace.TFF_World.Interactables`:
    - *Alden, The Valley Cartographer* (`NPC_cartographer`) at Safe Haven Map Table.
    - *Mara, Field Medic* (`NPC_medic`) at Safe Haven Medical Tent.
    - *The Old Keeper* (`NPC_old_keeper`) at Village Clock Tower Undercroft.
  - 6 Readable Story Clues placed across the valley: `StoryClue_safe_haven_orders`, `StoryClue_scout_journal`, `StoryClue_split_oak_carving`, `StoryClue_village_ledger`, `StoryClue_miner_warning`, `StoryClue_ancient_tablet`.
  - `StoryDefinitions.lua` catalog containing all dialogue trees, responses, and lore document transcripts.
  - `DialogueModal` in HUD with interactive topic selection and narrative viewing.
  - ProximityPrompt server listener in `PlayerService.lua` granting exploration XP on discovery.
- **Dynamic Weather & World Event Directors:**
  - `WeatherService.lua`: 5 weather profiles (`Clear`, `Light Rain`, `Heavy Rain`, `Dense Fog`, `Fog Surge`) driving `Lighting.Atmosphere` density (0.28 to 0.92) and warmth/sanity decay multipliers.
  - `EventService.lua`: Scheduled world events (Fog Surge wall, Strange Signal cache on Watcher's Bluff, Crystal Grotto resonance, Abandoned Caravan supply crate).
  - Environmental survival dynamics in `SurvivalService.lua`: cold zone warmth decay, hypothermia damage, wilderness sanity decay, campfire and lantern warmth recovery, safe late-join player handling.
- **Interactive World Map Screen (Key 'M'):**
  - Full-screen parchment `MapModal` with styled survey canvas, sector boundaries, survey legend, live coordinate telemetry, and real-time normalized player position tracking.
  - Quick-access Map button in HUD and keyboard ('M') / Gamepad Select bindings in `InputController.lua`.
- **Multi-Phase Forest Guardian Boss Encounter:**
  - `BossEncounterService.lua`: 4-phase encounter director:
    1. *Awakening*: Triggered on arena entry (`Z <= -2665`), runic surge and health sync.
    2. *Root Sweep*: Telegraphed red warning strips across arena floor with 1.2s dodge window dealing 22 damage.
    3. *Barrier Phase*: Invulnerability shield requiring all 5 Ancient Seals (`AncientSeal_1`..`5`) to be channeled.
    4. *Exposed Core*: 30s damage window to strike the pulsing `ForestGuardianCrystalHeart` core inside the Elder Tree.
    5. *Defeated*: Grants participating players 20 Ancient Tokens, 200 Forest Coins, `keeper_blade`, crystals, and 150 XP.
- **Master QA Test Suite:**
  - `tests/test_master_suite.lua` updated with 10 comprehensive specification verification gates. Verified 100% PASS in Roblox Studio DataModel.

## [1.1.0] - 2026-11-12 — Perfect Low-Poly Edition

### Added
- **Step 1 Atmosphere & Lighting Overhaul:** Atmosphere density 0.35 with teal haze, Bloom 0.65 threshold, ColorCorrection cinematic contrast/saturation tuning, and SunRays god-rays.
- **Step 2 Safe Haven Outpost Overhaul:** The Grand Hearth (stone ring, ash pit, teepee logs, embers, curved timber benches); The Smithy & Crafting Shed (timber post-and-beam frame, pitched wood roof, oak workbench, anvil, tool rack, lantern); The Supply Warehouse (timber canopy, iron-banded communal chest, stacked supply crates, oak barrels); The Expedition Quest Pavilion (timber roof, notice board, pinned parchment notices); Explorer Cabins/Tents (cream canvas tents with entrance cutouts); Perimeter split-rail fences and stone trailhead gateposts.
- **Step 3 Whispering Woods Low-Poly Detail Overhaul:** 28 multi-part stylized trees (Tiered Fir/Pine evergreens, gnarled Ancient Oaks with root buttresses, Slender Silver/Mossy Birch trees with bark rings); authentic hollow moss-covered log bridge crossing the creek ravine with shelf mushrooms; glowing fairy-ring mushroom clearing with 12 luminescent neon mushrooms and spore particle emitters; abandoned campsite expedition wagon with broken wooden spoked wheels, spilled crates, and sacks; Watcher's Bluff rustic timber observation deck with post-and-rope railings and ancient stone cairn; 116 scattered wild ferns, river stones, and floating firefly nodes.
- **Step 4 Abandoned Village & Old Stone Bridge Overhaul:** Arched Old Stone Bridge with heavy stone piers, cobblestone parapets, 4 iron streetlamps with warm lights, and climbing ivy; Fortified Village Gate with guard pillars, stone lintel, and glowing runic sigil; Village Square Well with stone coping, timber A-frame winch, rope, and bucket; 3 detailed ruined houses (Town Archive/Apothecary with stone chimney/fireplace and readable lore desk; Blacksmith workshop with forge embers and anvil; Residential cottage with fieldstone walls and hinged door); 3-tier Ruined Watchtower with battlements and signal fire brazier.
- **Step 5 Forest Guardian Boss Arena Overhaul:** Colossal Ancient Heartwood Tree (55 studs high, 22 studs thick, sprawling root spurs, hollow chest with pulsing crystal heart); 8 Ancient Pillars upgraded with basalt plinths, capital stones, inlaid glowing cyan vertical runes, and floating energy motes; 3 Ancient Seals upgraded into ornate stone altars with vertical glowing light pillars; 16 perimeter slate boulders and ground mist emitters.
- **Step 6 Sculpted Low-Poly Creatures:**
  - *The Stalker:* 19-part quadruped shadow predator with arched muscular torso, spine quills, clawed legs, sharp skull with glowing red ember eyes (`Neon`), lower jaw, and windup telegraph light.
  - *The Watcher:* 8-part tall entity with draped black robe silhouette, skeletal arms, bone mask, and glowing celestial third eye.
  - *The Mimic:* 21-part disguised wooden chest with bronze banding, hinged lid (35° angle), fanged wooden teeth, glowing purple interior maw with light, and root legs.
  - *Forest Guardian Boss:* 17-part colossal 18-stud treant golem with bark torso, mossy basalt pauldrons, massive fists, cylinder legs, carved head with antler horns, glowing mask eyes, and pulsing crystal heart core.
- **Step 7 Wieldable Tools & Hotbar System:** 5-slot Hotbar GUI at bottom-center of screen with keybindings 1-5, selection highlight stroke, and live item counts; 5 physical tool templates in `ServerStorage.TFF.Templates.Tools` (`torch`, `basic_tool`, `healing_potion`, `basic_trap`, `advanced_lantern`); server-authoritative equipping and consumable usage (`RequestEquipItem`, `RequestUseItem`).
- **Step 8 Interactive Gameplay Modals & Polish:** Interactive Workbench Crafting Modal with recipe cards and Craft button; Communal Storage Chest Modal; Expedition Notice Board Quest Modal; Ancient Lore Parchment Reader Modal; Boss Health Bar displaying Forest Guardian HP and phase status.
- **Step 9 Master QA Regression Verification:** All 12 test sections in `test_master_suite.lua` passing 100% in Studio; live simulation playtest confirmed 0 errors, 0 warnings.

## [1.0.0-rc1] - 2026-11-12

### Added
- **Phase 0 Foundation:** Project directory architecture, version control, 14 modular server services, RemoteRegistry, typed definitions for items, recipes, creatures, and balance configs.
- **Phase 1 Graybox World:** Safe Haven with 6 player spawns, central campfire, crafting workbench, communal storage chest, quest board, boundary lanterns, and safe zone trigger. Whispering Woods with trail, sunken creek, fallen log crossing, giant glowing mushroom clearing, campsite, and overlook bluff.
- **Phase 2 Atmosphere:** 20-minute day/night cycle (Morning, Afternoon, Sunset, Night, Dawn) with dynamic lighting transitions and day/night soundscape cross-fading.
- **Phase 3 Survival & Movement:** Health, Stamina, Warmth, Sanity server tracking, Sprint mechanics, stationary Downed state (30s), and Safe Haven regeneration.
- **Phase 4 Gathering & Crafting:** 12 interactive world resource nodes, server-authoritative gather locking, 20-slot inventory, atomic crafting recipes, and communal shared storage chest.
- **Phase 5 Creature AI:** Stalker hostile state machine with windup telegraph and leash range; Watcher non-damaging atmospheric observer; Mimic template; bounded pathfinding and hostile creature cap (12 max).
- **Phase 6 Death & Revive:** 4-second channelled teammate revival with range and damage interruption; idempotent 20% death resource loss with tool/equipment immunity.
- **Phase 7 Progression & Persistence:** Data-driven quests, dual currencies (Forest Coins, Ancient Tokens), level formula curve, versioned profile schema with safe mock fallback and migration.
- **Phase 8 Village & Boss:** Abandoned Village with ruined watchtower, overgrown well, collapsed house, archive story document, locked gate (Level 3 required), and Forest Guardian Boss Arena with 3 Ancient Seals and 2,500 HP boss template.
- **Phase 9 Polish & Accessibility:** Consistent parchment/slate/amber styling in `StarterGui.TFF_HUD`, Accessibility Settings modal (Reduced Effects, Camera Shake), and 100% part anchoring.
- **Phase 10 QA & Release Candidate:** Master automated regression test suite (`tests/test_master_suite.lua`) passing 100% across all subsystems with clean console output.
