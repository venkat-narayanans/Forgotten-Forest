# UI, UX, MULTIPLATFORM AND ACCESSIBILITY SPECIFICATION

## 1. Design goals

- Clear at a glance.
- Mobile-first responsive layout while retaining desktop convenience.
- Consistent forest-themed visual language.
- Avoid excessive overlays.
- Every interaction has clear feedback.
- Essential information is not conveyed by color alone.

## 2. Main HUD

Elements:
- Health bar.
- Stamina bar (contextual).
- Warmth indicator (show when relevant).
- Sanity indicator (show when relevant).
- Current phase and time.
- Objective text.
- Interaction prompt.
- Teammate/downed indicators.
- Inventory shortcut.

Use safe-area-aware layouts. Keep mobile thumb zones clear.

## 3. Menus

Required:
- Inventory.
- Crafting.
- Shared storage.
- Quest log.
- Map/region guide.
- Equipment.
- Settings.
- Death/revive screen.
- Event notification.

Menus should close predictably and not trap player input.

## 4. Input mapping

Desktop:
- WASD movement (Roblox default).
- Space jump (Roblox default).
- Shift sprint.
- E interact.
- Tab or chosen key inventory.
- Escape Roblox menu/settings.

Mobile:
- Roblox movement controls.
- Dedicated sprint button.
- Contextual interaction button or ProximityPrompt.
- Large enough inventory and menu targets.
- Avoid placing important buttons under thumbstick.

Gamepad:
- Use Roblox input abstraction and GuiService selection where practical.
- Provide focus navigation for menus.

## 5. Interaction prompts

Prompt should show:
- action verb;
- object name;
- input hint;
- disabled/locked reason when applicable.

Do not show an interaction prompt when the player is too far or the object is unavailable.

## 6. Feedback

Success:
- concise confirmation;
- item count change;
- subtle sound/animation.

Failure:
- explain why: too far, inventory full, missing ingredients, wrong tool, locked region, cooldown.

Never leave buttons appearing active when server has rejected the action.

## 7. Accessibility

- Text contrast should be strong.
- Use readable font sizes.
- Do not rely on color alone.
- Offer reduced camera shake.
- Avoid flashing.
- Offer music/ambience/effects volume controls if practical.
- Avoid long forced camera sequences.
- Ensure UI works with touch and different aspect ratios.

## 8. Performance

- Do not rebuild entire UI every frame.
- Update only changed values.
- Disconnect event listeners when UI is destroyed.
- Avoid excessive tween creation.
- Use image assets with appropriate dimensions and loading fallbacks.
- Test mobile portrait/landscape behavior.
