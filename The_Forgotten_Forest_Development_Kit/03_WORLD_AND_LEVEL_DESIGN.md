# WORLD AND LEVEL DESIGN BIBLE

## 1. World design goals

The world must feel mysterious, explorable and coherent while remaining small enough to build and optimize. Use one continuous map per server, with readable landmarks and gated connections.

Do not build a giant empty terrain. Every visible area should support a purpose: resource gathering, navigation, a quest, a vista, a story clue, a threat or a rest point.

## 2. Scale and navigation

Use Roblox character scale as the reference. Establish a consistent world grid and measure all paths using studs. The exact map dimensions should be chosen after a graybox playtest, not guessed from a screenshot.

Guidelines:
- Main paths: wide enough for two avatars to pass comfortably.
- Side paths: clearly readable but narrower.
- Important landmarks visible from at least one approach.
- Avoid long stretches with no resource, clue or visual interest.
- Place signposts and map markers at decision points.
- Use color, lighting and silhouette to distinguish regions.
- Avoid making darkness the only navigation challenge.

## 3. First-release map layout

Suggested top-down connectivity:

```text
                    [Abandoned Village]
                           |
                    Old Stone Bridge
                           |
[Whispering Woods] — [Safe Haven] — [Forest Trail]
       |                                   |
  Creek / Cave                        Locked Gate
       |                                   |
  Resource Grove                    Future Region
```

Safe Haven is the central navigation anchor. Whispering Woods is the first open exploration region. Abandoned Village is unlocked after an introductory quest chain.

The Crystal Caverns and Ancient Grounds are later expansions and should not be built fully for the first playable release.

## 4. Safe Haven

Purpose: social hub, preparation, crafting and safe recovery.

Required subareas:
- Spawn plaza.
- Central campfire.
- Crafting/workbench area.
- Shared storage.
- Quest board.
- NPC/trader stall.
- Equipment station.
- Region gate/map board.
- Small personal display area (cosmetic only, later).

Layout rules:
- Spawn points must be safe and unobstructed.
- Interactables should be easy to find.
- Keep the central plaza open for 12 players.
- No hostile creature spawn inside the safe-zone boundary.
- Use a visible boundary cue (lantern posts, stone markers or subtle rune line).
- Safe-zone rules are server-enforced, not just visual.

## 5. Whispering Woods

Visual identity: green, damp, layered, slightly uncanny.

Landmarks:
- Old trail sign.
- Fallen log crossing.
- Creek bend.
- Mushroom clearing.
- Abandoned campsite.
- Small cave entrance.
- Watcher overlook.

Gameplay:
- Wood, stone, herbs and basic food.
- Low-threat encounters.
- Tutorial resource nodes.
- A few hidden collectibles.
- Clear routes back to Safe Haven.

## 6. Abandoned Village

Visual identity: muted wood, stone, overgrown rooftops, warm window remnants, broken lanterns.

Landmarks:
- Village square.
- Well.
- Watchtower.
- Locked archive.
- Collapsed house.
- Underground storage entrance.

Gameplay:
- Metal scrap, cloth, uncommon herbs.
- Environmental puzzles.
- Story documents.
- Stalker/Mimic encounters.
- A gated clue chain.

## 7. Future region concepts

Crystal Caverns:
- Cool blue/purple palette.
- Large crystal silhouettes.
- Narrow but navigable paths.
- Avoid excessive transparency and particle effects.
- Rare minerals and special environmental hazards.

Ancient Grounds:
- Ancient stone, giant roots, glowing runes.
- Clear boss arena.
- Distinct entry/exit routes.
- Readable attack spaces and safe zones.
- Strong visual landmark: Ancient Tree.

## 8. Day/night environmental staging

Morning:
- Warm light, birds, clear sightlines.
- Resource gathering is easy to read.

Afternoon:
- Slightly longer shadows.
- Distant ambience changes.
- Event clues become visible.

Sunset:
- Orange/purple horizon.
- Lanterns begin to matter.
- Audio warning communicates transition.

Night:
- Cool blue lighting, controlled fog, localized lights.
- Keep paths and interactable silhouettes readable.
- Do not make the screen nearly black.
- Use sound and creature silhouettes for tension.

Dawn:
- Gradual warm-up, reduced creature activity.
- Reward and quest summary.

## 9. Resource placement

- Common nodes near safe routes.
- Uncommon nodes in side paths and village interiors.
- Rare nodes in exposed or gated locations.
- Do not place all rare resources behind combat.
- Use server-managed node state and respawn timers.
- Avoid spawning nodes inside geometry or inaccessible terrain.

## 10. Map unlocks

Use quest/achievement requirements, not arbitrary paid gates.

Initial gate:
- Safe Haven → Whispering Woods: available from start.
- Whispering Woods → Abandoned Village: complete introductory investigation and reach a modest player-level milestone.

The exact milestone should be configurable and playtested. Players should understand what is required.

## 11. World construction workflow

1. Graybox with simple Parts.
2. Test walking, camera, jump, sprint and group movement.
3. Test navigation and region connections.
4. Place gameplay interactables.
5. Test resource and creature spawn positions.
6. Add final low-poly geometry.
7. Add lighting, fog and audio.
8. Profile performance.
9. Run mobile/streaming checks.
10. Lock the first-release map before adding decorative details.

## 12. World quality checklist

- No critical path is blocked.
- Spawn points are safe.
- Landmarks are distinguishable.
- Players can return to Safe Haven without a map.
- Resource nodes are reachable.
- Creature navigation works in intended areas.
- No creature can trap players in an unavoidable spawn loop.
- Region gates explain unlock requirements.
- Streaming does not unload essential nearby gameplay objects.
- The map remains readable in daylight and nighttime conditions.
