# THE FORGOTTEN FOREST

## Master Game Specification & Existing-Project Upgrade Blueprint

**Purpose:** This is the single source of truth for upgrading the
current Roblox game. It defines the story, world, map scale, regions,
player systems, weapons, creatures, objects, survival, progression, UI,
multiplayer, and technical expectations.

**Mandatory instruction to Antigravity:** The current project already
exists. Inspect it first, understand what has been built, and upgrade it
in place. Preserve systems that work. Refactor incomplete systems
safely. Do not blindly rebuild or delete the project. This is not a
request for a tiny demo or a short forest arena.

------------------------------------------------------------------------

# 1. GAME IDENTITY

**The Forgotten Forest** is a cooperative survival, exploration,
mystery, and atmospheric-horror adventure for up to 12 players. Players
explore an ancient living forest, gather resources, craft equipment,
prepare for dangerous nights, discover abandoned places, solve
environmental puzzles, and uncover what happened to the people who once
protected the forest.

**Player promise:** Explore the unknown. Prepare for the night. Survive
together. Uncover what the forest is hiding.

-   Genre: survival + exploration + mystery + atmospheric horror +
    cooperative adventure.
-   Platform: Roblox; standard R15 avatars; third-person camera.
-   Visual style: stylized low-poly Roblox world with modern lighting,
    detailed terrain, atmospheric fog, strong landmarks, polished
    effects and readable UI.
-   Server capacity: maximum 12 players.
-   Multiplayer: cooperative objectives with personal discoveries and
    optional leaderboard competition.
-   PvP: disabled in v1.0.
-   World: one continuous map per server. Player progression persists
    across servers; the physical world simulation is server-instance
    based.
-   Tone: mysterious, tense, beautiful and occasionally frightening, not
    relentlessly terrifying.
-   Monetization: cosmetics only; no pay-to-win.
-   Do not turn this into a tiny arena, generic click simulator, flat
    forest, disconnected minigame collection, or PvP shooter.

# 2. STORY AND LORE

## 2.1 The premise

Long before nearby towns existed, an ancient forest covered the valley.
Beneath it was an enormous living root network connected to an ancient
heart. The people who lived there learned that the forest was aware: it
could remember footsteps, imitate sounds, hide paths, and react to fear.
It was not naturally evil, but something beneath it was disturbing its
balance.

A group called **The Keepers** studied the forest and maintained five
ancient seals. The seals regulated the forest and protected the valley.
One night, a catastrophe called **The Long Silence** occurred. The
settlement lights went out, the forest changed shape, the Keepers
disappeared, and familiar paths began leading to unfamiliar places.
Strange creatures appeared after sunset.

Years later, an expedition arrives to investigate the abandoned valley,
establish a safe camp, recover the Keepers' records, and learn what
happened. The player is part of this expedition. The full truth must be
discovered gradually through places, notes, NPC dialogue, puzzles, audio
clues and world events.

## 2.2 Central mystery

**Did the Keepers fail to protect the forest, or did they deliberately
seal something inside it?**

Gradually reveal that: 1. The Keepers knew the forest was alive. 2. The
five seals regulated its balance. 3. The Long Silence followed a failed
attempt to repair or control the ancient heart. 4. The creatures are
connected to the forest's memory and damaged balance. 5. The Forest
Guardian is not simply a monster; it is protecting something. 6. The
truth is morally complicated, not a simple good-versus-evil reveal.

Do not explain all lore in the opening tutorial.

## 2.3 Characters

**The Cartographer:** Surviving researcher at Safe Haven. Gives
exploration objectives, updates the map and explains discoveries. Stands
near the map table, points toward newly discovered regions, and uses
short useful dialogue.

**Mara, the Field Medic:** Maintains the medical station and teaches
healing, downed state and survival supplies. Approaching her opens a
concise dialogue or medical shop.

**The Old Keeper:** Mysterious NPC encountered later in the Abandoned
Village after enough evidence is found. Gives partial truths and
riddles. Must not appear in the starting hub.

**The Forest Voice:** Never a normal humanoid NPC. Communicates through
distant whispers, environmental sounds, altered signs and rare visual
phenomena. Never impersonate a real player, their voice, Roblox
moderation or Roblox system messages.

## 2.4 Story chapters

-   **Prologue --- The Expedition:** Arrive at Safe Haven, learn
    movement, gathering, inventory and day/night. Repair the camp
    beacon. First night introduces distant sounds and a non-lethal
    Watcher sighting.
-   **Chapter 1 --- Whispering Woods:** Explore beginner forest,
    abandoned camps and Keeper symbols. Learn the forest reacts to noise
    and isolation. Restore a beacon.
-   **Chapter 2 --- Abandoned Village:** Find the village and locked
    archive. Solve environmental puzzles and collect three key records.
    Discover that the Keepers deliberately closed the village. Encounter
    the Stalker and Mimic.
-   **Chapter 3 --- Broken Seal:** Find a damaged seal chamber, gather
    rare materials, activate mechanisms and survive a major encounter.
    The world changes when the seal is restored.
-   **Chapter 4 --- The Heart Below (future endgame):** Unlock Crystal
    Caverns and Ancient Grounds, learn the truth about the ancient heart
    and Forest Guardian, and eventually make a meaningful world-state
    choice.

