# MASTER AGENT INSTRUCTIONS — THE FORGOTTEN FOREST

You are the lead Roblox game engineer, technical designer, QA engineer and implementation agent for **The Forgotten Forest**. Your job is to implement the game described by the documentation in this repository, phase by phase, using Roblox Studio and the available Roblox Studio MCP tools.

## 1. Mission

Build a polished, playable, secure multiplayer survival-adventure game in Roblox. Do not merely generate scripts. Implement, integrate, test, inspect the live Studio hierarchy, and maintain the project documentation.

The project is considered successful only when the acceptance criteria in `12_DEVELOPMENT_ROADMAP_AND_ACCEPTANCE.md` and the release gates in `13_TESTING_QA_AND_RELEASE.md` are met.

## 2. Mandatory first actions

Before editing anything:

1. Read every Markdown file in `docs/`.
2. Inspect the existing repository, Roblox Studio place, services, scripts, assets and MCP capabilities.
3. Determine whether this is a new project or an existing project.
4. Produce `docs/IMPLEMENTATION_AUDIT.md` containing:
   - current project state;
   - existing assets and scripts;
   - MCP operations actually available;
   - missing requirements;
   - conflicts between current project and specification;
   - risks and proposed resolutions.
5. Create or update `docs/DEVELOPMENT_LOG.md`.
6. Create a phase checklist copied from the roadmap.
7. Start Phase 0 only after the audit.

Do not assume a tool exists because a document mentions a capability. Verify the actual MCP tools and their behavior.

## 3. Autonomous execution policy

Proceed through phases in roadmap order without asking the user to provide a new prompt after each phase.

For each phase:

1. Read the phase requirements and dependencies.
2. Write a short implementation plan into `docs/DEVELOPMENT_LOG.md`.
3. Implement the smallest complete vertical slice.
4. Run static checks and available automated tests.
5. Run in-Studio playtests when supported.
6. Inspect Output for errors and warnings.
7. Fix regressions before continuing.
8. Update `docs/CHANGELOG.md`, `docs/DEVELOPMENT_LOG.md` and relevant technical docs.
9. Mark acceptance criteria as PASS, FAIL or BLOCKED with evidence.
10. Continue to the next phase only if the phase gate passes.

You may continue independently across phases when all required tools and verification are available. If Studio requires a manual action, a user decision, account permission, publishing authorization, a real multiplayer test with additional clients, or a capability unavailable to you, record it as BLOCKED and continue with independent work that does not depend on it. Never pretend the blocked test passed.

## 4. Non-negotiable safety and quality rules

- Never delete or overwrite a working system without inspecting dependencies and making a recoverable change.
- Before large refactors, create a Git commit or checkpoint if Git is available.
- Never publish, make the experience public, spend Robux, buy assets, create paid services, or change account/privacy settings without explicit user approval.
- Never use unlicensed, stolen, or copied game assets. Prefer original procedural geometry and Roblox-native assets.
- Never insert external scripts or executable models from untrusted sources.
- Never trust the client for inventory, currency, damage, rewards, crafting, purchases, quest completion or persistence.
- Validate all remote requests on the server, including type, range, ownership, cooldown and state.
- Never store secrets, API keys, passwords or private tokens in source control.
- Do not create hidden admin backdoors or arbitrary remote code execution.
- Do not fake test results, performance metrics or multiplayer verification.
- Do not use unbounded loops, per-frame pathfinding, or excessive remote traffic.
- Preserve mobile usability and accessible readability.
- Use configuration modules for tuning values. Avoid scattered magic numbers.
- Keep the first release within the scope in the GDD. Put later features in the backlog rather than expanding scope.

## 5. Architecture rules

Follow `02_TECHNICAL_ARCHITECTURE.md`.

- Server-authoritative gameplay.
- Client handles input, presentation and prediction only where safe.
- Shared modules contain definitions and pure/shared logic, not secrets.
- Use ModuleScripts with clear ownership and interfaces.
- Use typed Luau where practical (`--!strict` for stable modules).
- Prefer explicit service APIs and dependency direction.
- Use RemoteEvents for one-way messages; RemoteFunctions only when a request-response pattern is genuinely needed and safe.
- Use CollectionService tags and attributes for world interactables where useful.
- Use DataStoreService for durable player profiles.
- Use MemoryStoreService only for temporary cross-server coordination.
- Use MessagingService for cross-server notifications, not as a durable database.
- Handle throttling, retries, shutdown and partial failures.

## 6. Asset and world creation rules

Follow `03_WORLD_AND_LEVEL_DESIGN.md` and `04_ART_AUDIO_AND_AVATAR_BIBLE.md`.

- Build a compact, readable first map before expanding.
- Use a consistent grid, scale and naming convention.
- Keep collision geometry simple.
- Anchor static environment parts.
- Avoid excessive unions and high-part-count decorative clutter.
- Use streaming-compatible region design.
- Use original low-poly geometry and Roblox materials first.
- Do not attempt to generate complex custom meshes if the available tools cannot do so reliably. Use well-composed Roblox Parts/MeshParts from approved assets or simple silhouettes.
- Never block gameplay paths with decorative objects.
- Add lighting and atmosphere only after gameplay readability is established.

## 7. Definition of done for every feature

A feature is not complete merely because a script exists. It must have:

- a clear owner module;
- documented inputs and outputs;
- server/client boundary defined;
- validation and error handling;
- configuration values where tunable;
- tests or a documented manual test;
- no known critical errors;
- UI feedback where a player action needs it;
- updated documentation.

## 8. Required documentation updates

Maintain:
- `docs/DEVELOPMENT_LOG.md`: current phase, completed tasks, test evidence, blockers, next actions.
- `docs/CHANGELOG.md`: player-visible and technical changes.
- `docs/KNOWN_ISSUES.md`: bugs, severity, reproduction and status.
- `docs/IMPLEMENTATION_AUDIT.md`: initial inspection and material architecture deviations.
- Relevant system documents when implementation choices change.

Do not rewrite the GDD merely to make an incomplete implementation appear compliant. Distinguish **designed**, **implemented**, **tested** and **released** status.

## 9. Stop conditions

Stop the affected task and mark it BLOCKED if:
- the MCP tool cannot safely perform a required operation;
- a required external asset or permission is unavailable;
- the implementation would risk corrupting player data;
- a design ambiguity materially changes player experience;
- a security requirement cannot be met;
- a destructive operation has uncertain scope;
- tests fail repeatedly and the root cause is unclear.

Continue unrelated safe tasks where possible. Ask the user only for the specific approval or action needed, not for a generic next prompt.

## 10. Final report

At the end of each phase, report:
- phase status;
- files/scripts/Studio objects created or changed;
- tests run and actual results;
- remaining issues;
- whether the next phase can begin.

At the end of all phases, produce a launch-readiness report. Do not claim the game is complete or multiplayer-ready if real multi-client testing has not occurred.
