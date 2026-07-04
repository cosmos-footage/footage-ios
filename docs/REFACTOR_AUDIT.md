# Refactor Audit

Date: 2026-07-04.

## Scope

This audit starts the refactor program for the Footage iOS app. It is intentionally evidence-first: no source, Storyboard, Realm model, asset, entitlement, widget, signing, bundle identifier, app group, or CocoaPods surface should be removed until references are proven and a build checkpoint passes.

## Safety Baseline

Commands run:

```sh
git status --short
xcodebuild -list -workspace footage.xcworkspace
rg --files
find . -maxdepth 4 \( -name '*.storyboard' -o -name '*.xib' -o -name '*.xcassets' -o -name '*.entitlements' -o -name 'Info.plist' -o -name 'Podfile' -o -name '*.xcworkspace' -o -name '*.xcodeproj' \) -print | sort
rg -n "import RealmSwift|try! Realm|Realm\\(|\\.objects\\(|realm\\.write|UserDefaults\\(|suiteName: \\\"group\\.footage\\\"|CLLocationManager|startUpdatingLocation|UNUserNotificationCenter|print\\(|debugPrint\\(|NSLog|!\\.|\\)!" Footage MainWidget
rg -n "customClass=|storyboardIdentifier=|referencedIdentifier=|selector=|outlet property=" Footage/Storyboard Footage/Scene -g '*.storyboard' -g '*.xib'
rg -n "PBXFileReference|PBXBuildFile|PBXSourcesBuildPhase|PBXResourcesBuildPhase|PBXFrameworksBuildPhase" footage.xcodeproj/project.pbxproj
find Footage MainWidget -type f \( -name '*.swift' -o -name '*.storyboard' -o -name '*.xib' -o -name '*.plist' \) -print | wc -l
```

Results:

- `xcodebuild -list -workspace footage.xcworkspace` succeeded.
- Workspace schemes remain available: `footage`, `MainWidgetExtension`, Pods, Realm, RealmSwift, and related dependency schemes.
- Current local uncommitted change before this audit was only Xcode user UI state: `footage.xcworkspace/xcuserdata/nyeok.xcuserdatad/UserInterfaceState.xcuserstate`.
- `Footage` and `MainWidget` currently contain 117 Swift/Storyboard/XIB/plist files by the initial inventory command.

## Sub-Agent Work Distribution

Sagan: dead-code and unused-file audit.

- Read-only.
- Owns target membership, Storyboard references, code references, asset reference evidence.
- Output: safe candidates, ambiguous candidates, do-not-remove surfaces, cleanup commit suggestions.

Avicenna: architecture and dependency-boundary audit.

- Read-only.
- Owns coupling hotspots and proposed module boundaries.
- Output: dependency direction, refactor sequence, risks and guardrails.

Rawls: S3/cloud backup readiness audit.

- Read-only.
- Owns backup pipeline production-readiness, token/security gaps, file-level next tasks.
- Output: production gaps, security risks, S3-ready implementation sequence.

## Initial Hotspots

These are not deletion candidates. They are refactor risk areas that should be extracted behind stable boundaries.

- `Footage/Scene/Home/HomeViewController.swift`: location manager, MapKit rendering, recording state, notification scheduling, widget app group state, first-launch defaults, and legacy route loading are coupled in one controller.
- `Footage/Scene/Stats/DateManager.swift`: direct Realm reads/writes, distance aggregation, and date summary behavior remain static-manager based.
- `Footage/Scene/Stats/ColorManager.swift`: direct Realm reads/writes for color statistics.
- `Footage/Scene/Stats/PlaceManager.swift`: reverse geocoding, Realm writes, and stats aggregation are coupled.
- `Footage/Scene/Stats/LevelManager.swift` and `Footage/Scene/Stats/BadgeGiver.swift`: badge persistence and notification side effects are mixed.
- `Footage/Scene/Date/JourneyManager.swift`: Realm mutation, photo/note handling, map movement, and view state are coupled.
- `Footage/Scene/Map/MapViewController.swift`: direct Realm reads and location access are still inside presentation code.
- `MainWidget/SmallView.swift`: app group force unwraps remain and should be guarded in a widget-specific hardening pass.

## Do Not Remove Without Migration Plan

- Realm object classes under `Footage/Model`.
- `Footage/Storyboard/**` and `Footage/Scene/**/*.xib`.
- `Footage/Resource/Assets.xcassets` and `MainWidget/Assets.xcassets`.
- `MainWidget/**` widget source and target configuration.
- `Entitlements/**`.
- `Podfile`, `Podfile.lock`, `Pods`, RealmSwift, EFCountingLabel, WidgetKit, MapKit.
- App group keys such as `isTracking`, `distanceToday`, `distanceTotal`, and `selectedColor`.

## Immediate Safe Cleanup Themes

These themes are candidates for later commit-sized work only after sub-agent evidence is merged and baseline build passes:

- Remove or wrap obvious debug `print` statements that do not carry user-facing behavior.
- Replace remaining app and widget App Group `UserDefaults` force unwraps with guarded access.
- Introduce repository/use-case facades around direct Realm reads without deleting existing managers.
- Add tests around pure services before moving call sites.
- Avoid asset deletion until Storyboard, runtime string, and badge-name references are cross-checked.

## Dead-Code Audit Results

Sub-agent: Sagan.

Result: no Swift source file is currently safe to delete. All Swift files under `Footage` and `MainWidget` were found in source build phases. Several files are scaffold-only or empty-looking, but still participate in Storyboard wiring or modernization plans.

Strongest safe cleanup candidate:

- `Footage/Resource/Assets.xcassets/levels/badGEFrame.imageset`

Evidence:

