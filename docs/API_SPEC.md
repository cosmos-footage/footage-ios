# API Spec

This API is a draft contract for a privacy-first, local-first Footage backend. It is intentionally auth-ready but does not require user login at bootstrap.

Base URL examples:

- Production: `https://api.example.com`
- Version prefix: `/v1`

Common requirements:

- All requests use HTTPS.
- All mutating requests include `Idempotency-Key` when retryable.
- Server logs must not include raw latitude/longitude, notes, photos, presigned URLs, anonymous device tokens, or auth tokens.
- The app never receives AWS credentials.
- Presigned URLs are short-lived.
- Server verifies owner/device scope for every object key.
- Phase 5 iOS scaffolding keeps cloud backup disabled by default and may use `application/x-ndjson` only as a development-only local scaffold. Production route batches should use `application/x-ndjson+gzip`.

Common identifiers:

- `ownerId`: logical data owner.
- `deviceId`: logical device identity.
- `installationId`: app install identity.
- `recordingId`: stable route/recording identifier.
- `syncBatchId`: stable upload batch identifier.
- `idempotencyKey`: retry deduplication key.

## POST /v1/bootstrap

Creates or resumes anonymous owner/device identity.

Request:

```json
{
  "installationId": "inst_01JZ8Q2Q2Z9R8P9M5RBM2G8K3K",
  "appBundleId": "co.el.footage",
  "appVersion": "1.2.2",
  "platform": "ios",
  "device": {
    "vendorIdHash": "sha256:optional-device-vendor-hash",
    "model": "iPhone",
    "osVersion": "26.0"
  },
  "capabilities": {
    "schemaVersion": 1,
    "supportsGzip": true,
    "supportsRestore": true
  }
}
```

Response:

```json
{
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "deviceId": "dev_01JZ8Q4D2CC37N7R7HDQ8WFE6V",
  "installationId": "inst_01JZ8Q2Q2Z9R8P9M5RBM2G8K3K",
  "anonymousDeviceToken": "opaque-token",
  "tokenExpiresAt": "2026-08-03T00:00:00Z",
  "serverTime": "2026-07-04T00:00:00Z",
  "minimumClientSchemaVersion": 1,
  "upload": {
    "maxBatchBytes": 5242880,
    "acceptedContentTypes": [
      "application/x-ndjson+gzip",
      "image/png",
      "image/jpeg",
      "application/zip"
    ]
  }
}
```

Notes:

- If the same installation is bootstrapped again, the server should return the existing owner/device mapping when possible.
- `anonymousDeviceToken` authenticates future anonymous backup calls until auth linking exists.

## POST /v1/uploads/presign

Returns a presigned S3 URL for an owner-scoped object.

Headers:

```text
Authorization: Bearer {anonymousDeviceToken or auth token}
Idempotency-Key: dev_...:batch_...:schema_1:presign
```

Request:

```json
{
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "deviceId": "dev_01JZ8Q4D2CC37N7R7HDQ8WFE6V",
  "recordingId": "rec_01JZ8R0D1G8T4N0KZ8M0E7WQCY",
  "syncBatchId": "batch_01JZ8R10V4A3C7KX5Y9P0P3T4T",
  "objectType": "routePoints",
  "contentType": "application/x-ndjson+gzip",
  "contentLength": 184321,
  "checksumSha256": "base64-sha256-checksum"
}
```

Response:

```json
{
  "uploadId": "upl_01JZ8R1D5E5X3S93S2QDPE5DKA",
  "method": "PUT",
  "url": "https://private-bucket.s3.amazonaws.com/...",
  "expiresAt": "2026-07-04T00:15:00Z",
  "requiredHeaders": {
    "Content-Type": "application/x-ndjson+gzip",
    "x-amz-checksum-sha256": "base64-sha256-checksum"
  },
  "objectKey": "owners/own_01JZ8Q4AVGS9DZK3HR0N4W35W7/devices/dev_01JZ8Q4D2CC37N7R7HDQ8WFE6V/recordings/rec_01JZ8R0D1G8T4N0KZ8M0E7WQCY/points.ndjson.gz"
}
```

## POST /v1/uploads/complete

Confirms that a presigned upload completed and records metadata.

Headers:

```text
Authorization: Bearer {anonymousDeviceToken or auth token}
Idempotency-Key: dev_...:batch_...:schema_1:complete
```

Request:

```json
{
  "uploadId": "upl_01JZ8R1D5E5X3S93S2QDPE5DKA",
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "deviceId": "dev_01JZ8Q4D2CC37N7R7HDQ8WFE6V",
  "recordingId": "rec_01JZ8R0D1G8T4N0KZ8M0E7WQCY",
  "syncBatchId": "batch_01JZ8R10V4A3C7KX5Y9P0P3T4T",
  "objectKey": "owners/own_.../devices/dev_.../recordings/rec_.../points.ndjson.gz",
  "checksumSha256": "base64-sha256-checksum",
  "contentLength": 184321
}
```

