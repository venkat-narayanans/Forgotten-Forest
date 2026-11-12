# PLAYER DATA, PERSISTENCE AND RECOVERY

## 1. Profile schema

Suggested versioned schema:
```lua
{
    schemaVersion = 1,
    level = 1,
    xp = 0,
    forestCoins = 0,
    ancientTokens = 0,
    inventory = {},
    equipment = {},
    unlockedRecipes = {},
    completedQuests = {},
    activeQuests = {},
    achievements = {},
    discoveries = {},
    cosmetics = {},
    settings = {
        reducedEffects = false,
        cameraShake = true
    },
    lastSaveUnix = 0
}
```

The exact schema may evolve. All changes require migration logic.

## 2. Loading

- Load profile before enabling data-dependent actions.
- Show a clear loading state.
- If data load fails, retry bounded transient failures.
- If load remains unsuccessful, do not start a blank profile that could overwrite existing data.
- Provide a safe failure message and prevent progression that cannot be saved.

## 3. Session ownership

Prevent the same profile from being actively written by multiple servers where possible. Use a robust session-lock strategy with expiry and recovery. Do not build a fragile lock that permanently strands users after a crash.

## 4. Saving

- Periodic autosave at a conservative interval (e.g. 60–120 seconds, tune to request budgets).
- Save on PlayerRemoving.
- Attempt bounded save on BindToClose.
- Use UpdateAsync where appropriate.
- Avoid saving on every inventory change.
- Coalesce changes and track dirty state.
- Respect DataStore request budgets.

## 5. Failure handling

- Exponential backoff with jitter.
- Bounded retry count.
- Keep in-memory state while retrying.
- Never replace a valid profile with defaults after a transient failure.
- Log failure category and player UserId only as needed for debugging; do not log private information.
- If final save fails, record clear telemetry/logs and do not claim it succeeded.

## 6. Transaction safety

Important reward and currency grants should use transaction IDs or idempotent completion flags where feasible.

Examples:
- Quest reward claim.
- Boss reward.
- Achievement reward.
- Purchase receipt processing if monetization is added later.

Do not rely on client UI state to prevent duplicate claims.

## 7. Data migrations

- Every schema change increments schemaVersion.
- Migration functions must be deterministic and tested against old sample profiles.
- Keep defaults for newly added fields.
- Preserve unknown safe fields where possible.
- Never run destructive migrations without a recoverable test.

## 8. Data testing

Use a separate test experience or mock storage in Studio. Do not test destructive save logic against real player production data.

Test:
- first-time profile;
- returning profile;
- malformed profile;
- missing fields;
- old schema migration;
- temporary DataStore failure;
- duplicate session;
- player leave during save;
- server shutdown;
- duplicate reward claim.

## 9. Global/server state

First release:
- player progression is persistent;
- shared storage is server-session scoped unless a later design explicitly makes it persistent;
- local resource depletion and temporary world state reset as documented;
- cross-server global events are optional post-launch work.

Do not use MessagingService as the source of truth for durable player data.
