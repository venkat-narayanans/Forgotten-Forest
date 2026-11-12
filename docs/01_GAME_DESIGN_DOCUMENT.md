# GAME DESIGN DOCUMENT — THE FORGOTTEN FOREST

**Version:** 1.0 | **Status:** Approved design baseline

## 1. High concept

The Forgotten Forest is an atmospheric multiplayer survival-adventure game for 8–12 players per Roblox server. Explorers establish a Safe Haven at the edge of a mysterious forest, gather resources, craft tools, investigate abandoned places, uncover ancient secrets and survive increasingly dangerous nights.

The forest is mysterious rather than graphically terrifying. The main emotional rhythm is curiosity by day, preparation at sunset, tension at night and relief/discovery at dawn.

**Tagline:** The forest remembers everything. The explorers remember nothing.

## 2. Design pillars

1. Exploration with meaningful discoveries.
2. Cooperative survival that rewards helping others.
3. Light survival management without tedious hunger/thirst micromanagement.
4. Mystery conveyed through environmental storytelling.
5. Long-term progression that survives death and server changes.
6. Replayability through configurable events, resource placement and creature encounters.

## 3. Player promise and session loop

A player should be able to join, understand the immediate objective, contribute within two minutes, discover something during a session and earn lasting progress.

Core loop:
1. Spawn at Safe Haven.
2. Check objectives and equipment.
3. Explore a connected region.
4. Gather resources, complete tasks and discover clues.
5. Return, craft, deposit or upgrade.
6. Prepare for night.
7. Defend, evade or investigate nighttime threats.
8. Reach dawn and receive contribution-based rewards.
9. Unlock future goals.

Target cycle: 20 minutes, configurable:
- Morning 3 min
- Afternoon 5 min
- Sunset 2 min
- Night 7 min
- Dawn 3 min

Do not make players wait idle. During each phase there should be useful activities.

## 4. Game mode and persistence model

**Persistent shared-world experience:** player profile and long-term progression persist across sessions. Each Roblox server hosts its own live simulation of the same designed world. Local server-session changes (temporary enemy positions, local resource depletion, structures) are not automatically global.

The first release does not require a single globally synchronized world. Cross-server events may be added later using MessagingService and MemoryStoreService, with durable global records in DataStoreService if justified.

Players can join an active server if capacity is available. The server supports up to 12 players. Do not reset all player progression when a server closes.

## 5. Tone and rating

- Atmospheric, mysterious, mildly scary.
- No gore, graphic injury or realistic violence.
- No relentless jump scares.
- Use distant silhouettes, unusual sounds, fog, light changes and environmental storytelling.
- Keep effects comfortable and readable; avoid flashing effects.
- Provide reduced camera shake and reduced intense visual effects settings where practical.

## 6. Player goals

Short-term:
- Gather materials.
- Craft a torch or healing item.
- Discover a landmark.
- Help revive a teammate.
- Complete a local event.

Medium-term:
- Unlock Abandoned Village.
- Upgrade lantern/tool/backpack.
- Complete creature records.
- Defeat a regional boss.
- Unlock recipes and passive perks.

Long-term:
- Explore all regions.
- Complete the mystery storyline.
- Collect artifacts and cosmetics.
- Reach progression milestones.
- Contribute to server-wide event goals.

## 7. Survival attributes

Initial attributes:
- Health: 100
- Stamina: 100
- Warmth: 100
- Sanity: 100

Health is a core combat value. Stamina supports sprinting and selected actions. Warmth is only relevant in cold regions/events. Sanity is an atmospheric mechanic, not a punishment meter.

Do not add hunger and thirst to version 1.0 unless playtesting proves they improve the loop. Avoid survival bars that decay constantly without meaningful decisions.

### Sanity design
- Sanity loss is limited to supernatural zones, selected creature encounters and night events.
- At 70: subtle audio ambience variation.
- At 45: occasional distant false silhouettes/audio cues.
- At 20: stronger but non-disabling distortions.
- At 0: do not remove player control; trigger a brief disorientation event and clamp further loss.
- Recovery: Safe Haven, selected consumables, completing calming interactions.
- Never use fake UI messages that imitate Roblox system/security messages.

## 8. Death and revival

At zero health, enter Downed state for 30 seconds.
- Downed player can crawl slowly or remain stationary; choose one consistent implementation.
- Teammate can revive through a 4-second interaction, interrupted by damage or leaving range.
- Successful revive restores 35 health and brief damage protection.
- If timer expires, respawn at Safe Haven.
- Lose 20% of eligible unprotected carried resource value, rounded down by item stack rules.
- Do not lose XP, levels, permanent unlocks, achievements, paid cosmetics or protected quest items.
- Display the loss clearly before respawn.
- Avoid deleting rare one-of-a-kind story artifacts.

