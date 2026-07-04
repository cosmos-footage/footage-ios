# Refactor Phase R6 Changelog

Date: 2026-07-04

## Scope

Phase R6 prepares the disabled cloud backup pipeline for S3-style uploads without enabling automatic backup or adding AWS credentials to the app.

## R6-1 Completed

- Added `BackupPayloadStager` injection to `CloudBackupService`.
- Routed route NDJSON upload preparation through `FileBackedBackupPayloadStager`.
- Preserved disabled-by-default behavior for Cloud Backup and development upload.
- Preserved the existing in-memory presigned upload API path while adding a transient protected file staging step.
- Cleaned up staged payload files on presign failure, upload failure, upload-complete failure, and after sync batch registration callback.
- Added composition-root construction for the payload stager.

## R6-2 Completed

- Added gzip compression support to `FileBackedBackupPayloadStager`.
- Built gzip payloads with a gzip header, deflate payload, CRC32, and original-size trailer.
- Updated bootstrap capabilities to advertise gzip support when Cloud Backup is explicitly enabled.
- Changed route NDJSON upload preparation to stage `application/x-ndjson+gzip`.
- Calculated upload checksum and content length from the compressed staged file.

## R6-3 Completed

- Added `localPayloadFilePath` and `payloadContentLength` metadata to `SyncOutboxPayload`.
- Added `LocalSyncOutboxPayloadStore` for protected Application Support payload files.
- Updated new local outbox enqueue paths to move raw NDJSON out of `UserDefaults`.
- Kept legacy `ndjson` payload compatibility in `CloudBackupService`.
- Updated backup upload preparation to read payload bytes from either legacy inline NDJSON or the new local payload file.

## R6-4 Completed

- Added `nextAttemptAt` to `SyncOutboxItem`.
- Added exponential retry delay metadata when marking items failed.
- Cleared retry metadata when items move to `.syncing`, `.synced`, or manual retry.
- Included interrupted `.syncing` items in pending scans so a later manual backup run can recover them after relaunch.

## R6-5 Completed

- Added `ManualCloudBackupRunning`.
- Added `ManualCloudBackupRunner` to prepare current Realm route export into local outbox batches.
- Added `ManualBackupPreparationResult` with prepared item count and local backup status.
- Added composition-root construction for the manual runner.
- Kept the runner manual-only; it is not called from app launch, recording, Settings, or background tasks.

## R6-6 Completed

- Added `CloudBackupSettingsStore` for local opt-in preference storage.
- Added a code-only Cloud Backup row to General Settings.
- Added a Settings switch that stores opt-in preference locally but does not start backup or upload.
- Added local outbox pending/failed status text to the Settings row.
- Kept Cloud Backup and development upload disabled by default.

## Behavior

- No automatic backup, restore, auth, S3 upload, or backend call path was enabled.
- No AWS credentials, bucket names, presigned URLs, object keys, raw coordinates, photos, or notes are logged.
- Existing local-first recording behavior was not changed.

## Validation

- `git diff --check` should pass.
- `scripts/phase1-build-baseline.sh` should pass before commit.

## Next Step

Next phase should keep the Settings opt-in disconnected from automatic upload until backend/device QA is complete.
