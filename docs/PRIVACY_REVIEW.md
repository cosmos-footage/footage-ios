# Privacy Review

Date: 2026-07-04.

## Data Collected Locally

- Walking route latitude/longitude points.
- Route timestamps.
- Distance summaries.
- User-selected route colors/categories.
- Optional photos attached to footsteps.
- Optional notes attached to footsteps.
- App group widget state: tracking status, distance totals, selected color.

## Data Stored Locally

- Realm stores route hierarchy, footsteps, photos, notes, distance, color, place, and badge data.
- UserDefaults stores app state, widget state, local installation identity, sync outbox scaffolding, and scaffolded auth identity metadata.

## Optional Future Cloud Data

Cloud backup is scaffolded but disabled by default. If enabled in a future production phase, cloud data may include:

- owner/device identifiers
- route batch metadata
- private route point objects
- optional media metadata or media objects

No production upload is enabled today.

## Data Not Collected

- No analytics SDK.
- No tracking SDK.
- No ad SDK.
- No public route sharing.
- No AWS credentials.
- No raw tokens intentionally logged.

## Logging Policy

Do not log:

- raw latitude/longitude
- notes
- photos
- bearer tokens
- anonymous device tokens
- provider identity tokens
- presigned URLs
- S3 object identifiers and internal random storage keys

Cloud/restore/auth scaffolds log operation status only.

## Cloud Deletion Policy

The API spec includes cloud-data deletion scaffolding. The app does not currently expose production cloud deletion because production cloud backup is not enabled.

Local on-device data must not be deleted by cloud deletion calls unless a separate explicit local deletion flow is implemented and confirmed by the user.

## Export Policy

A future privacy export should be owner-scoped, private, and delivered through short-lived server-authorized URLs. No production export flow exists today.

## Auth Linking Policy

Auth linking must preserve existing anonymous `ownerId`.

Login must not strand or reassign local data. Recording must remain available without login.

Raw provider tokens and emails must not be logged.
