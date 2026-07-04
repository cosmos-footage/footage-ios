# Refactor Phase R7 Changelog: Tests and Verification Harness

Date: 2026-07-04.

## Summary

Added the first XCTest verification harness for pure refactor-era services without changing app runtime behavior.

## Changes

- Added a `FootageTests` unit test target to `footage.xcodeproj`.
- Registered `FootageTests` in the shared `footage` scheme TestAction.
- Added unit tests for:
  - `DistanceCalculator`
  - `LocationFilter`
  - `RoutePointNDJSONSerializer`
- Added test-target framework search paths for app Swift module dependencies from CocoaPods:
  - `EFCountingLabel`
  - `Realm`
  - `RealmSwift`

## Commands Run

```sh
git status --short --untracked-files=all
plutil -lint footage.xcodeproj/project.pbxproj
git diff --check
xcodebuild -list -workspace footage.xcworkspace
xcrun simctl list devices available
xcodebuild -showdestinations -workspace footage.xcworkspace -scheme footage
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

## Validation Results

- `plutil -lint footage.xcodeproj/project.pbxproj` succeeded.
- `git diff --check` succeeded.
- `xcodebuild -list -workspace footage.xcworkspace` succeeded.
- `xcodebuild -showdestinations -workspace footage.xcworkspace -scheme footage` succeeded.
- First `xcodebuild test` failed because `FootageTests` could not resolve app module dependencies `EFCountingLabel` and `RealmSwift`.
- Added test target framework search paths for the Pods build products.
- Second `xcodebuild test` failed because `DistanceCalculatorTests` compared an optional speed result directly against a `Double`.
- Updated the test to unwrap the optional speed result.
- Final `xcodebuild test` succeeded on iPhone 17 Pro Simulator, iOS 26.5.

Passing tests:

- `RoutePointNDJSONSerializerTests.testNDJSONProducesOneJSONRecordPerLine`
- `RoutePointNDJSONSerializerTests.testRecordsUseDeterministicIdsAndSequences`
- `LocationFilterTests.testAcceptsFirstValidLocation`
- `LocationFilterTests.testRejectsAlwaysOnIndoorLikelyAfterNoSpeedLimit`
- `LocationFilterTests.testRejectsSpeedLimitExceeded`
- `DistanceCalculatorTests.testDistanceMetersReturnsZeroWithoutPreviousLocation`
- `DistanceCalculatorTests.testSpeedMetersPerSecondRejectsNonPositiveElapsedTime`
- `DistanceCalculatorTests.testSpeedMetersPerSecondUsesElapsedTime`

## Runtime Behavior

- No app runtime call sites were intentionally changed.
- No signing, bundle identifier, entitlement, app group, widget, Storyboard, asset, Pod, or Realm schema changes were made.
- The new test bundle identifier is `co.el.footage.tests`.

## Remaining Work

- Add tests for `LocalSyncOutboxRepository` retry/backoff behavior.
- Add tests for Cloud Backup request construction using a mock `URLProtocol`.
- Add restore duplicate detection tests.
- Add auth owner mismatch tests.
- Consider adding a dedicated `.xctestplan` after the initial harness stabilizes.

## Next Step

Continue R7 by adding tests around outbox retry/backoff and Cloud Backup API request construction before enabling any backend/S3 integration.
