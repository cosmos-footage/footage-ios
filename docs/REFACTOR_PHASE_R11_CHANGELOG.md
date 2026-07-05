# Refactor Phase R11 Changelog

Date: 2026-07-05.

## Goal

Introduce a use-case layer that legacy UIKit can call now and a rewritten UI can call later, while preserving current Realm-first behavior and avoiding any user-facing flow changes.

## Commands Run

```sh
git status --short
rg --files Footage/Domain Footage/Data Footage/Services Footage/App FootageTests docs
find . -maxdepth 3 \( -name '*.xcworkspace' -o -name '*.xcodeproj' -o -name '*.entitlements' \) -print
xcodebuild -list -workspace footage.xcworkspace
rg -n "C0D810|UseCases" footage.xcodeproj/project.pbxproj
xcodebuild -list -workspace footage.xcworkspace
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

## Results

- Initial `git status --short` showed only the pre-existing Xcode user state file: `footage.xcworkspace/xcuserdata/nyeok.xcuserdatad/UserInterfaceState.xcuserstate`.
- The sandboxed `xcodebuild -list -workspace footage.xcworkspace` attempt failed with CoreSimulator permission noise and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.`
- The approved `xcodebuild -list -workspace footage.xcworkspace` command succeeded and listed the expected schemes.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.

## Added

- `Footage/Domain/UseCases.swift`
  - `HomeDashboardUseCase`
  - `DateTimelineUseCase`
  - `StatsOverviewUseCase`
  - `BackupPreparationUseCase`
  - `RestorePreviewUseCase`
  - `AuthLinkingReadinessUseCase`
  - `SettingsPreferencesUseCase`
  - `RecordingLifecycleUseCase`

- `FootageTests/UseCasesTests.swift`

## Composition

`AppCompositionRoot` now has factories for the new use cases:

- `makeHomeDashboardUseCase`
- `makeDateTimelineUseCase`
- `makeStatsOverviewUseCase`
- `makeBackupPreparationUseCase`
- `makeRestorePreviewUseCase`
- `makeAuthLinkingReadinessUseCase`
- `makeSettingsPreferencesUseCase`
- `makeRecordingLifecycleUseCase`

## Safety Notes

- Existing ViewControllers are not migrated yet.
- No Realm model, schema version, migration, Storyboard, asset, widget file, entitlement, signing setting, bundle identifier, app group identifier, Pod, or visible UI flow was changed.
- Use cases depend on existing repository/service protocols and adapters instead of directly opening Realm.
- Backup, Restore, and Auth remain disabled or opt-in according to existing feature flags and settings.
- Recording remains local-first; the new lifecycle use case only wraps the pure domain transition policy.

## What Remains

- Start R12 by consolidating repository/service protocols and reducing direct Realm access in view controllers and managers.
- Migrate one read-only UIKit call site to a use case after presentation models exist.
- Keep mutation-heavy recording migration behind explicit side-effect order tests.
