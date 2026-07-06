# Refactor Phase R14 Changelog

Date: 2026-07-05.

## Goal

Start the new UI runway without cutting over production navigation or changing current UIKit/Storyboard behavior.

## Commands Run

```sh
git status --short
rg --files Footage FootageTests docs | rg 'FeatureFlags|Composition|Coordinator|Router|AppDelegate|SceneDelegate|SwiftUI|UI_REWRITE|MODERNIZATION'
rg -n "FeatureFlags|isCloudBackupEnabled|isRestoreEnabled|isAuthEnabled|UIRewrite|SwiftUI|AppCompositionRoot|rootViewController|TabBarController|tabBarController|SceneDelegate|AppDelegate" Footage FootageTests docs
sed -n '1,260p' Footage/App/AppCompositionRoot.swift
sed -n '1,220p' Footage/App/FeatureFlags.swift
sed -n '1,260p' Footage/App/AppEnvironment.swift
sed -n '1,240p' Footage/SceneDelegate.swift
sed -n '1,180p' Footage/AppDelegate.swift
sed -n '1,220p' FootageTests/UseCasesTests.swift
rg -n "C0D830|App/FeatureFlags.swift|AppCompositionRoot.swift|UseCasesTests.swift|PresentationModelsTests.swift" footage.xcodeproj/project.pbxproj
git diff -- Footage/App/FeatureFlags.swift FootageTests/UseCasesTests.swift
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
sed -n '500,620p' footage.xcodeproj/project.pbxproj
sed -n '760,800p' footage.xcodeproj/project.pbxproj
sed -n '1080,1110p' footage.xcodeproj/project.pbxproj
find Footage -maxdepth 2 -type d | sort
git diff -- Footage/Presentation/RenewedShellView.swift FootageTests/PresentationModelsTests.swift footage.xcodeproj/project.pbxproj Footage/App/FeatureFlags.swift FootageTests/UseCasesTests.swift
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
sed -n '1,180p' Footage/App/FeatureFlags.swift
sed -n '1,220p' Footage/Presentation/RenewedShellView.swift
tail -n 80 docs/REFACTOR_PHASE_R14_CHANGELOG.md
tail -n 80 docs/MODERNIZATION_PLAN.md
git diff -- Footage/App/FeatureFlags.swift Footage/Presentation/RenewedShellViewController.swift Footage/Presentation/RenewedShellView.swift FootageTests/UseCasesTests.swift footage.xcodeproj/project.pbxproj docs/REFACTOR_PHASE_R14_CHANGELOG.md docs/MODERNIZATION_PLAN.md
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg --files
find . -maxdepth 3 \( -name '*.xcworkspace' -o -name '*.xcodeproj' -o -name '*.entitlements' \)
rg -n "Storyboard|storyboard|instantiateViewController|UIStoryboard|tabBarController|RenewedShell|Coordinator|Factory|SceneDelegate|rootViewController" Footage FootageTests docs
sed -n '1,180p' Footage/Presentation/RenewedShellViewController.swift
sed -n '20,120p' Footage/Storyboard/Base.lproj/Main.storyboard
rg -n "storyboardIdentifier=|customClass=|viewControllerPlaceholder" Footage/Storyboard/Home.storyboard Footage/Storyboard/Date.storyboard Footage/Storyboard/Stats.storyboard Footage/Storyboard/Settings.storyboard Footage/Storyboard/FirstLaunch.storyboard Footage/Storyboard/Base.lproj/Main.storyboard
xcodebuild -list -workspace footage.xcworkspace
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "UIStoryboard\(name: \"Main\"|UIStoryboard\(name: \"FirstLaunch\"|instantiateViewController\(withIdentifier: \"TabBarController\"|instantiateViewController\(withIdentifier: \"PasswordVC\"|instantiateViewController\(withIdentifier: \"FL_VideoVC\"" Footage FootageTests
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "SceneDelegate|LegacyRoot|sceneWillEnterForeground|openURLContexts|widget|startedBefore|todayBadge|minimumTotalDistance|minimumTotalRecord|selectedColor" Footage FootageTests docs/REFACTOR_PHASE_R14_CHANGELOG.md docs/MODERNIZATION_PLAN.md
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git status --short
git diff -- Footage/SceneDelegate.swift Footage/Presentation/RenewedShellStoryboardFactory.swift FootageTests/UseCasesTests.swift
git diff -- docs/REFACTOR_PHASE_R14_CHANGELOG.md docs/MODERNIZATION_PLAN.md
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff -- Footage/SceneDelegate.swift Footage/Presentation/RenewedShellStoryboardFactory.swift FootageTests/UseCasesTests.swift
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
xcrun xcresulttool get object --legacy --path /Users/nyeok/Library/Developer/Xcode/DerivedData/footage-fcfkhlxrlvchugggglstbjyxsmlr/Logs/Test/Test-footage-2026.07.06_11-21-16-+0900.xcresult --format json
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

## Results

- `git diff --check` succeeded.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- A second `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the initial SwiftUI shell scaffold.
- A third `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after pivoting the shell scaffold to programmatic UIKit.
- `xcodebuild -list -workspace footage.xcworkspace` succeeded during the coordinator/factory follow-up.
- A fourth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the storyboard-backed renewed shell factory.
- A fifth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the launch storyboard guard test.
- The direct-storyboard-call search returned no remaining app/test matches for direct `Main` or `FirstLaunch` instantiation of `TabBarController`, `PasswordVC`, or `FL_VideoVC`.
- A sixth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after introducing the legacy root factory.
- A seventh `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting scene lifecycle decisions.
- An eighth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting first-launch defaults and widget tracking state stores.
- The first Home-tab accessor test run failed because the test directly instantiated `HomeViewController`, which crashed in the unit-test environment. The production build phase had succeeded.
- `xcrun xcresulttool get object --legacy --path /Users/nyeok/Library/Developer/Xcode/DerivedData/footage-fcfkhlxrlvchugggglstbjyxsmlr/Logs/Test/Test-footage-2026.07.06_11-21-16-+0900.xcresult --format json` confirmed `Crash: footage at UseCasesTests.testLegacyHomeTabControllerAccessorSelectsHomeTab()`.
- A ninth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after changing the test to avoid direct `HomeViewController` construction.
- A tenth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting background recording action decisions.
- An eleventh `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting initial connection planning.

## Changed

- Added `FeatureFlags.isNewUIRunwayEnabled`, defaulting to `false`.
- Added `AppRootDestination`, `AppRootRoute`, and `AppRootRouter`.
- Initially added a SwiftUI shell scaffold, then pivoted the runway direction to programmatic UIKit based on product direction.
- Clarified the UI policy: Storyboard removal is the goal, programmatic UIKit is the default app-shell path, and SwiftUI remains acceptable for widget-required or clearly isolated cleaner implementations.
- Added tests proving the legacy Storyboard route remains the default.
- Added tests proving the renewed shell route can be selected behind the flag without skipping first-launch onboarding.
- Replaced `RenewedShellView` with `RenewedShellViewController`, a minimal internal programmatic UIKit `UITabBarController` shell.
- Added `RenewedShellPresentation`, `RenewedShellTab`, and `RenewedShellTabKind`.
- Updated the app target membership in `footage.xcodeproj`.
- Added tests for the default internal shell tabs.
- Added `RenewedShellPresentation.legacyStoryboardBridge`, preserving the current runtime tab order: Home, Map, Stats, Date, Settings.
- Added `StoryboardSceneDescriptor`, `LegacyRenewedShellStoryboardSceneProvider`, `StoryboardBackedRenewedShellViewControllerFactory`, and `RenewedShellCoordinator`.
- Added a direct view-controller provider for the legacy inline Map tab because `MapViewController` has no storyboard identifier in `Main.storyboard`.
- Added tests for the legacy bridge tab order, storyboard descriptor mapping, direct Map-provider precedence, fallback behavior, coordinator root construction, and the current `Info.plist` Main storyboard launch configuration.
- Added central legacy root descriptors for `Main/TabBarController`, `FirstLaunch/FL_VideoVC`, and `Main/PasswordVC`.
- Added `LegacyRootViewControllerFactory` and `StoryboardLegacyRootViewControllerFactory`.
- Replaced direct storyboard instantiation in `SceneDelegate` and `FL_LetsStartVC` with the root factory while preserving the same storyboard-backed runtime destinations.
- Added tests proving the root factory uses the central descriptors.
- Added `SceneLifecycleCoordinator`, `SceneForegroundPlan`, `SceneForegroundRoute`, and `SceneWidgetTrackingAction`.
- Routed `SceneDelegate` foreground password/first-launch decisions and widget URL start/stop decisions through the coordinator.
- Added tests for password gate planning, first-launch/default foreground planning, widget URL recognition, and widget tracking action selection.
- Added `FirstLaunchDefaultsInitializer` for legacy first-launch `UserDefaults` and app-group color defaults.
- Added `SceneWidgetTrackingStateStore` for legacy app-group `isTracking` toggle/clear writes.
- Routed first-launch default initialization and widget tracking state mutation through the new helpers.
- Added tests proving the legacy default keys, color labels, and widget tracking toggle/clear behavior remain intact.
- Added `LegacyHomeTabControllerAccessor` to centralize legacy root tab selection.
- Routed `SceneDelegate` initial connection and widget URL handling through the home-tab accessor instead of repeating tab-bar lookup logic.
- Added tests for first-tab selection and nil behavior without directly constructing `HomeViewController`.
- Added `SceneBackgroundRecordingAction` and `SceneLifecycleCoordinator.backgroundRecordingAction(isRecording:alwaysOn:)`.
- Routed `SceneDelegate.sceneDidEnterBackground` through the coordinator for recording/always-on decisions while preserving the existing timer and location-manager side effects.
- Added tests for background non-recording, always-on refresh, and direct location-update actions.
- Added `SceneInitialConnectionPlan` and `SceneLifecycleCoordinator.initialConnectionPlan(isWindowScene:url:)`.
- Routed `SceneDelegate.scene(_:willConnectTo:options:)` through the initial connection plan for window-scene and widget-start decisions.
- Added tests for non-window scene, widget URL, and non-widget URL initial connection plans.

## Safety Notes

- No SceneDelegate, Storyboard, root controller, widget, signing, entitlement, bundle identifier, asset, Realm schema, network, auth, restore, or backup runtime behavior was changed.
- The renewed shell route is not wired into app launch yet.
- First-launch users still route to the existing FirstLaunch Storyboard in the router.
- The programmatic UIKit shell is compiled but not reachable from the production launch path.
- SwiftUI was not removed from widget-required or future isolated-use eligibility; only the app shell runway was clarified.
- `Info.plist`, `FirstLaunch.storyboard`, `Main.storyboard`, and existing storyboard identifiers were not changed.
- The coordinator can build a disabled-by-default UIKit root, but production still launches through the existing Main storyboard.
- The legacy bridge intentionally preserves `DateViewController` at tab index 3 because map child flows currently assume that index.
- `SceneDelegate` still preserves current foreground password and first-launch behavior, but now gets those controllers through `LegacyRootViewControllerFactory`.
- `SceneDelegate` still owns presentation and `HomeViewController.startTracking()` / `stopTracking()` calls, but default initialization and widget `isTracking` writes now live behind small helpers.
- `SceneDelegate` still performs the actual Home start/stop/category side effects; the new accessor only centralizes current tab lookup.
- `SceneDelegate` still performs timer scheduling, one-shot location requests, continuous location updates, and widget timeline reloads on background entry.
- `SceneDelegate` still performs `DateManager.loadTodayData()`, total-distance loading, category restoration, and optional Home tracking start during initial connection.
- `Info.plist`, Storyboards, widget target files, signing, entitlements, bundle identifiers, app group keys, Realm schema, backup, restore, and auth behavior were not changed.

## What Remains

- Extract remaining `SceneDelegate` side effects in smaller passes, starting with foreground password presentation.
- Add manual QA before enabling the renewed root route, with special attention to widget URL start/stop, password unlock, and Map -> Journey navigation.
- Keep the default app launch on the existing UIKit/Storyboard shell until manual QA proves parity.
