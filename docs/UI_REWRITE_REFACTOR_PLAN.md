# UI Rewrite Refactor Plan

Date: 2026-07-05.

## Scope

This is a documentation-only plan for preparing Footage for a later large-scale UI rewrite. The current UIKit/Storyboard UI must remain the working shell while core behavior is extracted into testable layers:

```text
UIKit / Storyboard temporary shell
  -> PresentationModels
    -> UseCases
      -> Domain
      -> Repository / Service protocols
        -> Realm, UserDefaults, App Group, MapKit, CoreLocation, Widget, Network adapters
```

The rewrite should not begin by replacing screens. It should begin by removing product logic from screens while preserving existing UI behavior, route history, photos, notes, Realm data, widget state, app group keys, signing, bundle identifiers, entitlements, Storyboards, XIBs, assets, CocoaPods, RealmSwift, EFCountingLabel, MapKit, and WidgetKit.

## Current Inspection Baseline

Commands run for this plan:

```sh
git status --short
rg --files
find . -maxdepth 3 \( -name '*.xcworkspace' -o -name '*.xcodeproj' -o -name '*.entitlements' \) -print
rg -n "LocationUpdate|DateManager|RecordingUseCase|Realm|Widget|UserDefaults|group\.footage|isTracking|distanceToday|distanceTotal|selectedColor" Footage MainWidget docs FootageTests
xcodebuild -list -workspace footage.xcworkspace
```

Result:

- Initial `git status --short` showed a pre-existing modified Xcode user state file: `footage.xcworkspace/xcuserdata/nyeok.xcuserdatad/UserInterfaceState.xcuserstate`.
- The first sandboxed `xcodebuild -list -workspace footage.xcworkspace` attempt failed with CoreSimulator/log permission errors and reported the workspace as invalid.
- The approved retry succeeded and listed schemes: `EFCountingLabel`, `footage`, `MainWidgetExtension`, `Pods-footage`, `Pods-MainWidgetExtension`, `Realm`, `Realm-realm_objc_privacy`, `RealmSwift`, `RealmSwift-realm_swift_privacy`, and `WidgetColorSelection`.
- Existing docs already define R0-R8 architecture, repository, recording, backup, restore, and test harness direction. This plan continues that sequence with R9-R15.

## Non-Negotiable Guardrails

- Keep recording local-first: every route point must be written locally before cloud, sync, widget, or network side effects.
- Do not rename or destructively migrate Realm classes under `Footage/Model`.
- Do not delete, rewrite, or replace Storyboards, XIBs, assets, widget files, entitlements, signing settings, bundle identifiers, app group identifiers, Pods, or Realm dependencies during R9-R14.
- Preserve app group `group.footage` and exact widget-visible keys including `isTracking`, `distanceToday`, `distanceTotal`, `selectedColor`, and color-name keys.
- Do not log raw latitude/longitude, photos, notes, tokens, presigned URLs, object identifiers, or internal storage keys.
- Keep Cloud Backup, Restore, and Auth opt-in or disabled unless a separate production plan explicitly enables them.
- Treat Realm files, photos, notes, app group values, widget behavior, and existing route history as user data.

## Target Folder Direction

Folder moves are lower priority than dependency direction. Additive files should move toward this shape only when the extracted boundary is real:

```text
Footage/
  Domain/
    Entities/
    ValueObjects/
    Policies/
    UseCases/
    Repositories/

  Data/
    Realm/
    Repositories/
    Migrations/
    Storage/

  Services/
    Location/
    Recording/
    Notifications/
    Backup/
    Restore/
    Auth/
    WidgetState/

  Presentation/
    Home/
    Date/
    Map/
    Stats/
    Settings/
    FirstLaunch/
    Shared/
      PresentationModels/
      Coordinators/
      Formatting/

  App/
    AppCompositionRoot.swift
    AppEnvironment.swift
    FeatureFlags.swift
```

Rules:

- `Domain` must not import UIKit, RealmSwift, MapKit, CoreLocation, WidgetKit, URLSession, or SwiftUI.
- `UseCases` should depend on protocols, domain entities, value objects, and policies.
- `Data` adapters may depend on RealmSwift, UserDefaults, app group storage, Keychain, files, and network clients.
- `PresentationModels` may format data for UIKit today and SwiftUI later, but should not open Realm or mutate persistent state directly.
- UIKit controllers may own outlets, navigation, animation, lifecycle, and view binding only.

## Phase R9: UI Rewrite Readiness Audit

Goal: map every current screen to the product behavior it owns before moving logic.

Tasks:

- Inventory Storyboard scenes, XIBs, view controllers, custom cells, and runtime identifiers.
- Document which screens read/write Realm, app group defaults, standard defaults, photos, notes, notifications, location state, MapKit overlays, widget state, backup/restore state, and auth state.
- Classify screen logic as view-only, presentation formatting, use case orchestration, domain policy, persistence, or platform service.
- Identify static mutable state that affects UI parity, including `HomeViewController.distanceTotal`, `HomeViewController.selectedColor`, `DateManager.lastData`, `LocationUpdate.lastLocation`, and manager caches.
- Produce a screen-to-boundary migration matrix before changing call sites.

