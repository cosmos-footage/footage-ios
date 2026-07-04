# Phase 3 Changelog: Recording Engine Extraction

Date: 2026-07-04.

## Scope

Phase 3 introduced a small recording engine boundary while preserving the existing Home screen recording behavior.

Added:

- `Footage/Services/Recording/DistanceCalculator.swift`
- `Footage/Services/Recording/LocationFilter.swift`
- `Footage/Services/Recording/RecordingStateStore.swift`
- `Footage/Services/Recording/RecordingService.swift`

Changed:

- `HomeViewController` now writes the existing widget keys `isTracking`, `distanceToday`, and `distanceTotal` through `RecordingStateStore`.
- The existing location delegate flow, map rendering, Realm models, Realm writes, photo/note storage, widget target, Storyboards, assets, signing, bundle identifiers, entitlements, Pods, and app group identifiers were preserved.

Not changed:

- No network calls.
- No S3 upload logic.
- No auth logic.
- No analytics or tracking SDK.
- No destructive Realm migration.
- No widget source modification.
- No full `CLLocationManagerDelegate` migration from `HomeViewController` yet.

## New Components

`DistanceCalculator` is independent of UIKit, MapKit rendering, Realm, and UserDefaults. It calculates distance, elapsed seconds, and derived speed with a guard for non-positive elapsed time.

`LocationFilter` is independent of UIKit, MapKit rendering, Realm, and UserDefaults. It models the existing speed, distance, no-speed, and always-on warmup decisions as pure Swift/CoreLocation logic.

`RecordingStateStore` wraps the existing app group UserDefaults keys and falls back to standard UserDefaults only when the app group store is unavailable. The fallback keeps callers safe, but production widget sharing still depends on the `group.footage` app group.

`RecordingService` is an adapter scaffold for future extraction. It can configure a location manager, filter points, calculate distance, persist through repositories, and report decisions to a delegate. It is not yet used as the live Home screen recording delegate because that migration touches UI animation, notifications, map rendering, and Realm write sequencing.

## Commands Run

```sh
git status --short
```

Result:

```text
 M footage.xcworkspace/xcuserdata/nyeok.xcuserdatad/UserInterfaceState.xcuserstate
```

```sh
rg -n "CLLocationManager|didUpdateLocations|startTracking|stopTracking|checkForMovement|isValid|LocationUpdate\\.processNewLocation|UserDefaults\\(suiteName|isTracking|distanceToday|distanceTotal|selectedColor|group\\.footage" Footage/Scene/Home/HomeViewController.swift Footage/Scene/Stats Footage/Data/Repositories MainWidget
```

Result: succeeded. The main live recording flow is in `HomeViewController`, with Realm writes delegated through `LocationUpdate`, `DateManager`, `ColorManager`, and `PlaceManager`. Widget state uses app group keys in the app and widget.

```sh
rg --files Footage | rg "(Footage/Scene/Home/HomeViewController.swift|Footage/Scene/Stats|Footage/Data|Footage/Domain|Footage/Services|Model)"
```

Result: succeeded. Existing Phase 2 repository/domain/sync scaffolds and legacy model/manager surfaces were present.

```sh
nl -ba Footage/Scene/Home/HomeViewController.swift | sed -n '1,210p'
nl -ba Footage/Scene/Home/HomeViewController.swift | sed -n '210,390p'
nl -ba Footage/Scene/Home/HomeViewController.swift | sed -n '520,630p'
nl -ba Footage/Scene/Stats/LocationUpdate.swift | sed -n '1,240p'
```

Result: succeeded. Confirmed the recording flow, filter constants, widget state writes, and local Realm write path.

```sh
xcodebuild -list -workspace footage.xcworkspace
```

Sandboxed result:

```text
xcodebuild: error: 'footage.xcworkspace' is not a workspace file.
```

Likely cause: sandboxed Xcode/CoreSimulator access failed to reach normal user simulator/log/cache services.

Approved Xcode result:

```text
Information about workspace "footage":
    Schemes:
        EFCountingLabel
        footage
        MainWidgetExtension
        Pods-footage
        Pods-MainWidgetExtension
        Realm
        Realm-realm_objc_privacy
        RealmSwift
        RealmSwift-realm_swift_privacy
        WidgetColorSelection
```

```sh
scripts/phase1-build-baseline.sh
```

Result: succeeded with exit code 0. The script ran `pod install`, workspace listing, and Debug/Release simulator builds for the `footage` app scheme and `MainWidgetExtension` scheme with `CODE_SIGNING_ALLOWED=NO`.

## Build Result

Workspace listing succeeded when run with normal Xcode/CoreSimulator access.

The Phase 1 baseline build script succeeded after Phase 3 changes. Build success is based on the script exit code 0 from `scripts/phase1-build-baseline.sh`.

## Behavior Notes

Existing UI behavior was not intentionally changed.

The only live call-site change is routing existing app group tracking and distance writes through `RecordingStateStore` while preserving the same keys. The live CoreLocation delegate, map polyline extension, notification behavior, and Realm write order remain in `HomeViewController` and existing managers for now.

## Next Step

Next recommended phase: migrate the live recording delegate into `RecordingService` in small slices, starting with pure `DistanceCalculator` and `LocationFilter` usage in `HomeViewController`, then moving persistence orchestration only after behavior parity is verified.
