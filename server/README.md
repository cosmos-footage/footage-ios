# Footage Server Proposal

This directory intentionally contains only a proposed backend architecture. Do not implement the full backend inside this iOS repository unless explicitly requested.

## Goals

- Support private cloud backup and restore for sensitive walking-route data.
- Keep the iOS app local-first.
- Avoid public storage and client-side AWS credentials.
- Support anonymous owner/device identity before auth.
- Allow future Sign in with Apple or Cognito linking without changing data ownership.

## Recommended Stack

Option A:

- FastAPI
- PostgreSQL
- S3-compatible object storage
- SQLAlchemy/Alembic
- Optional Redis/SQS for async jobs later

Option B:

- NestJS
- PostgreSQL
- S3-compatible object storage
- Prisma or TypeORM
- Optional Redis/SQS for async jobs later

Either stack is acceptable. FastAPI is simple and pragmatic for a small API; NestJS may be preferable if the project later needs a larger TypeScript service ecosystem.

## Core Services

- Bootstrap service: creates/resumes anonymous `ownerId`, `deviceId`, and `installationId` mapping.
- Upload service: validates object ownership and returns short-lived presigned S3 URLs.
- Sync service: records idempotent sync batches and uploaded object metadata.
- Restore service: builds owner-scoped restore manifests.
- Auth linking service: links Apple/Cognito identities to an existing owner.
- Deletion service: deletes owner cloud metadata and private S3 objects.

## Storage

PostgreSQL stores metadata:

- owners
- devices
- auth identities
- recordings
- sync batches
- route point batch object metadata
- media asset metadata

S3 stores private objects under random, server-generated storage keys:

```text
objects/7f/3a/{randomObjectName}
objects/d2/91/{randomObjectName}
```

The database, not the S3 path, defines ownership and relationships. Object metadata should include `objectId`, internal `storageKey`, `ownerId`, `deviceId`, `recordingId`, `syncBatchId`, `objectType`, `contentType`, `contentLength`, `checksumSha256`, upload status, and optional metadata JSON. API clients receive `objectId`; they never receive or choose `storageKey`.

## Security and Privacy

- The S3 bucket must be private.
- S3 objects must be encrypted at rest.
- The app must never include AWS credentials.
- Presigned URLs must be short-lived.
- Server logs must not contain raw latitude/longitude, notes, photos, tokens, presigned URLs, or internal storage keys.
- API access must be owner/device scoped.
- Cloud backup must be opt-in.
- Cloud data deletion must delete metadata and object storage.

## Auth-Ready Model

Anonymous mode:

- `ownerId` exists.
- `deviceId` exists.
- `authUserId` is null.

Linked mode:

- Same `ownerId`.
- `authUserId` is attached through `auth_identities`.
- Data ownership does not move.

This prevents data loss when Sign in with Apple or Cognito is added later.

## API Contract

See `../docs/API_SPEC.md` for the initial endpoint contract:

- `POST /v1/bootstrap`
- `POST /v1/uploads/presign`
- `POST /v1/uploads/complete`
- `POST /v1/sync/batches`
- `GET /v1/restore/manifest`
- `POST /v1/auth/link`
- `DELETE /v1/account/cloud-data`

## Non-Goals For This Repository

- No backend app scaffolding yet.
- No Terraform or cloud resources yet.
- No public route sharing.
- No analytics pipeline.
- No direct client AWS SDK credentials.