Acceptance criteria:

- The audit proves the current UIKit/Storyboard shell can remain active while each screen is migrated behind adapters.
- No source, Storyboard, XIB, asset, widget, Realm schema, entitlement, signing, bundle identifier, Pod, or app group change is made in this phase.
- The matrix names the first safe call-site migrations and the screens that require manual device QA.

## Phase R10: Domain Extraction

Goal: extract product concepts from UIKit, Realm, MapKit, CoreLocation, UserDefaults, and WidgetKit.

Tasks:

- Add plain Swift domain entities and value objects for route points, day summaries, journeys, colors/categories, badges, places, media references, notes, recording state, widget state snapshots, and user profile preferences.
- Move pure rules into policies: distance validity, location filtering thresholds, recording session state transitions, badge eligibility, daily/monthly/yearly grouping, color/category selection, and restore duplicate detection.
- Keep existing Realm object classes unchanged; add mapping code in adapters only.
- Define privacy-safe debug descriptions that never include raw coordinates, notes, photos, object identifiers, internal storage keys, tokens, or presigned URLs.

Acceptance criteria:

- Domain files compile without UI or persistence imports.
- Unit tests cover pure rules with deterministic inputs.
- Existing UIKit screens and Realm models still drive production behavior until use-case wiring is explicitly migrated.

## Phase R11: Use Case Layer

Goal: make app behavior callable from old UIKit now and new UI later.

Tasks:

- Define use cases for recording start/stop/location ingestion, home dashboard loading, date timeline loading, journey detail loading/editing, map archive loading, stats/report loading, badge display, settings/profile updates, notification scheduling preferences, widget state updates, manual backup preparation, restore preview, and auth linking readiness.
- Preserve the side-effect order for live recording: validate location, write local route data, update local aggregates, update widget/app group state, then enqueue backup/sync if enabled.
- Inject repository and service protocols through `AppCompositionRoot`.
- Keep Cloud Backup and Restore disconnected from automatic flows unless separately approved.

Acceptance criteria:

- Each migrated screen action calls a use case instead of directly coordinating persistence/platform side effects.
- Mock repositories can test use-case behavior without Realm, Storyboards, MapKit, or CoreLocation.
- Recording tests prove local write is required before outbox/widget/network side effects.

## Phase R12: Repository and Service Consolidation

Goal: isolate storage and platform APIs behind stable adapters while keeping Realm local-first.

Tasks:

- Finish repository protocols for routes, summaries, media, notes, badges, colors, places, profile/settings, app group widget state, backup outbox, restore preview, and installation identity.
- Move direct `try! Realm()`, `.objects`, and `realm.write` calls out of view controllers and managers into Realm-backed adapters or legacy facades.
- Keep app group storage behind a reader/writer that preserves `group.footage` and exact key names.
- Keep widget source isolated; app-side code may write widget state only through the app group adapter.
- Add file-backed media and backup staging adapters only additively; do not remove old inline Realm photo data before a migration/export plan exists.

Acceptance criteria:

- View controllers no longer open Realm directly for migrated flows.
- Repository contract tests run against test Realm configurations or fakes.
- Existing Realm data opens without schema migration, destructive writes, or data loss.
- Widget-visible values remain compatible with the current `MainWidgetExtension`.

## Phase R13: Presentation Models and UIKit Shell Migration

Goal: make old screens thin enough that a later UI can replace them without reimplementing product logic.

Tasks:

- Add presentation models for Home, Date, Journey Detail, Map Archive, Stats, Reports, Levels/Badges, Settings, First Launch, Backup Status, Restore Preview, and Auth Linking.
- Move formatting, display text, section construction, empty states, button states, and error mapping out of view controllers.
- Keep UIKit controllers responsible for outlets, layout, animation, user gestures, map/cell binding, and navigation.
- Add adapters that convert use-case outputs into UIKit-ready presentation models; later SwiftUI views should consume the same model shape or a thin equivalent.
- Keep Storyboard identifiers and segues stable.

Acceptance criteria:

- Migrated view controllers can render from presentation models without reaching into Realm managers.
- Snapshot or assertion tests cover presentation model construction for representative empty, partial, and populated states.
- UI behavior remains visually and navigationally equivalent on the temporary UIKit shell.

## Phase R14: New UI Runway

Goal: prepare the actual UI rewrite without cutting over user data paths.

Tasks:

- Use programmatic UIKit as the rewrite surface. Do not mix in SwiftUI for the app shell unless a later architecture decision explicitly reverses this.
- Add feature flags for new screen entry points, defaulting off.
- Build new UI screens against use cases and presentation models, not Realm or manager singletons.
- Introduce coordinators or routing adapters so old and new screens can coexist during parity checks.
- Add visual QA plans for Home recording, date archive, journey detail, map archive, stats/report, settings, backup status, restore preview, first launch, and widget-adjacent color selection flows.

