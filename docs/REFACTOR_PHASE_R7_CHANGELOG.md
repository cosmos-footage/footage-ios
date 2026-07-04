# Refactor Phase R7 Changelog: Tests and Verification Harness

Date: 2026-07-04.

## Summary

Added the first XCTest verification harness for pure refactor-era services without changing app runtime behavior. Expanded it to cover sync outbox retry/backoff, cloud backup request construction, restore duplicate detection, and auth owner mismatch handling.

## Changes

- Added a `FootageTests` unit test target to `footage.xcodeproj`.
- Registered `FootageTests` in the shared `footage` scheme TestAction.
- Added unit tests for:
  - `DistanceCalculator`
  - `LocationFilter`
  - `RoutePointNDJSONSerializer`
  - `LocalSyncOutboxRepository`
  - `CloudBackupAPIClient`
  - `RestoreDuplicateDetector`
  - `AuthLinkingService`
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
scripts/phase1-build-baseline.sh
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
- Added remaining R7 tests for local outbox retry/backoff, cloud backup request construction, restore duplicate detection, and auth owner mismatch.
- One Cloud Backup API request test initially failed because `URLSession` surfaced the JSON body through `httpBodyStream`; the test helper now reads either `httpBody` or `httpBodyStream`.
- Final `xcodebuild test` succeeded on iPhone 17 Pro Simulator, iOS 26.5, with 15 passing tests.
- `scripts/phase1-build-baseline.sh` succeeded with exit code 0 after the expanded test harness.

Passing tests:

- `RoutePointNDJSONSerializerTests.testNDJSONProducesOneJSONRecordPerLine`
- `RoutePointNDJSONSerializerTests.testRecordsUseDeterministicIdsAndSequences`
- `LocationFilterTests.testAcceptsFirstValidLocation`
- `LocationFilterTests.testRejectsAlwaysOnIndoorLikelyAfterNoSpeedLimit`
- `LocationFilterTests.testRejectsSpeedLimitExceeded`
- `DistanceCalculatorTests.testDistanceMetersReturnsZeroWithoutPreviousLocation`
- `DistanceCalculatorTests.testSpeedMetersPerSecondRejectsNonPositiveElapsedTime`
- `DistanceCalculatorTests.testSpeedMetersPerSecondUsesElapsedTime`
- `LocalSyncOutboxRepositoryTests.testEnqueueExternalizesInlineNDJSONPayload`
- `LocalSyncOutboxRepositoryTests.testMarkFailedStoresBackoffAndExcludesFromPendingUntilRetry`
- `RestoreDuplicateDetectorTests.testDuplicateCandidateCountUsesRecordingAndPointIds`
- `RestoreDuplicateDetectorTests.testFallbackKeyRoundsCoordinatesToFiveDecimalPlaces`
- `AuthLinkingServiceTests.testLinkRejectsOwnerMismatchAndMarksStateFailed`
- `CloudBackupAPIClientTests.testPresignUploadBuildsAuthenticatedIdempotentJSONRequest`
- `CloudBackupAPIClientTests.testRestoreManifestBuildsQueryAndBearerHeader`

## Runtime Behavior

- No app runtime call sites were intentionally changed.
- No signing, bundle identifier, entitlement, app group, widget, Storyboard, asset, Pod, or Realm schema changes were made.
- The new test bundle identifier is `co.el.footage.tests`.

## Remaining Work After R7

- Consider adding a dedicated `.xctestplan` after the initial harness stabilizes.
- Add integration-style tests once backend/S3 development configuration exists.
- Add UI/manual QA evidence for physical-device background location and widget behavior.

## Next Step

Proceed to R8 backend/S3 integration only behind explicit development configuration and manual opt-in. Keep default app behavior local-first and cloud-disabled.