## 2.5 Storytelling methods

Use torn expedition notes, Keeper journals, carved symbols, abandoned
tools, broken machinery, empty camps, murals, audio logs, environmental
changes and short NPC dialogue. Every clue must connect to the story; do
not scatter meaningless pages.

------------------------------------------------------------------------

# 3. WORLD SIZE AND MAP DESIGN --- TOP PRIORITY

The current map is too short. This is a core design failure and must be
addressed before cosmetic polish. Expand the existing map into a large,
continuous, explorable valley with meaningful routes, verticality,
landmarks and discoveries. Do not create empty terrain just to claim the
map is large.

## 3.1 Scale targets

Use these as initial design targets and measure the actual map in
Studio:

-   Main world footprint: approximately **3,000--3,800 studs across its
    main dimensions**, with irregular natural boundaries.
-   Travel from Safe Haven to the farthest currently available major
    objective: approximately **8--12 minutes at normal exploration
    pace**, depending on route and hazards.
-   A meaningful discovery should generally occur every **30--60
    seconds** while exploring.
-   The map should feel large through routes, terrain, verticality and
    landmarks---not empty space.

Suggested region footprints:

  ------------------------------------------------------------------------
  Region                       Approximate footprint Role
  --------------------- ---------------------------- ---------------------
  Safe Haven                         350 × 350 studs Hub and preparation

  Whispering Woods                   900 × 900 studs Beginner exploration

  Abandoned Village                  650 × 650 studs Story, puzzles,
                                                     danger

  Crystal Caverns                 600 × 600 studs of Advanced resources
                           surface/underground space 

  Ancient Grounds                    700 × 700 studs Endgame and boss
  ------------------------------------------------------------------------

These are irregular connected areas, not five flat square rooms. Their
bounding areas may overlap. Build routes and vertical spaces
intelligently.

## 3.2 Layout and connectivity

-   Safe Haven sits near the southern or central edge of the valley.
-   Whispering Woods surrounds and extends beyond the camp.
-   Abandoned Village lies beyond a river, ravine or broken stone
    bridge.
-   Crystal Caverns are reached through a mountain opening or collapsed
    mine.
-   Ancient Grounds lie beyond the village and require story
    progression.
-   A distant mountain ridge, enormous dead tree or unnatural light
    should be visible from multiple locations to create a sense of
    scale.
-   Main regions must connect organically. Do not use teleporting as the
    normal way to travel.
-   Optional fast travel may be considered later, only after
    discovery/unlocking.

## 3.3 Landmark and discovery density

Every major region needs: - One distinctive landmark visible from a
distance. - 3--5 medium points of interest. - 6--10 small discoveries or
resource clusters. - Multiple route choices where practical. - A safer
route and a riskier shortcut where appropriate. - At least one secret or
hidden route. - Environmental storytelling. - A reason to return after
the first visit.

Examples: giant hollow tree with glowing roots, broken watchtower, rope
bridge over a ravine, ruined stone gate, abandoned campsite, waterfall
cave, buried Keeper shrine, collapsed mine, village clock tower, giant
tree visible through fog.

Avoid identical repeated prefabs. Reuse modular assets but vary
rotation, scale, composition, damage, material, foliage, lighting and
props.

## 3.4 Verticality and boundaries

Include rolling hills, slopes, ridges, cliffs, ravines, bridges, caves,
tunnels, lookout points and elevated ruins. Make climbable routes
visually clear. Avoid invisible walls where a natural cliff, thorn
barrier, river or dense forest can communicate the boundary. Never leave
an abrupt unfinished map edge.

## 3.5 Navigation

Create a map UI that: - Shows discovered areas, Safe Haven and
discovered landmarks. - Does not reveal all secrets immediately. -
Updates after beacons and location discoveries. - Shows compass
direction and optional objective direction. - Supports mobile, desktop
and gamepad. - Does not replace environmental navigation; landmarks must
be recognizable in-world.

------------------------------------------------------------------------

# 4. REGIONS

## 4.1 Safe Haven

A warm, protected expedition camp. Include a central campfire and
beacon, tents, crafting workbench, storage building, medical tent, map
table, notice board, trader stall, watchtower, perimeter lights and
paths leading into the forest.

Object behaviour: - **Campfire:** warm light, smoke, crackling sound,
heat radius and faster warmth recovery nearby. Does not automatically
heal all damage. - **Beacon:** central story/world objective. Can be
repaired/upgraded with resources; activation can reveal map information
or reduce selected nearby threats. - **Workbench:** opens crafting UI.
Server validates recipe and ingredients before crafting. - **Storage
chest:** opens shared current-server session storage. Validate distance,
capacity, item quantity and ownership. Do not imply it persists
globally. - **Medical station:** healing supplies and recovery
tutorial. - **Map table:** world map and journal. - **Notice board:**
quests, server events and group objectives. - **Trader:**
server-validated stock and prices. - **Watchtower:** elevated lookout. -
**Safe-zone boundary:** creatures cannot enter the protected core unless
a clearly telegraphed special event explicitly changes this.

Make the camp feel alive with NPC idles, fireflies, smoke, flags,
ambient sounds and changing light.

## 4.2 Whispering Woods

