# Refactor Phase R15 Completion Plan

Date: 2026-07-06.

## Summary

R15 is the UI cutover preparation phase. Its safe automated scope is to keep hardening the disabled programmatic UIKit runway, add rollback-flagged read-only routes, and record evidence that Storyboards remain retained until final release-readiness.

R15 is not the phase that deletes Storyboards or enables the renewed root by default.

## Assumptions

- Production launch stays on the existing Storyboard root.
- `FeatureFlags.isNewUIRunwayEnabled` stays disabled by default.
- Physical-device-only behavior is deferred to final release-readiness:
  - background location recording
  - widget URL start/stop handoff
  - password foreground gate
- Existing Realm data parity is not a renewal gate for this phase, but Realm files and models must still not be destructively changed.

## Affected Areas

- `Footage/App/FeatureFlags.swift`
- `Footage/App/AppCompositionRoot.swift`
- `Footage/Presentation/ProgrammaticRenewedShellFactory.swift`
- `Footage/Presentation/RenewedSettingsDashboardViewController.swift`
- `footageTests/`
- R15 documentation under `docs/`

## Execution Strategy

Finish R15 with small checkpoints:

1. Add explicit rollback control for read-only renewed Settings detail routes.
2. Prove the rollback control with tests.
3. Re-run simulator-safe tests.
4. Record R15 automated completion and leave device-only gates open.

Each checkpoint should be committed separately where meaningful.

## Tasks

### Task R15-C1: Gate renewed Settings detail routes

**Objective**

Add an explicit disabled-by-default flag for renewed Settings read-only detail routes so About/privacy/status screens can be enabled independently of the renewed shell.

**Scope**

Allowed files or areas:

- `Footage/App/FeatureFlags.swift`
- `Footage/App/AppCompositionRoot.swift`
- `Footage/Presentation/ProgrammaticRenewedShellFactory.swift`
- targeted tests in `footageTests/`
- R15 docs

Out of scope:

- Storyboard deletion
- production root cutover
- Home recording, widget URL, password gate, or background location changes

**Acceptance Criteria**

- Renewed Settings detail routes are controlled by a rollback flag.
- The flag is disabled by default.
- Existing production root behavior remains unchanged.
- Tests cover default-disabled and override-enabled behavior.

**Implementation Notes**

- Launch argument: `--footage-enable-renewed-settings-details`
- Environment variable: `FOOTAGE_ENABLE_RENEWED_SETTINGS_DETAILS=1`
- This flag only controls read-only renewed Settings detail routes. It does not enable the renewed root by itself.

**Validation**

Run:

```bash
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

Expected result:

- Diff check passes.
- Test command succeeds.

### Task R15-C2: Record R15 automated closure

**Objective**

Update the R15 docs to mark simulator-safe automated work complete and name the exact remaining manual gates.

**Scope**

Allowed files or areas:

- `docs/MODERNIZATION_PLAN.md`
- `docs/REFACTOR_PHASE_R15_DEVICE_DEFERRED_PLAN.md`
- `docs/REFACTOR_PHASE_R15_STORYBOARD_REMOVAL_MATRIX.md`
- optional new R15 completion note

Out of scope:

- Any app source changes

**Acceptance Criteria**

- R15 docs distinguish completed simulator-safe work from deferred device QA.
- The next phase or next release-readiness step is explicit.

**Validation**

Run:

```bash
git diff --check
```

Expected result:

- Diff check passes.

## Stop Conditions

Stop and re-plan if any R15 task requires:

- changing signing, entitlements, bundle identifiers, app group identifiers, or widget target files
- destructive Realm migration or model deletion
- deleting Storyboards or assets
- enabling the renewed root by default
- changing live recording, widget URL handling, password foreground gating, or background location lifecycle before physical-device QA