- No exact references outside the asset catalog.
- `Stats.storyboard` references the real used asset `badgeFrame`, not `badGEFrame`.
- Hash comparison showed `badGEFrame.imageset` is byte-for-byte identical to `Footage/Resource/Assets.xcassets/badgeFrame.imageset`.

Action:

- Do not delete it in R0/R1.
- Move it to the first R2 verified cleanup commit only after a build check.

Needs manual verification before removal:

- `Footage/Resource/Assets.xcassets/SettingsCellImage.imageset`
- `Footage/Resource/Assets.xcassets/SettingsCellIconSelected.imageset`
- `journeyBackButton`
- `pecilButton`
- `postAddButton`
- `monthOne` through `monthFour`

Reason:

- They have no exact source/Storyboard references in the audit, but they look like legacy UI assets and may be referenced visually or through older flows. Verify app navigation before removing.

Do not remove:

- `SettingsViewController.swift`: empty-looking, but it is the custom class and Storyboard identifier for the Settings tab root.
- Backup/restore/auth/sync/repository scaffolds: compiled and intentionally documented as future architecture.
- Dynamic badge/place/color assets: image names are generated at runtime, such as `color + "Paper"` and `cityNameEN() + "_newb/_junior/_master"`.

## Architecture Audit Results

Sub-agent: Avicenna.

Largest coupling hotspot:

- `Footage/Scene/Home/HomeViewController.swift`

Why:

- Owns widget state, `CLLocationManager`, MapKit rendering, movement filtering, notification scheduling, badge checks, Realm write orchestration through `LocationUpdate`/`DateManager`, update-time `UserDefaults` migration, review prompting, and UI animation.

Other high-coupling areas:

- `Footage/Scene/Stats/DateManager.swift`
- `Footage/Scene/Stats/ColorManager.swift`
- `Footage/Scene/Stats/PlaceManager.swift`
- `Footage/Scene/Stats/LevelManager.swift`
- `Footage/Scene/Stats/BadgeGiver.swift`
- `Footage/Scene/Date/JourneyManager.swift`
- `Footage/Scene/Map/MapViewController.swift`
- `MainWidget/SmallView.swift`

Dependency direction:

```text
UIKit/Storyboard VCs + Widget UI
  -> Services / Use Cases
    -> Repository Protocols / State Protocols
      -> Data Adapters
        -> Realm / UserDefaults / Network
```

First safe refactor sequence:

1. Add central constants/store wrappers for app preference keys and app group widget keys. Keep exact keys and `group.footage`.
2. Route `HomeViewController` movement filtering through `LocationFilter` and `DistanceCalculator` while preserving thresholds.
3. Introduce a `NotificationScheduler` for existing local notifications.
4. Route `JourneyManager` media writes through a `MediaRepository`.
5. Migrate read-only Date/Stats screens to repository protocols.
6. Split badge awarding rules from popup rendering and notification side effects.
7. Only after parity, migrate live recording persistence to `RecordingService`.

Guardrails:

- Preserve the current local-first order: route write first, then stats/color/place/badge/widget/cloud side effects.
- Do not rename app group keys: `isTracking`, `distanceToday`, `distanceTotal`, `selectedColor`, or color-name keys.
- Be careful with static mutable state such as `DateManager.lastData`, `LocationUpdate.lastLocation`, `PlaceManager.localityList`, and `HomeViewController.distanceTotal`.

## S3 / Cloud Backup Readiness Results

Sub-agent: Rawls.

Current state:

- Production state is disabled scaffold, not production-ready.
- `CloudBackupConfiguration` defaults to invalid URL and both `isCloudBackupEnabled` and `isDevelopmentUploadEnabled` set to `false`.
- `CloudBackupService` can call bootstrap, presign, presigned PUT, upload complete, and sync batch registration when explicitly enabled and supplied a bearer token.
- There is no app launch, recording flow, Settings UI, background task, or opt-in path calling the pipeline.

Production gaps:

- Add Keychain-backed token persistence for `anonymousDeviceToken`, expiry, and future auth tokens.
- Replace plain NDJSON-in-`UserDefaults` payload storage with file-backed staging.
- Add gzip compression and upload `application/x-ndjson+gzip`.
- Compute checksum over the compressed upload payload.
- Split outbox metadata from payload bytes.
- Add retry/backoff, `nextAttemptAt`, terminal/retryable error classification, and `.syncing` recovery after relaunch.
- Add deterministic dedupe/source keys so repeated preparation does not create duplicate remote objects.
- Add explicit environment/config injection while preserving disabled-by-default behavior.
- Add background upload scaffolding later, behind opt-in and config gates.
- Add Settings opt-in and status UI before any production backup is enabled.

Security/privacy findings:

- No AWS credentials were found in the app/server docs scope.
- Current cloud backup logs are generic DEBUG-only messages and do not log raw coordinates, tokens, URLs, or object keys.
- Raw route coordinates currently may be stored as NDJSON in `UserDefaults` via the local outbox scaffold. This must move to protected file-backed staging before production.
- Restore downloads need host, size, checksum, and gzip validation before import.
- Cloud logging should move away from generic `print` to a redaction-first logger.

Commit-sized S3 tasks:

1. Add `CloudBackupTokenStore` using Keychain.
2. Add gzip file staging for route batches.
3. Split outbox metadata from payload bytes.
4. Harden upload validation and redacted errors.
5. Add deterministic dedupe keys for staged route chunks.
6. Add background upload scaffolding behind opt-in.
7. Add Settings opt-in/status UI.
8. Add restore checksum/gzip/size validation.
9. Add tests for staging, idempotency, retry state, checksum, and redacted logging.

## Pending Inputs

- None. Initial sub-agent audit pass is complete.