Response:

```json
{
  "uploadId": "upl_01JZ8R1D5E5X3S93S2QDPE5DKA",
  "status": "completed",
  "recordedAt": "2026-07-04T00:05:12Z"
}
```

## POST /v1/sync/batches

Registers a logical sync batch and its uploaded objects.

Headers:

```text
Authorization: Bearer {anonymousDeviceToken or auth token}
Idempotency-Key: dev_01JZ8Q4D2CC37N7R7HDQ8WFE6V:batch_01JZ8R10V4A3C7KX5Y9P0P3T4T:schema_1
```

Request:

```json
{
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "deviceId": "dev_01JZ8Q4D2CC37N7R7HDQ8WFE6V",
  "installationId": "inst_01JZ8Q2Q2Z9R8P9M5RBM2G8K3K",
  "syncBatchId": "batch_01JZ8R10V4A3C7KX5Y9P0P3T4T",
  "schemaVersion": 1,
  "startedAt": "2026-07-04T00:01:00Z",
  "completedAt": "2026-07-04T00:05:12Z",
  "recordings": [
    {
      "recordingId": "rec_01JZ8R0D1G8T4N0KZ8M0E7WQCY",
      "localDate": "2026-07-04",
      "pointCount": 932,
      "distanceMeters": 4210.7,
      "objects": [
        {
          "objectType": "routePoints",
          "objectKey": "owners/own_.../devices/dev_.../recordings/rec_.../points.ndjson.gz",
          "checksumSha256": "base64-sha256-checksum",
          "contentLength": 184321
        }
      ]
    }
  ]
}
```

Response:

```json
{
  "syncBatchId": "batch_01JZ8R10V4A3C7KX5Y9P0P3T4T",
  "status": "accepted",
  "acceptedRecordings": 1,
  "acceptedObjects": 1,
  "serverTime": "2026-07-04T00:05:13Z"
}
```

## GET /v1/restore/manifest

Returns restore metadata for an owner.

Headers:

```text
Authorization: Bearer {anonymousDeviceToken or auth token}
```

Query parameters:

```text
ownerId=own_01JZ8Q4AVGS9DZK3HR0N4W35W7
deviceId=dev_01JZ8Q4D2CC37N7R7HDQ8WFE6V
since=optional-iso8601
```

Response:

```json
{
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "generatedAt": "2026-07-04T00:10:00Z",
  "schemaVersion": 1,
  "recordings": [
    {
      "recordingId": "rec_01JZ8R0D1G8T4N0KZ8M0E7WQCY",
      "deviceId": "dev_01JZ8Q4D2CC37N7R7HDQ8WFE6V",
      "localDate": "2026-07-04",
      "pointCount": 932,
      "distanceMeters": 4210.7,
      "objects": [
        {
          "objectType": "routePoints",
          "downloadUrl": "https://private-bucket.s3.amazonaws.com/...",
          "expiresAt": "2026-07-04T00:25:00Z",
          "checksumSha256": "base64-sha256-checksum",
          "contentLength": 184321
        }
      ]
    }
  ]
}
```

Phase 6 iOS scaffold note:

- The restore client reads `downloadUrl` values from this manifest directly.
- Plain `application/x-ndjson` parsing is scaffolded first.
- Gzip restore parsing remains future work and should preserve the same privacy rule: do not log route object contents or full private URLs.

## POST /v1/auth/link

Links an external auth subject to an existing owner.

Headers:

```text
Authorization: Bearer {anonymousDeviceToken and/or provider token}
Idempotency-Key: own_...:auth-link:apple:sub-hash
```

Request:

```json
{
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "provider": "apple",
  "providerToken": "apple-identity-token",
  "authorizationCode": "apple-authorization-code",
  "nonce": "client-nonce"
}
```

Response:

```json
{
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "authUserId": "auth_apple_01JZ8T2X1QY4KQ8K7M5Y1DB7ZG",
  "provider": "apple",
  "linkedAt": "2026-07-04T00:20:00Z"
}
```

## DELETE /v1/account/cloud-data

Deletes cloud metadata and private object storage for an owner. Local on-device data is not deleted by this server call.

Headers:

```text
Authorization: Bearer {anonymousDeviceToken or auth token}
Idempotency-Key: own_...:delete-cloud-data:request_...
```

Request:

```json
{
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "confirmation": "DELETE_CLOUD_DATA",
  "reason": "user_requested"
}
```

Response:

```json
{
  "ownerId": "own_01JZ8Q4AVGS9DZK3HR0N4W35W7",
  "status": "delete_scheduled",
  "requestedAt": "2026-07-04T00:30:00Z",
  "estimatedCompletionAt": "2026-07-04T01:30:00Z"
}
```

## Future GET /v1/account/export

Future endpoint for privacy export. The export must be owner-scoped and delivered through short-lived private URLs.
