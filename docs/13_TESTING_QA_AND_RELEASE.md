# TESTING, QA AND RELEASE PLAN

## 1. Test layers

### Static/code checks
- syntax and Luau analysis where available;
- require/module loading;
- configuration validation;
- no circular dependencies;
- no accidental client-only/server-only references.

### Unit-style tests
Test pure functions and service logic:
- XP curve;
- inventory capacity;
- stack math;
- death loss calculation;
- recipe validation;
- quest reward idempotency;
- event eligibility.

### Studio integration tests
- player spawn;
- interaction;
- gathering;
- crafting;
- enemy detection;
- damage;
- revive;
- phase transitions;
- UI updates.

### Multiplayer tests
Use Roblox Studio's multi-client test tools or published private test server as appropriate:
- two players gathering one node;
- shared storage concurrency;
- revive across clients;
- boss participation rewards;
- player join during night;
- player leave during save;
- server shutdown.

### Device tests
- desktop keyboard/mouse;
- mobile touch;
- gamepad where practical;
- low/mid-range device performance.

## 2. Critical test scenarios

1. New player joins and receives a valid profile.
2. Returning player loads previous progression.
3. DataStore unavailable: existing profile is not overwritten.
4. Player gathers a resource node.
5. Two players contest the final node yield.
6. Player crafts with sufficient materials.
7. Player crafts with insufficient materials.
8. Inventory is full.
9. Client sends invalid item ID.
10. Client spams gather remote.
11. Stalker attacks and player takes server-calculated damage.
12. Player is downed and revived.
13. Player dies and loses only eligible resources.
14. Player rejoins and retains permanent progression.
15. Player joins midway through night.
16. Event expires and cleans up.
17. Boss is defeated and rewards are granted once.
18. Server closes and attempts bounded saves.

## 3. Severity

- P0 Critical: data loss, exploit enabling currency/item duplication, remote code execution, game cannot start.
- P1 High: core loop broken, multiplayer desync, progression not saved, major softlock.
- P2 Medium: feature works with workaround, UI or balancing issue.
- P3 Low: cosmetic issue, minor audio or alignment defect.

Do not proceed to release with open P0/P1 issues.

## 4. Performance checks

Record:
- server frame time;
- client FPS;
- memory usage;
- active NPC count;
- pathfinding activity;
- remote event frequency;
- part/mesh count;
- streaming behavior.

Do not invent results. Capture actual Studio profiling observations.

## 5. Release preparation

Before public release:
- confirm owner approval;
- verify experience title, description and icon;
- verify Roblox content moderation status;
- verify permissions and asset ownership;
- test privacy and age-appropriate settings;
- test purchase flows only if approved;
- create a known-issues list;
- create rollback/checkpoint;
- verify DataStore experience configuration;
- run a private test;
- publish only after explicit approval.

## 6. Launch readiness report

Include:
- build/version identifier;
- phase status;
- core features implemented;
- multiplayer tests completed;
- persistence tests completed;
- performance measurements;
- unresolved bugs;
- asset/licensing status;
- release blockers;
- owner approvals still required.

A generated game is not automatically a tested game. A Studio single-player test is not proof of 8–12 player readiness.
