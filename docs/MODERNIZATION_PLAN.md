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
- Two minimal Pods build-setting fixes were needed: set generated Pods deployment target to iOS 13.0 and remove the stale iPhone simulator `arm64` exclusion. No app source, signing, bundle identifiers, entitlements, data models, Storyboards, assets, or widget source files were changed.
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
- Review deployment target strategy. Keep existing app iOS 13/widget iOS 14 until measured; propose renewed target iOS 17+ after baseline.
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

## Phase 3: SwiftUI Renewal Shell

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

## Phase 4: Local-First Recording Stabilization

Goal: extract recording from `HomeViewController` and make it testable.

Tasks:

- Introduce `RecordingService`.
- Introduce `LocationFilter` for speed, distance, accuracy, and timestamp rules.
- Use the newest `CLLocation` in delegate batches.
- Guard zero/negative timestamp intervals.
- Move distance calculation and local write orchestration out of the view controller.
- Add a local `SyncOutbox` abstraction but keep network disabled by default.
- Preserve App Group widget updates.

Acceptance criteria:

- Recording works offline.
- Points are saved before UI/cloud side effects.
- Existing distance and route rendering behavior is preserved or intentionally adjusted.
- Filtering rules are unit tested.

## Phase 5: Cloud Backup with Anonymous Owner/Device

Goal: add opt-in cloud backup without requiring login.

Tasks:

- Add bootstrap client for `POST /v1/bootstrap`.
- Store `ownerId`, `deviceId`, `installationId`, and anonymous credential securely.
- Add backup settings UI with clear opt-in language.
- Add sync batch creation from local outbox.
- Upload route point batch files through presigned S3 URLs.
- Complete uploads through server metadata endpoint.
- Avoid logging raw coordinates, presigned URLs, and tokens.

Acceptance criteria:

- Cloud backup is off by default.
- Enabling backup creates anonymous owner/device identity.
- Local recording works without network.
- Upload retry is idempotent.
- S3 object keys are private and owner-scoped.

## Phase 6: Restore

Goal: let a user restore cloud-backed data after reinstall or device change.

Tasks:

- Fetch restore manifest.
- Download route batches through server-authorized URLs.
- Import into local repository using stable IDs and idempotency.
- Handle existing local data without destructive overwrite.
- Restore summaries and media metadata; restore photos only if enabled.

Acceptance criteria:

- Reinstall restore can rebuild route history.
- Duplicate route points are not created on repeated restore.
- User can inspect restore status and failures.

## Phase 7: Auth Linking

Goal: link anonymous data to a real account without changing ownership IDs.

Tasks:

- Add Sign in with Apple or Cognito adapter.
- Call `POST /v1/auth/link`.
- Keep `ownerId` stable and attach nullable `authUserId`.
- Add account status handling and server-to-server notification planning for Apple.

Acceptance criteria:

- Anonymous data remains under the same `ownerId` after login.
- Logout does not delete local data.
- Account deletion flow is explicit and privacy-reviewed.

## Phase 8: App Store/TestFlight Readiness

Goal: ship a privacy-first renewed app.

Tasks:

- Run full release build on modern Xcode.
- Add tests for recording, data migration, sync outbox, and restore import.
- Add privacy manifest if required.
- Prepare App Store privacy disclosures.
- Review location permission copy.
- Verify background location UX and entitlement use.
- Verify widget behavior.
- Add TestFlight rollout checklist and rollback plan.

Acceptance criteria:

- Release build succeeds on the supported baseline.
- Existing data is preserved through update.
- Cloud backup and deletion behavior match privacy policy.
- TestFlight build has no known critical data-loss risks.

## First Phase 1 Codex Command

Use this after selecting full Xcode on the machine:

```text
Begin Phase 1 build recovery. Do not change signing, bundle identifiers, entitlements, Pods, Storyboards, Realm models, assets, or widget target. First run git status, xcodebuild -list -workspace footage.xcworkspace, and a simulator build if list succeeds. Document exact failures in docs/TECHNICAL_AUDIT.md and propose the smallest build-only fixes before editing project settings.
```
