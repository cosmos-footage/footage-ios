# Refactor Phase R10 Changelog

Date: 2026-07-05.

## Goal

Extract plain Swift domain concepts and policies that can be reused by legacy UIKit now and a rewritten UI later, without moving current Realm data or changing app behavior.

## Commands Run

```sh
git status --short
rg --files Footage FootageTests docs
find . -maxdepth 3 \( -name '*.xcworkspace' -o -name '*.xcodeproj' -o -name '*.entitlements' \) -print
xcodebuild -list -workspace footage.xcworkspace
rg -n "Identifiers.swift|RecordingDrafts.swift|DistanceCalculatorTests|FootageTests|PBXSourcesBuildPhase|objectVersion|PBXFileSystemSynchronized" footage.xcodeproj/project.pbxproj
rg -n "enum RecordingState|struct RecordingState|class RecordingState|struct WidgetState|enum Badge|struct Badge|struct Place|struct ColorCategory|Domain" Footage FootageTests
rg -n "import (UIKit|RealmSwift|MapKit|CoreLocation|WidgetKit|SwiftUI)" Footage/Domain FootageTests/DomainModelsTests.swift FootageTests/DomainPoliciesTests.swift
date -u -r 1772582400 '+%Y-%m-%d %H:%M:%S %Z'
xcodebuild -list -workspace footage.xcworkspace
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

## Results

- Initial `git status --short` showed only the pre-existing Xcode user state file: `footage.xcworkspace/xcuserdata/nyeok.xcuserdatad/UserInterfaceState.xcuserstate`.
- The sandboxed `xcodebuild -list -workspace footage.xcworkspace` attempt failed with CoreSimulator permission noise and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.`
- The approved `xcodebuild -list -workspace footage.xcworkspace` command succeeded and listed the expected schemes.
- The first test run failed during `DomainPolicies.swift` compilation because `RecordingStateTransitionPolicy.RejectionReason` did not conform to `Error` and the start transition switch was not exhaustive.
- After fixing the transition policy, `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.

## Added

- `Footage/Domain/DomainModels.swift`
  - `GeoCoordinate`
  - `RoutePointEntity`
  - `RecordingSessionEntity`
  - `DaySummaryEntity`
  - `JourneyEntity`
  - `FootageColorCategory`
  - `BadgeProgress`
  - `PlaceSummaryEntity`
  - `MediaReference`
  - `FootageNote`
  - `RecordingLifecycleState`
  - `WidgetStateSnapshot`
  - `UserProfilePreferences`

- `Footage/Domain/DomainPolicies.swift`
  - `RoutePointValidationPolicy`
  - `RecordingStateTransitionPolicy`
  - `BadgeEligibilityPolicy`
  - `DateGroupingPolicy`
  - `ColorCategorySelectionPolicy`

- `FootageTests/DomainModelsTests.swift`
- `FootageTests/DomainPoliciesTests.swift`

## Safety Notes

- Domain files import `Foundation` only.
- No UIKit, RealmSwift, MapKit, CoreLocation, WidgetKit, URLSession, or SwiftUI dependency was added to `Footage/Domain`.
- No Realm model, schema version, migration, Storyboard, asset, widget file, entitlement, signing setting, bundle identifier, app group identifier, Pod, or user-facing flow was changed.
- Existing UIKit screens and legacy managers still drive production behavior.
- Debug descriptions redact coordinates, note text, local media identifiers, and object identifiers.

## What Remains

- Move existing service-level CoreLocation policies into pure domain equivalents only after parity tests are in place.
- Add mapper/adapters from current Realm objects to the new domain entities.
- Start Phase R11 by defining use-case protocols and wiring one read-only path first.
