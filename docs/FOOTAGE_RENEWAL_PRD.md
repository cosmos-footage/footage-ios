# Footage Renewal PRD: 2026 Modernization and Cloud Sync

## 1. Product Definition

Footage is a personal walking-route archive app that records where the user has walked and turns those routes into a visual map of their life.

The renewed product should become a private local-first life map that safely records walking traces on device, backs them up to the cloud, and lets the user restore them across time, devices, and future accounts.

The durable product value is not fitness tracking. It is not losing the map of a user's life.

## 2. Repository-Aware Current State

The current repository is a 2020-era Swift iOS app with:

- UIKit and Storyboard-based UI under `Footage/Storyboard` and `Footage/Scene`.
- Main app target `footage` and WidgetKit extension target `MainWidgetExtension`.
- CocoaPods dependencies: `RealmSwift 10.1.2`, `Realm 10.1.2`, and `EFCountingLabel 5.1.2`.
- MapKit/CoreLocation route recording and rendering through `HomeViewController`, `LocationUpdate`, `DateManager`, and `DrawOnMap`.
- Realm models under `Footage/Model`: `Year`, `Month`, `DayData`, `Footstep`, `Distance`, `Color`, `Place`, `Badge`, `WidgetRealm`, and view structs such as `Journey`/`Asset`.
- App Group UserDefaults with `group.footage`, used by the app and widget for tracking state, selected color, and distance counters.
- Widget UI under `MainWidget`, including `MainWidget.swift` and `SmallView.swift`.
- Background location mode declared in `Footage/Resource/Info.plist`.

Current core route model:

- `Year`
- `Month`
- `DayData`
- `Footstep`

`Footstep` currently contains timestamp, latitude, longitude, color, start-marker state, photos, and notes. `DayData` contains date, distance, preview image data, and a list of footsteps.

## 3. Product Strategy

Footage should move from a personal iOS project to a privacy-first personal data product. The modernization must prioritize:

- Data preservation.
- Local-first route recording.
- Device migration and restore.
- Private cloud backup.
- Future auth linking without losing anonymous data.
- Long-term App Store maintainability.

## 4. Goals

### P0

- Make the app buildable with modern Xcode.
- Preserve existing local-first recording behavior.
- Protect existing local data and app group state.
- Define a migration path from existing Realm data.
- Add a repository/service layer around data access before replacing Realm.
- Add cloud-sync-ready identifiers to core entities.
- Prepare anonymous owner/device/installation identity.
- Document privacy-first cloud backup UX.
- Document S3 object storage and backend API contracts.
- Keep authentication optional but structurally supported.

### P1

- Introduce a renewed SwiftUI shell where practical, without a full UI rewrite.
- Improve recording reliability and state management.
- Add a local sync outbox.
- Add cloud backup opt-in.
- Add S3 upload through presigned URLs.
- Add restore manifest flow.
- Add server-side metadata model.

### P2

- Add Sign in with Apple.
- Add Cognito or equivalent auth adapter if selected.
- Add multi-device restore.
- Add photo and note backup.
- Add richer map timeline and memory UX.
- Add App Store release assets, privacy policy, privacy manifest, and privacy disclosures.

## 5. Non-Goals

The renewal must not introduce these in the first implementation:

- Social feed.
- Public route sharing.
- Real-time location sharing.
- Web app.
- AI insights.
- Ads.
- Third-party tracking SDKs.
- Complex multi-device merge.
- Full backend implementation inside this iOS repository unless explicitly requested.

## 6. Users

Primary user:

- Wants to keep a private record of where they have walked.
- Values memory, place, time, and personal history.
- Does not want complex fitness metrics.
- Wants the record to survive reinstall and device change.

Secondary user:

- Uses the app as a lightweight life log.
- Wants daily/monthly/yearly views.
- May attach photos or notes to route points.

## 7. Core User Stories

- I can start recording my walking route.
- I can stop recording.
- I can see today's route on a map.
- I can see past routes by date.
- I can see total distance and daily distance.
- I can keep my data on device without internet.
- I can opt in to cloud backup.
- I can see whether my data is backed up.
- I can reinstall the app and restore old data.
- I can later connect an Apple account without losing anonymous data.
- I can delete my cloud data.

