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

The active renewal sequence now moves recording engine extraction before programmatic UIKit shell work. This keeps the highest-risk local-first route recording path testable before changing app navigation or screen structure. Storyboard replacement is deferred until recording and sync boundaries are stable.

## Deferred UI Renewal: Programmatic UIKit Renewal Shell

Status: deferred.

Goal: introduce modern navigation without rewriting all existing screens.

Tasks:

- Create a programmatic UIKit shell that can eventually replace existing Storyboard navigation.
- Proposed tabs: Today, Map, Timeline, Stats, Backup, Settings.
- Keep existing Storyboards available during transition.
- Host or port critical UIKit controllers behind explicit routing adapters during transition.
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
- S3 storage keys are random and server-internal; ownership is scoped by database metadata and app-visible `objectId`.

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

## Phase 9: Final Hardening and Release Candidate Preparation

Status: completed for release candidate baseline documentation and minimal hardening.

Goal: reduce release risk and define Go/No-Go status without adding major features.

Tasks:

- Re-ran repository status, recent log, docs/server file inventory, workspace listing, and established simulator build baseline.
- Audited unsafe defaults for cloud backup, development upload, restore, auth, placeholder backend configuration, tokens, AWS credentials, presigned URL logging, raw coordinate logging, App Group force unwraps, and destructive restore defaults.
- Reviewed TODO/FIXME comments and categorized remaining work as follow-up rather than broad cleanup.
- Removed debug printing of pending notification request objects from the recording start path.
- Guarded app-side App Group `UserDefaults` accesses touched in home/settings code.
- Added `docs/RC_STATUS.md` and `docs/PHASE9_CHANGELOG.md`.

Acceptance criteria:

- Release candidate status is documented.
- Unsafe defaults are audited.
- Cloud Backup remains disabled by default.
- Restore remains non-automatic and non-destructive by default.
- Auth remains optional.
- Existing local data is not destructively migrated.
- Build/list result is documented.

Phase 9 completion notes:

- `xcodebuild -list -workspace footage.xcworkspace` succeeded.
- `scripts/phase1-build-baseline.sh` succeeded with exit code 0.
- Phase 9 originally found no automated XCTest target or `.xctestplan`; Refactor Phase R7 has since added a `FootageTests` XCTest target for pure service coverage.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded after R7 with 15 passing tests.
- Signed archive was not run because signing/provisioning was intentionally not changed.
- Recommendation is No-Go for production App Store release today, and Go for continued internal TestFlight preparation after human signing, device QA, widget QA, StoreKit validation, and privacy metadata review.

## Refactor Phase R10: Domain Extraction

Status: completed for additive pure-domain scaffolding.

Goal: add reusable domain concepts and pure policies without moving existing Realm data or changing current UIKit behavior.

Tasks:

- Added plain Swift domain models for route points, recording sessions, day summaries, journeys, color categories, badge progress, places, media references, notes, recording lifecycle state, widget snapshots, and profile preferences.
- Added pure policies for route point validation, recording state transitions, badge eligibility, date grouping, and color category selection.
- Added unit tests for coordinate validity, privacy-safe debug descriptions, recording lifecycle behavior, route point validation, badge progress, date grouping, and color fallback selection.
- Kept Domain imports limited to `Foundation`.
- Kept existing Realm models, Storyboards, widget files, signing, entitlements, bundle identifiers, Pods, app group keys, and user-facing flows unchanged.

Phase R10 completion notes:

- `xcodebuild -list -workspace footage.xcworkspace` succeeded after approved Xcode access.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- Next step is Phase R11: define use-case protocols and migrate the first read-only call path behind the new domain boundary.

## Refactor Phase R11: Use Case Layer

Status: completed for additive use-case scaffolding.

Goal: make app behavior callable from the legacy UIKit shell now and the future rewritten UI later.

Tasks:

