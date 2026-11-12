# PLAYER MOVEMENT, PHYSICS AND CONTROLS

## 1. Base character

Use Roblox's standard character controller and Humanoid behavior for the first release. Do not implement a fully custom physics controller. This improves compatibility with Roblox avatars, animation, mobile controls and networking.

Target:
- R15 preferred.
- Standard Roblox avatar appearance.
- Normal Roblox jump and collision behavior.
- No forced first-person camera.
- Third-person camera by default.

## 2. Movement defaults

Treat values as starting configuration; test in Studio:
- WalkSpeed: 16 studs/second.
- SprintSpeed: 22 studs/second.
- JumpPower: use Roblox default unless testing shows a reason to tune.
- Stamina maximum: 100.
- Sprint drain: 12 stamina/second.
- Stamina regeneration: 18/second after a 1-second recovery delay.
- Sprint cannot start if stamina is below 10.
- Sprint stops at zero stamina.

Keep values in `MovementConfig`, not scattered across scripts.

## 3. Sprint behavior

- Desktop: Left Shift.
- Mobile: visible sprint button.
- Gamepad: configurable button mapping.
- Server validates sprint state if it affects stamina or gameplay.
- Client may provide immediate visual response, but server remains authoritative for stamina and action restrictions.
- Do not let sprint toggle bypass stamina.

## 4. Stamina

- Sprinting consumes stamina.
- Normal movement does not consume stamina.
- Stamina regenerates when not sprinting.
- Selected heavy actions may consume a small configurable amount.
- Do not make players walk slowly for long periods after a brief sprint.
- UI should show a clear low-stamina state.

## 5. Physics rules

- Static environment anchored.
- Use simple collision geometry.
- Avoid excessive CanCollide decorative foliage.
- Use collision groups for characters, creatures, triggers and projectiles where needed.
- Use server ownership for critical physics objects.
- Avoid client-owned physics for loot, traps, boss mechanisms or objects whose state affects rewards.
- Avoid unanchored assemblies that can be pushed to grief players.
- Use raycasts for line-of-sight and interaction checks when appropriate.
- Validate interaction distance on the server.

## 6. Combat movement

- Attack animations should have readable wind-up and recovery.
- Hit detection should be server-validated.
- Do not accept client-reported target damage.
- Use raycast/hitbox validation with server-known attack windows.
- Prevent attacks through walls where line-of-sight is required.
- Add attack cooldowns and state checks.

## 7. Camera

- Third-person camera by default.
- Preserve normal Roblox camera behavior where possible.
- Avoid forced camera shake.
- Boss camera moments should be brief, optional or non-disruptive.
- Ensure camera does not clip excessively through major geometry.
- Do not lock the player camera during routine interactions.

## 8. Interaction

- Use proximity prompts or a custom interaction layer with consistent behavior.
- Interaction range target: 10 studs, configurable by interaction type.
- Show object name and action.
- Support keyboard, touch and gamepad.
- Server validates range, line-of-sight if required, object state and player state.
- Interactions should cancel if player dies, moves too far or the target becomes unavailable.

## 9. Downed movement

For version 1.0, use a simple downed state with limited crawl or stationary behavior. Prefer stationary downed state if reliable custom crawl animation is unavailable. Revival interaction should be readable and consistent.

## 10. Physics acceptance checks

- Character cannot sprint indefinitely.
- Stamina cannot become negative.
- Players cannot push critical structures out of place.
- Interactables cannot be activated from unreasonable distances.
- Creature collision does not permanently pin players.
- Mobile touch controls are usable.
- Default Roblox avatar rigs remain functional.