## 9. Resource and crafting loop

Initial resource families:
- Wood, Stone, Herbs, Food, Cloth (common)
- Metal Scrap, Rope, Animal Materials (uncommon)
- Crystals, Ancient Fragments, Rare Minerals (rare)

Initial recipes:
- Torch: Wood + Cloth
- Healing Potion: Herbs + Water
- Wooden Barricade: Wood
- Basic Trap: Wood + Rope
- Advanced Lantern: Crystal + Metal Scrap
- Warm Clothing: Cloth + Animal Materials
- Basic Tool: Wood + Stone

Recipe costs, gathering yields and craft durations must be configured in one place. Use server validation and atomic inventory changes.

## 10. Inventory and storage

- Initial personal inventory: 20 slots.
- Stack limits are per item definition; do not assume every item stacks.
- Equipment has dedicated slots.
- Quest-critical items are protected.
- Shared Safe Haven storage is a shared resource pool; clearly communicate that it is shared.
- Storage operations must be atomic and server-authoritative.
- Do not implement player-to-player trading in first release.

## 11. Creatures

### The Watcher
Non-combat atmospheric creature. Appears at distance, watches, then disappears or relocates. It should not cause unavoidable damage.

### The Stalker
Basic hostile creature. Detects nearby players, pursues within a bounded area, attacks with a telegraphed animation, and disengages when too far away or pathfinding fails repeatedly.

### The Mimic
Advanced creature that uses sound cues and occasional non-damaging illusions to create uncertainty. It must not impersonate real players in a way that enables scams or confusion about identity. Use clearly fictional sound/visual cues.

### Forest Guardian
First boss. Multi-phase encounter at Ancient Grounds or a gated boss arena. Requires players to respond to readable attack telegraphs and activate environmental mechanisms. Rewards participation, not just last hit.

## 12. Cooperative and competitive play

Cooperative:
- revive teammates;
- gather for shared goals;
- defend Safe Haven;
- activate ancient mechanisms;
- defeat bosses;
- complete group events.

Competitive:
- personal discovery score;
- optional collection challenges;
- resource gathering milestones;
- individual quest records;
- non-exclusive leaderboard achievements.

No PvP in version 1.0. No stealing, griefing, camp destruction by players or blocking essential paths. Reward meaningful participation, not exploitative kill stealing.

## 13. World events

Initial event set:
1. Strange Signal — clue beacon at a location.
2. Crystal Bloom — temporary rare resource cluster.
3. Fog Surge — visibility changes, with safe navigation cues.
4. Abandoned Caravan — temporary loot and clue opportunity.
5. Creature Migration — increased creature presence in a marked area.
6. Ancient Awakening — structure puzzle and group reward.

Events must be telegraphed, have clear start/end states and not spawn on top of players. Events should not overlap in ways that make the server impossible.

## 14. Quest types

- Exploration: find landmarks and hidden locations.
- Survival: gather, craft, survive, revive.
- Mystery: locate documents, activate mechanisms, investigate signals.
- Group: complete a shared event or boss.

Quest definitions should be data-driven. Rewards must be server-authoritative and idempotent (the same completion cannot grant rewards twice).

## 15. Economy and monetization

Currencies:
- Forest Coins: normal gameplay rewards, basic items and cosmetics.
- Ancient Tokens: rarer exploration/boss rewards and special cosmetics.

Version 1.0 should prioritize a fair free-to-play economy. Monetization, if added, should be cosmetic-first:
- lantern skins;
- outfits;
- emotes;
- camp decorations;
- cosmetic pet appearances.

No paid damage boosts, exclusive combat power or pay-to-win progression. Do not create passes, developer products or publish monetization without owner approval.

## 16. First release scope

Required:
- Safe Haven and Whispering Woods;
- Abandoned Village (compact);
- day/night cycle;
- health/stamina/warmth/sanity;
- resource gathering;
- inventory, storage and crafting;
- campfire/barricade;
- three creatures;
- one boss;
- downed/revive/death penalty;
- XP, Forest Coins and progression;
- quests and basic achievements;
- DataStore persistence;
- multiplayer support and server validation;
- readable desktop/mobile UI.

Post-launch:
- Crystal Caverns and Ancient Grounds expansion;
- pets;
- player trading;
- seasonal content;
- expanded story chapters;
- additional bosses and events.
