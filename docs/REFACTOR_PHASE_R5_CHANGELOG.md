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

## R5-2 Completed

- Added default `DaySummaryRepository`, `ColorRepository`, and `PlaceRepository` dependencies to `StatsViewController`.
- Replaced direct `DateManager.loadMonthlyDistance()`, `ColorManager.getRankingDistance(...)`, and `PlaceManager.getRankingDistance(...)` calls in `viewWillAppear(_:)`.
- Preserved the existing weekly date range, ranking arrays, image selection, segue payloads, and storyboard creation.

## R5-3 Completed

- Added default `ColorRepository` and `PlaceRepository` dependencies to `ReportVC`.
- Replaced direct monthly color/place ranking reads in `prepare(for:sender:)`.
- Replaced direct color ranking reads used to enable/disable month navigation buttons.
- Preserved the existing month range calculation, button state behavior, and report detail segue payloads.

## R5-4 Completed

- Added `monthlyBadges(month:)` to `BadgeRepository`.
- Implemented `RealmBadgeRepository.monthlyBadges(month:)` through the existing `LevelManager.callMonthlyBadge(month:)` adapter path.
- Added a default `BadgeRepository` dependency to `ReportDetailVC`.
- Replaced direct monthly badge reads in `ReportDetailVC.viewDidLoad()`.
- Preserved the existing fallback empty badge behavior when a month has no badges.

## R5-5 Completed

- Added `badge(imageName:)` to `BadgeRepository`.
- Implemented `RealmBadgeRepository.badge(imageName:)` through the existing `LevelManager.loadTodayBadge(imageName:)` adapter path.
- Added a default `BadgeRepository` dependency to `LevelVC`.
- Replaced direct current-badge and badge-list reads in `LevelVC.viewDidLoad()`.
- Preserved the existing empty badge fallback behavior.

## R5-6 Completed

- Added `footsteps(hex:from:to:)` to `ColorRepository`.
- Implemented `RealmColorRepository.footsteps(hex:from:to:)` through the existing `ColorManager.footstepsWithColor(color:from:to:)` adapter path.
- Added a default `ColorRepository` dependency to `ColoredJourneyVC`.
- Replaced direct colored route reads in `ColoredJourneyVC.configureMap()`.
- Preserved the existing Realm `List<Footstep>` route rendering behavior.

## Behavior

- Existing date screen behavior was not intentionally changed.
- Realm object classes, migrations, Storyboards, assets, signing, entitlements, Pods, bundle identifiers, and widget files were not modified.

## Validation

- `git diff --check` succeeded.
- `scripts/phase1-build-baseline.sh` should be run before committing each R5 slice.

## Next Step

Next repository migration should add read models for map screens before migrating those views.
