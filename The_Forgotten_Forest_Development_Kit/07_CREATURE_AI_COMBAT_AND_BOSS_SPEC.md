# CREATURE AI, COMBAT AND BOSS SPECIFICATION

## 1. AI design principles

- Server-authoritative AI.
- Clear state machines.
- Readable telegraphs.
- Bounded pathfinding and active NPC count.
- No unavoidable damage.
- Creatures should be challenging but fair.
- Fail safely if pathfinding fails.

## 2. Shared creature states

Suggested states:
- Dormant
- Idle
- Patrol
- Investigate
- Chase
- Windup
- Attack
- Recover
- Stagger
- Return
- Despawn

Each creature definition configures which states it uses.

## 3. The Watcher

Purpose: atmospheric tension, not direct combat.

Behavior:
- Spawn at curated distant points.
- Select a visible or plausible observation point.
- Observe for a short configurable duration.
- Disappear or relocate when approached or looked at for too long.
- Avoid appearing inside the player's immediate camera view.
- Do not cause damage.
- Use low frequency and cooldown to avoid repetition.

## 4. The Stalker

Purpose: first combat threat.

Initial tuning targets:
- Health: 100
- Detection radius: 45 studs
- Attack range: 4 studs
- Attack damage: 12
- Attack cooldown: 2.2 seconds
- Chase speed: 14
- Leash range: 90 studs from spawn area

Behavior:
1. Patrol.
2. Detect eligible player.
3. Investigate.
4. Chase within leash.
5. Show wind-up.
6. Attack if still in range and line-of-sight rules pass.
7. Recover.
8. Return if target escapes.

Telegraph:
- brief pose/sound before attack;
- visible enough for a player to dodge or retreat.

## 5. The Mimic

Purpose: create uncertainty through sound and environmental cues.

Rules:
- Does not copy actual player display names, chat, voice or identity.
- Uses a library of original fictional sound cues.
- Can create a false distant lantern or silhouette.
- False cues must not impersonate Roblox system notifications or purchase prompts.
- It should not cause unavoidable damage.
- Its real body must have a consistent discoverable clue.
- Use sparingly and avoid repeated targeting of one player.

## 6. Forest Guardian boss

Initial encounter:
- One arena with clear entry/exit.
- Boss health target: tune for 8–12 players; start with 2,500 aggregate health and playtest.
- Boss attacks are telegraphed.
- Use 2–3 attack patterns initially.
- Environmental mechanisms create vulnerability windows.
- Participation rewards are based on meaningful contribution, not only last hit.

Suggested phases:
1. Awakening: boss introduces itself; no surprise damage.
2. Root Sweep: ground attack with visible safe lanes.
3. Seed Burst: targeted area warning, bounded damage.
4. Ancient Seal: players activate 2–3 mechanisms.
5. Vulnerability: boss takes increased damage for a short window.
6. Defeat: reward and story reveal.

## 7. Combat rules

- Server validates attack start, cooldown, range and state.
- Server determines damage.
- Use server raycasts or server-validated hitboxes.
- Do not accept client damage values.
- No friendly fire in version 1.0.
- Add damage attribution for rewards.
- Avoid excessive stun-lock.
- Give players recovery windows.

## 8. Pathfinding performance

- Do not recompute paths every Heartbeat.
- Repath on target movement threshold, blockage or timer.
- Limit concurrent path requests.
- Use path waypoint progression.
- Detect stuck state.
- After bounded failures, return to spawn or use a safe fallback.
- Keep spawn points and patrol zones clear.
- Profile NPC performance with full server population.

## 9. Spawn director

Use a server-side encounter director:
- region-specific spawn points;
- maximum active creatures;
- cooldowns;
- player proximity rules;
- day/night multipliers;
- event modifiers;
- no spawn directly beside a player;
- avoid spawning multiple threats on one isolated new player.

## 10. Acceptance tests

- Stalker cannot damage through walls where line-of-sight is required.
- Stalker disengages beyond leash range.
- Pathfinding failure does not freeze server.
- Mimic never impersonates real users or system messages.
- Watcher does not damage players.
- Boss telegraphs are visible and attacks are avoidable.
- Boss rewards cannot be claimed repeatedly.
- NPC count remains within configured cap.