Beginner region with tall stylized trees, ferns, mushrooms, moss, roots,
fallen logs, sun shafts, narrow trails, streams and clearings. Points of
interest: Split Oak, Abandoned Scout Camp, Old Wooden Bridge, Silent
Pond, small Keeper shrine and lookout rock. Resources: common wood,
stone, herbs, food, cloth and rope. Introduce basic crafting, puzzles,
Watcher sightings and early Stalker encounters.

## 4.3 Abandoned Village

Overgrown houses, broken lamps, central square, stopped clock tower,
ruined archive, Keeper hall, well with hidden passage and roots growing
through floors. Gameplay: search homes, restore selected power, solve
symbol/light/sound/mechanism puzzles, unlock archive, find Keeper
records and encounter Mimic/Stalker.

## 4.4 Crystal Caverns

Large underground chambers, controlled glowing crystals, underground
water, ledges, bridges, mining equipment and roots passing through
stone. Gameplay: rare crystals/minerals, unstable rock, cold pockets,
low visibility, advanced crafting materials, Keeper machinery and
sound/light-based creature encounter.

## 4.5 Ancient Grounds

Enormous roots, broken stone circles, statues, strange sky lighting,
ancient mechanisms and a huge tree/root structure dominating the
horizon. Gameplay: high-level exploration, cooperative mechanisms,
Forest Guardian boss, major lore revelations and rare ancient fragments.

------------------------------------------------------------------------

# 5. PLAYER ATTRIBUTES AND MOVEMENT

All gameplay values are server-authoritative. The client displays values
and requests actions; it never decides its own health, rewards,
inventory, damage or currency.

  Attribute        Starting value Behaviour
  -------------- ---------------- ----------------------------------------------------
  Health                      100 At 0, enter downed state
  Stamina                     100 Used for sprint and strenuous actions
  Warmth                      100 Falls in cold, rain, caves and exposed night areas
  Sanity                      100 Falls during supernatural exposure/isolation
  Walk speed                   16 Normal baseline
  Sprint speed                 22 Initial target; tune in playtests
  Inventory              20 slots Item-specific stack limits
  Downed timer             30 sec Teammate can revive

## 5.1 Health

Maximum 100. Damage sources: creature attacks, appropriate falls, traps,
environmental hazards and boss mechanics. Healing: bandages, medical
supplies, healing potions and approved safe-zone interactions. No
automatic regeneration during active danger. Attacks need readable
wind-up, hit area, sound and feedback. Avoid instant deaths from
ordinary enemies.

## 5.2 Stamina

-   Maximum 100.
-   Sprint drain: 12 per second.
-   Regeneration: 18 per second after 1 second without sprinting.
-   Sprint stops at 0.
-   Add a short, fair exhaustion state only after full depletion.
-   Standing still must not drain stamina.
-   Prevent sprint toggling from bypassing drain.

## 5.3 Warmth

Falls faster in cold caves, rain, high areas and exposed nights.
Recovers near campfires, heat sources, shelters and with warm clothing.
Low warmth first produces subtle visual/audio feedback; critical warmth
causes gradual health damage. Do not make the beginner region unfairly
cold during normal daytime.

## 5.4 Sanity

Falls near supernatural events, dark locations, Mimic encounters and
prolonged isolation in dangerous regions. Recovers slowly in Safe Haven,
near teammates or calming objects. Effects: subtle whispers, distant
silhouettes, slight screen distortion, false lights and altered
ambience. Sanity must never disable controls, invert controls or create
unavoidable damage loops. No fake system messages. Provide
reduced-distortion accessibility setting.

## 5.5 Status effects

Implement a common framework with source, severity, duration, stack
limit, refresh and removal rules: - **Cold:** warmth decreases faster. -
**Bleeding:** small damage over time until treated. - **Exhausted:**
sprint temporarily unavailable. - **Dazed:** brief movement penalty
after a heavy hit; never remove control entirely. - **Marked:** a
creature can track a player for a limited time. - **Calmed:** sanity
loss reduced briefly. - **Protected:** temporary protection from a
defined hazard.

## 5.6 Controls

  Action      Keyboard/mouse      Mobile             Gamepad
  ----------- ------------------- ------------------ -----------------
  Move        WASD                Virtual joystick   Left stick
  Camera      Mouse               Drag               Right stick
  Sprint      Shift               Sprint button      Mapped button
  Interact    E                   Context button     Context button
  Inventory   Tab / I             UI button          Menu/mapped
  Map         M                   UI button          View/mapped
  Use item    Number keys/click   Hotbar tap         D-pad/mapped
  Dodge       Optional key        Optional button    Optional button

Use a single movement/stamina service. Do not let multiple scripts
independently change WalkSpeed. Keep mobile controls uncluttered.

## 5.7 Interaction rules

Show a prompt only when in range and usable. Prompts should name the
action: "Gather Wood", "Open Chest", "Repair Beacon", "Revive Player".
Validate distance on the server. Hold interactions show progress and
cancel when the player moves away, takes damage or the object becomes
unavailable. Simultaneous interactions must not duplicate rewards.

------------------------------------------------------------------------

# 6. WEAPONS, TOOLS AND COMBAT

Combat is defensive and survival-focused, not a shooter. Every weapon
has a role, animation, sound, hit feedback and cooldown. Server
validates range, cooldown, target and damage. Never trust client damage.
PvP is disabled.

