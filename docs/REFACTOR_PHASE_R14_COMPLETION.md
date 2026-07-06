# Refactor Phase R14 Completion

Date: 2026-07-06.

## Completion Decision

Phase R14 is complete for the automated, repository-owned scope.

R14 prepared the new UI runway without cutting over production user flows:

- Programmatic UIKit is the selected app-shell rewrite surface.
- SwiftUI remains allowed for WidgetKit-required surfaces or isolated screens where it is clearly simpler.
- New UI entry points are behind `FeatureFlags.isNewUIRunwayEnabled`, which defaults to `false`.
- The default production launch path still uses the current UIKit/Storyboard shell.
- First-launch users still route to the existing FirstLaunch Storyboard flow.
- Existing users still keep the current Main Storyboard root when the renewed flag is off.
- The renewed UIKit shell can be constructed internally for QA.
- Read-only renewed tabs/screens are backed by use cases and presentation models instead of direct Realm manager access.
- Backup, restore, auth, About, privacy, and contact detail paths in renewed Settings are isolated behind disabled-by-default factories.

## Automated Evidence

Latest validation command:

```sh
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

Latest result:

- `** TEST SUCCEEDED **`
- Result bundle: `/Users/nyeok/Library/Developer/Xcode/DerivedData/footage-fcfkhlxrlvchugggglstbjyxsmlr/Logs/Test/Test-footage-2026.07.06_16-46-52-+0900.xcresult`

Additional validation:

```sh
git diff --check
```

Latest result:

- Succeeded.

## Acceptance Criteria Status

### New UI paths can be launched internally without changing default user flows

Status: satisfied for automated scope.

Evidence:

- `AppRootRouter` can select the renewed shell only when the renewed UI flag is enabled.
- `AppRootViewControllerFactory` can build the renewed UIKit shell.
- `SceneDelegate` consults the root router, but default flags still produce `.keepStoryboardRoot`.
- Tests cover default legacy root, first-launch protection, enabled renewed root construction, widget URL launch planning, and non-window scenes.

### Default production flow still uses the current UIKit/Storyboard shell

Status: satisfied.

Evidence:

- `FeatureFlags.isNewUIRunwayEnabled` defaults to `false`.
- Launch configuration tests keep `UIMainStoryboardFile` and scene `UISceneStoryboardFile` on `Main`.
- `SceneDelegate` keeps the storyboard root when the router returns `.keepStoryboardRoot`.
- No Storyboard, bundle identifier, entitlement, signing, widget, Realm schema, asset, or app group change was made in this completion step.

### Manual QA proves old and new UI paths read the same local data and produce the same write side effects

Status: not claimable by automation.

Resolution:

- This is explicitly carried to R15/manual release readiness.
- `docs/RENEWED_ROOT_QA_PLAN.md` defines the required simulator and physical-device QA gate.
- The renewed root must remain disabled by default until manual QA passes.

## R14 Deliverables Completed

- Feature flag boundary for the renewed UI runway.
- Root route and root view-controller factories.
- Scene lifecycle planning boundaries for initial connection, foreground, background, widget URLs, root installation, first launch, password gate, widget timeline reload, selected color, and Home dispatch.
- Programmatic UIKit shell and coordinator.
- Storyboard bridge for parity hosting.
- Programmatic renewed shell factory.
- Read-only renewed screens for Today, Map, Timeline, Stats, Settings, Backup Status, Restore Status, Auth Readiness, About, Privacy Policy, and Contact Mail.
- Presentation-model/use-case backed tests for renewed screen slices.
- Manual QA plan for renewed root cutover.
- R14 changelog and modernization-plan status updates.

## Explicit Non-Completions

These are not R14 completion blockers because they belong to manual QA or later cutover phases:

- Enabling the renewed root by default.
- Removing Storyboards.
- Removing legacy view controllers.
- Removing CocoaPods or Realm.
- Migrating recording writes into the renewed UI path.
- Claiming physical-device background location parity.
- Claiming widget QA parity.
- Claiming manual renewed-root readiness.
- Triggering cloud backup, restore import, auth linking, or network calls from renewed Settings.

## R15 Entry Criteria

R15 should not begin production cutover until:

- `docs/RENEWED_ROOT_QA_PLAN.md` has simulator and physical-device evidence.
- Existing-user local Realm data is verified in both legacy and renewed read-only paths.
- Widget URL start/stop behavior is verified.
- Background location behavior is verified on a physical device.
- Password foreground gate behavior is verified.
- Backup, restore, and auth renewed Settings detail screens are confirmed read-only.
- A rollback plan keeps the existing Storyboard root available.

## R15 Recommended First Task

Begin with manual QA instrumentation and evidence capture for the disabled renewed root.

Do not enable `FeatureFlags.isNewUIRunwayEnabled` by default until that evidence exists.
