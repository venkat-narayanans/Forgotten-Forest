# SURVIVAL, GATHERING, INVENTORY AND CRAFTING SPECIFICATION

## 1. Initial configuration

Keep all values in configuration modules:
- MaxHealth = 100
- MaxStamina = 100
- MaxWarmth = 100
- MaxSanity = 100
- InventorySlots = 20
- InteractionRange = 10 studs
- ReviveDuration = 4 seconds
- DownedDuration = 30 seconds
- DeathResourceLossPercent = 20

These are initial test values, not final balance.

## 2. Resource definitions

Every item definition should include:
- ItemId (stable string identifier)
- DisplayName
- Description
- Category
- Rarity
- StackLimit
- IsQuestProtected
- IsTradeable (false in first release)
- Icon asset reference (optional)
- World model reference (optional)
- Weight only if a weight system is later approved

Initial resources:
- `wood`
- `stone`
- `herb`
- `food`
- `cloth`
- `metal_scrap`
- `rope`
- `animal_material`
- `crystal`
- `ancient_fragment`
- `rare_mineral`
- `water`

Do not use display names as internal IDs.

## 3. Resource node behavior

Each node has:
- stable node identifier;
- item ID;
- remaining yield or health;
- gather duration;
- required tool (optional);
- respawn duration;
- region;
- rarity;
- interaction state.

Gathering flow:
1. Client requests gather by node ID.
2. Server resolves node from its registry.
3. Server validates player alive/not downed.
4. Server validates distance and required tool.
5. Server checks node availability and cooldown.
6. Server reserves/consumes node yield.
7. Server grants item through InventoryService.
8. Server sends success/failure result.
9. Client updates UI from authoritative inventory snapshot.

Prevent two players from receiving the same final node yield. Use server-side locking/state transition.

## 4. Initial gathering defaults

- Common resource node: 2–4 items per successful gather.
- Uncommon node: 1–2 items.
- Rare node: 1 item.
- Gather duration: 1.5–3 seconds depending on node.
- Common respawn: 3–5 minutes.
- Uncommon respawn: 6–10 minutes.
- Rare respawn: 10–15 minutes or event-based.

Use randomized ranges only on the server and keep results bounded.

## 5. Inventory rules

- 20 initial slots.
- Stack limits defined per item.
- Equipment slots separate from backpack.
- Server owns inventory truth.
- Client receives snapshots/deltas.
- Validate all add/remove operations.
- Use transaction-like operations for crafting and storage.
- Never let the client choose quantity beyond available capacity/materials.
- Show clear “inventory full” feedback.
- Do not silently discard items.

## 6. Crafting

Each recipe:
- RecipeId;
- output item and amount;
- ingredient map;
- station requirement;
- craft duration;
- unlock requirement;
- optional region requirement.

Initial recipe defaults:
- Torch: 2 wood + 1 cloth.
- Healing Potion: 2 herbs + 1 water.
- Wooden Barricade: 5 wood.
- Basic Trap: 3 wood + 2 rope.
- Advanced Lantern: 2 crystal + 3 metal_scrap.
- Warm Clothing: 3 cloth + 2 animal_material.
- Basic Tool: 2 wood + 2 stone.

These costs are initial. Validate that resource availability is realistic.

Craft flow:
1. Client selects recipe and quantity.
2. Server validates player state, recipe, station and unlock.
3. Server checks materials and output capacity.
4. Server removes ingredients and grants output atomically.
5. If any step fails, no partial transaction should remain.
6. Server informs client of result.

## 7. Shared storage

- Safe Haven storage is shared by the current server instance.
- Server validates every deposit/withdrawal.
- Use a transaction lock to prevent duplicate withdrawal.
- Display that storage is shared with current server players.
- Do not persist the shared storage globally in version 1.0 unless explicitly designed and protected.
- If shared storage resets when the server closes, communicate this clearly.

## 8. Death resource loss

- Only eligible carried resources are considered.
- Permanent progression and protected quest items are excluded.
- Apply 20% of eligible carried resource value, with deterministic stack rounding.
- Show the exact loss summary.
- Do not lose items twice if death/respawn events fire more than once.
- Make death handling idempotent.

## 9. UI states

Inventory UI must support:
- empty slot;
- occupied slot;
- selected item;
- item details;
- stack quantity;
- full inventory;
- loading state;
- server request pending;
- failed action.

Crafting UI must show:
- recipe;
- required station;
- required ingredients;
- available/required quantities;
- output;
- craft time;
- locked/unlocked status;
- failure reason.

## 10. Acceptance tests

- Two players gathering one remaining node cannot both receive the same final yield.
- Invalid item IDs are rejected.
- Negative or enormous quantities are rejected.
- Crafting with insufficient materials fails without consuming items.
- Full inventory does not delete crafted output.
- Death penalty excludes protected items.
- Duplicate death requests do not apply the penalty twice.
- Storage cannot be withdrawn below zero.