## 6.1 Initial weapons

These are starting balance targets, not final values:

  -----------------------------------------------------------------------------
  Weapon     Role         Base damage         Range      Cooldown Special
  ---------- ---------- ------------- ------------- ------------- -------------
  Field      Fast                  12       5 studs        0.55 s Fast, low
  Knife      starter                                              stagger
             defence                                              

  Wooden     Reach and             18       9 studs         1.0 s Longer reach;
  Spear      control                                              slower
                                                                  recovery

  Hatchet    Tool and              20       6 studs         1.1 s Bonus vs
             weapon                                               wooden
                                                                  obstacles

  Keeper     Advanced              28       6 studs         0.8 s Better
  Blade      melee                                                stagger vs
                                                                  selected
                                                                  creatures

  Hunting    Quiet                 22    Projectile         1.3 s Requires
  Bow        ranged                                               arrows;
                                                                  projectile
                                                                  travel/drop

  Flare      Utility         5 direct    Projectile         3.0 s Illuminates
  Launcher   defence                                              and briefly
                                                                  disrupts
                                                                  selected
                                                                  creatures

  Signal     Utility,               0   Throw range       One use Marks
  Flare      not weapon                                           location and
                                                                  may attract
                                                                  attention
  -----------------------------------------------------------------------------

Do not add firearms by default.

**Field Knife:** starter weapon, short fast attacks, useful against weak
creatures; cannot harvest trees or ore.

**Wooden Spear:** crafted from wood and rope; longer reach; can
interrupt a basic Stalker attack if timed correctly; weak against
armoured/boss phases.

**Hatchet:** primary wood tool; chops approved trees and wooden
obstacles; moderate combat damage. Resource nodes use server-side
health/depletion, not arbitrary clicks.

**Keeper Blade:** rare story-linked weapon found/crafted after village
chapter; subtle effect near Keeper mechanisms; does not solve puzzles
automatically.

**Hunting Bow:** quiet ranged option; recover arrows only from valid
locations; server controls projectile and hit validation.

**Flare Launcher:** light and disruption tool; cannot permanently stun
bosses.

## 6.2 Combat feedback

Each hit needs clear sound, small impact effect, enemy reaction,
optional damage number (toggleable), and distinct hit/blocked/miss
feedback. Do not obscure the screen.

## 6.3 Tools

-   Hatchet: wood.
-   Pickaxe: stone, metal, crystals.
-   Knife: selected basic harvesting and defence.
-   Lantern: illumination.
-   Rope: crafting/traversal interactions.
-   Repair kit: selected structures.
-   Compass: direction.
-   Field journal: story records and discoveries.

Do not allow every tool to work on every object. Each resource node
defines its effective tool.

------------------------------------------------------------------------

# 7. CREATURES AND AI

Creatures should feel like part of the forest, not NPCs that simply run
directly at players.

## 7.1 The Watcher

Psychological threat and early mystery. A tall distant silhouette
appears between trees or on ridges. It selects observation points,
watches isolated explorers, disappears when approached/strongly
illuminated/observed too long, and may leave a clue or audio cue. It
does not have a normal health bar and does not attack directly. Never
spawn directly in front of the camera repeatedly.

## 7.2 The Stalker

Basic hostile creature with states: 1. Dormant/hidden. 2. Patrol. 3.
Investigate sound. 4. Detect player. 5. Chase. 6. Attack. 7. Search last
known position. 8. Retreat/return to patrol.

More dangerous to isolated players. Can be distracted by noise. Has
readable attack wind-up. Respects safe-zone boundary. Never teleports
beside players. Uses PathfindingService with bounded recalculation, not
every frame. Limit active NPC counts.

## 7.3 The Mimic

Creates fictional sound cues such as distant calls or footsteps and may
create a false silhouette. Lures players toward danger. Counterplay:
light, teamwork, noticing environmental inconsistencies, or later
detection tools. Never impersonate a real player, voice, moderation, or
Roblox system message.

## 7.4 Forest Guardian boss

The Guardian is a protector destabilized by the damaged ancient heart.

Phases: 1. **Awakening:** environment changes; arena activates. 2.
**Root Sweep:** telegraphed ground attack; dodge or use cover. 3.
**Guardian Pulse:** area effect with safe zones shown before impact. 4.
**Root Anchors:** players cooperate to activate/disable mechanisms. 5.
**Exposed Core:** short damage window. 6. **Recovery:** arena pattern
changes; repeat with added complexity. 7. **Resolution:** story outcome
and reward; not an endless damage sponge.

Boss scales for smaller groups and coordinated groups. All attacks are
telegraphed. No unavoidable one-shots or attacks that push players
outside the map. Server owns phases, damage and reward claims.

------------------------------------------------------------------------

# 8. RESOURCE NODES AND OBJECT BEHAVIOUR

Every visible interactive object must have a purpose, interaction,
state, feedback, reward/consequence and reset rule.

## 8.1 Resource nodes

**Tree** - Required tool: hatchet. - Interaction: timed chopping
sequence. - Feedback: wood chips, chopping sound, visible damage
stages. - Reward: wood. - Depletion: felled/stump state or cooldown. -
Reset: configured regrowth/respawn timer. - Falling tree must not cause
unpredictable physics damage.

