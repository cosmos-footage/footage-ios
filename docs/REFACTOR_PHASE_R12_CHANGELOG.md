# Refactor Phase R12 Changelog

Date: 2026-07-05.

## Goal

Consolidate repository and service boundaries by moving small, high-confidence Date/Journey persistence paths behind adapters while preserving current UIKit behavior and Realm-first local storage.

## Commands Run

```sh
git status --short
rg -n "Refactor Phase R12|R12|Repository and Service Consolidation|Refactor Phase" docs/MODERNIZATION_PLAN.md docs
git diff -- Footage/Data/Repositories/RepositoryProtocols.swift Footage/Data/Repositories/RealmRepositories.swift Footage/Data/Repositories/LocalPreferencesRepositories.swift Footage/Scene/Date/DateViewController.swift Footage/Scene/Date/JourneyViewController.swift FootageTests/LocalPreferencesRepositoriesTests.swift docs/MODERNIZATION_PLAN.md
sed -n '395,450p' docs/MODERNIZATION_PLAN.md
sed -n '1,120p' docs/REFACTOR_PHASE_R11_CHANGELOG.md
sed -n '140,190p' docs/UI_REWRITE_REFACTOR_PLAN.md
ls scripts
sed -n '1,220p' scripts/phase1-build-baseline.sh
rg -n "try!? Realm\(|Realm\(|realm\.write|UserDefaults\(|UserDefaults\.standard|suiteName:|CLGeocoder\(|UNUserNotificationCenter|PHPhotoLibrary|Product\.products|LAContext" Footage FootageTests
find . -maxdepth 3 \( -name '*.xcworkspace' -o -name '*.xcodeproj' -o -name '*.entitlements' \) -print
xcodebuild -list -workspace footage.xcworkspace
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "import RealmSwift|try!? Realm\(|realm\.write|UserDefaults\.standard\.data\(forKey: \"profileImage\"\)|UserDefaults\.standard\.string\(forKey: \"userName\"\)" Footage/Scene/Date Footage/Data/Repositories
```

## Results

- Initial `git status --short` showed the R12 source edits plus the pre-existing Xcode user state file: `footage.xcworkspace/xcuserdata/nyeok.xcuserdatad/UserInterfaceState.xcuserstate`.
- A sandboxed `xcodebuild -list -workspace footage.xcworkspace` attempt failed with CoreSimulator permission noise and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.`
- The approved `xcodebuild -list -workspace footage.xcworkspace` command succeeded and listed the workspace schemes.
- `git diff --check` succeeded.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.

## Changed

- Added `JourneyPreviewRepository` so Journey preview persistence can be called without opening Realm in the view controller.
- Added `UserProfileRepository` and `UserProfileSnapshot` so profile display data can be loaded without direct `UserDefaults` reads in `DateViewController`.
- Added `RealmJourneyPreviewRepository` as the Realm-backed adapter for existing `DayData`, `Month`, and `Year` preview data.
- Added `UserDefaultsUserProfileRepository` as the local profile preferences adapter using the existing `userName` and `profileImage` keys.
- Updated `JourneyViewController` to save generated preview images through `JourneyPreviewRepository` and count annotated footsteps through `RouteRepository`.
- Updated `DateViewController` to load the profile name and image through `UserProfileRepository`.
- Added focused tests for profile preference persistence and clearing.

## Safety Notes

- No Realm classes, schema version, migrations, Storyboards, assets, widget files, entitlements, signing settings, bundle identifiers, app group identifiers, Pods, or visible UI flows were changed.
- `JourneyViewController` still writes the same preview data to the same Realm-backed objects through the new adapter.
- `DateViewController` still reads the same `UserDefaults.standard` keys through the new adapter.
- No network, S3, restore, auth, analytics, tracking, or cloud sync behavior was introduced.
- Recording remains local-first and unchanged.

## What Remains

- Continue reducing direct Realm and platform access from remaining view controllers and manager classes through small adapter-backed migrations.
- Start R13 with read-only presentation models for the Date/Home/Journey shell before attempting broader UI rewrites.
- Keep mutation-heavy recording and widget paths behind explicit side-effect order tests before migrating them.
