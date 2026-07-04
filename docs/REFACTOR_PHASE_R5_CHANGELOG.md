# Refactor Phase R5 Changelog

Date: 2026-07-04

## Scope

Phase R5 starts migrating direct Realm manager reads behind repository protocols.

## R5-1 Completed

- Added a default `RouteRepository` dependency to `DateViewController`.
- Replaced direct `DateManager.loadFromRealm(rangeOf:)` calls in `loadWithRange(_:)` with `routeRepository.loadJourneys(rangeOf:)`.
- Preserved the existing range mapping:
  - `0` -> `day`
  - `1` -> `month`
  - default -> `year`
- Preserved `DateViewController.journeys`, snapshot creation, storyboard instantiation, and segue behavior.

## Behavior

- Existing date screen behavior was not intentionally changed.
- Realm object classes, migrations, Storyboards, assets, signing, entitlements, Pods, bundle identifiers, and widget files were not modified.

## Validation

- `git diff --check` succeeded.
- `scripts/phase1-build-baseline.sh` should be run before committing each R5 slice.

## Next Step

R5-2 should migrate a similarly small read-only stats screen slice using the existing repository protocols.
