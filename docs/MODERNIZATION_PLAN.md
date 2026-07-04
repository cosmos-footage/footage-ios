# Modernization Plan

This plan assumes the first implementation pass must preserve user data, current recording behavior, bundle identifiers, signing, entitlements, widget target, Storyboards, CocoaPods, Realm, and MapKit rendering.

## Phase 0: Build Recovery and Audit

Status: started.

Deliverables:

- Add repository-specific `AGENTS.md`.
- Add PRD, technical audit, modernization plan, API spec, data model, and server README.
- Inventory targets, dependencies, entitlements, app group, models, and critical flows.
- Attempt `xcodebuild -list -workspace footage.xcworkspace`.
- Document environment blockers instead of claiming a build baseline.

Acceptance criteria:

- Documentation exists and reflects the actual repository.
- No app behavior, signing, dependencies, user data models, assets, or targets are removed.
- Build/list command result is recorded.

Current finding:

- Full Xcode is installed and selected at `/Applications/Xcode.app/Contents/Developer`.
- CocoaPods 1.10.0 is installed in the user gem directory at `/Users/nyeok/.gem/ruby/2.6.0/bin/pod`, with Ruby 2.6 compatibility pins for `public_suffix`, `ffi`, and `i18n`.
- `pod install` restored `Pods/Pods.xcodeproj` and `Pods/Manifest.lock`.
- Workspace listing succeeds. Available schemes are `EFCountingLabel`, `footage`, `MainWidgetExtension`, `Pods-footage`, `Pods-MainWidgetExtension`, `Realm`, `RealmSwift`, and `WidgetColorSelection`.
- The first successful Debug simulator build command is `xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build`.
- Two minimal Pods build-setting fixes were needed during Phase 1: set generated Pods deployment target to iOS 13.0 and remove the stale iPhone simulator `arm64` exclusion. The renewal baseline has since been raised to iOS 18.0 across the app, widget, project, and generated Pods settings.
- Follow-up warning cleanup removed the CocoaPods `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` override warning and the `LABiometryType.opticID` exhaustiveness warning.
- Follow-up Interface Builder cleanup added a reuse identifier to an otherwise unused empty `Date.storyboard` prototype cell and removed the Date storyboard reuse identifier warning.
- `scripts/phase1-build-baseline.sh` now captures the repeatable Phase 1 local baseline: `pod install`, workspace scheme listing, main app Debug simulator build, and widget extension Debug simulator build.
- Release simulator workspace builds now also succeed for `footage` and `MainWidgetExtension` with `CODE_SIGNING_ALLOWED=NO`.
- First dependency patch completed: EFCountingLabel `5.1.2 -> 6.0.0.1`.
- EFCountingLabel 6 required a minimal `@MainActor` compatibility fix for `HomeAnimation.homeStartAnimation(_:)` and `HomeAnimation.homeStopAnimation(_:)`.
- Second dependency patch completed: Realm/RealmSwift `10.1.2 -> 20.0.4` using the CocoaPods trunk version available to this project.
- Realm Swift GitHub also shows `v20.0.5` as latest, while local CocoaPods resolution reports `20.0.4`; treat that as a future follow-up, not a blocker for the CocoaPods `20.0.4` baseline.
- Remaining dependency modernization candidate is CocoaPods tooling `1.10.0 -> 1.16.2`.
- `scripts/phase1-build-baseline.sh` now runs `pod install`, workspace listing, and Debug/Release simulator builds for both app and widget sequentially.
- `pod outdated --no-repo-update` reports no remaining pod updates with the current CocoaPods Specs state.
- Remaining warnings are documented in the technical audit and are currently from Realm/RealmSwift generated Pods.
- Phase 2 repository scaffolding added `Footage/Domain`, `Footage/Data/Repositories`, `Footage/Data/Migration`, and `Footage/Services/Sync`.
- Added sync-ready plain Swift identifier/draft types, local installation identity persistence, local sync outbox draft persistence, repository protocols, and local/Realm-backed adapter scaffolds.
- The repository boundary step is additive only; no Realm schema, destructive migration, existing manager implementation, widget file, Storyboard, asset, app group, bundle identifier, entitlement, signing setting, network call, S3 logic, or auth flow was changed.

## Phase 1: Dependency and Project Modernization

Goal: recover a repeatable build baseline with modern Xcode while changing as little product code as possible.

Tasks:

