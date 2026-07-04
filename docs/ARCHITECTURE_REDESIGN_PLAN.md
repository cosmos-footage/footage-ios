# Architecture Redesign Plan

Date: 2026-07-04.

## Goal

Move Footage toward a production-grade, local-first architecture that can support S3 cloud backup, restore, and future auth linking without risking existing route history, photos, notes, widget state, Storyboards, or Realm data.

## Non-Negotiable Guardrails

- Preserve local-first recording.
- Do not change signing, bundle identifiers, entitlements, or app group identifiers.
- Do not remove Pods, Realm, Storyboards, XIBs, assets, or widget target files during early refactor phases.
- Do not rename Realm object classes or perform destructive Realm migrations.
- Do not enable Cloud Backup, Restore, or Auth by default.
- Do not add AWS credentials to the app.
- Do not log raw latitude/longitude, notes, photos, bearer tokens, provider tokens, object keys, or presigned URLs.

## Target Dependency Direction

```text
Presentation
  -> UseCases
    -> Domain Policies / Entities
    -> Repository Protocols
      -> Realm Adapters
      -> UserDefaults / App Group Adapters
      -> Network Clients
      -> Keychain / Secure Storage
```

Allowed directions:

- View controllers may depend on use cases and presentation models.
- Use cases may depend on repository protocols and service protocols.
- Repository adapters may depend on Realm, UserDefaults, Keychain, URLSession, and platform APIs.
- Widget should depend only on a small app-group read layer and widget presentation code.

Disallowed long-term directions:

- View controllers directly opening Realm.
- View controllers directly owning S3/network backup logic.
- Backup services reading UIKit state.
- Widget code force-unwrapping app group storage.
- Domain models depending on UIKit, Realm, URLSession, or WidgetKit.

## Proposed Folder Shape

```text
Footage/
  App/
    AppCompositionRoot.swift
    AppEnvironment.swift
    FeatureFlags.swift

  Domain/
    Entities/
    ValueObjects/
    UseCases/
    Policies/

  Data/
    Realm/
    Repositories/
    Migrations/
    DTO/

  Services/
    Recording/
    Sync/
    Backup/
    Restore/
    Auth/
    Security/
    Location/

  Infrastructure/
    Network/
    Storage/
    Logging/
    Configuration/

  Presentation/
    Home/
    Date/
    Stats/
    Settings/
    FirstLaunch/
    Shared/

MainWidget/
  Widget UI
  AppGroup state reader only
```

This folder shape should be reached incrementally. Moving files before behavior is isolated is lower priority than reducing dependencies.

## Refactor Phases

### R0: Safety Baseline

Status: started.

Tasks:

- Run repository status, workspace list, file inventory, Storyboard/XIB inventory, target membership search, direct dependency search.
- Create `docs/REFACTOR_AUDIT.md`.
- Keep all source behavior unchanged.

Exit criteria:

- Baseline commands documented.
- No destructive change.
- Workspace list succeeds.

### R1: Dead-Code Audit

Status: delegated.

Tasks:

- Classify unused code/file/asset candidates as safe, ambiguous, or do-not-remove.
- Verify candidates against target membership, Storyboards, runtime identifiers, selectors, asset names, Realm models, widget, and app group keys.

Exit criteria:

- No file deletion yet.
- `docs/REFACTOR_AUDIT.md` contains evidence-backed cleanup candidates.

### R2: Verified Safe Cleanup

Status: pending.

Tasks:

- Remove only evidence-backed dead code.
- Remove or gate debug prints that do not affect behavior.
- Guard force unwraps in app group access.
- Keep cleanup commits small and reversible.

Exit criteria:

- `scripts/phase1-build-baseline.sh` succeeds.
- No Storyboard, asset, widget, Realm, entitlement, signing, or Pod deletion unless explicitly approved.

### R3: Composition Root and Feature Flags

Status: started.

Tasks:

- Add `AppCompositionRoot`, `AppEnvironment`, and centralized `FeatureFlags`.
- Centralize construction of repositories, recording service, sync outbox, backup, restore, auth, and configuration.
- Keep Cloud Backup, Restore, Auth disabled by default.

Exit criteria:

- Existing UI flow still creates screens normally.
- No automatic backup/restore/auth behavior.

R3 progress:

- Added `FeatureFlags`, `AppEnvironment`, and `AppCompositionRoot`.
- Default flags keep Cloud Backup, Restore, Auth, and development upload disabled.
- Composition root constructs existing scaffold services only; it is not wired into app launch yet.
- Added a Keychain-backed cloud backup token store as inert production-prep scaffolding.
- Added a local notification scheduling service wrapper without migrating call sites.

### R4: Recording Use Case Extraction

Status: pending.

Tasks:

