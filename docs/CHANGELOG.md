# CHANGELOG — THE FORGOTTEN FOREST

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