## 8. App Requirements

### Build Modernization

- Build with modern Xcode and the current App Store SDK requirement.
- Keep deployment target explicit. The renewed baseline is iOS 18.0 for the app, widget, project, and generated Pods settings.
- Preserve `MainWidgetExtension`.
- Preserve entitlements and app group unless a migration plan covers both app and widget.
- Remove brittle architecture settings only after a baseline is captured.

### Dependency Modernization

Current:

- CocoaPods.
- RealmSwift.
- EFCountingLabel.

Direction:

- Prefer Swift Package Manager for future dependencies.
- Avoid unnecessary dependencies.
- Do not remove Realm in Phase 0.
- Add repository abstraction before replacing persistence.
- Evaluate keeping Realm temporarily, migrating to SwiftData, or moving high-volume route points to SQLite-backed storage.

Recommendation:

- Phase 1: repository abstraction over existing Realm and a dependency audit.
- Phase 2: decide persistence replacement based on route-point volume, widget constraints, migration complexity, and restore requirements.

### UI Modernization

- Do not rewrite every screen at once.
- Introduce a SwiftUI shell gradually if it can host existing UIKit flows.
- Keep MapKit rendering stable.
- Prioritize recording reliability over visual redesign.
- Initial renewed IA: Today, Map, Timeline, Stats, Backup, Settings.

### Location Recording

- Continue using CoreLocation and MapKit.
- Recording must work offline.
- Recording must save locally first.
- Reject impossible jumps using speed, distance, accuracy, and timestamp filters.
- Preserve route color/category concept unless product review removes it.
- Extract `RecordingService`, `LocationFilter`, `RouteRepository`, and `SyncOutbox` from the current `HomeViewController` flow.

## 9. Data Requirements

Every local entity added or migrated for sync must support:

- `localId`
- nullable `serverId`
- nullable `ownerId` before cloud bootstrap
- `deviceId`
- `syncStatus`
- `createdAt`
- `updatedAt`
- nullable `deletedAt`

Core renewed entities:

- `Owner`
- `Device`
- `RecordingSession`
- `RoutePoint`
- `DaySummary`
- `MediaAsset`
- `SyncBatch`

Migration must preserve existing `Year`/`Month`/`DayData`/`Footstep` data and should add identifiers through additive schema changes or export/import paths.

## 10. Cloud Backup Requirements

Principles:

- Local-first.
- Cloud-backed.
- Auth-ready.
- Privacy-first.
- Idempotent.
- Recoverable.

Cloud backup must be opt-in. Turning backup off must stop new uploads without deleting local data. Deleting cloud data must remove server metadata and private object storage objects for the owner.

### Anonymous Bootstrap

Before auth, the app requests anonymous owner/device identity from the server. The server returns:

- `ownerId`
- `deviceId`
- `installationId`
- anonymous device token or refreshable credential

All cloud data is stored under `ownerId`. Later auth links to the same `ownerId`.

### Sync Outbox

- Route points are written locally immediately.
- Unsynced records are queued locally.
- Uploads happen in batches.
- Retries are automatic and idempotent.
- `idempotencyKey` is required.

Recommended key format:

`deviceId + syncBatchId + schemaVersion`

## 11. S3 Storage

S3 should store:

- Compressed route point batch files.
- Preview images.
- Photos if enabled.
- Realm/export backups during migration.
- Manifest files.

Recommended private object storage policy:

```text
objects/{shardA}/{shardB}/{randomObjectName}
```

The backend owns the relationship between data and files. It stores a random internal `storageKey` in the database and exposes only an app-safe `objectId` in API responses. DB metadata maps each object to owner/device/recording/sync batch/object type/checksum/content length.

Security requirements:

- Bucket is private.
- The app never includes AWS credentials.
- Server issues short-lived presigned URLs.
- Objects are encrypted at rest.
- Access is owner/device scoped through database metadata, not through readable S3 paths.

## 12. Backend Requirements

Recommended backend:

- FastAPI or NestJS.
- PostgreSQL.
- S3.
- Optional Redis/SQS later.
- Optional Cognito adapter later.