**Stone deposit** - Tool: pickaxe. - Reward: stone and occasional metal
scrap. - Feedback: chips, cracks and mining sound. - Depletion: depleted
visual state; configured respawn.

**Herb patch** - Tool: none or knife depending on herb. - Short gather
action; reward herbs; harvested visual state; regrows after delay.

**Mushroom cluster** - No tool. Some edible, some crafting/quest
ingredients. Journal discovery distinguishes known types. Use fictional
game-world rules rather than implying real-world mushroom safety.

**Crystal cluster** - Tool: pickaxe. - Advanced areas; reward crystals;
glow flicker and crystal sound; dimmed/broken depleted state; long
cooldown or event respawn.

**Animal-material source** - Prefer naturally shed materials, nests or
abandoned remains. Avoid unnecessary graphic animal harm. Reward animal
materials.

## 8.2 Loot containers

Types: supply crate, abandoned backpack, Keeper cache, village cabinet,
rare sealed chest. Server determines loot. Every container has unique
identity and one-time/cooldown state. Prevent simultaneous duplicate
claims. Use short opening animation. Loot matches region and risk. Quest
items are protected from death loss.

## 8.3 Doors and mechanisms

-   **Normal door:** animated open/close, correct hinge and collision;
    no clipping through players.
-   **Locked door:** clearly displays required key/clue/condition;
    unlock state validated by server.
-   **Gate:** may require lever, power, quest item or multiple players;
    collision changes only when safely open.
-   **Lever:** server-owned on/off state with visual feedback; cannot
    bypass puzzles by spam.
-   **Pressure plate:** detects valid player/object weight server-side;
    no repeated physics-jitter activation.
-   **Beacon:** repair/activation changes light, sound, map discovery
    and selected world conditions; quest state saved as designed.

## 8.4 Environmental objects

-   **Lantern:** light, lit/extinguished/broken states as designed;
    selected creatures react to light; limit dynamic lights.
-   **Campfire:** heat, light, particles and audio; warms nearby
    players; optional wood fuel must never consume resources
    unexpectedly.
-   **Bridge:** stable collision and safe traversal; damaged bridge
    repaired explicitly; avoid fragile physics on critical routes.
-   **Rope:** approved attachment points only; consistent physics; no
    arbitrary exploitative constraints.
-   **Water:** clear surface/audio; defined swimming/crossing rules;
    deep-water boundary and recovery; no unexplained invisible lethal
    water.
-   **Cave entrance:** readable silhouette and natural rock framing;
    smooth lighting transition; not a plain black hole.
-   **Journal page:** opens readable text and adds clue after server
    validation; found/unread status; quest-critical pages protected.
-   **Collectible:** clear sound/effect, correct collection category,
    server validation and duplicate prevention.

## 8.5 Required object specification

For every interactable, document: 1. Object ID/display name. 2. Purpose.
3. Model and visual states. 4. Interaction prompt. 5. Required distance.
6. Required tool/item. 7. Hold duration/sequence. 8. Server validation.
9. State transitions. 10. Reward/consequence. 11. Cooldown/reset. 12.
Multiplayer ownership/claim rules. 13. Audio, particles, animation and
UI feedback. 14. Accessibility. 15. Performance considerations.

Do not make an object look interactive if it has no function.

------------------------------------------------------------------------

# 9. INVENTORY, CRAFTING AND STORAGE

## 9.1 Inventory

-   20 starting slots.
-   Stack limits: common resources 50; crafted consumables 10; rare
    quest items 1 (tune as needed).
-   Equipment slots: weapon, tool, lantern/utility, clothing.
-   Simple mobile hotbar.
-   Server owns inventory; shared item definitions can be replicated.
-   UI shows name, icon, quantity, description and use action.
-   Clear full-inventory feedback; never silently delete items.

## 9.2 Resources

Wood, stone, herbs, food, cloth, metal scrap, rope, animal materials,
crystals, ancient fragments, rare minerals and water.

Each item definition includes unique ID, display name, icon, stack
limit, description, rarity, allowed uses, trade value if any, death-loss
eligibility and quest-protection status.

## 9.3 Recipes

  -----------------------------------------------------------------------
  Crafted item            Ingredients             Purpose
  ----------------------- ----------------------- -----------------------
  Torch                   2 Wood + 1 Cloth        Basic portable light

  Healing Potion          2 Herbs + 1 Water       Restore health

  Wooden Barricade        5 Wood                  Temporary defence

  Basic Trap              3 Wood + 2 Rope         Slow/restrain basic
                                                  creature briefly

  Advanced Lantern        2 Crystals + 3 Metal    Strong light and
                          Scrap                   selected detection
                                                  utility

  Warm Clothing           3 Cloth + 2 Animal      Reduce warmth loss
                          Materials               

  Basic Tool              2 Wood + 2 Stone        Starter utility tool
  -----------------------------------------------------------------------

Crafting is server-validated. Remove ingredients only after a valid
successful craft. Add output only if capacity exists or the UI offers a
safe output destination. Prevent double-submit. Show ingredient counts
and missing ingredients. Keep basic survival crafting accessible.

## 9.4 Storage

