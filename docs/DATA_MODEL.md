# Data Model

This document defines the target local and server data model for the Footage renewal. It also describes how the current Realm models should migrate safely.

## Current Realm Model Summary

Current persistent Realm objects:

- `Year`
- `Month`
- `DayData`
- `Footstep`
- `Distance`
- `Color`
- `Place`
- `Badge`
- `WidgetRealm`

Current route hierarchy:

```text
Year
  Month
    DayData
      Footstep
```

Current `Footstep` fields:

- `timestamp: Date`
- `latitude: Double`
- `longitude: Double`
- `color: String`
- `setAsStart: Bool`
- `photos: List<Data>`
- `notes: List<String>`

Current `DayData` fields:

- `date: Int`
- `distance: Double`
- `preview: Data`
- `footsteps: List<Footstep>`

Current limitations:

- No primary keys.
- No owner/device/installation IDs.
- No server IDs.
- No sync status.
- Photos are stored inline in Realm as binary data.
- Deletions are not represented as tombstones.

## Target Identifier Model

Identifiers:

- `ownerId`: logical owner of the data.
- `deviceId`: logical device identity returned by bootstrap.
- `installationId`: app install identity generated locally before bootstrap.
- `recordingId`: stable identifier for a recording session or day route.
- `pointId`: stable identifier for a route point.
- `syncBatchId`: stable identifier for a sync upload batch.
- `idempotencyKey`: stable retry key, recommended as `deviceId + syncBatchId + schemaVersion`.

Auth-ready rule:

- `ownerId` is the durable data owner.
- `authUserId` is nullable and never replaces `ownerId`.
- Anonymous data must link to auth without changing `ownerId`.

## Local Model

### LocalOwner

```text
localId: String
ownerId: String?
authUserId: String?
authProvider: String?
createdAt: Date
updatedAt: Date
```

### LocalDevice

```text
localId: String
deviceId: String?
installationId: String
anonymousTokenRef: String?
createdAt: Date
updatedAt: Date
lastBootstrapAt: Date?
```

`anonymousTokenRef` should point to secure storage, not plain UserDefaults.

### RecordingSession

```text
localId: String
recordingId: String
serverId: String?
ownerId: String?
deviceId: String?
localDate: String
startedAt: Date
endedAt: Date?
distanceMeters: Double
primaryColor: String?
syncStatus: String
createdAt: Date
updatedAt: Date
deletedAt: Date?
```

### RoutePoint

```text
localId: String
pointId: String
serverId: String?
recordingId: String
ownerId: String?
deviceId: String?
timestamp: Date
latitude: Double
longitude: Double
horizontalAccuracy: Double?
altitude: Double?
speed: Double?
course: Double?
color: String
setAsStart: Bool
sequence: Int
syncStatus: String
createdAt: Date
updatedAt: Date
deletedAt: Date?
```

### DaySummary

```text
localId: String
serverId: String?
ownerId: String?
deviceId: String?
localDate: String
distanceMeters: Double
recordingCount: Int
pointCount: Int
previewAssetId: String?
syncStatus: String
createdAt: Date
updatedAt: Date
deletedAt: Date?
```

### MediaAsset

```text
localId: String
assetId: String
serverId: String?
ownerId: String?
deviceId: String?
recordingId: String?
pointId: String?
kind: String
localFilePath: String?
objectKey: String?
contentType: String
byteSize: Int
checksumSha256: String?
note: String?
syncStatus: String
createdAt: Date
updatedAt: Date
deletedAt: Date?
```

Recommendation:

- Move new photos/previews toward file-backed local storage plus metadata, not inline database blobs.
- Preserve old inline Realm photos until migration/export is implemented.

### SyncBatch

```text
localId: String
syncBatchId: String
ownerId: String?
deviceId: String?
installationId: String
schemaVersion: Int
idempotencyKey: String
status: String
attemptCount: Int
objectKey: String?
checksumSha256: String?
createdAt: Date
updatedAt: Date
completedAt: Date?
lastErrorCode: String?
lastErrorMessage: String?
```

Suggested `syncStatus` values:

- `localOnly`
- `pending`
- `syncing`
- `uploaded`
- `synced`
- `failed`
- `deleted`

Phase 2 app scaffolding currently uses the local enum cases requested for the iOS outbox draft:

- `localOnly`
- `pending`
- `syncing`
- `synced`
- `failed`

Server/upload-specific states such as `uploaded` and deletion tombstones remain target-model concepts and are not implemented in local storage yet.

## Phase 2 Implemented Local Scaffolding

Added as plain Swift types without Realm schema migration:

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

Added repository protocols:

