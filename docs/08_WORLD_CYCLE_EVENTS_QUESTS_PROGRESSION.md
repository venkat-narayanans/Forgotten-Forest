# WORLD CYCLE, EVENTS, QUESTS AND PROGRESSION

## 1. Day/night controller

One server-side TimeCycleService owns the phase and current time. Clients receive phase/time updates for presentation.

Default cycle:
- Morning: 180 seconds
- Afternoon: 300 seconds
- Sunset: 120 seconds
- Night: 420 seconds
- Dawn: 180 seconds

Total: 1,200 seconds / 20 minutes.

Requirements:
- Configurable durations.
- Smooth Lighting transitions.
- Server phase is authoritative.
- Late joiners receive current phase immediately.
- UI displays phase and approximate time remaining.
- Do not let client clock determine creature behavior.

## 2. Phase gameplay

Morning:
- safer exploration;
- basic resources;
- low threat.

Afternoon:
- exploration and quests;
- rare node opportunities;
- preparation.

Sunset:
- warning;
- return/preparation incentives;
- lighting transition.

Night:
- increased threat;
- special events;
- warmth/sanity pressure in selected areas;
- rare discoveries.

Dawn:
- threat reduction;
- contribution summary;
- rewards;
- reset selected temporary event state.

## 3. Event director

The server selects eligible events based on:
- region;
- cycle phase;
- cooldown;
- player count;
- event prerequisites;
- active event limit.

Initial event definitions:
- Strange Signal
- Crystal Bloom
- Fog Surge
- Abandoned Caravan
- Creature Migration
- Ancient Awakening

Each event includes:
- ID;
- display name;
- description;
- eligible region;
- trigger conditions;
- duration;
- cooldown;
- start/end behavior;
- objective;
- reward;
- failure/expiry behavior.

Only one major event should be active per server initially. Minor ambient events may overlap if performance and readability permit.

## 4. Quest system

Quest definition:
- QuestId;
- title;
- description;
- category;
- prerequisites;
- objective type;
- target;
- amount;
- reward;
- repeatability;
- expiry (optional).

Objective types:
- CollectItem
- DiscoverLocation
- CraftItem
- DefeatCreature
- RevivePlayer
- SurviveNight
- ActivateObject
- CompleteEvent

Quest progress is server-owned. Rewards must be granted once. Persist completed permanent quests and appropriate active quest state.

## 5. Progression

XP sources:
- discoveries;
- quests;
- helping/reviving;
- creature encounters;
- boss participation;
- event completion.

Avoid rewarding AFK time. Avoid making combat the only efficient XP source.

Level curve:
- Use a configurable XP table or formula.
- Early levels should arrive quickly to teach progression.
- Later levels should slow gradually.
- No hard paywall for level progression.

Initial test target:
- first level-up within 1–2 short sessions;
- meaningful unlock every few levels;
- tune after playtesting.

## 6. Currency

Forest Coins:
- common quest and gameplay rewards;
- basic cosmetics and selected utility items.

Ancient Tokens:
- rare discoveries, boss and difficult event rewards;
- special cosmetics and recipe unlocks.

Use server-side reward tables. Prevent duplicate claims. Keep an economy ledger or transaction identifiers for important grants.

## 7. Achievements

Initial examples:
- First Steps: discover first landmark.
- Prepared Explorer: craft first torch.
- Helping Hand: revive a teammate.
- Night Survivor: survive a full night.
- Curious Mind: find a hidden document.
- Guardian's Bane: participate in boss defeat.

Achievement completion is server-side and persistent.

## 8. Leaderboards

Use personal records such as:
- discoveries;
- nights survived;
- teammates revived;
- quests completed;
- boss encounters.

Do not rank only kills or damage. Do not expose private player data. Use Roblox-supported ordered data stores only when justified and within request budgets.

## 9. Acceptance tests

- Late joiner receives correct current phase.
- Cycle transitions do not drift excessively.
- Events respect cooldown and active limits.
- Quest rewards cannot be duplicated.
- XP cannot be granted from client-supplied amounts.
- Achievement progress persists.
- Event failure/expiry cleans up temporary objects.
