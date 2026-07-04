# Phase 2 Changelog

Date: 2026-07-04.

## Scope

Phase 2 introduced data repository abstraction and sync-ready local scaffolding. It did not change existing UI behavior, recording flow, Realm schema, widget target, Storyboards, assets, signing, bundle identifiers, entitlements, backend networking, cloud sync, S3 upload, or auth linking.

## Commands Run

```sh
git status --short
sed -n '1,220p' AGENTS.md
sed -n '1,220p' docs/DATA_MODEL.md
sed -n '1,240p' docs/MODERNIZATION_PLAN.md
sed -n '1,220p' Footage/Model/Footstep.swift
sed -n '1,220p' Footage/Model/DayData.swift
sed -n '1,180p' Footage/Model/Year.swift
sed -n '1,180p' Footage/Model/Month.swift
sed -n '1,180p' Footage/Model/Distance.swift
sed -n '1,180p' Footage/Model/Color.swift
sed -n '1,220p' Footage/Model/Place.swift
sed -n '1,180p' Footage/Model/Badge.swift
sed -n '1,260p' Footage/Scene/Date/JourneyManager.swift
sed -n '1,130p' Footage/Scene/Stats/ColorManager.swift
sed -n '1,130p' Footage/Scene/Stats/PlaceManager.swift
sed -n '1,90p' Footage/Scene/Stats/LevelManager.swift
rg -n "try! Realm|Realm\\(|realm\\.write|realm\\.add|realm\\.delete|objects\\(" Footage MainWidget
rg --files Footage
xcodebuild -list -workspace footage.xcworkspace
scripts/phase1-build-baseline.sh
```

## Source Changes

Added:

- `Footage/Domain/Identifiers.swift`
- `Footage/Domain/RecordingDrafts.swift`
- `Footage/Services/Sync/SyncOutboxDraft.swift`
- `Footage/Data/Repositories/RepositoryProtocols.swift`
- `Footage/Data/Repositories/RealmRepositories.swift`
- `Footage/Data/Repositories/LocalDeviceIdentityRepository.swift`
- `Footage/Data/Repositories/LocalSyncOutboxRepository.swift`
- `Footage/Data/Migration/MigrationExportModels.swift`

Updated:

- `footage.xcodeproj/project.pbxproj`
- `docs/DATA_MODEL.md`
- `docs/MODERNIZATION_PLAN.md`
- `docs/TECHNICAL_AUDIT.md`

## Domain Types Added

- `OwnerID`
- `DeviceID`
- `InstallationID`
- `RecordingID`
- `PointID`
- `SyncBatchID`
- `SyncStatus`
- `RecordingSessionDraft`
- `RoutePointDraft`
- `DaySummaryDraft`
- `SyncOutboxDraft`
- `MigrationExportDraft`

## Repository Protocols Added

- `RouteRepository`
- `DaySummaryRepository`
- `DeviceIdentityRepository`
- `MigrationExportRepository`
- `SyncOutboxRepository`

Supplemental boundaries were also kept for existing app surfaces:

- `ColorRepository`
- `PlaceRepository`
- `MediaRepository`
- `BadgeRepository`
- `WidgetStateStore`

## Local/Realm Adapters Added

- `RealmRouteRepository`
- `RealmDaySummaryRepository`
- `RealmMigrationExportRepository`
- `LocalDeviceIdentityRepository`
- `LocalSyncOutboxRepository`

Additional safe wrappers:

- `RealmColorRepository`
- `RealmPlaceRepository`
- `RealmMediaRepository`
- `RealmBadgeRepository`
- `AppGroupWidgetStateStore`

## Installation ID

`LocalDeviceIdentityRepository` generates a stable `installationId` once and stores it in local `UserDefaults`.

`installationId` is not the same as `ownerId` or `deviceId`:

- `installationId` exists locally before network, auth, or bootstrap.
- `ownerId` is the future durable data owner returned by bootstrap.
- `deviceId` is the future logical device identity returned by bootstrap.

No backend, S3, auth, or network logic was added.

## Sync Outbox

`SyncStatus` includes:

- `localOnly`
- `pending`
- `syncing`
- `synced`
- `failed`

`LocalSyncOutboxRepository` persists draft outbox batches to local `UserDefaults`. It does not upload, presign, call a backend, or contact S3.

## Realm and Migration Safety

- No Realm object class was renamed.
- No Realm schema field was added.
- No destructive migration was performed.
- Photos and notes remain in `Footstep.photos: List<Data>` and `Footstep.notes: List<String>`.
- Existing managers and UI call sites remain intact.

## Validation

`scripts/phase1-build-baseline.sh` succeeded after Phase 2 changes. The script ran:

1. `pod install`
2. `xcodebuild -list -workspace footage.xcworkspace`
3. `footage` Debug simulator build
4. `MainWidgetExtension` Debug simulator build
5. `footage` Release simulator build
6. `MainWidgetExtension` Release simulator build

## Remaining Work

- Migrate selected call sites to repository protocols in small patches.
- Add tests around local identity and outbox persistence.
- Add read-only export execution paths after validating export format.
- Design additive Realm schema migration only after backup/export strategy is ready.

## Next Recommended Phase

Phase 3 should migrate low-risk read call sites to repository protocols, starting with stats/day-summary reads. Do not start recording-service extraction until repository call-site migration has a small proven pattern.
