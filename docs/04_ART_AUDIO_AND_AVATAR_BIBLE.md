# ART, AUDIO, AVATAR AND PRESENTATION BIBLE

## 1. Art direction

**Style:** stylized low-poly Roblox adventure.

The target is polished and atmospheric, not photorealistic. Use simple geometry, strong silhouettes, restrained detail, consistent materials and deliberate lighting.

Visual keywords:
- enchanted;
- overgrown;
- mysterious;
- cozy at the hub;
- eerie in the forest;
- readable;
- colorful but not oversaturated.

## 2. Palette

Use these as design references; tune in Studio:
- Safe Haven warm amber: `#D99A52`
- Forest deep green: `#254B3A`
- Moss: `#647B4C`
- Night blue: `#17263C`
- Mist blue-gray: `#8293A0`
- Stone: `#77766E`
- UI parchment: `#E9E1D1`
- UI dark background: `#202A2B`
- Alert accent: `#C76B55`

Do not use every color everywhere. Regions need distinct palettes with shared material language.

## 3. Geometry and materials

- Prefer simple meshes and Parts with clean silhouettes.
- Use low-poly trees with varied trunk/canopy shapes.
- Use a small set of material families: wood, stone, foliage, soil, cloth, metal, crystal.
- Avoid excessive tiny parts.
- Avoid unnecessary unions; use MeshParts or grouped parts where appropriate.
- Static geometry should be anchored.
- Collision geometry should be simpler than visual geometry.
- Decorative foliage should not obstruct movement or camera.

## 4. Character/avatar direction

Use Roblox-compatible player avatars rather than forcing a custom rig in version 1.0.

Requirements:
- Support standard Roblox avatar rigs (R15 preferred; do not break R6 if feasible).
- Preserve player identity and avatar customization.
- Provide a small set of optional game outfits/cosmetics that fit the explorer theme.
- Use standard humanoid movement unless there is a tested reason to customize.
- Ensure accessories do not create unfair hitbox or camera issues.
- Avoid replacing player avatars with a custom body in the first release.

Suggested outfit theme:
- explorer jacket/vest;
- simple backpack;
- boots;
- scarf or hood;
- lantern accessory (visual only unless explicitly equipped as gameplay gear).

Do not depend on paid catalog assets. Use Roblox-native or approved original assets. Check asset permissions and moderation status.

## 5. Creature silhouette design

Watcher:
- Tall, thin, distant silhouette.
- Minimal detail; visible eyes only at appropriate distance.
- Must read as non-combat/observational.

Stalker:
- Four-limbed or hunched silhouette.
- Clear wind-up before attack.
- Readable movement and hit range.

Mimic:
- Unusual, asymmetrical silhouette.
- Distinctive sound language.
- Never imitate actual player names or UI identity.

Forest Guardian:
- Large ancient-root/wood/stone silhouette.
- Strong telegraphed attacks.
- Clear vulnerable areas or mechanisms.
- Boss effects must not obscure attack indicators.

## 6. UI direction

Visual language:
- parchment-like panels;
- dark forest-green surfaces;
- warm amber highlights;
- readable white/cream text;
- restrained ornamental borders;
- simple icons;
- subtle motion.

UI requirements:
- Mobile-safe scale and layout.
- Text must remain readable at common screen sizes.
- Never communicate essential information by color alone.
- Support controller/gamepad navigation where practical.
- Avoid excessive full-screen overlays.
- Provide clear feedback for failed interactions.

## 7. HUD

Always visible when appropriate:
- Health.
- Stamina.
- Warmth when relevant.
- Sanity when relevant.
- Day/night phase and time.
- Current objective.
- Interaction prompt.
- Teammate/downed status.

Do not show all meters at maximum prominence all the time. Contextualize Warmth and Sanity.

## 8. Animation direction

Use simple, readable animation:
- idle;
- walk/run;
- jump/fall;
- gather;
- craft;
- revive;
- creature idle/patrol/chase/attack/stagger/death.

Use Roblox animation systems and approved assets. If custom animations are unavailable, use simple Roblox-compatible placeholder animations and document them. Do not claim custom animation is complete when only a static model exists.

## 9. Lighting and atmosphere

- Use Lighting and Atmosphere carefully.
- Keep player silhouettes and navigation cues visible.
- Night should be moody, not unplayably dark.
- Avoid heavy post-processing that harms low-end/mobile performance.
- Keep shadow quality appropriate to target devices.
- Use localized point lights for lanterns/campfires; limit active light count.
- Add accessibility options for reduced effects and camera shake.

## 10. Audio bible

Sound layers:
1. Ambient bed: wind, distant birds, water, leaves.
2. Interaction: gathering, crafting, doors, pickup.
3. Player: footsteps, jump, breathing only when contextually useful.
4. Threat: distant call, rustle, creature movement, attack telegraph.
5. UI: soft confirmation and warning sounds.
6. Music: sparse exploration motif, night tension, dawn relief.

Audio rules:
- Avoid ear-piercing peaks.
- Do not play constant loud music.
- Use 3D positional audio for world sources.
- Use volume sliders or respect Roblox volume settings.
- Use original or properly licensed audio.
- Never upload copyrighted music without rights.

## 11. Effects and accessibility

- Particle effects should be low-count and short-lived.
- Avoid rapid flashing.
- Camera shake must be subtle and optional.
- Sanity effects must not cause motion sickness or make controls unusable.
- Provide reduced visual effects mode if feasible.
- Critical alerts require text/icon as well as sound.
