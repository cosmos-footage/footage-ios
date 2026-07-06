# Renewed Root QA Plan

This plan defines the manual QA gate before the disabled renewed UIKit root can replace the current Storyboard root for any production-facing build.

## Scope

- Main app target: `footage`
- Current production root: existing `Main.storyboard` tab bar root
- Candidate root: `RenewedShellViewController` created through `AppCompositionRoot.makeAppRootViewControllerFactory`
- Gate under review: `FeatureFlags.isNewUIRunwayEnabled`

## Non-Goals

- Do not enable the renewed root by default in this QA phase.
- Do not remove Storyboards.
- Do not change signing, entitlements, app group, widget files, Pods, or Realm schema.
- Bundle identifiers already use the explicit renewal namespace `co.nyeok`; do not change them again without a separate owner decision.
- Do not start cloud backup, restore import, or auth linking from the renewed Settings detail screens.
- Do not log raw latitude/longitude, auth tokens, presigned URLs, object keys, photos, or notes.

## Required Devices

- iPhone simulator matching the current build baseline.
- At least one physical iPhone for background location, permission, and widget-adjacent checks.
- Existing-user install with app defaults set.
- Fresh install with no app data.

## Critical Pass Criteria

- Default feature flags keep the current Storyboard root.
- First launch still opens the existing FirstLaunch flow.
- Existing users can enter the app without root replacement when the renewed flag is off.
- When the renewed flag is enabled only for QA, the app opens the renewed UIKit shell without crashing.
- Widget URL start/stop still reaches the same recording intent path.
- Background location behavior is not weakened or duplicated.
- Password foreground gate still appears when configured.
- No current-session route, photo, note, widget, app group, or Realm data is deleted or migrated unexpectedly.
- Backup, restore, and auth Settings detail screens remain read-only.

## Launch Matrix

| Scenario | Flag | Expected Result |
| --- | --- | --- |
| Fresh install | Off | Existing FirstLaunch storyboard flow opens. |
| Fresh install | On | Existing FirstLaunch storyboard flow still opens. |
| Existing user | Off | Existing Main storyboard tab root remains active. |
| Existing user | On | Renewed UIKit shell opens for QA only. |
| Existing user from widget URL | Off | Existing root remains active and widget start signal is preserved. |
| Existing user from widget URL | On | Renewed root opens and widget start signal is preserved. |

## Manual Checks

### First Launch

- Fresh install opens the current onboarding flow.
- Onboarding video and initial state do not crash.
- Completing onboarding still lands in the existing app path with default flags.

### Existing User Launch

- Existing-user defaults route to the app path with flags off.
- App does not show FirstLaunch for existing users.
- Tab selection and initial Home preparation match the current app.

### Renewed Root QA Path

- Today tab opens without crashing.
- Map tab opens an `MKMapView` canvas without requesting unintended data mutation.
- Timeline tab lists read-only journey summaries when available.
- Stats tab renders read-only summary values.
- Settings tab renders cloud backup, restore, and auth feature state.
- Settings `백업 상태`, `복원 상태`, and `계정 연결 상태` entries open read-only detail screens.

### Recording And Widget

- Start recording from the existing production Home path with flags off.
- Stop recording from the existing production Home path with flags off.
- Launch from widget start URL and confirm the same recording action is planned.
- Launch from widget stop URL and confirm the same stop action is planned.
- App group values for `isTracking`, `distanceToday`, `distanceTotal`, and `selectedColor` remain compatible with the widget.

### Foreground And Background

- Password foreground gate appears when the password setting requires it.
- Background entry still schedules the existing always-on location timer when expected.
- Returning to foreground still invalidates the timer as before.
- Widget timelines still reload at the same lifecycle points.

### Privacy And Safety

- Console output does not include raw coordinates.
- Console output does not include backup payloads, auth tokens, presigned URLs, object keys, photos, or notes.
- Read-only Settings detail screens do not call prepare, restore preview/import, auth linking, or network APIs.

## Blockers

- Any crash on launch, widget URL launch, or first launch.
- Any loss or mutation of current-session recording data outside the current recording behavior.
- Any regression in widget start/stop state.
- Any duplicated background location session or missing background recording behavior.
- Any password gate bypass.
- Any cloud backup, restore import, or auth linking action triggered from the renewed Settings read-only screens.
- Any sensitive data in logs.

## Rollback Rule

If any critical check fails, keep `FeatureFlags.isNewUIRunwayEnabled` disabled by default and continue launching through the current Storyboard root.

## Validation Commands

```bash
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

Do not claim renewed root readiness unless the automated test command succeeds and the manual checks above pass on simulator and physical device.