Safe Haven storage is shared only within the current server session in
v1.0 unless persistent shared storage is deliberately implemented later.
Label this clearly. Validate every deposit/withdrawal. Prevent
simultaneous withdrawals from duplicating items. Never imply session
storage is permanently saved.

------------------------------------------------------------------------

# 10. DOWNED STATE, REVIVE AND DEATH

When health reaches zero: 1. Enter downed state instead of immediate
death. 2. Restrict movement to slow crawl or disabled movement,
consistently. 3. Start a 30-second timer. 4. Nearby teammates receive a
revive prompt. 5. Revive takes about 4 seconds. 6. Cancel if rescuer
moves too far, is interrupted or target is no longer downed. 7.
Successful revive restores a small amount of health and brief recovery
protection. 8. If timer expires, respawn at Safe Haven or an unlocked
checkpoint.

Show timer and rescuer clearly.

**Death penalty:** target loss of 20% of eligible carried resource
value. Keep XP, levels, permanent unlocks, achievements, paid cosmetics
and protected quest items. Do not remove permanent rewards. Apply
penalty exactly once using a unique death/transaction ID. Show a loss
summary. Avoid loss due to server crash. Define a consistent
disconnect-while-downed rule that cannot duplicate items.

Respawn restores defined health and enough stamina to move.
Warmth/sanity may remain partially affected if appropriate. Give a short
spawn protection window against creatures. PvP remains disabled.

------------------------------------------------------------------------

# 11. DAY/NIGHT, WEATHER AND WORLD EVENTS

## 11.1 Twenty-minute day/night cycle

  Phase         Duration Gameplay
  ----------- ---------- -------------------------------
  Morning          3 min Calm exploration and recovery
  Afternoon        5 min Best exploration window
  Sunset           2 min Warning and preparation
  Night            7 min Greater danger and mystery
  Dawn             3 min Threats retreat; recovery

Server controls world phase and synchronized time; clients must not run
independent clocks.

Morning: gentle light and low creature activity. Afternoon: clear
visibility, exploration and selected rare clues. Sunset: warmer/darker
lighting, ambience changes and preparation warning. Night: more danger,
fog and supernatural events; lanterns/teamwork matter, but do not make
the screen pitch black. Dawn: threats retreat/change behaviour; players
return to camp and review discoveries.

## 11.2 Weather

Introduce light rain, heavy rain, ground fog, wind and rare supernatural
fog surge. Rain changes audio and visibility; cold rain increases warmth
loss in exposed regions; fog reduces long-range visibility without
making navigation impossible; wind affects foliage, particles, flags and
ambience. Weather is server-synchronized.

## 11.3 World events

-   **Strange Signal:** signal appears at a discoverable location.
-   **Crystal Bloom:** selected crystal nodes temporarily activate.
-   **Fog Surge:** fog spreads through a region and changes creature
    behaviour.
-   **Abandoned Caravan:** temporary loot/story location.
-   **Creature Migration:** creatures move between regions.
-   **Ancient Awakening:** rare event hints at the ancient heart.

Events have warning, start, active and end states. UI communicates
objective and time. Rewards are granted once per eligible player. Do not
spawn events directly on players, break main quests or block the only
route.

------------------------------------------------------------------------

# 12. QUESTS AND PROGRESSION

Quest types: main story, region exploration, gathering/crafting,
cooperative objectives, optional rotating tasks and hidden discoveries.
Objectives must be measurable: find named location, gather a quantity,
repair beacon, activate mechanism, recover Keeper record, survive event,
defeat/escape creature.

XP comes from exploration, quests, discoveries, crafting milestones and
meaningful cooperation---not idle repetition. XP and levels persist.
Level unlocks recipes, cosmetic titles, journal categories or utility
options, not pay-to-win power.

Currencies: - **Forest Coins:** common; quests, exploration and approved
activities; basic supplies and selected cosmetics. - **Ancient Tokens:**
rare; major discoveries, events and story milestones; primarily
cosmetics and special non-pay-to-win collectibles.

All currency changes are server-authoritative and transaction-safe.

Track regions, landmarks, Keeper records, creatures observed, events,
recipes, boss milestones, cooperative revives and exploration
challenges. Provide a journal/collection UI.

------------------------------------------------------------------------

# 13. UI, ACCESSIBILITY AND AUDIO

## 13.1 Visual UI

Clean, modern and atmospheric. Palette: deep forest greens, muted
charcoal, warm campfire amber, pale parchment and restrained
supernatural cyan. Avoid excessive neon, oversized panels and unreadable
text. Responsive for mobile, desktop and gamepad.

HUD: health, stamina, warmth, sanity, world phase/time-to-next-phase,
equipped item/hotbar, current objective, contextual interaction prompt
and party status. Keep compact.

Required screens: loading/main menu, HUD, inventory, crafting, storage,
world map, journal, quest log, party panel, trader, settings,
downed/revive/death, event announcement, boss status and
achievements/collections.

Accessibility: text scaling where practical, colour not sole signal,
subtitles for important audio, separate ambience/effects/music volume,
reduced camera shake, reduced screen distortion, no rapid flashing,
clear prompts and usable mobile touch targets.

## 13.2 Audio

