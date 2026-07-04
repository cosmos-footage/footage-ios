# Phase 5 Changelog: Cloud Backup API Client Scaffold

Date: 2026-07-04.

## Scope

Phase 5 added a disabled-by-default cloud backup API scaffold that matches the draft API contract and prepares for a future S3 presigned upload flow.

Added:

- `Footage/Services/Backup/CloudBackupConfiguration.swift`
- `Footage/Services/Backup/CloudBackupLogger.swift`
- `Footage/Services/Backup/CloudBackupService.swift`
- `Footage/Network/CloudBackupAPIClient.swift`
- `Footage/Network/DTO/CloudBackupDTOs.swift`

Changed:

- Registered the new Network and Backup files with the main app target.
- Updated documentation for the disabled-by-default backup scaffold.

Not changed:

- No backup UI was added.
- No app launch, recording, widget, or sync-outbox call site invokes cloud backup automatically.
- No AWS SDK or AWS credentials were added.
- No Auth/login flow was added.
- No Realm schema or migration was added.
- No signing, bundle identifier, entitlement, Pod, Storyboard, asset, app group, or widget target was changed.

## Configuration

`CloudBackupConfiguration` defaults to:

```text
baseURL: https://footage-cloud-backup.invalid
isCloudBackupEnabled: false
isDevelopmentUploadEnabled: false
requestTimeout: 30
schemaVersion: 1
```

Both `isCloudBackupEnabled` and `isDevelopmentUploadEnabled` must be true before `CloudBackupService.runPendingBackup` can upload data. This is intentionally a development-only safety gate for the scaffold.

## API Client

`CloudBackupAPIClient` uses `URLSession` and supports:

- JSON request/response bodies.
- Bearer token header injection.
- `Idempotency-Key` header injection.
- HTTP status code handling.
- JSON decoding failure handling.
- Presigned `PUT` upload using server-provided URL and headers.

The client does not contain AWS access keys, AWS secret keys, public S3 URLs, or Auth logic.

## DTOs

Added DTO scaffolding for:

- `BootstrapRequest`
- `BootstrapResponse`
- `PresignUploadRequest`
- `PresignUploadResponse`
- `UploadCompleteRequest`
- `UploadCompleteResponse`
- `SyncBatchRequest`
- `SyncBatchResponse`
- `RestoreManifestResponse`
- `AuthLinkRequest`
- `AuthLinkResponse`
- `DeleteCloudDataRequest`
- `DeleteCloudDataResponse`

Auth and delete DTOs are present only as contract shapes. No login, account linking, or cloud deletion flow is implemented.

## Service Behavior

`CloudBackupService` can:

- Manually bootstrap an installation when cloud backup is enabled.
- Save returned `ownerId` and `deviceId` through the existing local identity repository.
- Leave `anonymousDeviceToken` unstored; a caller must inject a bearer token explicitly.
- Read pending `SyncOutboxItem` values.
- Build presign, upload complete, and sync batch requests from local outbox metadata.
- Upload NDJSON payload data only when both safety flags are enabled and a bearer token is supplied.
- Mark outbox items as synced or failed.

The service is not wired into app launch, recording, widgets, or visible UI.

## Privacy-Safe Logging

`CloudBackupLogger` logs operation names and coarse status only in debug builds.

It must not log:

- raw latitude/longitude
- notes or photo data
- presigned URLs
- object keys
- bearer tokens
- anonymous device tokens
- AWS credentials

## Commands Run

```sh
git status --short
```

Result: succeeded. The worktree already contained Phase 3 and Phase 4 changes plus the existing Xcode user state file.

```sh
sed -n '1,280p' /Users/nyeok/.codex/attachments/b681c48f-45cf-4ef6-8b75-1dec1ad342d6/pasted-text.txt
sed -n '1,220p' AGENTS.md
sed -n '1,240p' docs/API_SPEC.md
sed -n '240,380p' docs/API_SPEC.md
sed -n '1,260p' Footage/Services/Sync/SyncOutboxModels.swift
sed -n '1,260p' Footage/Data/Repositories/LocalSyncOutboxRepository.swift
rg -n "URLSession|Network|APIClient|Backup|Cloud|token|Bearer|URLRequest|presign|upload" Footage docs/API_SPEC.md docs/MODERNIZATION_PLAN.md
```

Result: succeeded. Existing API contract, Phase 4 outbox state, and network surfaces were inspected before implementation.

```sh
xcodebuild -list -workspace footage.xcworkspace
```

Result: succeeded with approved Xcode access.

```sh
scripts/phase1-build-baseline.sh
```

First result: failed with exit code 65.

Exact compile error:

```text
Footage/Network/CloudBackupAPIClient.swift:212:41: error: reference to property 'decoder' in closure requires explicit use of 'self' to make capture semantics explicit
```

Fix:

- Changed `decoder.decode(...)` to `self.decoder.decode(...)` inside the URLSession callback.

Second result: succeeded with exit code 0. The script ran `pod install`, workspace listing, and Debug/Release simulator builds for `footage` and `MainWidgetExtension` with `CODE_SIGNING_ALLOWED=NO`.

## Build Result

Workspace listing succeeded.

The established Phase 1 baseline build script succeeded after the Phase 5 compile fix.

## What Remains Before Real Cloud Backup

- Add explicit opt-in backup UI and privacy copy.
- Decide secure storage for `anonymousDeviceToken`; it is not stored in Phase 5.
- Add backend availability checks and endpoint configuration outside source-controlled secrets.
- Add gzip compression and file-backed payload staging for route batches.
- Add checksum and retry tests around outbox state transitions.
- Persist stable route point IDs through an additive migration with rollback/export notes.
- Add server implementation and private object storage policy review.
- Keep cloud backup disabled until the above are complete.