- Added use-case protocols and default implementations for home dashboard, date timeline, stats overview, backup preparation, restore preview, auth linking readiness, settings preferences, and recording lifecycle transitions.
- Added `AppCompositionRoot` factories for the new use cases.
- Added unit tests using fake repositories/services to verify use-case behavior without Storyboards or live Realm writes.
- Kept existing ViewControllers on their current paths; no call-site migration was performed in this phase.
- Kept Cloud Backup, Restore, and Auth behind existing disabled/default-off flags and opt-in settings.

Phase R11 completion notes:

- `xcodebuild -list -workspace footage.xcworkspace` succeeded after approved Xcode access.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- Next step is Phase R12: consolidate repository/service boundaries and reduce direct Realm/platform access behind adapters.

## Refactor Phase R12: Repository and Service Consolidation

Status: completed for a narrow Date/Journey repository consolidation slice.

Goal: isolate storage and preferences access behind stable adapters while keeping Realm local-first and preserving the temporary UIKit shell.

Tasks:

- Added `JourneyPreviewRepository` and `RealmJourneyPreviewRepository` for Journey preview persistence.
- Added `UserProfileRepository`, `UserProfileSnapshot`, and `UserDefaultsUserProfileRepository` for local profile preference reads/writes.
- Migrated `JourneyViewController` away from direct Realm imports and direct `Realm()` usage for preview saving and annotated-footstep counting.
- Migrated `DateViewController` away from direct profile `UserDefaults` reads.
- Added focused tests for local profile preference persistence and clearing.
- Kept existing managers, Storyboards, widget files, Realm models, signing, bundle identifiers, entitlements, Pods, assets, app group keys, and user-facing flows unchanged.

Phase R12 completion notes:

- `xcodebuild -list -workspace footage.xcworkspace` succeeded after approved Xcode access.
- `git diff --check` succeeded.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- Next step is Phase R13: add presentation models and migrate the first read-only UIKit shell paths without rewriting the UI yet.

## Refactor Phase R13: Presentation Models and UIKit Shell Migration

Status: completed for the current safe UIKit shell slices.

Goal: make legacy UIKit screens thinner by moving display formatting into tested presentation models while preserving the current screens.

Tasks completed so far:

- Added a new `Footage/Presentation` area for UI-ready models that do not depend on UIKit, Storyboards, Realm, MapKit, or CoreLocation.
- Added `JourneyDatePresentation` to format legacy year/month/day date keys.
- Added `JourneyTimelineItemPresentation` to hold the Date timeline cell title and preview data.
- Migrated `DateViewController` cell binding away from inline date-label formatting.
- Added `JourneyDateDetailPresentation` for Journey detail date animation state.
- Migrated `JourneyAnimation` away from inline date decomposition.
- Added `HomeDistancePresentation` for Home recording/total distance labels, counter values, and Korean heading text.
- Migrated `HomeAnimation` and the live Home distance label assignment to use `HomeDistancePresentation`.
- Added `CityPresentation`, `DistanceTextPresentation`, and `ReportButtonPresentation`.
- Migrated formatting-only display state in `StatsViewController`, `ColorVC`, `PlaceVC`, `Place_DetailVC`, `ReportVC`, and `ReportDetailVC`.
- Added `MapFootstepPresentation` for map archive date, distance, category, photo count, and note count labels.
- Migrated `MapTableCell` and `SelectedView` in `MapBottomVC` to use `MapFootstepPresentation`.
- Added `CloudBackupStatusPresentation`, `SettingsPushTimePresentation`, and `AppVersionPresentation`.
- Migrated display-only Settings formatting in `Settings_GeneralVC`, `Settings_General_PushVC`, and `Settings_AboutVC`.
- Added read-only Restore/Auth display models: `RestoreStatusPresentation`, `RestoreImportPlanPresentation`, `AuthLinkStatePresentation`, and `AuthLinkingReadinessPresentation`.
- Kept Restore/Auth display models disconnected from user-facing UI because those features remain disabled scaffolds.
- Added `BadgePresentation` and migrated `LevelVC` selected-badge image/detail display formatting.
- Reviewed First Launch controllers and deferred their display work to R14 because the remaining logic is coupled to profile/photo permissions, onboarding navigation, and app launch state.
- Added tests for year/month/day formatting and preview-data retention.
- Added tests for Journey detail legacy date-counter state and Home distance display formatting.
- Added tests for city presentation fallbacks, distance text formats, and report button state.
- Added tests for map archive footstep cell text.
- Added tests for cloud backup status text, push time row/picker text, and legacy version label text.
- Added tests for restore status text, restore import-plan count text, and auth-linking action readiness.
- Added tests for badge detail display text without introducing Realm dependencies into the presentation model.