- Keep full Xcode selected with `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` when building locally.
- Keep CocoaPods tooling pinned to the lockfile generator version `1.10.0`; use `/Users/nyeok/.gem/ruby/2.6.0/bin/pod` unless PATH is updated.
- Use `scripts/phase1-build-baseline.sh` for the repeatable local build baseline.
- Use workspace builds for the real app/widget baseline; project-only builds do not include Pods targets correctly.
- Continue warning cleanup as small follow-up patches, prioritizing build compatibility warnings before UI/storyboard cleanup.
- Before changing dependency versions, document current versions, candidate target versions, expected build impact, and rollback notes.
- Consider CocoaPods tooling third if still needed; dependency builds now pass with CocoaPods 1.10.0.
- Keep Realm local-only during modernization. Do not adopt Realm Device Sync; the planned private backup service should remain separate from Realm's deprecated sync service.
- Deployment target strategy is now set to iOS 18.0 across the app, widget, project, and generated Pods settings.
- Keep the iPhone simulator `arm64` exclusion removed for generated Pods targets; it blocks Xcode 26.6 Apple Silicon simulator builds.
- Review `UIRequiredDeviceCapabilities = armv7` after baseline.
- Check RealmSwift modern compatibility options: current CocoaPods version, latest CocoaPods-compatible version, and SPM option.
- Check EFCountingLabel compatibility. Do not remove because Storyboards reference it.
- Add CI only after the local dependency update sequence is stable.

Phase 1 constraints:

- No persistence migration.
- No Storyboard rewrite.
- No signing or bundle identifier changes.
- No widget removal.
- No analytics/tracking SDKs.

Acceptance criteria:

- `xcodebuild -list` succeeds on a full Xcode environment.
- Documented Debug and Release simulator build commands exist for the app and widget.
- First build failures are fixed or documented with exact next changes.
- Dependency modernization decision is documented before dependency changes.

## Phase 2: Data Layer Migration and Repository Abstraction

Status: completed for scaffolding.

Goal: isolate persistence behind interfaces before changing Realm schema or storage engine.

Tasks:

- Defined repository protocols for route, day summary, device identity, migration export, sync outbox, color, place, media, badge, and widget state boundaries.
- Added initial Realm-backed adapters that preserve current manager behavior.
- Added read-only migration export draft scaffolding for existing Realm data.
- Added sync-ready plain Swift identifiers and draft types without Realm schema migration.
- Added local identity store for `installationId`, plus nullable future `ownerId` and `deviceId` storage.
- Added local sync outbox draft storage without backend, S3, upload, or auth logic.
- Defer call-site migration to small, separately verified patches.
- Defer additive Realm schema migration until a backup/export strategy is ready.
- Choose high-volume route-point storage after measuring Realm size and write performance.

Acceptance criteria:

- Existing screens can read route data through repository interfaces.
- Existing writes still persist locally first.
- No existing route/photo/note data is deleted.
- Migration is additive and reversible through backup/export.

Phase 2 completion notes:

- Existing screens are not yet migrated to the repository interfaces; current behavior remains intact through existing managers.
- New repository protocols and adapters are available for the next call-site migration phase.
- `installationId` is local-only and is intentionally separate from future `ownerId` and `deviceId`.

## Current Sequence Adjustment

The active renewal sequence now moves recording engine extraction before SwiftUI shell work. This keeps the highest-risk local-first route recording path testable before changing app navigation or screen structure. SwiftUI shell work is deferred until recording and sync boundaries are stable.

## Deferred UI Renewal: SwiftUI Renewal Shell

Status: deferred.

Goal: introduce modern navigation without rewriting all existing screens.

Tasks:

- Create a SwiftUI shell or host controller that can present existing UIKit flows.
- Proposed tabs: Today, Map, Timeline, Stats, Backup, Settings.
- Keep existing Storyboards available during transition.
- Wrap critical UIKit controllers with `UIViewControllerRepresentable` only when useful.
- Add feature flags or compile-time isolation so the existing app remains shippable.

Acceptance criteria:

- App can launch through the renewed shell in development builds.
- Existing route rendering and recording remain available.
- No data migration is required to view existing journeys.

## Phase 3: Recording Engine Extraction

Status: completed for scaffolding.

Goal: extract recording from `HomeViewController` and make it testable.

Tasks:

- Added `RecordingService` scaffold with delegate callbacks and repository-backed persistence path for future migration.
- Added `LocationFilter` for speed, distance, no-speed, and always-on warmup decisions.
- Added `DistanceCalculator` with guarded elapsed-time speed calculation.
- Added `RecordingStateStore` around existing app group widget keys.
- Routed the smallest safe `HomeViewController` state writes through `RecordingStateStore`.
- Deferred live `CLLocationManagerDelegate` migration to a later small patch because the current method also coordinates UI animation, notifications, map rendering, and Realm write sequencing.
- Preserved App Group widget keys and current live recording behavior.

Acceptance criteria:

- Recording works offline.
- Points are saved before UI/cloud side effects.
- Existing distance and route rendering behavior is preserved or intentionally adjusted.
- Filtering rules are unit tested.

