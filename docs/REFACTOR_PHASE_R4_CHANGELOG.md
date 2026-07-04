# Refactor Phase R4 Changelog

Date: 2026-07-04

## Scope

Phase R4 begins the recording use-case extraction without changing the live Home screen recording flow yet.

## Completed

- Added `RecordingUseCase` as the protocol boundary for recording start, stop, and location processing.
- Made `RecordingService` conform to `RecordingUseCase`.
- Added `RecordingWidgetStateWriting` as a widget state writer abstraction.
- Made `RecordingStateStore` conform to `RecordingWidgetStateWriting`, preserving the existing app group keys.
- Updated `RecordingService` to depend on `RecordingWidgetStateWriting` instead of the concrete `RecordingStateStore`.
- Added `AppCompositionRoot.makeRecordingUseCase(...)` to centralize construction for the next wiring step.

## Behavior

- Existing `HomeViewController` recording behavior was not intentionally changed.
- No Realm model, Storyboard, entitlement, signing, bundle identifier, widget target, Pod, or asset was modified.
- No cloud sync, S3 upload, restore import, auth linking, or network behavior was enabled.

## Validation

- `git diff --check` succeeded.
- `plutil -lint footage.xcodeproj/project.pbxproj` succeeded.
- `scripts/phase1-build-baseline.sh` succeeded with exit code 0.

## Next Step

R4-2 should migrate `HomeViewController` start/stop construction and state transitions through `RecordingUseCase` while preserving the current UI animations, local-first writes, location manager behavior, and widget state keys.
