# App Store Readiness

Date: 2026-07-04.

## Build Baseline

- Workspace: `footage.xcworkspace`
- Main app scheme: `footage`
- Widget scheme: `MainWidgetExtension`
- Minimum deployment target: iOS 18.0
- Build baseline command: `scripts/phase1-build-baseline.sh`
- Current simulator baseline: Debug and Release builds for app and widget succeed with `CODE_SIGNING_ALLOWED=NO`.

Archive readiness is documented but not verified in this phase because signing and distribution provisioning were intentionally not changed.

Suggested archive command after signing review:

```sh
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Release -destination generic/platform=iOS archive
```

## Release-Sensitive Settings

- App bundle identifier: `co.el.footage`
- Widget bundle identifier: `co.el.footage.MainWidget`
- App group: `group.footage`
- Main app entitlement: `Entitlements/footage.entitlements`
- Widget entitlement: `Entitlements/MainWidgetExtension.entitlements`
- Background mode: location
- Widget target preserved.
- Storyboards and Realm local storage preserved.

## Permission Review

Location permission strings exist:

- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSLocationWhenInUseUsageDescription`

Photo permission string exists:

- `NSPhotoLibraryUsageDescription`

Face ID permission string exists:

- `NSFaceIDUsageDescription`

Release review should confirm the Korean copy clearly explains continuous walking-route recording, background location, and private local archive behavior.

## Background Location Review

The app declares `UIBackgroundModes = location` and records walking routes. Review notes should explain:

- Route recording is user-initiated.
- Local recording works without cloud.
- Widget reflects tracking status.
- Cloud backup remains disabled by default.

## Disabled Scaffold Features

Cloud Backup:

- Scaffold exists.
- `CloudBackupConfiguration.isCloudBackupEnabled` defaults to `false`.
- `isDevelopmentUploadEnabled` defaults to `false`.
- No app launch/UI/recording call site starts upload.

Restore:

- Scaffold exists.
- No automatic restore.
- Default import policy is `skipExisting`.
- Import repository is preview-only.

Auth:

- Scaffold exists.
- Login is not required.
- Recording is not account-gated.
- Sign in with Apple capability was not added.

## Privacy Disclosure Checklist

- Location: collected locally for walking-route recording.
- Photos/notes: stored locally in Realm when user attaches them to footsteps.
- Cloud backup: not enabled by default; disclose only when production opt-in exists.
- Auth: not required; disclose when production account linking exists.
- Analytics/tracking: none added.
- Public route sharing: none added.
- AWS credentials: none in client.

## TestFlight Checklist

- Run `scripts/phase1-build-baseline.sh`.
- Run a signed archive locally after provisioning review.
- Install on device and verify first launch.
- Verify recording start/stop.
- Verify background location prompt and behavior.
- Verify widget start/stop status.
- Verify existing Realm data remains readable after update.
- Verify cloud backup, restore, and auth are not visible/enabled unless intentionally configured.

## Rollback Plan

- Preserve the previous App Store/TestFlight build as rollback.
- Do not run destructive Realm migrations before release.
- If location, widget, or Realm behavior regresses, disable rollout and ship a build from the last known baseline branch.
