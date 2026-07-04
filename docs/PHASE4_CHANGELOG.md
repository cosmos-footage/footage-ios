# Phase 4 Changelog: Local Sync Outbox

Date: 2026-07-04.

## Scope

Phase 4 implemented a local-only sync preparation layer. It can prepare route-point batches for future backup and track outbox item state transitions without contacting a backend.

Added:

- `Footage/Services/Sync/SyncOutboxModels.swift`
- `Footage/Services/Sync/RoutePointNDJSONSerializer.swift`
- `Footage/Services/Sync/LocalSyncBatchBuilder.swift`

Changed:

- `SyncOutboxRepository` now includes item-based enqueue/list/status transition methods.
- `LocalSyncOutboxRepository` now persists local outbox items in `UserDefaults` in addition to the Phase 2 draft batch storage.
- The main app target now includes the new Sync service files.

Not changed:

- No Realm schema was changed.
- No destructive migration was added.
- No route/photo/note storage was moved.
- No network, backend, S3, upload, presign, or Auth logic was added.
- No UI was added.
- No widget source, Storyboard, asset, signing, bundle identifier, entitlement, Pod, or app group setting was changed.

## New Local Sync Concepts

Added local plain Swift/Codable concepts:

- `IdempotencyKey`
- `SyncBatchConfiguration`
- `SyncBatchDraft`
- `SyncOutboxItem`
- `SyncOutboxItemType`
- `SyncOutboxItemStatus`
- `SyncOutboxPayload`
- `LocalBackupStatus`
- `RoutePointNDJSONRecord`

The idempotency key is generated locally as:

```text
installationId:syncBatchId:schema_<schemaVersion>
```

This intentionally uses `installationId` until the future bootstrap flow provides durable `ownerId` and `deviceId`. It is enough for retrying the same locally persisted batch, but future cloud backup should prefer server-issued device identity once available.

## Repository Behavior

`LocalSyncOutboxRepository` can now:

- enqueue a single outbox item
- enqueue multiple outbox items
- list all outbox items
- list pending items
- list failed items
- mark an item as syncing
- mark an item as synced
- mark an item as failed with an error message
- retry a failed item
- prepare route-point batches from `MigrationExportDraft`
- return local backup preparation status

The old Phase 2 `SyncOutboxDraft` methods remain available for compatibility.

## Batch and Serialization Behavior

`LocalSyncBatchBuilder` groups exported route points by day and chunks each day by `SyncBatchConfiguration.maxPointsPerBatch`.

`RoutePointNDJSONSerializer` creates a local plain NDJSON string representation for future `points.ndjson.gz` work. Gzip compression, file persistence, checksums, object keys, S3 upload, and API calls are not implemented in this phase.

The NDJSON payload contains private location data and must not be logged.

## Commands Run

```sh
git status --short
```

Result: succeeded. The worktree already contained Phase 3 changes and the existing Xcode user state file.

```sh
sed -n '1,260p' /Users/nyeok/.codex/attachments/9af4893a-5a04-4063-ab9d-29e81af9f4c3/pasted-text.txt
sed -n '1,220p' AGENTS.md
sed -n '1,260p' Footage/Data/Repositories/LocalSyncOutboxRepository.swift
sed -n '1,220p' Footage/Services/Sync/SyncOutboxDraft.swift
sed -n '1,220p' Footage/Data/Repositories/RepositoryProtocols.swift
sed -n '1,220p' Footage/Domain/Identifiers.swift
sed -n '1,220p' Footage/Data/Migration/MigrationExportModels.swift
sed -n '1,220p' Footage/Domain/RecordingDrafts.swift
sed -n '1,240p' docs/DATA_MODEL.md
rg -n "SyncOutbox|SyncStatus|syncBatch|outbox|Idempotency|idempotency" Footage docs
```

Result: succeeded. Existing Phase 2/3 outputs and sync-related documentation were inspected before implementation.

```sh
xcodebuild -list -workspace footage.xcworkspace
```

Result: succeeded with approved Xcode access. Workspace schemes listed:

```text
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

Result: succeeded with exit code 0. The script ran `pod install`, workspace listing, and Debug/Release simulator builds for `footage` and `MainWidgetExtension` with `CODE_SIGNING_ALLOWED=NO`.

## Behavior Notes

Existing user-facing behavior was not intentionally changed. The local outbox is not wired into visible UI or cloud sync yet.

Existing Realm data remains untouched. Batch preparation reads from export drafts and writes only local Codable outbox state.

## Next Step

Next recommended phase: wire local outbox preparation to recording persistence in a local-only way, then introduce cloud backup bootstrap/presign/complete APIs only after explicit opt-in UI and privacy review.