- `RouteRepository`
- `DaySummaryRepository`
- `DeviceIdentityRepository`
- `MigrationExportRepository`
- `SyncOutboxRepository`

Added safe local/Realm-backed scaffolds:

- `RealmRouteRepository`
- `RealmDaySummaryRepository`
- `RealmMigrationExportRepository`
- `LocalDeviceIdentityRepository`
- `LocalSyncOutboxRepository`

`LocalDeviceIdentityRepository` generates `installationId` once and stores it in local `UserDefaults`. This value identifies the app install before any server bootstrap. It is not the same as `ownerId` or `deviceId`:

- `installationId`: local app-install identity; exists before auth or network.
- `ownerId`: future durable data owner returned by bootstrap or restore flow.
- `deviceId`: future logical device identity returned by bootstrap.

No backend, S3, auth, or network call is implemented in Phase 2.

## Server Model

### owners

```text
owner_id primary key
created_at
updated_at
deleted_at nullable
cloud_data_deleted_at nullable
```

### devices

```text
device_id primary key
owner_id foreign key
installation_id
display_name nullable
platform
created_at
updated_at
last_seen_at
revoked_at nullable
```

### auth_identities

```text
auth_identity_id primary key
owner_id foreign key
provider
provider_subject_hash
email_hash nullable
created_at
updated_at
revoked_at nullable
```

### recordings

```text
recording_id primary key
owner_id foreign key
device_id foreign key
local_date
started_at
ended_at nullable
distance_meters
point_count
schema_version
created_at
updated_at
deleted_at nullable
```

### route_point_batches

```text
batch_id primary key
sync_batch_id unique with device_id
owner_id foreign key
device_id foreign key
recording_id foreign key
object_key
content_type
content_length
checksum_sha256
point_count
schema_version
created_at
completed_at nullable
deleted_at nullable
```

The server should not store raw route points in request logs. Whether route points are parsed into PostgreSQL is a later decision; initial backup can store compressed objects in private S3 plus metadata.

### media_assets

```text
asset_id primary key
owner_id foreign key
device_id foreign key
recording_id nullable
point_id nullable
object_key
kind
content_type
content_length
checksum_sha256 nullable
created_at
updated_at
deleted_at nullable
```

### sync_batches

```text
sync_batch_id primary key
owner_id foreign key
device_id foreign key
installation_id
idempotency_key unique
schema_version
status
created_at
updated_at
completed_at nullable
```

## Route Batch File Format

Recommended initial route batch format: gzip-compressed NDJSON.

Each line:

```json
{"pointId":"pt_01JZ8R...","recordingId":"rec_01JZ8R...","timestamp":"2026-07-04T00:02:03Z","latitude":37.1234567,"longitude":127.1234567,"horizontalAccuracy":8.4,"speed":1.2,"color":"#EADE4Cff","setAsStart":false,"sequence":42}
```

Privacy note:

- Do not log this file content.
- Keep the bucket private and encrypted.
- Download only through server-authorized short-lived URLs.

## Migration Strategy From Current Realm

Phase 0/1:

- Do not change Realm schema.
- Document current model and build risks.
- Add no destructive migrations.

Phase 2 additive migration:

- Add local IDs to current Realm objects where possible in a later, explicitly migrated step.
- For `Footstep`, later add `pointId`, `recordingId`, `deviceId`, nullable `ownerId`, `syncStatus`, `createdAt`, `updatedAt`, and nullable `deletedAt`.
- For `DayData`, later add `recordingId` or a mapping table to `RecordingSession`.
- For `Distance`, keep as a derived summary until replaced by `DaySummary`.
- Keep old `Year`/`Month` hierarchy during migration so existing UI keeps working.

Backfill rules:

- `installationId`: generated once and stored locally.
- `deviceId`: populated after bootstrap; before bootstrap it may be null.
- `ownerId`: populated after bootstrap; before bootstrap it may be null.
- `recordingId`: generated deterministically or stored once per `DayData`.
- `pointId`: generated once per `Footstep`; if no primary key exists, migration must persist the generated value and never regenerate it on later launches.
- `createdAt`: use existing timestamp for route points; use migration time for summaries where no source exists.
- `updatedAt`: migration time.
- `syncStatus`: `localOnly` for existing data.

Backup before migration:

- Before any schema migration that touches route points/photos/notes, create a local export or Realm backup plan.
- If cloud backup is already available, upload an encrypted/private Realm export under `owners/{ownerId}/backups/realm/{backupId}.realm.zip`.

Do not:

- Delete `Year`, `Month`, `DayData`, or `Footstep` in early phases.
- Move photos out of Realm without a tested migration and rollback path.
- Convert date integers to strings in place without preserving old fields or a compatibility adapter.