- Introduce `RecordingUseCase` and widget state writer abstraction.
- Route recording state changes through service boundaries.
- Preserve `HomeViewController` UI behavior while reducing direct location/stats/widget persistence coupling.

Exit criteria:

- Start/stop recording behavior unchanged.
- Local writes remain first.
- Outbox enqueue can be added after local persistence succeeds.

### R5: Realm Repository Migration

Status: pending.

Tasks:

- Move direct reads/writes from `DateManager`, `JourneyManager`, `ColorManager`, `PlaceManager`, `LevelManager`, and map/date view controllers behind repository protocols.
- Do not rename Realm object classes.
- Do not run destructive migrations.

Exit criteria:

- Legacy managers become adapters or thin facades.
- Screens still read existing Realm data.

### R6: S3-Ready Backup Pipeline

Status: pending.

Tasks:

- Add Keychain token store.
- Add file-backed route payload staging.
- Add gzip compression for route NDJSON.
- Add retry/backoff and idempotency persistence.
- Add manual-only backup runner.
- Keep backup opt-in and disabled by default.

Exit criteria:

- One manual batch can be prepared without automatic upload.
- No AWS credentials in app.
- No sensitive logging.

### R7: Tests and Verification Harness

Status: pending.

Tasks:

- Add unit test target if absent.
- Test pure services first: `LocationFilter`, `DistanceCalculator`, NDJSON serializer, outbox repository, API request construction, restore duplicate detection, auth owner mismatch.

Exit criteria:

- Tests run locally.
- Baseline build remains green.

### R8: Backend/S3 Integration

Status: pending.

Tasks:

- Implement backend endpoints from `docs/API_SPEC.md`.
- Configure private S3 bucket and short-lived presigned URLs.
- Wire iOS manual backup to real backend using Keychain token.
- Test idempotent retry and upload complete flow.

Exit criteria:

- Internal-only manual backup succeeds for a small route batch.
- Restore remains preview-only until separately approved.

## First Implementation Slice

The first code-writing slice after audits should be:

1. Add `AppCompositionRoot` and `FeatureFlags`.
2. Add `AppGroupTrackingStateStore` protocol/adapter and use it in app code.
3. Guard widget app group reads.
4. Add tests for pure recording utilities.

This sequence reduces risk before S3 integration and gives later backup code a stable place to attach.

## Sub-Agent Execution Plan

The first implementation pass should be split into disjoint ownership areas so multiple agents can work without overlapping edits.

### Agent A: App Configuration and Composition

Ownership:

- `Footage/App/`
- `Footage/Services/Backup/CloudBackupConfiguration.swift`
- project file entries for new `Footage/App` files

Tasks:

- Add `AppEnvironment`.
- Add `FeatureFlags`.
- Add `AppCompositionRoot`.
- Keep Cloud Backup, Restore, and Auth disabled by default.
- Do not wire UI behavior yet.

Exit criteria:

- Existing app launch behavior is unchanged.
- Workspace list and baseline build pass.

### Agent B: App Group State Wrapper

Ownership:

- new app group state files under `Footage/Data/`
- app-side call sites in `SceneDelegate`, `HomeViewController`, `HomeAnimation`, and settings color-name screens
- no widget source changes in the first pass unless separately assigned

Tasks:

- Add central app group key constants.
- Add app-side app group state writer/reader.
- Migrate one or two app-side call sites at a time.
- Preserve exact key names and `group.footage`.

Exit criteria:

- Widget-visible keys remain unchanged.
- No forced migration of existing `UserDefaults`.

### Agent C: Recording Utility Parity

Ownership:

- `Footage/Services/Recording/`
- narrow helper extraction in `HomeViewController`

Tasks:

- Compare existing speed/distance validity behavior with `LocationFilter` and `DistanceCalculator`.
- Route one pure decision path through existing recording utilities.
- Preserve thresholds and UI behavior exactly.

Exit criteria:

- Recording UI remains unchanged.
- Local route persistence remains untouched.

### Agent D: Cloud Backup Production Prep

Ownership:

- `Footage/Services/Security/`
- `Footage/Services/Backup/`
- `Footage/Services/Sync/`
- `Footage/Network/`

Tasks:

- Start with Keychain token storage only.
- Do not enable Cloud Backup.
- Do not add real backend URL.
- Do not add AWS credentials.
- Do not move payloads out of `UserDefaults` until the file-staging task is explicitly assigned.

Exit criteria:

- Token store compiles and is unused or explicitly injected behind disabled config.
- No automatic network behavior is introduced.

## First Cleanup Pass

Only one deletion candidate is strong enough for a first cleanup pass:

- `Footage/Resource/Assets.xcassets/levels/badGEFrame.imageset`

Even this should be handled in its own commit after an explicit cleanup command, because assets are release-sensitive and AGENTS requires careful justification.

All other unreferenced-looking assets require manual UI verification before removal.
