# Refactor Phase R15 QA Evidence

Date: 2026-07-06.

## Purpose

R15 is the UI cutover and legacy cleanup phase. This document starts the R15 gate by defining the evidence required before any production-facing renewed root cutover.

This is not a cutover approval.

## Current Decision

Status: QA evidence gate started.

Production root status:

- `FeatureFlags.isNewUIRunwayEnabled` must remain `false` by default.
- The default app launch must remain on the current UIKit/Storyboard shell.
- The renewed UIKit root may be exercised only for QA/internal validation.
- QA can enable the renewed root with launch argument `--footage-enable-renewed-ui` or environment variable `FOOTAGE_ENABLE_RENEWED_UI=1`.
- Storyboards, widget files, Realm schema, signing, entitlements, app group keys, assets, Pods, and existing user data models must not be removed during this gate.
- Bundle identifiers now use the explicit renewal namespace `co.nyeok` after owner approval.

## QA-Only Renewed Root Override

The renewed root override is intended for local simulator/device QA only.

Supported toggles:

```sh
--footage-enable-renewed-ui
FOOTAGE_ENABLE_RENEWED_UI=1
```

Safety rules:

- The default app environment leaves all feature flags disabled.
- The QA override only enables `isNewUIRunwayEnabled`.
- The QA override does not enable cloud backup, restore, auth, or development upload.
- `FOOTAGE_ENABLE_RENEWED_UI=0` and other environment values do not enable the renewed root.
- First-launch users must still route to the existing FirstLaunch Storyboard even when the QA override is enabled.
- Do not leave the override in a release scheme or production-facing TestFlight setup unless a separate cutover decision is made.

## Automated Validation

These commands can be run by the repository agent.

| Check | Command | Latest Result | Evidence |
| --- | --- | --- | --- |
| Git working tree | `git status --short` | Passed with expected docs-only changes before commit | `M docs/MODERNIZATION_PLAN.md`, `M docs/REFACTOR_PHASE_R15_QA_EVIDENCE.md` |
| Workspace schemes | `xcodebuild -list -workspace footage.xcworkspace` | Passed | Schemes listed: `EFCountingLabel`, `footage`, `MainWidgetExtension`, `Pods-footage`, `Pods-MainWidgetExtension`, `Realm`, `Realm-realm_objc_privacy`, `RealmSwift`, `RealmSwift-realm_swift_privacy`, `WidgetColorSelection` |
| Unit/integration tests | `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` | Passed | `** TEST SUCCEEDED **`; result bundle `/Users/nyeok/Library/Developer/Xcode/DerivedData/footage-fcfkhlxrlvchugggglstbjyxsmlr/Logs/Test/Test-footage-2026.07.06_17-29-07-+0900.xcresult` |
| Whitespace/diff check | `git diff --check` | Passed | No output |

Do not mark a command as passed unless that exact command, or a documented destination substitution, actually ran.

## Simulator Launch Smoke Evidence

These checks were run on 2026-07-06 against the iOS 26.5 simulator after the QA-only renewed root override was added.

Device:

- iPhone 17 Pro simulator
- Runtime: iOS 26.5
- UDID: `95D8FB23-A840-44C9-851E-7CE54603720B`

Status after bundle namespace renewal:

- The earlier launch smoke was captured before the app namespace moved to `co.nyeok`.
- Treat the earlier smoke result as superseded for R15 cutover purposes.
- Post-renewal workspace listing passed with `xcodebuild -list -workspace footage.xcworkspace`.
- Post-renewal Debug simulator build passed with `xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -derivedDataPath build/NamespaceRenameDerivedData CODE_SIGNING_ALLOWED=NO build`.
- The rebuilt app reported `CFBundleIdentifier` as `co.nyeok.footage`, and the embedded widget reported `co.nyeok.footage.MainWidget`.
- Post-renewal clean install passed with `xcrun simctl install 95D8FB23-A840-44C9-851E-7CE54603720B build/NamespaceRenameDerivedData/Build/Products/Debug-iphonesimulator/footage.app`.
- Post-renewal default launch passed with `xcrun simctl launch 95D8FB23-A840-44C9-851E-7CE54603720B co.nyeok.footage` and returned `co.nyeok.footage: 79974`.
- Post-renewal QA override launch passed after clean reinstall with `xcrun simctl launch 95D8FB23-A840-44C9-851E-7CE54603720B co.nyeok.footage --footage-enable-renewed-ui` and returned `co.nyeok.footage: 85577`.
- Post-renewal QA override screenshot after 6 seconds showed the existing FirstLaunch video screen with the footprint logo and `시작` button.
- Post-renewal default launch after another clean reinstall returned `co.nyeok.footage: 87429`.
- Post-renewal default launch screenshot after 6 seconds showed the existing FirstLaunch video screen with the footprint logo and `시작` button.
- Existing-user defaults were seeded with `UserState=noPassword`, `startedBefore=true`, and app-group `selectedColor=#EADE4Cff`.
- Existing-user default launch passed with `xcrun simctl launch 95D8FB23-A840-44C9-851E-7CE54603720B co.nyeok.footage` and returned `co.nyeok.footage: 97536`; screenshot showed the existing Main storyboard Home tab.
- Existing-user QA override launch passed with `xcrun simctl launch 95D8FB23-A840-44C9-851E-7CE54603720B co.nyeok.footage --footage-enable-renewed-ui` and returned `co.nyeok.footage: 98622`; screenshot showed the renewed UIKit shell Today tab.
- Widget URL smoke reached the iOS URL-opening confirmation prompt with `xcrun simctl openurl 95D8FB23-A840-44C9-851E-7CE54603720B widget://toggle`.
- Widget URL in-app action was not completed automatically because accepting the simulator confirmation prompt required Computer Use permissions that were not granted in this session.
- Physical-device QA and widget QA remain unclaimed.
- Existing Realm display parity is no longer a renewal gate because the app is being rebuilt around clean service boundaries instead of preserving legacy Realm UI parity.