Phase R13 current completion notes:

- `git diff --check` succeeded.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- No Storyboard, asset, widget, Realm schema, network, auth, restore, signing, entitlement, or bundle identifier behavior was changed.
- Next step is Phase R14: choose and scaffold the new UI runway behind disabled feature flags.

## Refactor Phase R14: New UI Runway

Status: started with disabled-by-default routing scaffold.

Goal: prepare the actual UI rewrite without cutting over user data paths.

Tasks:

- Choose the rewrite surface deliberately: programmatic UIKit by default, with SwiftUI allowed for WidgetKit-required or clearly isolated cleaner implementations. Do not remove existing Storyboards until replacement paths and parity checks exist.
- Add feature flags for new screen entry points, defaulting off.
- Build new UI screens against use cases and presentation models, not Realm or manager singletons.
- Introduce coordinators or routing adapters so old and new screens can coexist during parity checks.
- Add visual QA plans for Home recording, date archive, journey detail, map archive, stats/report, settings, backup status, restore preview, first launch, and widget-adjacent color selection flows.

Phase R14 progress:

- Selected programmatic UIKit as the runway direction so Storyboards can eventually be removed after parity is proven.
- Clarified that SwiftUI remains acceptable for widget-required surfaces or isolated screens where it is clearly simpler; the migration goal is Storyboard removal, not a blanket UIKit-only or SwiftUI-only rewrite.
- Added `FeatureFlags.isNewUIRunwayEnabled`, defaulting to `false`.
- Added pure routing scaffolding: `AppRootDestination`, `AppRootRoute`, and `AppRootRouter`.
- Added tests proving existing users still default to the legacy `Main` Storyboard `TabBarController`.
- Added tests proving first-launch users still route to the legacy `FirstLaunch` Storyboard even when the new UI flag is enabled.
- The router is now consulted by `SceneDelegate` during initial connection, but the default feature flags still keep the existing storyboard root, so current runtime behavior is unchanged.
- Initially added a SwiftUI shell scaffold, then replaced it with `RenewedShellViewController`, a minimal internal programmatic UIKit `UITabBarController` shell.
- Added `RenewedShellPresentation`, `RenewedShellTab`, and `RenewedShellTabKind` for the future shell tab model.
- Added the UIKit shell file to the app target without wiring it into launch.
- Added tests for the internal shell tab definitions.
- Added a storyboard-backed renewed shell factory and coordinator that can host legacy storyboard tabs without changing launch behavior.
- Added `RenewedShellPresentation.legacyStoryboardBridge` to preserve the current tab order and `DateViewController` index expected by existing map flows.
- Added launch configuration tests proving `UIMainStoryboardFile` and scene `UISceneStoryboardFile` still point to `Main` during the runway.
- Added `LegacyRootViewControllerFactory` and routed `SceneDelegate` / `FL_LetsStartVC` through it so legacy root storyboard construction is centralized.
- Added `SceneLifecycleCoordinator` and routed foreground gate and widget URL decisions through it while leaving side effects in `SceneDelegate`.
- Added `FirstLaunchDefaultsInitializer` and `SceneWidgetTrackingStateStore`, then routed legacy first-launch default setup and widget `isTracking` mutation through those helpers.
- Added tests for the first-launch default keys, app-group color labels, and widget tracking toggle/clear behavior.
- Added `LegacyHomeTabControllerAccessor` and routed `SceneDelegate` initial connection / widget URL handling through it to remove repeated tab-bar lookup.
- Added tests for first-tab selection and nil behavior without directly constructing `HomeViewController`.
- Added `SceneBackgroundRecordingAction` and routed `SceneDelegate` background recording / always-on decisions through `SceneLifecycleCoordinator`.
- Added tests for background non-recording, always-on refresh, and direct location-update actions.
- Added `SceneInitialConnectionPlan` and routed `SceneDelegate` initial connection window-scene / widget-start decisions through `SceneLifecycleCoordinator`.
- Added tests for non-window scene, widget URL, and non-widget URL initial connection plans.
- Added `SceneFullScreenPresenter` and routed `SceneDelegate` foreground password-unlock modal setup through it.
- Added tests for top-controller traversal and legacy full-screen size/modal configuration.
- Added `SceneRootControllerInstaller` and routed first-launch root replacement through it.
- Added `SceneWidgetTimelineReloading` / `WidgetKitSceneWidgetTimelineReloader` and routed widget timeline reload calls through that boundary.
- Added tests for root replacement and fake widget timeline reload behavior.
- Added `SceneHomeInitialDataLoading` / `LegacySceneHomeInitialDataLoader` and routed legacy Home startup data preparation through that boundary.
- Added `SceneSelectedColorStore` and routed initial selected-category restoration through it while preserving the legacy app-group key.
- Added tests for selected-color app-group reads and fake Home initial-data loader behavior.
- Added `SceneHomeTrackingCommand` and routed initial/widget URL Home start-stop dispatch through `SceneHomeViewControllerDispatching`.
- Added tests for Home tracking command mapping and fake Home view-controller dispatch.
- Added `SceneBackgroundRecordingDispatching` and routed background timer/location-manager side effects through it.
- Added a fake background recording dispatcher test.
- Added `SceneUserStateStore` and routed foreground/background legacy `UserState` / `alwaysOn` reads through it.
- Added a test for isolated legacy user-state defaults reads.
- Added `SceneForegroundRouteDispatching` and routed foreground timer invalidation, password unlock, and first-launch root replacement through it.
- Added a fake foreground route dispatcher test.
- Removed the unused `SceneDelegate.homeVC` instance property after confirming no remaining references.
- Added `SceneLifecycleSupport.swift` and moved the accumulated Scene lifecycle helper types out of `RenewedShellStoryboardFactory.swift`.
- Added `SceneLifecycleSupport.swift` to the app target in `footage.xcodeproj`.
- Added `LegacyStoryboardBridge.swift` and moved legacy storyboard descriptors/providers/root factory out of `RenewedShellStoryboardFactory.swift`.
- Added `LegacyStoryboardBridge.swift` to the app target in `footage.xcodeproj`.
- Added `RenewedShellPresentation.swift` and moved renewed shell composition types plus the placeholder tab factory out of `RenewedShellViewController.swift`.
- Added `RenewedShellPresentation.swift` to the app target in `footage.xcodeproj`.
- Added `RenewedShellPlaceholderViewController.swift` so disabled-by-default renewed shell fallback tabs have a concrete programmatic UIKit screen boundary.
- Fixed the new placeholder controller's stored property from `tab` to `shellTab` after `xcodebuild test` exposed a collision with UIKit's `UIViewController.tab` API.
- Added `RenewedShellCoordinator.swift` and moved renewed shell root assembly out of the storyboard-backed tab factory file.
- Added `RenewedShellCoordinator.swift` to the app target in `footage.xcodeproj`.
- Added `ProgrammaticRenewedShellFactory.swift` as the non-storyboard tab factory boundary for future Home/Map/Timeline/Stats/Settings replacements.
- Added a test proving that boundary currently returns placeholder programmatic UIKit screens for the default internal tabs.
- Added `AppRootViewControllerFactory.swift` to map `AppRootRoute` values to legacy storyboard roots or the disabled programmatic renewed shell root.
- Added a test proving route-to-root creation works without wiring the new factory into `SceneDelegate`.
- Added `AppRootRouting.swift` and moved root route types out of `FeatureFlags.swift` so feature-flag configuration and launch routing have separate homes.
- Added composition-root factory methods for app root routing and root view-controller creation, still without wiring them into `SceneDelegate`.
- Added a pure `SceneAppRootInstallAction` policy so Scene lifecycle code can later decide whether to keep the storyboard root or replace it with the disabled renewed UIKit shell root.
- Added the first screen-level programmatic UIKit slice: a disabled Today dashboard screen backed by `HomeDashboardUseCase` / `HomeDistancePresentation`.
- Wired the Today dashboard only through the disabled `ProgrammaticRenewedShellViewControllerFactory`; remaining renewed tabs still use placeholders and production launch still uses the existing storyboard root.
- Added a disabled read-only Settings dashboard screen backed by `SettingsPreferencesUseCase` / `SettingsPreferencesPresentation`.
- Added a disabled read-only Stats overview screen backed by `StatsOverviewUseCase` / `StatsOverviewPresentation`.
- Added a disabled read-only Timeline screen backed by `DateTimelineUseCase` / `RenewedTimelineItemPresentation`.
- Added a disabled programmatic Map canvas screen backed by `MKMapView`, with route overlays and annotation behavior intentionally deferred.
- Added `SceneAppRootInstaller` and wired `SceneDelegate` to consult the app root route during initial connection; with default flags disabled, it keeps the existing storyboard root and continues the legacy Home preparation path.
- Added `SceneInitialLaunchPlan` so initial window-scene, widget URL, and app-root installation decisions are planned together before `SceneDelegate` performs side effects.