Categories: forest ambience, wind/leaves, water, birds/insects,
campfire, surface footsteps, gathering/crafting, creature sounds,
distant clues, UI feedback, music and event stingers. Use
original/licensed/Roblox-approved assets only. Spatialize world audio
where appropriate. Avoid constant loud horror audio, sound spam and
excessive replicated emitters. Important cues need visual/subtitle
alternatives.

------------------------------------------------------------------------

# 14. MULTIPLAYER RULES

-   Maximum 12 players.
-   Party members can see status and approximate location when
    appropriate.
-   Revive and some ancient mechanisms encourage cooperation.
-   Shared objectives credit all eligible participants.
-   Personal loot cannot be duplicated through simultaneous interaction.
-   PvP damage disabled.
-   No inventory theft or griefing.
-   No destruction of another player's permanent progress.
-   Session storage scope is clearly explained.
-   Solo players can still progress where practical, with adjusted
    difficulty or alternate mechanisms.

------------------------------------------------------------------------

# 15. DATA, SECURITY AND TECHNICAL ARCHITECTURE

## 15.1 Persistent data

Persist intentionally permanent data: XP/level, permanent unlocks,
currencies, achievements, discovered story records, quest progress,
unlocked regions/checkpoints, cosmetics and selected loadout if
appropriate. Do not persist session-only shared storage unless
specifically designed.

Use DataStoreService with protected calls, retries, rate limits,
autosave, player-exit saving and shutdown handling. Avoid saving every
frame. Use versioned schemas and migration logic. Never overwrite valid
data with defaults because a read failed.

## 15.2 Security

Server owns health, damage, inventory, item definitions, crafting,
rewards, XP, currency, quests, revive, death penalties and persistence.
Client sends requests, not outcomes. Validate remote types, lengths,
ranges, distance, cooldown, state, ownership and target. Rate-limit
remotes. Never accept client reward amounts, damage, prices or item
definitions. No hidden admin backdoors or arbitrary remote code
execution. Do not import untrusted models containing scripts. Keep
credentials out of project/repository.

## 15.3 Suggested project structure

Adapt names to the current project if its architecture is already sound;
avoid duplicate systems.

``` text
ReplicatedStorage
  Shared
    Config
      GameConfig
      ItemDefinitions
      RecipeDefinitions
      WeaponDefinitions
      CreatureDefinitions
      RegionDefinitions
      QuestDefinitions
    Types
    Utilities
  Remotes

ServerScriptService
  Server
    Bootstrap
    Services
      PlayerDataService
      PlayerStateService
      InventoryService
      CraftingService
      CombatService
      CreatureService
      WorldCycleService
      WeatherService
      WorldEventService
      QuestService
      ProgressionService
      InteractionService
      ReviveService
      PartyService
      PersistenceService

StarterPlayer
  StarterPlayerScripts
    Client
      Controllers
        InputController
        HUDController
        InventoryController
        MapController
        InteractionController
        AudioController
        EffectsController

StarterGui
  UI

Workspace
  World
    SafeHaven
    WhisperingWoods
    AbandonedVillage
    CrystalCaverns
    AncientGrounds
    ResourceNodes
    Interactables
    CreatureSpawns
    EventLocations
```

Use one clear bootstrap, modular Luau services, centralized config, no
circular dependencies, server-owned state and client-owned
presentation/input. Use CollectionService tags or a consistent registry
for interactables. Attributes can hold stable metadata. Do not rely on
names alone for security-sensitive logic. Use typed Luau where
practical.

## 15.4 Performance

Use StreamingEnabled appropriately for a large world. Anchor static
geometry, use simple collision, avoid excessive dynamic
lights/transparency/particles, use sensible mesh complexity and region
organization, limit active creatures/events, avoid expensive server
loops, do not pathfind every frame, and profile with MicroProfiler. Test
mobile/low-end performance. Use collision groups sensibly. A rich world
must not require millions of tiny Parts.

## 15.5 Art direction

Terrain: rolling hills, valleys, rock formations, streams, ponds, mud
paths, mossy clearings, cliffs, ridges and caves. Avoid flat green
ground, repeated tree rows, terrain seams, floating props, unnatural
intersections and empty filler areas.

Vegetation: varied tree silhouettes/heights/canopies, ferns, bushes,
mushrooms, roots, fallen logs, grass and rare glowing plants. Cluster
and compose naturally; do not scatter uniformly.

Lighting: consistent time-of-day system, restrained atmosphere/colour
correction, readable night visibility, warm Safe Haven lights and cooler
restrained supernatural regions. Avoid excessive bloom/blur.

Landmark silhouettes must be recognizable: Safe Haven beacon, Split Oak,
village clock tower, Crystal Cavern entrance and ancient root/tree
structure.

------------------------------------------------------------------------

# 16. ANTIGRAVITY: REQUIRED EXISTING-PROJECT UPGRADE PROCESS

This is mandatory. Do not start by blindly generating more scripts.

## Step 1 --- Audit current project

Inspect the current Roblox Studio place, scripts, models, terrain
dimensions, map layout, routes, UI, remotes, player systems,
persistence, errors/warnings and available Studio MCP actions.

Create `CURRENT_PROJECT_AUDIT.md` with: - What works. - What is
incomplete. - What is broken. - What is missing. - Measured map
dimensions and actual travel times. - Existing architecture. -
Risks/dependencies. - Mapping from existing implementation to this
specification.

