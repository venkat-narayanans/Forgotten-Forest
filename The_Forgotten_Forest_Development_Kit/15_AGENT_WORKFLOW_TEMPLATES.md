# AGENT WORKFLOW AND RECOVERY TEMPLATES

## A. Start-of-session checklist

Before coding:
- Read master instructions.
- Read relevant design/system docs.
- Inspect current branch and uncommitted changes.
- Inspect Studio hierarchy.
- Check Output for existing errors.
- Read development log and known issues.
- Identify current phase and gate.

## B. Before implementing a feature

Write:
- objective;
- requirements;
- dependencies;
- modules to create/change;
- server/client ownership;
- remotes involved;
- security validation;
- tests;
- rollback plan.

## C. Before refactoring

- inspect all references;
- identify dependencies;
- create Git checkpoint if available;
- change one subsystem at a time;
- run regression tests;
- preserve public module contracts or document migration.

## D. When blocked

Record:
- exact blocker;
- tool/capability needed;
- attempted safe alternatives;
- what can continue independently;
- precise user action required.

Do not ask the user for a broad new prompt. Ask only for the missing permission or decision.

## E. Development log template

```markdown
# Development Log

## Current status
- Phase:
- Status:
- Last updated:

## Completed
- [ ] Task — evidence:

## Tests
- Test:
- Result:
- Evidence:

## Known issues
- Issue:
- Severity:
- Reproduction:

## Blockers
- Blocker:
- Required action:

## Next actions
- [ ] Next task
```

## F. Changelog template

```markdown
# Changelog

## Unreleased
### Added
### Changed
### Fixed
### Technical
```

## G. Completion report template

```markdown
# Phase Completion Report

Phase:
Status: PASS / FAIL / BLOCKED

Implemented:
- ...

Changed files/Studio instances:
- ...

Tests actually run:
- ...

Results:
- ...

Known issues:
- ...

Next phase:
- READY / BLOCKED

Evidence:
- ...
```
