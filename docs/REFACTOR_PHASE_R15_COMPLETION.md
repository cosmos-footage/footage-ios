# Refactor Phase R15 Completion

Date: 2026-07-06.

## Status

R15 automated work is complete.

Production cutover is not complete and is not claimed.

## Completed Automated Scope

- Kept the existing Storyboard root as the default production launch path.
- Added QA-only renewed root override through `--footage-enable-renewed-ui` or `FOOTAGE_ENABLE_RENEWED_UI=1`.
- Hardened renewed programmatic UIKit screens with simulator-safe layout improvements:
  - Settings dashboard
  - About
  - backup status
  - restore status
  - auth readiness
  - Stats overview
  - Timeline
  - Today dashboard
  - Map canvas containment
- Added the Storyboard removal matrix and marked all Storyboards as retained for now.
- Added an independent renewed Settings detail rollback flag:
  - `--footage-enable-renewed-settings-details`
  - `FOOTAGE_ENABLE_RENEWED_SETTINGS_DETAILS=1`
- Verified that renewed Settings detail routes are hidden unless the detail flag is enabled.

## Validation Evidence

Latest successful automated validation:

```bash
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

Result:

- `git diff --check` passed.
- `xcodebuild test` passed.
- Result bundle: `/Users/nyeok/Library/Developer/Xcode/DerivedData/footage-fcfkhlxrlvchugggglstbjyxsmlr/Logs/Test/Test-footage-2026.07.06_22-08-02-+0900.xcresult`

One earlier R15-C1 run failed because a new test inspected hidden button titles instead of button visibility. The test expectation was corrected to assert `isHidden`, and the next full test run succeeded.

## Not Completed In R15

These are intentionally deferred to final release-readiness on a physical iPhone:

- Background location recording QA.
- Widget URL start/stop handoff QA.
- Password foreground gate QA.
- App group state compatibility QA for widget-visible values.

These are also not done:

- Storyboard deletion.
- Default root cutover to the renewed UIKit shell.
- Production Settings replacement.
- Home recording UI replacement.
- Journey detail/photo/note replacement.
- StoreKit donation replacement.

## Release Position

R15 leaves the app with a safer programmatic UIKit runway, but the shippable default remains the existing Storyboard path.

The next work should start a new refactor/release-readiness phase focused on one of:

1. Physical-device QA evidence collection.
2. A small production route cutover behind a rollback flag.
3. A new programmatic UIKit replacement for a non-device-dependent read-only scene.