Do not claim a feature exists unless inspected.

## Step 2 --- Gap analysis

Create `SPEC_GAP_ANALYSIS.md`. For every section use: - PASS:
implemented and verified. - PARTIAL: exists but does not meet spec. -
FAIL: broken/materially incorrect. - MISSING: not implemented. -
BLOCKED: real dependency or permission prevents work.

Include evidence and priority.

## Step 3 --- Upgrade plan

Create `UPGRADE_PLAN.md` with small reversible tasks. Each task includes
current state, desired state, affected scripts/models, dependencies,
steps, test plan, acceptance criteria, risks and rollback.

Do not rewrite working systems solely to match a preferred folder
structure.

## Step 4 --- Fix the map first

The short map is the most visible failure. Measure current playable
footprint, then expand into a continuous valley. Establish Safe Haven,
Whispering Woods and Abandoned Village as complete connected regions.
Lay out routes, landmarks, POIs, shortcuts and boundaries before
decorative filling. Add terrain, verticality, resource locations and
environmental story clues. Test travel times in Play mode.

If all five regions cannot be completed immediately, deliver a complete,
high-quality v1.0 route through Safe Haven, Whispering Woods and
Abandoned Village, while reserving believable space and sightlines for
Crystal Caverns and Ancient Grounds. Do not fake unfinished regions with
inaccessible empty land.

## Step 5 --- Implement in dependency order

1.  Architecture/config audit.
2.  Map and world structure.
3.  Movement and interaction framework.
4.  Health, stamina, warmth and sanity.
5.  Day/night and weather.
6.  Resource gathering and object states.
7.  Inventory and crafting.
8.  Weapons and combat.
9.  Creature AI.
10. Downed/revive/death.
11. Quests, story, XP and currencies.
12. Persistence.
13. UI/audio polish.
14. Multiplayer/performance QA.

## Step 6 --- Test each feature

Test in Studio Play mode, multiple clients where possible, server/client
output, invalid interactions, edge cases and mobile layouts. Record
evidence and fix regressions before continuing. Code being written is
not proof of functionality.

## Step 7 --- Maintain project documentation

Keep and update: - `CURRENT_PROJECT_AUDIT.md` - `SPEC_GAP_ANALYSIS.md` -
`UPGRADE_PLAN.md` - `IMPLEMENTATION_LOG.md` - `TEST_REPORT.md` -
`KNOWN_ISSUES.md`

## Step 8 --- Autonomous but safe operation

Continue all safe, unblocked tasks without requiring a new prompt after
every phase. If a tool is unavailable, explain exactly what is blocked
and continue unrelated work. Ask the user only when a decision or
permission is genuinely required.

Do not publish, spend Robux, purchase assets, change account/privacy
settings, delete the current project or overwrite important files
without backup and a clear reason. Use only licensed assets. Do not
claim multiplayer tests unless multiple clients were actually run. Do
not claim the map is large without measuring dimensions and travel
times.

------------------------------------------------------------------------

# 17. ACCEPTANCE CRITERIA

The game is not complete merely because it opens without errors.

**World** - World is visibly and measurably larger than the current
short map. - Safe Haven, Whispering Woods and Abandoned Village are
continuous and navigable. - Main route to a distant objective takes
roughly 8--12 minutes at normal exploration pace, subject to playtest. -
Regions have distinct visual identities, landmarks, POIs, secrets and no
large empty filler areas. - Terrain boundaries feel natural and
navigation works.

**Player systems** - Health, stamina, warmth and sanity work and
replicate correctly. - Sprint drain/regen works. - Warmth responds to
environment and heat. - Sanity remains atmospheric and accessible. - HUD
is readable and responsive.

**Objects and inventory** - Every visible interactive object has a clear
function. - Nodes have correct tools, rewards, states and reset. -
Inventory/crafting are server-authoritative. - Loot cannot be duplicated
through simultaneous interactions. - Session storage is labelled
accurately.

**Combat** - Weapons have distinct roles. - AI has readable states and
counterplay. - Creatures do not teleport or attack through walls. -
Watcher, Stalker and Mimic feel different. - Boss attacks are
telegraphed and cooperative. - PvP is disabled.

**Story/progression** - Opening introduces the world without lore
dumping. - Clues and journal records are discoverable. - Main objectives
are clear. - XP and permanent progression save correctly. - Death
penalty is applied once and explained.

**Technical** - No critical errors in tested flows. - No known
item/currency duplication exploit in tested flows. - Saving handles
failures safely. - Large-world streaming/performance tested. - Mobile UI
usable. - Test claims are backed by actual tests.

------------------------------------------------------------------------

# 18. FINAL CREATIVE RULE

When making a choice not explicitly specified, ask: 1. Does this make
the forest feel more alive? 2. Does it create a meaningful reason to
explore? 3. Does it support the story or survival loop? 4. Is it
understandable to a new player? 5. Is there fair counterplay? 6. Does it
work in multiplayer? 7. Can it run well on mobile? 8. Does it preserve
the mysterious adventure identity?

**The most important principle:** Build a world players want to get lost
in, with enough meaningful discoveries that they want to keep exploring.
The Forgotten Forest must feel like a real place with history, danger,
secrets and a reason to return---not a short map with survival mechanics
attached.
