# ASSET REGISTER — THE FORGOTTEN FOREST

**Target Reference:** `The_Forgotten_Forest_Complete_Experience_Bible.md` (Section 14 & 16)  
**Release:** v2.2.0-experience-bible  
**Art Style:** Stylized Low-Poly Roblox Environment with Modern Atmospheric Lighting  
**Anchoring Guarantee:** 100% Anchored Geometry, CanCollide and Collision Groups optimized  

---

## 1. Environment & Flora Families

| Asset ID | Category | Style & Description | Source | Scripts / Safety Check | Performance & Physics |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Tree_StraightPine_Tall` | Flora / Tree | Tall straight pine (42 studs) with tiered conical foliage and timber trunk. | Procedural Luau Sculpt | Clean (No untrusted scripts) | Single Mesh/Union or grouped anchored parts; Box collision. |
| `Tree_AncientOak_Wide` | Flora / Tree | Broad canopy oak (32 studs tall, 26 studs spread) with gnarled roots and leaf clusters. | Procedural Luau Sculpt | Clean | Grouped anchored parts; CanCollide on trunk, false on leaf clusters. |
| `Tree_SplitOak_Landmark` | Flora / Landmark | Lightning-split ancient oak (46 studs); one side charred/dead, one side living with glowing roots. | Procedural Luau Sculpt | Clean; includes hidden `StoryClue` & ProximityPrompt | Tagged landmark; unique mesh silhouette. |
| `Tree_TwistedSupernatural` | Flora / Tree | Curving dark pine leaning toward paths with subtle cyan bioluminescent moss. | Procedural Luau Sculpt | Clean | Anchored; low part count. |
| `Prop_HollowLog` | Flora / Traversable | Large hollow fallen timber log (28 studs length) player can crouch or walk through. | Procedural Luau Sculpt | Clean | Hull collision; safe crossing over ravine. |
| `Foliage_GrassClump` | Flora / Detail | 3-blade stylized grass cluster with vertex tilt. | Procedural Luau Sculpt | Clean | Non-collidable (`CanCollide = false`). |
| `Foliage_ForestFern` | Flora / Detail | Multi-frond forest fern with soft forest green hue. | Procedural Luau Sculpt | Clean | Non-collidable (`CanCollide = false`). |
| `Node_SoothingHerbs` | Resource Node | Herb patch with flowering purple tips and green foliage. | Procedural Luau Sculpt | ProximityPrompt with server interaction | Tagged `TFF_ResourceNode`; respawn timer. |
| `Node_ForestMushrooms` | Detail / Forage | Cluster of 3 low-poly forest mushrooms with dotted caps. | Procedural Luau Sculpt | Clean | Non-collidable. |
| `Node_CrystalMushrooms` | Detail / Cavern | Subterranean glowing cyan mushrooms emitting soft light (`Range = 8`). | Procedural Luau Sculpt | Clean | Non-collidable; PointLight attached. |

---

## 2. Architecture & Interactive Landmarks

| Asset ID | Category | Style & Description | Source | Scripts / Safety Check | Performance & Physics |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `SafeHaven_CentralBeacon` | Landmark / Interactive | Carved stone foundation, iron brackets, dark crystal core, and amber flame cage. | Procedural Luau Sculpt | Multi-state `ProximityPrompt` (`BeaconService`) | Anchored; switches between Damaged/Active states. |
| `SafeHaven_Watchtower` | Architecture | 30-stud timber lookout tower with climbable steps, viewing deck, and canopy. | Procedural Luau Sculpt | Clean | Anchored; stable stepped ascent. |
| `Prop_BrassTelescope` | Interactive Prop | Mounted brass telescope on watchtower deck looking toward valley landmarks. | Procedural Luau Sculpt | ProximityPrompt triggering client camera zoom | Non-collidable interactive tool. |
| `SafeHaven_ArtisanWorkshop` | Architecture / Prop | Heavy iron blacksmith anvil, quenching trough, and timber tool racks. | Procedural Luau Sculpt | Clean | Box collision on anvil; non-collidable props. |
| `SafeHaven_TraderStall` | Architecture / Prop | Timber market stall with display shelves, ledger book, and earthenware jars. | Procedural Luau Sculpt | Clean | Anchored pavilion. |
| `Bridge_Ravine_Timber` | Architecture / Shortcut | 40-stud wooden trestle bridge across the creek ravine with rope guide rails. | Procedural Luau Sculpt | Repair prompt via `WorldInteractionService` | Anchored; non-slip walkable deck. |
| `Shrine_KeeperTriPillar` | Landmark / Lore | Circular stone dais with 3 triangular rune pillars and glowing central glyph. | Procedural Luau Sculpt | ProximityPrompt for lore memory | Anchored stone geometry. |
| `Village_ClockTower_48` | Architecture / Landmark | 48-stud stone tower, pitched shingle roof, belfry, and stopped clock face. | Procedural Luau Sculpt | Gear inspection prompt (`ClockTowerService`) | Box collision; visible from Lookout Rock. |
| `Village_KeeperArchive` | Architecture / Puzzle | Heavy stone archive portal, carved lintel, iron gate, and Three Puzzle Lanterns. | Procedural Luau Sculpt | Three Lantern sequence validator | Dynamic hinge/transparency on unlock. |
| `Village_DryFountain` | Landmark / Square | Hexagonal dry stone fountain basin with central 5-Seal engraved emblem. | Procedural Luau Sculpt | Clean | Anchored; low part count. |
| `Village_SecretWell` | Landmark / Passage | Stone well rim with wooden windlass; hidden descending ladder into undercroft. | Procedural Luau Sculpt | ProximityPrompt / ladder climb | Navigable undercroft chamber. |

---

## 3. Weapons, Tools & Equipment Assets

| Asset ID | Category | Visual Specification | Source | Authority |
| :--- | :--- | :--- | :--- | :--- |
| `field_knife` | Weapon / Tool | Compact steel blade, dark wrapped handle, leather crossguard. | Procedural Model Template | Server-authoritative combat & light harvest |
| `wooden_spear` | Weapon | Carved ash shaft, copper wire bound grip, fire-hardened leaf tip. | Procedural Model Template | Server-authoritative reach & stagger |
| `hatchet` | Weapon / Tool | Forged steel axehead, polished hickory curved handle. | Procedural Model Template | Server-authoritative tree harvesting |
| `keeper_blade` | Story Weapon | Runic inscribed ancient broadsword with subtle cyan edge glow. | Procedural Model Template | Server-authoritative boss stagger |
| `hunting_bow` | Ranged Weapon | Recurve timber bow with braided linen string; leather quiver. | Procedural Model Template | Server projectile physics & arrow recovery |
| `flare_launcher` | Utility / Ranged | Brass nautical flare gun with knurled grip and amber muzzle. | Procedural Model Template | Server disruption & illumination |
| `pickaxe` | Tool / Weapon | Double-pointed cast iron pick on reinforced oak haft. | Procedural Model Template | Server stone & crystal mining |
| `advanced_lantern` | Tool / Deployable | Hexagonal crystal-shielded brass lantern with brilliant cyan glow. | Procedural Model Template | Client dynamic lighting & sanity protection |
| `wooden_barricade` | Deployable Defense | Reinforced criss-cross timber stakes bound with hemp rope. | Procedural Model Template | Server obstacle collision & creature block |
| `basic_trap` | Deployable Trap | Concealed wooden spring-loaded snare with ground pegging. | Procedural Model Template | Server proximity trigger & creature root |

---

## 4. NPC & Creature Character Models

| Character ID | Type | Rig & Presentation | Source | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `NPC_cartographer` (Alden) | Friendly NPC | R15 Low-Poly Humanoid, navy explorer coat, fedora, glasses, map desk. | Custom Procedural Sculpt | Basecamp dialogue & survey map updates |
| `NPC_medic` (Mara) | Friendly NPC | R15 Low-Poly Humanoid, white tunic, red cross armband, beret, potion table. | Custom Procedural Sculpt | Basecamp healing guidance & warmth recovery |
| `NPC_old_keeper` | Friendly NPC | R15 Low-Poly Humanoid, midnight cowl, silver beard, runic talisman, gem staff. | Custom Procedural Sculpt | Village lore & Ancient Seal guidance |
| `Creature_Watcher` | Supernatural Entity | Tall slender silhouette (11 studs), dark shadow mesh, twin glowing white dot eyes. | Custom Procedural Sculpt | Vanishes when approached or directly lit |
| `Creature_Stalker` | Hostile Beast | Lean quadrupedal/bipedal forest predator with angular chitin and clawed limbs. | Custom Procedural Sculpt | Pathfinding AI, sound investigation, telegraphed attack |
| `Creature_Mimic` | Decoy Entity | Distorted decoy silhouette with mismatched proportions and eerie stillness. | Custom Procedural Sculpt | False calls, sound lures, retreating trail traps |
| `Boss_ForestGuardian` | Titan Boss | 28-stud colossal root-and-stone titan with embedded Keeper masonry & crystal core. | Custom Procedural Sculpt | Multi-phase combat encounter in Ancient Grounds |

---

## 5. Asset Safety & Performance Compliance

1. **Zero External Free Models:** All assets are generated 100% procedurally via deterministic Luau scripts authored within the project repository.
2. **Script Cleanliness:** No foreign scripts, hidden backdoors, or unvetted remotes exist in any model hierarchy.
3. **Collision & Streaming:** Non-interactive decorative foliage elements have `CanCollide = false` and `CanTouch = false` to eliminate physics engine overhead. Large structures utilize box colliders and are fully compatible with `StreamingEnabled`.