Phase 3 completion notes:

- No Realm schema, destructive migration, network call, S3 upload, auth flow, widget file, Storyboard, asset, signing, bundle identifier, entitlement, or Pod removal was introduced.
- `scripts/phase1-build-baseline.sh` succeeded after Phase 3 changes.
- Next step is a focused live call-site migration: use `DistanceCalculator` and `LocationFilter` from `HomeViewController` while preserving current output, then migrate persistence orchestration into `RecordingService` after parity is verified.

## Phase 4: Local Sync Outbox

Status: completed for local-only implementation.

Goal: prepare local route data for future backup without adding networking or changing user-facing behavior.

Tasks:

- Added local outbox item and batch models: `SyncOutboxItem`, `SyncOutboxItemType`, `SyncOutboxItemStatus`, `SyncBatchDraft`, `SyncBatchConfiguration`, `IdempotencyKey`, and `LocalBackupStatus`.
- Extended `SyncOutboxRepository` with enqueue/list/status transition methods.
- Extended `LocalSyncOutboxRepository` to persist item-based outbox state in `UserDefaults`.
- Added deterministic local idempotency key generation using `installationId`, `syncBatchId`, and schema version.
- Added route-point NDJSON serialization scaffolding for future `points.ndjson.gz`.
- Added local batch creation from `MigrationExportDraft`, grouped by day and chunked by configurable max point count.
- Kept gzip compression, file persistence, checksums, object keys, backend API calls, S3 upload, Auth, and visible UI out of scope.

Acceptance criteria:

- Local outbox items can be enqueued, listed, marked syncing/synced/failed, and retried.
- Existing Realm data is not migrated or deleted.
- Existing recording UX is not intentionally changed.
- No cloud/network/S3/Auth behavior exists yet.

Phase 4 completion notes:

- `scripts/phase1-build-baseline.sh` succeeded after Phase 4 changes.
- The local outbox is ready to be wired into recording persistence in a later local-only patch.
- Cloud backup should not start until opt-in UI, bootstrap identity, private object storage, retry policy, and privacy review are explicitly implemented.

## Phase 5: Cloud Backup with Anonymous Owner/Device

Status: completed for disabled-by-default client scaffolding.

Goal: add opt-in cloud backup without requiring login.

Tasks:

- Added `CloudBackupConfiguration` with cloud backup disabled by default and a separate development upload gate.
- Added `CloudBackupAPIClient` using `URLSession`.
- Added DTOs for bootstrap, presign upload, upload complete, sync batch registration, restore manifest, future auth link, and future cloud data deletion.
- Added `CloudBackupService` scaffold that can read pending outbox items and represent the presign/upload/complete/sync-batch sequence.
- Added privacy-safe debug logging for operation names and coarse status only.
- Stored returned `ownerId` and `deviceId` through the existing identity repository if bootstrap is manually invoked.
- Did not persist `anonymousDeviceToken`; secure storage remains future work.
- Did not add backup settings UI yet.
- Did not enable automatic backup.
- Did not add AWS credentials, AWS SDK, Auth, S3 public URLs, or production endpoint configuration.

Acceptance criteria:

- Cloud backup is off by default.
- Enabling backup creates anonymous owner/device identity.
- Local recording works without network.
- Upload retry is idempotent.
- S3 object keys are private and owner-scoped.

Phase 5 completion notes:

- `scripts/phase1-build-baseline.sh` succeeded after a small compile fix in `CloudBackupAPIClient`.
- No user-facing behavior changed.
- No Realm schema or destructive migration was introduced.
- No real network upload can happen by default because both backup flags default to false and no call site invokes the service automatically.
- Real cloud backup remains blocked on opt-in UI, secure token storage, backend availability, gzip/file staging, test coverage, and privacy review.

## iOS 18 Baseline Update

Status: completed.

Goal: set the entire app baseline to iOS 18.0.

Changes:

- Set `Podfile` platform to iOS 18.0.
- Set generated Pods `IPHONEOS_DEPLOYMENT_TARGET` post-install value to iOS 18.0.
- Set project, app target, and widget target deployment targets to iOS 18.0.
- Updated renewal docs to reflect the current iOS 18.0 baseline.

Validation:

- `xcodebuild -list -workspace footage.xcworkspace` succeeded.
- `scripts/phase1-build-baseline.sh` succeeded after the baseline update.

Follow-up warnings exposed by iOS 18:

- StoreKit 1 donation flow used APIs deprecated/no longer supported in iOS 18. This has been replaced with StoreKit 2 `Product.purchase`.
- `UIApplication.shared.applicationIconBadgeNumber` was replaced with `UNUserNotificationCenter.setBadgeCount`.
- `UIApplication.shared.windows` uses were replaced with scene-local `window` access.
- Static `CLLocationManager.authorizationStatus()` usage was replaced with instance `authorizationStatus`.
- Realm/RealmSwift Pods still emit generated dependency warnings.

