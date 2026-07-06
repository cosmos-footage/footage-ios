# Refactor Phase R15 Storyboard Removal Matrix

Date: 2026-07-06.

## Purpose

This matrix defines what can and cannot be removed before the app starts deleting Storyboard scenes.

No Storyboard file is approved for deletion by this document. It is a planning checkpoint for future small removal tasks.

## Current Decision

Production launch must keep the existing Storyboard root until final release-readiness gates pass.

Keep these surfaces unchanged for now:

- `Main.storyboard` root and `TabBarController`.
- `FirstLaunch.storyboard`.
- `Home.storyboard`.
- `Date.storyboard`.
- `Stats.storyboard`.
- `Settings.storyboard`.
- `PasswordVC` in `Main.storyboard`.
- Widget target and app group keys.
- Realm models and local recording persistence.

## Removal States

| State | Meaning |
| --- | --- |
| `Retain` | Must remain in production. Do not delete or unlink. |
| `Programmatic runway` | A disabled renewed UIKit replacement exists, but production still uses the Storyboard path. |
| `Device QA deferred` | Physical-device or widget behavior must be verified before any cutover/removal. |
| `Removal candidate later` | Can be considered only after target membership, runtime references, Storyboard references, asset references, tests, and manual QA evidence are captured. |

## Top-Level Storyboard Matrix

| Storyboard surface | Current production role | Renewed path status | R15 state | Removal note |
| --- | --- | --- | --- | --- |
| `Main.storyboard` / `TabBarController` | Production root for existing users. Owns tab wiring and password gate source. | `RenewedShellViewController` exists behind disabled QA flag. | `Retain` | Do not remove until default root cutover and rollback plan are proven. |
| `FirstLaunch.storyboard` | Production first-run onboarding. | No production replacement. First-launch intentionally still routes here even with QA flag. | `Retain` | Do not remove before onboarding replacement and first-run QA. |
| `Home.storyboard` / `HomeViewController` | Production recording surface. Owns location, recording UI, widget state, map rendering, alerts. | `RenewedTodayDashboardViewController` is read-only only. | `Device QA deferred` | Do not remove or cut over before physical-device recording/background/widget QA. |
| `Date.storyboard` / `DateViewController` and journey detail | Production archive and journey detail path. | `RenewedTimelineViewController` is read-only summary only. | `Retain` | Do not remove before journey detail, photo/note flows, and archive navigation replacements exist. |
| `Stats.storyboard` / stats detail flows | Production stats, badge, color, place, report flows. | `RenewedStatsOverviewViewController` is read-only overview only. | `Retain` | Overview has runway; detail flows still need replacements. |
| `Settings.storyboard` / settings flows | Production settings, profile, passcode, push, donation, color naming, about. | Renewed Settings/About/status screens are read-only only. | `Retain` | Do not remove mutation-heavy settings until replacements and QA exist. |

## Renewed Programmatic UIKit Runway

These replacements exist behind the renewed-root QA flag and have passed simulator tests, but they are not production cutover approvals.

| Renewed screen | Covers | Does not cover yet | R15 state |
| --- | --- | --- | --- |
| `RenewedTodayDashboardViewController` | Read-only today/total/tracking snapshot display. | Recording controls, live route drawing, category buttons, notifications, widget writes. | `Programmatic runway` |
| `RenewedMapViewController` | Empty `MKMapView` canvas with safe-area containment. | Existing route overlays, annotations, bottom sheet, current-location controls. | `Programmatic runway` |
| `RenewedTimelineViewController` | Read-only journey summaries. | Journey detail, slider, photo/note creation/removal, map previews. | `Programmatic runway` |
| `RenewedStatsOverviewViewController` | Read-only stats overview. | Badge grid, color ranking detail, place detail, monthly report flows. | `Programmatic runway` |
| `RenewedSettingsDashboardViewController` | Read-only backup/restore/auth status and About entry. | Profile edits, passcode edits, push settings, color naming, donation purchase flow. | `Programmatic runway` |
| `RenewedBackupStatusViewController` | Read-only local backup status. | Opt-in toggle, preparation trigger, upload execution. | `Programmatic runway` |
| `RenewedRestoreStatusViewController` | Read-only restore status. | Manifest preview, import, destructive or additive restore. | `Programmatic runway` |
| `RenewedAuthReadinessViewController` | Read-only auth linking readiness. | Real auth provider linking. | `Programmatic runway` |
| `RenewedAboutViewController` and `RenewedPrivacyPolicyViewController` | Version, privacy text, contact mail boundary. | Legal/privacy copy rewrite, production Settings replacement. | `Programmatic runway` |

## First Safe Removal Candidates

There are no Storyboard files safe to remove yet.

The first future removal candidates should be individual read-only scenes after they meet all gates below:

1. Programmatic replacement exists.
2. Production route can be switched behind a rollback flag.
3. Tests prove routing and construction.
4. Simulator visual smoke is captured.
5. Runtime string references and Storyboard segues are audited.
6. Target membership and asset references are audited.
7. Manual QA confirms no user-facing regression.

Suggested first future candidates:

- Renewed About/privacy display path, after production Settings can route to it behind a rollback flag.
- Renewed backup/restore/auth read-only status details, because they should remain side-effect free.

Do not start with:

- `HomeViewController`.
- `PasswordVC`.
- Widget URL handling.
- Background location behavior.
- Journey detail photo/note flows.
- StoreKit donation flow.

## Required Evidence Before Deletion

Before deleting any Storyboard scene, add a small deletion-specific note containing:

- Scene or file proposed for removal.
- Replacement controller and route.
- `rg` evidence for Storyboard identifiers, custom classes, segue identifiers, and runtime string references.
- Xcode target membership evidence.
- Asset reference evidence.
- Test command and result.
- Manual QA or explicit reason manual QA is deferred.
- Rollback plan.

## Next Executable Task

Start with a routing-only task, not deletion:

```text
R15-S2: Add a rollback-flagged route from the renewed Settings dashboard to one read-only programmatic detail that is already side-effect free, then document the legacy Storyboard scene as retained.
```

The recommended first target is the About/privacy path because it is display-oriented and already has a programmatic UIKit runway.

