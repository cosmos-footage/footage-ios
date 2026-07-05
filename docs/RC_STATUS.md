# Release Candidate Status

Date: 2026-07-04.

## Current Build Status

- `xcodebuild -list -workspace footage.xcworkspace` succeeds.
- `scripts/phase1-build-baseline.sh` succeeds with exit code 0.
- The baseline script runs `pod install`, lists the workspace, then builds the `footage` and `MainWidgetExtension` schemes for Debug and Release with `CODE_SIGNING_ALLOWED=NO`.
- Refactor Phase R7 added a `FootageTests` XCTest target for pure service coverage.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeds with 15 passing tests.
- Signed archive was not run because signing and provisioning were intentionally not changed during renewal.

## Current Feature Status

Production-ready for the current local app baseline:

- Existing UIKit and Storyboard app flow remains in place.
- Existing Realm-backed local route, photo, note, stats, and widget state remain the active persistence path.
- iOS minimum deployment target is now iOS 18.0.
- App and widget simulator builds pass the established baseline.

Scaffold-only:

- Repository abstraction exists but legacy managers still own most call sites.
- Recording service extraction exists but the legacy `HomeViewController` flow is still preserved.
- Local sync outbox exists locally, but no automatic cloud sync is enabled.
- Cloud Backup API and presigned upload client exist, but are disabled by default.
- Restore preview scaffolding exists, but restore is not automatic and import is not destructive.
- Auth linking scaffolding exists, but auth is not required for recording and provider login is not enabled.

## Unsafe Default Audit

- Cloud Backup enabled by default: no. `CloudBackupConfiguration.isCloudBackupEnabled` defaults to `false`.
- Development upload enabled by default: no. `isDevelopmentUploadEnabled` defaults to `false`.
- Restore automatic execution: no. Restore service is not called by app launch, recording, or widget code.
- Auth required for recording: no.
- Placeholder production base URL: yes, the disabled scaffold uses `https://footage-cloud-backup.invalid`.
- Hardcoded token: not found.
- AWS credentials: not found.
- Full presigned URL logs: not found.
- Raw latitude/longitude logs: not found in active logging. Latitude/longitude model fields and docs remain expected.
- App Group UserDefaults force unwraps: app-side force unwraps touched in Phase 9 were guarded. Widget source force unwraps remain as a known follow-up because this phase did not modify widget source.
- Destructive import/replace defaults: no. Restore defaults to `skipExisting`, and destructive import throws.

## Hardening Applied

- Removed debug printing of pending notification request objects when tracking starts.
- Replaced app-side App Group `UserDefaults` force unwraps in touched settings/home code with optional access.

## Known Blockers

- Signed archive and provisioning are not verified.
- App Store privacy nutrition labels and review copy are not finalized.
- Background location behavior needs physical-device QA.
- Widget App Group force unwraps remain in `MainWidget/SmallView.swift`.
- StoreKit products and purchase/restore flows need App Store Connect validation.
- Cloud Backup requires explicit opt-in UI, secure token storage, backend deployment, gzip/file staging, tests, and privacy review before enabling.
- Restore requires explicit user confirmation UX, additive import implementation, stable persisted point IDs, tests, and rollback notes before enabling.
- Auth requires Sign in with Apple/Cognito UI, capability review, secure token handling, server verification, and privacy copy before enabling.
- Test coverage is still early and currently covers selected recording utilities, sync outbox behavior, cloud backup request construction, restore duplicate detection, and auth owner mismatch handling.

## Known Privacy Risks

- Route history contains precise location and timestamps.
- Photos and notes may contain sensitive personal information.
- Background location requires clear App Store review language and user-facing copy.
- Future cloud backup must avoid logging route coordinates, notes, photos, bearer tokens, provider tokens, object identifiers, internal storage keys, presigned URLs, and AWS credentials.

## Known Data Migration Risks

- Realm remains the source of truth and should not be destructively migrated for this release candidate.
- Photos and notes remain in Realm until a tested file-backed migration and rollback path exists.
- Restore duplicate detection is not production-grade until stable point IDs are persisted locally.

## Manual QA Checklist

- Install over an existing local Realm database and verify route history, photos, and notes remain.
- Launch, start recording, stop recording, relaunch, and verify local-first route persistence.
- Test background recording on a physical device with location permissions.
- Verify widget loading, color/category state, start/stop deep link behavior, and distance values.
- Verify password/Face ID gate.
- Verify photo and note attachment flows.
- Verify App Store subscription screens and restore purchase behavior.
- Verify default builds do not perform cloud backup, restore, or auth linking.

## Go / No-Go

Recommendation: No-Go for production App Store release today.

Reason: simulator build baseline is healthy, but signed archive/provisioning, physical-device background location QA, widget QA, App Store privacy metadata, StoreKit validation, and cloud/restore/auth security review remain human release blockers.

Recommendation: Go for continued internal TestFlight preparation after signing/provisioning is verified and manual QA passes.