Phase R14 current completion notes:

- `git diff --check` succeeded.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- One intermediate `xcodebuild test` failed because `RenewedShellPlaceholderViewController.tab` collided with UIKit's `UIViewController.tab`; the property was renamed to `shellTab`, and the next `xcodebuild test` succeeded.
- The latest `xcodebuild test` succeeded after splitting `RenewedShellCoordinator.swift`.
- The latest `xcodebuild test` succeeded after adding `ProgrammaticRenewedShellFactory.swift`.
- The latest `xcodebuild test` succeeded after adding `AppRootViewControllerFactory.swift`.
- The latest `xcodebuild test` succeeded after splitting `AppRootRouting.swift`.
- The latest `xcodebuild test` succeeded after adding app root routing factories to `AppCompositionRoot`.
- The latest `xcodebuild test` succeeded after adding the pure Scene app-root install policy.
- Two intermediate Today-dashboard test runs failed and were fixed: first an Xcode project file ID collision with `AppRootRouting.swift`, then a missing `return` in `ProgrammaticRenewedShellFactory`.
- The latest `xcodebuild test` succeeded after adding the disabled programmatic Today dashboard screen.
- The latest `xcodebuild test` succeeded after adding the disabled programmatic Settings dashboard screen.
- The latest `xcodebuild test` succeeded after adding the disabled programmatic Stats overview screen.
- The latest `xcodebuild test` succeeded after adding the disabled programmatic Timeline screen.
- The latest `xcodebuild test` succeeded after adding the disabled programmatic Map canvas screen.
- The latest sandboxed `xcodebuild test` failed before build/test execution because CoreSimulator was unavailable and xcodebuild reported `footage.xcworkspace is not a workspace file`; the workspace XML was inspected and valid, then the same test command succeeded with external Xcode/Simulator permissions.
- The latest `xcodebuild test` succeeded after wiring the disabled-by-default app-root install dispatcher into `SceneDelegate`.
- The latest `xcodebuild test` succeeded after moving initial launch root/action planning into `SceneInitialLaunchPlan`.
- No Storyboard, asset, widget, Realm schema, network, auth, restore, signing, entitlement, bundle identifier, or default root-controller behavior was changed.
- Next step is to add parity smoke checks for the disabled renewed root route before any feature flag can be enabled outside development.

## First Phase 1 Codex Command

Use this after selecting full Xcode on the machine:

```text
Begin Phase 1 build recovery. Do not change signing, bundle identifiers, entitlements, Pods, Storyboards, Realm models, assets, or widget target. First run git status, xcodebuild -list -workspace footage.xcworkspace, and a simulator build if list succeeds. Document exact failures in docs/TECHNICAL_AUDIT.md and propose the smallest build-only fixes before editing project settings.
```