## Manual QA Evidence Required

These checks require simulator interaction, physical-device interaction, seeded local data, or human observation. They are not passed by repository-only automation.

| Area | Required Evidence | Result |
| --- | --- | --- |
| Fresh install with renewed flag off | Existing FirstLaunch storyboard opens. | Simulator visual smoke passed after bundle namespace renewal; clean install launch returned `co.nyeok.footage: 87429`, and delayed screenshot showed the existing FirstLaunch video screen with the footprint logo and `시작` button |
| Fresh install with renewed flag on for QA | Existing FirstLaunch storyboard still opens. | Simulator visual smoke passed after bundle namespace renewal; clean install launch returned `co.nyeok.footage: 85577`, and delayed screenshot showed the existing FirstLaunch video screen with the footprint logo and `시작` button |
| Existing user with renewed flag off | Existing Main storyboard root remains active and local data is visible. | Simulator seeded-user visual smoke passed; launch returned `co.nyeok.footage: 97536`, and screenshot showed the existing Main storyboard Home tab |
| Existing user with renewed flag on for QA | Renewed UIKit shell opens without crash. | Simulator seeded-user visual smoke passed; launch returned `co.nyeok.footage: 98622`, and screenshot showed the renewed UIKit shell Today tab |
| Widget URL start/stop | Widget start/stop URLs preserve current recording intent path. | Partial simulator smoke only; `widget://toggle` reached the iOS open confirmation prompt, but in-app action after tapping `열기` was not completed automatically |
| App group compatibility | `isTracking`, `distanceToday`, `distanceTotal`, and `selectedColor` remain compatible. | Partial simulator smoke only; `selectedColor=#EADE4Cff` was seeded/read for launch, but full widget state compatibility remains manual QA |
| Background location | Recording/background/relaunch behavior passes on a physical iPhone. | Not run |
| Password foreground gate | Password gate behavior remains unchanged. | Not run |
| First launch completion | Onboarding completion still lands in the expected app path. | Not run |
| Backup status detail | Renewed Settings backup detail remains read-only. | Not run |
| Restore status detail | Renewed Settings restore detail remains read-only. | Not run |
| Auth readiness detail | Renewed Settings auth detail remains read-only. | Not run |
| Privacy/contact detail | Renewed About privacy/contact paths do not log sensitive data. | Not run |
| Rollback | Disabling the renewed flag returns to the current Storyboard root without data loss. | Not run |

## Cutover Blockers

Do not enable the renewed root by default if any of the following are true:

- Manual QA has not been run.
- Physical-device background location QA has not passed.
- Widget URL/app-group compatibility has not passed.
- Existing user route crashes or loses required current-session recording state.
- FirstLaunch behavior differs from the current app.
- Password foreground gate behavior differs from the current app.
- Any renewed Settings detail triggers backup preparation, restore preview/import, auth linking, or network side effects unexpectedly.
- Any logs include raw coordinates, photos, notes, auth tokens, presigned URLs, private object keys, or user-entered mail content.
- A rollback path to the Storyboard root is not preserved.

## R15 Cutover Order

Recommended sequence after this QA gate has evidence:

1. Keep the renewed root disabled by default and run manual QA with a QA-only flag override.
2. Fix parity gaps as separate bounded tasks.
3. Cut over one read-only area at a time behind rollback flags.
4. Defer recording and mutation-heavy flows until physical-device QA is stable.
5. Remove legacy Storyboard scenes only after replacement paths, target membership, runtime references, and rollback evidence are documented.

## Current Next Step

Run simulator and physical-device manual QA from `docs/RENEWED_ROOT_QA_PLAN.md`, then update the manual evidence table with exact observations.

Manual QA remains required before any R15 production-facing cutover.
