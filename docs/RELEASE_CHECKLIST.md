# Release Checklist

Date: 2026-07-04.

## Pre-Build Checks

- Confirm working tree contains only intentional release changes.
- Confirm no signing, bundle identifier, entitlement, app group, widget, Storyboard, asset, Pod, or Realm model changes are accidental.
- Confirm `CloudBackupConfiguration` defaults remain disabled.
- Confirm Restore is not automatic.
- Confirm Auth is not required for recording.

## Build Checks

- Run `xcodebuild -list -workspace footage.xcworkspace`.
- Run `scripts/phase1-build-baseline.sh`.
- Run signed archive after provisioning review.
- Inspect warnings; generated Realm/RealmSwift warnings are tracked separately.

## Manual QA Checks

- First launch.
- Existing user data opens.
- Start recording.
- Stop recording.
- Background recording behavior.
- App relaunch while tracking state exists.
- Map rendering.
- Stats screens.
- Photo/note attachment flows.
- Password/Face ID gate.

## Background Location QA

- When-in-use prompt.
- Always-location prompt.
- Start route, lock device, walk, relaunch.
- Verify no unexpected route deletion.

## Widget QA

- Widget loads.
- Widget color/category reflects app group state.
- Widget start/stop URL opens app and toggles tracking.
- Widget distance values are reasonable.

## Data Migration QA

- Install over a build with existing Realm data.
- Verify route history remains.
- Verify photos and notes remain.
- Verify no destructive Realm migration runs.

## Cloud Backup QA

- Default build: cloud backup disabled.
- Development-only configuration: manually prepare outbox, bootstrap, presign, upload, complete, sync batch against a test backend only.
- Verify no raw location/token/private URL logging.

## Restore QA

- Default build: restore not automatic.
- Preview-only restore plan can be created from fixture data.
- Import does not mutate Realm until explicit additive import is implemented.

## Auth QA

- Default build: login not required.
- Auth link scaffold rejects owner mismatch.
- Provider tokens are not logged.

## App Store Metadata Checklist

- Location use description.
- Background location explanation.
- Privacy nutrition labels.
- Data deletion/export status.
- No analytics/tracking disclosure unless added later.

## Rollback Checklist

- Preserve previous known-good build.
- Keep Realm backup/export plan before any future migration.
- Disable rollout on location, widget, or data-loss regression.