Server responsibilities:

- Bootstrap owner/device.
- Issue upload/download presigned URLs.
- Store metadata.
- Verify object ownership.
- Process sync batches.
- Support restore manifest.
- Support account linking.
- Support deletion/export.

## 13. API Requirements

Required endpoints:

- `POST /v1/bootstrap`
- `POST /v1/uploads/presign`
- `POST /v1/uploads/complete`
- `POST /v1/sync/batches`
- `GET /v1/restore/manifest`
- `POST /v1/auth/link`
- `DELETE /v1/account/cloud-data`
- Future: `GET /v1/account/export`

## 14. Auth-Ready Identity Model

Do not make `authUserId` the primary owner.

Use:

- `ownerId`: logical owner of data.
- `deviceId`: physical/logical device.
- `installationId`: app install identity.
- `authUserId`: nullable external auth subject.
- `provider`: `apple`, `cognito`, or future provider.

Before login, `ownerId` exists and `authUserId` is null. After login, the same `ownerId` is linked to `authUserId`.

## 15. Privacy Requirements

Location data is sensitive.

- Cloud backup must be opt-in.
- User can turn backup off.
- User can delete cloud data.
- Do not log raw latitude/longitude in app or server logs.
- Do not add third-party analytics without explicit review.
- Do not use location data for ads.
- Do not expose public route URLs.
- Provide privacy policy and App Store privacy disclosure.
- Include privacy manifest where required.
- Account deletion must trigger cloud data handling flow.

If Sign in with Apple is used for account creation, include server-to-server notification support for Apple account status changes.

## 16. Analytics and Success Metrics

Footage must not use third-party tracking SDKs, ad attribution SDKs, or raw location analytics in the renewal baseline. Product and technical metrics should be privacy-preserving and should avoid raw coordinates, route geometry, photo content, note content, and persistent cross-app identifiers.

Allowed measurement direction:

- Local-only counters surfaced to the user or included in explicit diagnostics.
- Server operational metrics for sync and restore health.
- Aggregated counts for backup opt-in, sync completion, restore completion, and deletion completion.
- Crash/build diagnostics only after a separate privacy review, with location payloads disabled.

Prohibited without explicit review:

- Third-party analytics SDKs.
- Advertising identifiers.
- Public route URLs.
- Event logs containing raw latitude/longitude.
- Behavioral tracking unrelated to backup, restore, recording reliability, or App Store quality.

Product metrics:

- First successful recording rate.
- 7-day retained recording users.
- Cloud backup opt-in rate.
- First sync success rate.
- Restore success rate.
- Data deletion completion rate.

Technical metrics:

- Crash-free sessions.
- Location recording failure rate.
- Sync success rate.
- Duplicate point rate.
- Restore failure rate.
- S3 storage cost per active user.
- API p95 latency.

Metrics must be measured without raw location analytics or third-party tracking. Prefer local counters and privacy-preserving server operational metrics.

## 17. Rollout

- Phase 0: Build/audit baseline, docs, `AGENTS.md`, project inventory.
- Phase 1: Xcode/project modernization, dependency audit, build recovery, CI baseline.
- Phase 2: Data repository abstraction, Realm export, sync-ready IDs.
- Phase 3: Recording service extraction, location filtering, local sync outbox.
- Phase 4: SwiftUI renewal shell, Today/Map/Timeline/Stats/Backup/Settings.
- Phase 5: Backend API spec, S3 presigned upload, cloud backup opt-in.
- Phase 6: Restore flow.
- Phase 7: Auth linking.
- Phase 8: TestFlight/App Store readiness.

## 18. MVP Acceptance Criteria

MVP is complete when:

- App builds on modern Xcode.
- Existing route recording still works.
- Existing local data is not destroyed.
- Data access is behind repository interfaces.
- Route points have stable local IDs.
- Sync outbox exists locally.
- Cloud backup PRD/API/spec are documented.
- Anonymous owner/device model is documented.
- S3 object model is documented.
- Auth linking path is documented.
- Privacy requirements are documented.
- Next implementation phase is actionable.
