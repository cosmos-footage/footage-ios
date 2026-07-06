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
- Storyboards, widget files, Realm schema, signing, entitlements, bundle identifiers, app group keys, assets, Pods, and existing user data models must not be removed during this gate.

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
| Git working tree | `git status --short` | Passed with expected docs-only changes before commit | `M docs/MODERNIZATION_PLAN.md`, `?? docs/REFACTOR_PHASE_R15_QA_EVIDENCE.md` |
| Workspace schemes | `xcodebuild -list -workspace footage.xcworkspace` | Passed | Schemes listed: `EFCountingLabel`, `footage`, `MainWidgetExtension`, `Pods-footage`, `Pods-MainWidgetExtension`, `Realm`, `Realm-realm_objc_privacy`, `RealmSwift`, `RealmSwift-realm_swift_privacy`, `WidgetColorSelection` |
| Unit/integration tests | `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` | Passed | `** TEST SUCCEEDED **`; result bundle `/Users/nyeok/Library/Developer/Xcode/DerivedData/footage-fcfkhlxrlvchugggglstbjyxsmlr/Logs/Test/Test-footage-2026.07.06_16-55-00-+0900.xcresult` |
| Whitespace/diff check | `git diff --check` | Passed | No output |

Do not mark a command as passed unless that exact command, or a documented destination substitution, actually ran.

## Manual QA Evidence Required

These checks require simulator interaction, physical-device interaction, seeded local data, or human observation. They are not passed by repository-only automation.

| Area | Required Evidence | Result |
| --- | --- | --- |
| Fresh install with renewed flag off | Existing FirstLaunch storyboard opens. | Not run |
| Fresh install with renewed flag on for QA | Existing FirstLaunch storyboard still opens. | Not run |
| Existing user with renewed flag off | Existing Main storyboard root remains active and local data is visible. | Not run |
| Existing user with renewed flag on for QA | Renewed UIKit shell opens without crash. | Not run |
| Existing Realm data parity | Today, Timeline, Stats, Settings read the expected local data. | Not run |
| Widget URL start/stop | Widget start/stop URLs preserve current recording intent path. | Not run |
| App group compatibility | `isTracking`, `distanceToday`, `distanceTotal`, and `selectedColor` remain compatible. | Not run |
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
- Existing user Realm data visibility has not been checked.
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