## iOS 18 Warning Modernization

Status: completed for app source.

Changes:

- Replaced `Settings_DonateVC` StoreKit 1 payment queue flow with StoreKit 2 product loading and purchase.
- Replaced app badge clearing with `UNUserNotificationCenter.setBadgeCount`.
- Replaced app badge visibility check with delivered-notification based alert dot refresh.
- Replaced deprecated `UIApplication.shared.windows` lookups with controller/scene-local windows.
- Replaced static CoreLocation authorization checks with `CLLocationManager.authorizationStatus` instance access.
- Replaced deprecated review prompt with `AppStore.requestReview(in:)`.
- Removed obsolete iOS 14 availability checks now that the minimum baseline is iOS 18.

Validation:

- `rg` found no remaining app-source uses of the deprecated APIs that triggered the iOS 18 warnings.
- `scripts/phase1-build-baseline.sh` succeeded after the changes.

## Phase 6: Restore

Status: completed for non-destructive preview scaffolding.

Goal: let a user restore cloud-backed data after reinstall or device change.

Tasks:

- Added `RestoreService` scaffold for manifest fetch, private route object download, parsing, and preview plan creation.
- Added `RestoreImportPlan`, `RestoreConflictPolicy`, and `RestoreStatus`.
- Added plain NDJSON route point parser returning `RoutePointDraft`.
- Added duplicate detection scaffold by `recordingId + pointId`.
- Added preview-only import repository that does not mutate Realm.
- Deferred gzip parsing, media restore, summary restore, and real additive Realm import.

Acceptance criteria:

- Reinstall restore can rebuild route history.
- Duplicate route points are not created on repeated restore.
- User can inspect restore status and failures.

Phase 6 completion notes:

- `scripts/phase1-build-baseline.sh` succeeded after Phase 6 changes.
- Restore is not automatic and has no visible UI.
- Restore cannot overwrite or delete local data by default.
- Real restore remains blocked on explicit UX, additive import implementation, persisted stable point IDs, gzip/file staging, and privacy review.

## Phase 7: Auth Linking

Status: completed for scaffold.

Goal: link anonymous data to a real account without changing ownership IDs.

Tasks:

- Added `AuthProvider`, `AuthIdentity`, and `AuthLinkState`.
- Added provider adapter protocol plus Apple and Cognito placeholder adapters.
- Added `AuthLinkingService` scaffold for `POST /v1/auth/link`.
- Added local auth identity metadata store without raw token persistence.
- Preserved existing anonymous `ownerId` and rejects owner mismatch responses.
- Did not add Sign in with Apple capability, login UI, required login, or account-gated recording.

Acceptance criteria:

- Anonymous data remains under the same `ownerId` after login.
- Logout does not delete local data.
- Account deletion flow is explicit and privacy-reviewed.

Phase 7 completion notes:

- `scripts/phase1-build-baseline.sh` succeeded after Phase 7 changes.
- Login is not required after this phase.
- Recording remains local-first and available without auth.
- Production auth remains blocked on Sign in with Apple/Cognito UI, entitlements/capability review, secure token handling, server behavior, and privacy copy.

## Phase 8: App Store/TestFlight Readiness

Status: completed for documentation and simulator build baseline.

Goal: ship a privacy-first renewed app.

Tasks:

- Added App Store readiness documentation.
- Added privacy review documentation.
- Added release checklist.
- Audited Info.plist, entitlements, background location, app group, widget, disabled feature flags, and placeholder backend configuration.
- Verified workspace listing and established simulator build baseline.
- Documented archive command but did not change signing or verify signed archive.

Acceptance criteria:

- Release build succeeds on the supported baseline.
- Existing data is preserved through update.
- Cloud backup and deletion behavior match privacy policy.
- TestFlight build has no known critical data-loss risks.

Phase 8 completion notes:

- `scripts/phase1-build-baseline.sh` succeeded.
- Archive readiness is documented only; signed archive is a human signing/provisioning follow-up.
- No user-facing permission copy was changed in this phase.
- Cloud Backup, Restore, and Auth remain disabled/not automatic.

## First Phase 1 Codex Command

Use this after selecting full Xcode on the machine:

```text
Begin Phase 1 build recovery. Do not change signing, bundle identifiers, entitlements, Pods, Storyboards, Realm models, assets, or widget target. First run git status, xcodebuild -list -workspace footage.xcworkspace, and a simulator build if list succeeds. Document exact failures in docs/TECHNICAL_AUDIT.md and propose the smallest build-only fixes before editing project settings.
```
