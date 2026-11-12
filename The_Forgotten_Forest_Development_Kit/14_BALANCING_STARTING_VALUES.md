# BALANCING CONFIGURATION — STARTING VALUES

These are initial hypotheses for playtesting, not final promises. Store all values in configuration modules so they can be tuned without rewriting gameplay logic.

## Player
| Setting | Initial value |
|---|---:|
| Max health | 100 |
| Max stamina | 100 |
| Max warmth | 100 |
| Max sanity | 100 |
| Walk speed | 16 |
| Sprint speed | 22 |
| Sprint drain | 12/sec |
| Stamina regen | 18/sec |
| Regen delay | 1 sec |
| Inventory slots | 20 |
| Interaction range | 10 studs |

## Cycle
| Phase | Duration |
|---|---:|
| Morning | 180 sec |
| Afternoon | 300 sec |
| Sunset | 120 sec |
| Night | 420 sec |
| Dawn | 180 sec |

## Death/revive
| Setting | Initial value |
|---|---:|
| Downed duration | 30 sec |
| Revive duration | 4 sec |
| Revive health | 35 |
| Resource loss | 20% eligible carried value |

## Stalker
| Setting | Initial value |
|---|---:|
| Health | 100 |
| Detection radius | 45 studs |
| Attack range | 4 studs |
| Damage | 12 |
| Attack cooldown | 2.2 sec |
| Chase speed | 14 |
| Leash range | 90 studs |

## Resource gathering
| Rarity | Yield | Gather time | Respawn |
|---|---:|---:|---:|
| Common | 2–4 | 1.5–2 sec | 3–5 min |
| Uncommon | 1–2 | 2–2.5 sec | 6–10 min |
| Rare | 1 | 2.5–3 sec | 10–15 min/event |

## Multiplayer and AI
| Setting | Initial value |
|---|---:|
| Max players | 12 |
| Target minimum | 8 |
| Standard hostile NPC cap | 8–12 |
| Boss encounters | 1 per arena |
| Major simultaneous events | 1 |

## Tuning rules
- Do not change many variables at once.
- Record test conditions and player count.
- Tune for a group, not only solo play.
- Ensure solo players can still make reasonable progress where possible.
- Avoid making a single optimal strategy mandatory.
- Keep reward curves fair across exploration, support and combat.
