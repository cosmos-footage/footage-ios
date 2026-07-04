# Phase 6 Changelog: Restore Flow Scaffold

Date: 2026-07-04.

## Scope

Phase 6 added a restore preview scaffold. It can request a restore manifest, download private route objects through manifest URLs, parse plain NDJSON route points, and create a non-destructive import plan.

Added:

- `Footage/Services/Restore/RestoreModels.swift`
- `Footage/Services/Restore/RestoreService.swift`
- `Footage/Services/Restore/Parsing/RoutePointRestoreParser.swift`
- `Footage/Services/Restore/Import/RestoreDuplicateDetector.swift`
- `Footage/Services/Restore/Import/RestoreImportRepository.swift`

Changed:

- `CloudBackupAPIClient` now has restore manifest GET and private data download helpers.
- The main app target now includes the restore scaffold files.

Not changed:

- No automatic restore.
- No visible restore UI.
- No Auth requirement.
- No Realm schema or destructive migration.
- No local route/photo/note deletion or overwrite.
- No AWS credentials or SDK.
- No raw latitude/longitude, bearer token, or presigned URL logging.

## Restore Behavior

`RestoreService` is disabled unless `CloudBackupConfiguration.isCloudBackupEnabled` is true and a bearer token is explicitly supplied. It is not invoked by app launch, recording, widget, or UI code.

`RestoreImportPlan` defaults to `RestoreConflictPolicy.skipExisting`, `requiresUserConfirmation = true`, and `canImport = false`.

`LocalRestoreImportRepository.importData` currently throws instead of mutating Realm. Destructive replacement is explicitly rejected.

## Parsing

`RoutePointRestoreParser` supports plain NDJSON route point parsing into `RoutePointDraft`.

Gzip parsing remains deferred. Adding gzip should happen with file-backed staging and tests.

## Validation

Commands run:

```sh
git status --short
xcodebuild -list -workspace footage.xcworkspace
scripts/phase1-build-baseline.sh
```

Results:

- Workspace listing succeeded.
- `scripts/phase1-build-baseline.sh` succeeded after Phase 6 changes.

## Next Step

Next recommended phase: Auth linking scaffold that preserves anonymous `ownerId` and keeps recording usable without login.
