# Refactor Phase R15 Device-Deferred Plan

Date: 2026-07-06.

## Decision

Physical-device validation is deferred to the final release-readiness gate.

Until a physical iPhone is available, do not refactor the runtime paths that depend on iOS lifecycle behavior:

- Background location recording.
- Widget URL start/stop launch behavior.
- Password foreground gate behavior.

These paths should remain on the current production implementation unless a concrete bug is found.

## Reasoning

Those behaviors are tightly coupled to iOS process lifecycle, permissions, widget handoff, app group state, and foreground/background transitions. Splitting them before device validation would create extra risk without proving the user-facing behavior.

The current R15 direction is therefore:

- Keep `FeatureFlags.isNewUIRunwayEnabled` disabled by default.
- Keep the current Storyboard root as the production root and rollback path.
- Keep device-dependent behavior unchanged until final physical-device QA.
- Continue refactoring areas that can be reviewed with simulator, unit tests, or static inspection.

## Active Workstream

Continue Storyboard removal preparation through low-risk UIKit work:

1. Build or harden programmatic UIKit replacements behind the renewed-root QA flag.
2. Move presentation decisions out of legacy ViewControllers when the move is pure or read-only.
3. Keep recording, widget, password, and background lifecycle mutation paths on the current implementation.
4. Remove Storyboard scenes only after their programmatic replacement, route wiring, target membership, and rollback plan are documented.

## Deferred Device QA Gate

Before any production-facing renewed-root cutover, run and document:

- Physical-device background location recording.
- Widget URL start/stop handoff through the real widget surface.
- Password foreground gate with real app foreground/background transitions.
- App group state compatibility for widget-visible values.

## Next Executable Task

Start the next R15 implementation task with the renewed UIKit shell, not the device-dependent lifecycle paths.

Recommended next task:

```text
R15-S1: Continue programmatic UIKit cutover by selecting one read-only Storyboard-backed surface, adding or hardening its programmatic replacement behind the renewed-root QA flag, and documenting the old Storyboard scene as still retained for rollback.
```

Current R15-S1 checkpoint:

- Renewed Settings and About remain read-only and disabled by default.
- Their programmatic UIKit layouts now use scroll-backed content instead of center-fixed stacks, preparing them for Storyboard removal without touching production routing.
- Renewed backup status, restore status, and auth readiness detail screens now use the same scroll-backed read-only layout pattern.
- Renewed Stats overview now uses the same scroll-backed read-only layout pattern without changing the production Stats Storyboard path.
- Renewed Timeline now uses the same scroll-backed read-only layout pattern without changing the production Date Storyboard path.
- Renewed Today dashboard now uses the same scroll-backed read-only layout pattern without changing the production Home Storyboard or recording flow.
- Renewed Map canvas now uses safe-area containment and a minimal accessibility label without changing production route overlays, annotations, or location behavior.
- `docs/REFACTOR_PHASE_R15_STORYBOARD_REMOVAL_MATRIX.md` now defines Storyboard retention/removal states and blocks deletion until replacement, routing, test, reference-audit, QA, and rollback evidence exists.

Suggested first candidate:

- Settings/About or Settings detail surfaces, because they are read-only and already isolated behind disabled-by-default factories.

Avoid as first candidates:

- Home recording controls.
- Widget start/stop.
- Password foreground gate.
- Background location lifecycle.