Acceptance criteria:

- New UI paths can be launched internally without changing default user flows.
- Default production flow still uses the current UIKit/Storyboard shell.
- Manual QA proves both old and new UI paths read the same local Realm/app group data and produce the same write side effects.

## Phase R15: UI Cutover and Legacy Cleanup

Goal: switch default navigation to the rewritten UI only after behavior and data parity are proven.

Tasks:

- Cut over one feature area at a time, starting with read-only screens before recording or mutation-heavy flows.
- Keep rollback flags for any migrated screen until TestFlight and device QA pass.
- Remove legacy Storyboard scenes, assets, or controllers only after target membership, runtime string, Storyboard, asset, and manual UI evidence proves they are unused.
- Do not remove Realm, WidgetKit, app group state, or CocoaPods without a separate data/dependency migration plan.
- Update release checklist, privacy review, App Store readiness, and user-data rollback notes after each cutover.

Acceptance criteria:

- Existing users can install over a prior build and retain route history, photos, notes, statistics, selected color, widget behavior, and settings.
- Physical-device background location QA passes for recording start, pause/resume, stop, relaunch, and widget interactions.
- Widget QA passes with unchanged app group keys.
- A rollback build can return to the prior UI shell without losing or corrupting Realm data.

## Migration Guardrails for Realm and Widget Data

- Treat the current Realm hierarchy `Year -> Month -> DayData -> Footstep` as the source of truth until a fully documented migration ships.
- Any new identifiers or sync status fields must be additive and backfilled safely; never require existing objects to already contain them.
- Do not move inline photos or notes out of Realm until export, validation, rollback, and restore paths exist.
- Before any Realm schema migration, document current schema version, target schema version, default values, migration code, rollback limitation, and test fixture coverage.
- Use migration dry runs against copied Realm files before device QA.
- App group keys must remain stable: `isTracking`, `distanceToday`, `distanceTotal`, `selectedColor`, plus existing color-name keys.
- Widget writes should be small, synchronous, and best-effort after local app persistence succeeds.
- Widget reads should tolerate missing app group defaults and fall back without crashing.
- Never introduce public route sharing or object storage paths that expose sensitive identifiers.

## Test Strategy

Baseline commands for source-changing phases:

```sh
git status --short
xcodebuild -list -workspace footage.xcworkspace
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
scripts/phase1-build-baseline.sh
git diff --check
git status --short
```

Use the available destination and OS on the development machine if `iPhone 17 Pro, OS=26.5` is unavailable, and document the exact substitution.

Coverage expectations:

- Domain: pure unit tests for location filtering, distance calculation, badge rules, date grouping, duplicate detection, recording state transitions, and privacy-safe descriptions.
- Use cases: fake repository tests for side-effect order, local-first recording, widget updates after persistence, settings updates, restore preview, manual backup preparation, and auth owner-linking safety.
- Repositories: contract tests for Realm adapters using isolated test configurations, app group state stores using test suites, file staging with temporary directories, and outbox idempotency.
- Presentation models: deterministic tests for populated/empty/error/loading display states.
- UI/manual QA: physical-device recording, background location, relaunch while tracking, widget start/stop/deep link behavior, selected color/category, map rendering, date navigation, photo/note display, stats/report screens, first launch, settings, backup status, and restore preview.

Do not claim a build, test, or manual QA pass unless the command or device pass actually ran.

## Commit Strategy

- Keep this plan as a docs-only checkpoint owned by `docs/UI_REWRITE_REFACTOR_PLAN.md`.
- Future implementation should use one phase branch or commit series per R-phase, with small reviewable commits.
- Separate commits by boundary: domain types, use-case protocols, repository adapters, presentation models, UIKit call-site migration, tests, and docs.
- Do not combine project file target membership edits with behavior changes unless the new files require membership and the diff is unavoidable.
- Keep every source-changing commit buildable or clearly marked as an internal checkpoint that is not ready to merge.
- For migration-sensitive work, include a doc or PR note describing current version, target version, migration behavior, rollback limitation, and validation result.
- Do not delete legacy UI, assets, Realm classes, widget files, entitlements, signing, app group values, or Pods in the same commit as a replacement. Deletion requires its own evidence-backed cleanup commit after parity.

## Review Checklist for Every R9-R15 PR

- Does `git status --short` show only intended files?
- Does the PR preserve `co.el.footage`, `co.el.footage.MainWidget`, and `group.footage`?
- Does recording still write locally before sync, backup, widget, or network side effects?
- Does the PR avoid raw coordinate/photo/note/token/presigned URL/object identifier/internal storage key logging?
- Does the PR avoid destructive Realm migrations and app group key renames?
- Are Storyboards, XIBs, assets, widget files, Pods, and entitlements untouched unless the PR explicitly owns that later-phase migration?
- Are tests or manual QA proportional to the touched behavior?
- Are rollback notes present for UI cutover, data migration, or sync identity changes?
