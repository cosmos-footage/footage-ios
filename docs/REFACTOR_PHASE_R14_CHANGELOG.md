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
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
pwd
ls -la footage.xcworkspace
find footage.xcworkspace -maxdepth 2 -type f -print
file footage.xcworkspace footage.xcworkspace/contents.xcworkspacedata
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "let homeVC = HomeViewController\(\)|homeVC" Footage/SceneDelegate.swift FootageTests docs/REFACTOR_PHASE_R14_CHANGELOG.md docs/MODERNIZATION_PLAN.md
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "enum SceneForegroundRoute|struct SceneLifecycleCoordinator|struct SceneFullScreenPresenter|WidgetKitSceneWidgetTimelineReloader|SceneLifecycleSupport.swift" Footage/Presentation footage.xcodeproj/project.pbxproj
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "struct StoryboardSceneDescriptor|protocol LegacyRootViewControllerFactory|LegacyStoryboardBridge.swift|struct StoryboardBackedRenewedShellViewControllerFactory" Footage/Presentation footage.xcodeproj/project.pbxproj
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "SceneAppRootInstallAction|appRootInstallAction|testSceneLifecycleCoordinatorPlansAppRootInstallAction" Footage FootageTests
git diff -- Footage/Presentation/SceneLifecycleSupport.swift FootageTests/UseCasesTests.swift
git diff --check -- Footage/Presentation/SceneLifecycleSupport.swift FootageTests/UseCasesTests.swift
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git status --short
sed -n '1,220p' Footage/Presentation/ProgrammaticRenewedShellFactory.swift
sed -n '1,220p' Footage/Presentation/RenewedShellPresentation.swift
sed -n '1,220p' Footage/Presentation/RenewedShellPlaceholderViewController.swift
sed -n '1,560p' FootageTests/PresentationModelsTests.swift
rg -n "struct .*UseCase|final class .*UseCase|protocol .*UseCase|HomeDashboard|StatsOverview|SettingsPreferences|CloudBackupStatus" Footage FootageTests
sed -n '1,90p' Footage/Domain/UseCases.swift
sed -n '1,220p' Footage/Presentation/PresentationModels.swift
sed -n '100,210p' Footage/App/AppCompositionRoot.swift
rg -n "ProgrammaticRenewedShellFactory.swift|RenewedShellPlaceholderViewController.swift|RenewedShellCoordinator.swift|AppRootViewControllerFactory.swift" footage.xcodeproj/project.pbxproj
rg -n "RenewedTodayDashboardViewController|homeDashboardUseCase|testProgrammaticRenewedShellFactoryBuildsTodayDashboard|testRenewedTodayDashboardRendersHomeSnapshot" Footage FootageTests footage.xcodeproj/project.pbxproj
git diff --check -- Footage/App/AppCompositionRoot.swift Footage/Presentation/ProgrammaticRenewedShellFactory.swift Footage/Presentation/RenewedTodayDashboardViewController.swift FootageTests/PresentationModelsTests.swift footage.xcodeproj/project.pbxproj
git diff -- Footage/App/AppCompositionRoot.swift Footage/Presentation/ProgrammaticRenewedShellFactory.swift Footage/Presentation/RenewedTodayDashboardViewController.swift FootageTests/PresentationModelsTests.swift footage.xcodeproj/project.pbxproj
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "AppRootRouting.swift|RenewedTodayDashboardViewController.swift" footage.xcodeproj/project.pbxproj
git diff --check -- Footage/App/AppCompositionRoot.swift Footage/Presentation/ProgrammaticRenewedShellFactory.swift Footage/Presentation/RenewedTodayDashboardViewController.swift FootageTests/PresentationModelsTests.swift footage.xcodeproj/project.pbxproj
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
sed -n '220,270p' Footage/Domain/UseCases.swift
sed -n '260,330p' Footage/Presentation/PresentationModels.swift
sed -n '90,130p' FootageTests/UseCasesTests.swift
sed -n '1,140p' Footage/Presentation/ProgrammaticRenewedShellFactory.swift
rg -n "RenewedSettingsDashboardViewController|SettingsPreferencesPresentation|settingsPreferencesUseCase" Footage FootageTests footage.xcodeproj/project.pbxproj
git diff --check -- Footage/App/AppCompositionRoot.swift Footage/Presentation/ProgrammaticRenewedShellFactory.swift Footage/Presentation/PresentationModels.swift Footage/Presentation/RenewedSettingsDashboardViewController.swift FootageTests/PresentationModelsTests.swift footage.xcodeproj/project.pbxproj
git status --short
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
sed -n '89,132p' Footage/Domain/UseCases.swift
sed -n '35,90p' Footage/Scene/Stats/StatsViewController.swift
sed -n '36,62p' FootageTests/UseCasesTests.swift
sed -n '1,80p' Footage/Presentation/ProgrammaticRenewedShellFactory.swift
rg -n "RenewedStatsOverviewViewController|StatsOverviewPresentation|statsOverview" Footage FootageTests footage.xcodeproj/project.pbxproj
git diff --check -- Footage/App/AppCompositionRoot.swift Footage/Presentation/ProgrammaticRenewedShellFactory.swift Footage/Presentation/PresentationModels.swift Footage/Presentation/RenewedStatsOverviewViewController.swift FootageTests/PresentationModelsTests.swift footage.xcodeproj/project.pbxproj
git status --short
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
sed -n '1,90p' Footage/Domain/DomainModels.swift
sed -n '90,140p' Footage/Scene/Date/DateViewController.swift
sed -n '150,175p' Footage/Scene/Date/DateViewController.swift
sed -n '54,88p' Footage/Domain/UseCases.swift
rg -n "RenewedTimelineViewController|RenewedTimelineItemPresentation|timelineJourneys" Footage FootageTests footage.xcodeproj/project.pbxproj
git diff --check -- Footage/App/AppCompositionRoot.swift Footage/Presentation/ProgrammaticRenewedShellFactory.swift Footage/Presentation/PresentationModels.swift Footage/Presentation/RenewedTimelineViewController.swift FootageTests/PresentationModelsTests.swift footage.xcodeproj/project.pbxproj
git status --short
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "RenewedMapViewController|mapViewController" Footage FootageTests footage.xcodeproj/project.pbxproj
git diff --check -- Footage/App/AppCompositionRoot.swift Footage/Presentation/ProgrammaticRenewedShellFactory.swift Footage/Presentation/RenewedMapViewController.swift FootageTests/PresentationModelsTests.swift footage.xcodeproj/project.pbxproj
git status --short
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git status --short
sed -n '1,260p' Footage/SceneDelegate.swift
sed -n '1,260p' Footage/Presentation/SceneLifecycleSupport.swift
rg -n "SceneLifecycle|AppRoot|RootController|isNewUIRunwayEnabled|SceneDelegate" Footage FootageTests docs/REFACTOR_PHASE_R14_CHANGELOG.md docs/MODERNIZATION_PLAN.md
sed -n '240,360p' Footage/Presentation/SceneLifecycleSupport.swift
sed -n '1,260p' Footage/App/AppRootViewControllerFactory.swift
sed -n '1,260p' Footage/App/AppRootRouting.swift
sed -n '360,430p' FootageTests/UseCasesTests.swift
sed -n '130,190p' FootageTests/UseCasesTests.swift
sed -n '1,260p' Footage/App/AppCompositionRoot.swift
sed -n '1,120p' Footage/App/FeatureFlags.swift
sed -n '1,130p' FootageTests/UseCasesTests.swift
rg -n "FakeLegacyRootViewControllerFactory|Fake.*AppRoot|Fake.*Factory" FootageTests/UseCasesTests.swift FootageTests/PresentationModelsTests.swift
sed -n '520,610p' FootageTests/UseCasesTests.swift
git diff -- Footage/SceneDelegate.swift Footage/Presentation/SceneLifecycleSupport.swift FootageTests/UseCasesTests.swift
git diff --check
rg -n "SceneAppRootInstaller|appRootInstaller|testSceneAppRootInstaller" Footage FootageTests
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
ls -la footage.xcworkspace
find footage.xcworkspace -maxdepth 2 -type f -print
file footage.xcworkspace footage.xcworkspace/contents.xcworkspacedata
sed -n '1,80p' footage.xcworkspace/contents.xcworkspacedata
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git status --short
sed -n '1,90p' Footage/SceneDelegate.swift
sed -n '1,110p' Footage/Presentation/SceneLifecycleSupport.swift
sed -n '220,280p' FootageTests/UseCasesTests.swift
git diff -- Footage/SceneDelegate.swift Footage/Presentation/SceneLifecycleSupport.swift FootageTests/UseCasesTests.swift
git diff --check
rg -n "SceneInitialLaunchPlan|initialLaunchPlan|connectionPlan" Footage FootageTests
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
sed -n '1,260p' AGENTS.md
sed -n '1,260p' docs/CODEX_TASK_HARNESS.md
git diff --check -- AGENTS.md docs/CODEX_TASK_HARNESS.md
git status --short
sed -n '160,215p' FootageTests/UseCasesTests.swift
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
xcrun xcresulttool get object --legacy --path /Users/nyeok/Library/Developer/Xcode/DerivedData/footage-fcfkhlxrlvchugggglstbjyxsmlr/Logs/Test/Test-footage-2026.07.06_15-40-12-+0900.xcresult --format json
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git status --short
sed -n '130,310p' FootageTests/UseCasesTests.swift
sed -n '1,90p' Footage/Presentation/SceneLifecycleSupport.swift
sed -n '1,80p' Footage/App/AppRootRouting.swift
git diff --check
rg -n "testInitialLaunchParityMatrix" FootageTests/UseCasesTests.swift
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
git status --short
sed -n '1,180p' Footage/Presentation/RenewedSettingsDashboardViewController.swift
sed -n '1,160p' Footage/Presentation/ProgrammaticRenewedShellFactory.swift
sed -n '180,240p' Footage/App/AppCompositionRoot.swift
rg -n "BackupPreparation|CloudBackupStatusPresentation|Fake.*Backup|backup" Footage FootageTests
sed -n '120,170p' Footage/Domain/UseCases.swift
sed -n '300,330p' Footage/Presentation/PresentationModels.swift
sed -n '150,178p' Footage/Services/Sync/SyncOutboxModels.swift
rg -n "RenewedBackupStatusViewController" Footage FootageTests footage.xcodeproj/project.pbxproj
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
sed -n '1,240p' Footage/Presentation/RenewedSettingsDashboardViewController.swift
sed -n '1,220p' Footage/Presentation/ProgrammaticRenewedShellFactory.swift
sed -n '380,580p' FootageTests/PresentationModelsTests.swift
sed -n '120,190p' Footage/Domain/UseCases.swift
sed -n '190,260p' Footage/App/AppCompositionRoot.swift
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg -n "Restore|Auth|Readiness|Renewed.*ViewController|Settings" Footage/Presentation Footage/Domain Footage/App FootageTests
sed -n '150,225p' Footage/Domain/UseCases.swift
sed -n '390,490p' Footage/Presentation/PresentationModels.swift
sed -n '60,110p' Footage/App/AppCompositionRoot.swift
sed -n '250,320p' FootageTests/PresentationModelsTests.swift
rg -n "RenewedRestoreStatusViewController" Footage FootageTests footage.xcodeproj/project.pbxproj
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
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
- A twelfth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting foreground full-screen presentation.
- A thirteenth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting root replacement and widget timeline reload boundaries.
- A fourteenth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting Home initial data loading and selected-color restore boundaries.
- The next sandboxed `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` attempt failed with CoreSimulator connection/log permission errors and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.`
- `pwd`, `ls -la footage.xcworkspace`, `find footage.xcworkspace -maxdepth 2 -type f -print`, and `file footage.xcworkspace footage.xcworkspace/contents.xcworkspacedata` confirmed the workspace package still exists and `contents.xcworkspacedata` is an XML document.
- A fifteenth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting Home tracking command dispatch.
- A sixteenth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting background recording dispatch.
- A seventeenth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting scene user-state reads.
- An eighteenth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after extracting foreground route dispatch.
- The stale delegate-state search for `let homeVC = HomeViewController()` returned no remaining references after cleanup.
- A nineteenth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after removing stale `SceneDelegate.homeVC`.
- The Scene helper placement search confirmed the lifecycle helper definitions now live in `SceneLifecycleSupport.swift` and the file is included in `footage.xcodeproj`.
- A twentieth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after moving Scene lifecycle helpers into their own source file.
- The storyboard bridge placement search confirmed legacy storyboard descriptors/root factory definitions now live in `LegacyStoryboardBridge.swift` and the renewed shell factory remains in `RenewedShellStoryboardFactory.swift`.
- A twenty-first approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after moving legacy storyboard bridge/root factory types into their own source file.
- The renewed shell composition placement search confirmed `RenewedShellPresentation`, `RenewedShellTab`, `RenewedShellTabKind`, and the placeholder factory now live in `RenewedShellPresentation.swift`, with the new file included in `footage.xcodeproj`.
- A twenty-second approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after splitting renewed shell composition out of the UIKit shell controller file.
- The first placeholder-controller split test run failed with `Property 'tab' with type 'RenewedShellTab' cannot override a property with type 'UITab?'`. The cause was a new placeholder property name colliding with UIKit's `UIViewController.tab` API.
- A follow-up search confirmed the placeholder now uses `shellTab` instead of `tab`.
- A twenty-third approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after fixing the UIKit property-name conflict.
- The renewed shell coordinator placement search confirmed `RenewedShellCoordinator` now lives in `RenewedShellCoordinator.swift` and `StoryboardBackedRenewedShellViewControllerFactory` remains in `RenewedShellStoryboardFactory.swift`.
- A twenty-fourth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after splitting the renewed shell coordinator into its own source file.
- The programmatic shell factory search confirmed `ProgrammaticRenewedShellViewControllerFactory` lives in `ProgrammaticRenewedShellFactory.swift` and is included in `footage.xcodeproj`.
- A twenty-fifth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the programmatic renewed shell factory boundary.
- The app root factory search confirmed `AppRootViewControllerFactory` lives under `Footage/App`, maps `AppRootRoute` to legacy first-launch/main roots or the renewed UIKit shell, and is included in `footage.xcodeproj`.
- A twenty-sixth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the route-to-root factory boundary.
- The app root routing placement search confirmed `AppRootDestination`, `AppRootRoute`, and `AppRootRouter` now live in `AppRootRouting.swift`, with `FeatureFlags.swift` focused on flags.
- A twenty-seventh approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after splitting app root routing types out of `FeatureFlags.swift`.
- The composition-root boundary search confirmed `AppCompositionRoot` can now build `AppRootRouter` and `AppRootViewControllerFactory` from the current environment.
- A twenty-eighth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding composition-root factories for app root routing.
- The Scene app-root install policy search confirmed `SceneAppRootInstallAction`, `SceneLifecycleCoordinator.appRootInstallAction(route:)`, and its test live in the expected files.
- A twenty-ninth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the pure Scene app-root install policy.
- The programmatic screen candidate inspection selected the disabled Today dashboard as the safest first screen-level UIKit slice because it can use `HomeDashboardUseCase` and `HomeDistancePresentation` without touching live recording, MapKit, Storyboards, or Realm models.
- The first Today dashboard `xcodebuild test` failed because the new Xcode project file IDs collided with the existing `AppRootRouting.swift` references, making Xcode look for `Footage/Presentation/AppRootRouting.swift`.
- A follow-up `rg` confirmed `AppRootRouting.swift` and `RenewedTodayDashboardViewController.swift` now use separate project file/build IDs.
- The second Today dashboard `xcodebuild test` failed with `Missing return in instance method expected to return 'UIViewController'` in `ProgrammaticRenewedShellFactory.swift`; the placeholder fallback now returns the controller explicitly.
- A thirtieth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the disabled programmatic Today dashboard screen.
- The Settings screen inspection confirmed `SettingsPreferencesUseCase` already provides a read-only preferences snapshot suitable for a disabled renewed-shell screen.
- A thirty-first approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the disabled programmatic Settings dashboard screen.
- The Stats screen inspection confirmed `StatsOverviewUseCase` already provides read-only monthly distance, today/total distance, and ranking summary data suitable for a disabled renewed-shell screen.
- A thirty-second approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the disabled programmatic Stats overview screen.
- The Timeline inspection confirmed `DateTimelineUseCase` can provide `JourneyEntity` values without touching the legacy collection view, image preview cells, or storyboard navigation.
- A thirty-third approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the disabled programmatic Timeline screen.
- The Map inspection kept the first slice to a programmatic `MKMapView` canvas only, without route overlays, user-location permission prompts, annotation selection, or legacy map-bottom coupling.
- A thirty-fourth approved `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the disabled programmatic Map canvas screen.

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
- Added `SceneFullScreenPresenter` to centralize top-controller lookup and legacy full-screen sizing.
- Routed `SceneDelegate` password-unlock foreground presentation through the presenter.
- Added tests for presented-top-controller traversal and full-screen size/modal configuration.
- Added `SceneRootControllerInstaller` to centralize root view-controller replacement.
- Added `SceneWidgetTimelineReloading` and `WidgetKitSceneWidgetTimelineReloader` to isolate `WidgetCenter.shared.reloadAllTimelines()`.
- Routed `SceneDelegate` first-launch root replacement and widget timeline reload calls through the new helpers.
- Added tests for root replacement and a fake widget timeline reloader boundary.
- Added `SceneHomeInitialDataLoading` and `LegacySceneHomeInitialDataLoader` for legacy Home startup data preparation.
- Added `SceneSelectedColorStore` for legacy app-group `selectedColor` reads.
- Routed `SceneDelegate.scene(_:willConnectTo:options:)` through the new Home initial-data and selected-color boundaries.
- Added tests for selected-color app-group key reads and fake Home initial-data loader behavior.
- Added `SceneHomeTrackingCommand` and Home tracking command mapping on `SceneLifecycleCoordinator`.
- Added `SceneHomeViewControllerDispatching` / `LegacySceneHomeViewControllerDispatcher` to isolate legacy Home category restore and start/stop calls.
- Routed widget URL and initial widget-start Home tracking dispatch through the new dispatcher.
- Added tests for Home tracking command mapping and a fake Home view-controller dispatcher boundary.
- Added `SceneBackgroundRecordingDispatching` / `LegacySceneBackgroundRecordingDispatcher` to isolate legacy background timer/location-manager side effects.
- Routed `SceneDelegate.sceneDidEnterBackground(_:)` background recording action dispatch through that boundary.
- Added a fake background recording dispatcher test.
- Added `SceneUserStateStore` for legacy `UserState` and `alwaysOn` reads.
- Routed `SceneDelegate` foreground planning and background recording planning through `SceneUserStateStore`.
- Added a test proving the legacy foreground keys are read from isolated defaults.
- Added `SceneForegroundRouteDispatching` / `LegacySceneForegroundRouteDispatcher`.
- Routed foreground timer invalidation, password unlock presentation, and first-launch root replacement through the foreground route dispatcher.
- Added a fake foreground route dispatcher test.
- Removed the unused `SceneDelegate.homeVC` instance property.
- Added `SceneLifecycleSupport.swift` and moved Scene lifecycle coordinator, stores, dispatchers, presenter, root installer, Home initial data loader, selected-color store, and widget timeline reloader into it.
- Updated `footage.xcodeproj` target membership for `SceneLifecycleSupport.swift`.
- Removed the now-unneeded `WidgetKit` import from `RenewedShellStoryboardFactory.swift`.
- Added `LegacyStoryboardBridge.swift` and moved storyboard descriptors, storyboard instantiation, legacy renewed-shell storyboard providers, direct legacy Map provider, and legacy root factory into it.
- Updated `footage.xcodeproj` target membership for `LegacyStoryboardBridge.swift`.
- Added `RenewedShellPresentation.swift` and moved renewed shell composition types plus the placeholder tab factory into it.
- Updated `footage.xcodeproj` target membership for `RenewedShellPresentation.swift`.
- Added `RenewedShellPlaceholderViewController.swift` so disabled-by-default placeholder tabs are concrete programmatic UIKit controllers rather than inline factory views.
- Updated `PlaceholderRenewedShellViewControllerFactory` to return `RenewedShellPlaceholderViewController`.
- Added a test proving placeholder factory output carries the expected shell tab and title.
- Added `RenewedShellCoordinator.swift` and moved renewed shell root assembly out of `RenewedShellStoryboardFactory.swift`.
- Updated `footage.xcodeproj` target membership for `RenewedShellCoordinator.swift`.
- Added `ProgrammaticRenewedShellFactory.swift` with `ProgrammaticRenewedShellViewControllerFactory`, establishing the non-storyboard tab factory insertion point for future screen replacements.
- Added a test proving the programmatic factory currently returns placeholder screens for the default internal tabs.
- Added `AppRootViewControllerFactory.swift`, which converts `AppRootRoute` values into legacy storyboard roots or a disabled-by-default programmatic renewed shell root.
- Added a test proving the app root factory can build legacy main tabs, legacy first launch, and renewed shell roots without wiring it into runtime launch.
- Added `AppRootRouting.swift` and moved `AppRootDestination`, `AppRootRoute`, and `AppRootRouter` out of `FeatureFlags.swift`.
- Updated `footage.xcodeproj` target membership for `AppRootRouting.swift`.
- Added `AppCompositionRoot.makeAppRootRouter()` and `makeAppRootViewControllerFactory(...)`.
- Added a test proving the composition root can create the app root routing boundaries without wiring them into `SceneDelegate`.
- Added `SceneAppRootInstallAction` and `SceneLifecycleCoordinator.appRootInstallAction(route:)` to describe whether a planned route should keep the storyboard root or request a root replacement.
- Added a test proving legacy routes keep the storyboard root while the disabled renewed UIKit shell route requests replacement.
- Added `RenewedTodayDashboardViewController`, a read-only programmatic UIKit Today screen backed by `HomeDashboardSnapshot` and existing `HomeDistancePresentation` formatting.
- Extended `ProgrammaticRenewedShellViewControllerFactory` so only the `.today` tab returns `RenewedTodayDashboardViewController` when a `HomeDashboardUseCase` provider is injected; all other tabs still fall back to placeholders.
- Updated `AppCompositionRoot.makeAppRootViewControllerFactory(...)` so the disabled renewed shell can inject `makeHomeDashboardUseCase()` into the programmatic Today screen.
- Added tests proving the programmatic factory returns the Today dashboard only when the use case provider exists and proving the Today dashboard renders a fake snapshot.
- Updated `footage.xcodeproj` target membership for `RenewedTodayDashboardViewController.swift`.
- Added `SettingsPreferencesPresentation` for read-only cloud backup, restore, and auth feature state text.
- Added `RenewedSettingsDashboardViewController`, a read-only programmatic UIKit Settings screen backed by `SettingsPreferencesSnapshot`.
- Extended `ProgrammaticRenewedShellViewControllerFactory` so the `.settings` tab returns `RenewedSettingsDashboardViewController` when a `SettingsPreferencesUseCase` provider is injected; tabs without providers still fall back to placeholders.
- Updated `AppCompositionRoot.makeAppRootViewControllerFactory(...)` so the disabled renewed shell can inject `makeSettingsPreferencesUseCase()` into the programmatic Settings screen.
- Added tests proving Settings presentation text, factory routing, and fake-snapshot rendering.
- Updated `footage.xcodeproj` target membership for `RenewedSettingsDashboardViewController.swift`.
- Added `StatsOverviewPresentation` for read-only today, total, monthly, top color, and top place display text.
- Added `RenewedStatsOverviewViewController`, a read-only programmatic UIKit Stats screen backed by `StatsOverviewSnapshot`.
- Extended `ProgrammaticRenewedShellViewControllerFactory` so the `.stats` tab returns `RenewedStatsOverviewViewController` when a stats snapshot provider is injected.
- Updated `AppCompositionRoot.makeAppRootViewControllerFactory(...)` so the disabled renewed shell can inject a `makeStatsOverviewUseCase()` snapshot using the existing `DateConverter.lastMondayToday()` range.
- Added tests proving Stats presentation text, factory routing, and fake-snapshot rendering.
- Updated `footage.xcodeproj` target membership for `RenewedStatsOverviewViewController.swift`.
- Added `RenewedTimelineItemPresentation` for read-only journey date, distance, and count summary text.
- Added `RenewedTimelineViewController`, a read-only programmatic UIKit Timeline screen backed by `[JourneyEntity]`.
- Extended `ProgrammaticRenewedShellViewControllerFactory` so the `.timeline` tab returns `RenewedTimelineViewController` when a timeline journey provider is injected.
- Updated `AppCompositionRoot.makeAppRootViewControllerFactory(...)` so the disabled renewed shell can inject `makeDateTimelineUseCase().loadTimeline(range: .day)`.
- Added tests proving Timeline item presentation, factory routing, and fake-journey rendering.
- Updated `footage.xcodeproj` target membership for `RenewedTimelineViewController.swift`.
- Added `RenewedMapViewController`, a programmatic UIKit Map screen with a full-view `MKMapView` canvas.
- Extended `ProgrammaticRenewedShellViewControllerFactory` so the `.map` tab returns a programmatic map controller when a map provider is injected.
- Updated `AppCompositionRoot.makeAppRootViewControllerFactory(...)` so the disabled renewed shell can inject `RenewedMapViewController()`.
- Added tests proving Map factory routing and programmatic `MKMapView` layout.
- Updated `footage.xcodeproj` target membership for `RenewedMapViewController.swift`.
- Added `SceneAppRootInstaller`, a small side-effect boundary that either keeps the current storyboard root or installs a routed replacement root.
- Wired `SceneDelegate.scene(_:willConnectTo:options:)` to consult `AppCompositionRoot.makeAppRootRouter()` and dispatch `SceneLifecycleCoordinator.appRootInstallAction(route:)` before legacy Home preparation.
- Added tests proving the app-root installer leaves the existing root untouched for `.keepStoryboardRoot` and replaces the root for `.renewedUIKitShell`.
- Added `SceneInitialLaunchPlan` so the initial window-scene, widget URL, and app-root action are planned together.
- Updated `SceneDelegate` to consume the combined initial launch plan instead of stitching the initial connection and app-root install decisions inline.
- Added tests proving non-window scenes never request root replacement and widget-launched renewed routes preserve the widget-start signal while planning the renewed root replacement.
- Added the repository task harness files and committed them before continuing R14 executor tasks.
- Added a renewed-root smoke test proving `AppCompositionRoot` can build a `RenewedShellViewController` for an enabled existing-user route without returning the legacy first-launch controller.
- Added an initial launch parity matrix test covering first-launch with flags off/on, existing-user default widget launch, existing-user renewed widget launch, and non-window-scene renewed launch.
- Used a read-only sub-agent to confirm backup status use-case and fake patterns before adding the next screen slice.
- Added `RenewedBackupStatusViewController`, a standalone programmatic UIKit screen that reads `BackupPreparationUseCase.status()` and renders pending/failed counts plus last prepared/error text.
- Added a rendering test proving the backup status screen does not call `prepare(configuration:)`.
- Added `RenewedBackupStatusViewController.swift` to the app target in `footage.xcodeproj`.
- Used a read-only sub-agent to confirm the smallest safe follow-up for exposing the backup status screen from renewed Settings.
- Added an optional read-only "백업 상태" entry to `RenewedSettingsDashboardViewController`; it appears only when a backup-status screen factory is injected.
- Wired `ProgrammaticRenewedShellViewControllerFactory` and `AppCompositionRoot` so the disabled renewed Settings path can lazily create `RenewedBackupStatusViewController` from `BackupPreparationUseCase`.
- Added tests proving the Settings entry navigates to `RenewedBackupStatusViewController` without calling `prepare(configuration:)`.
- Used a read-only sub-agent to split restore and auth readiness; restore status was selected as the next bounded task, and auth readiness remains separate.
- Added `RenewedRestoreStatusViewController`, a read-only UIKit screen that renders `RestorePreviewUseCase.status()` through `RestoreStatusPresentation`.
- Added an optional renewed Settings "복원 상태" entry that appears only when a restore-status screen factory is injected.
- Wired `ProgrammaticRenewedShellViewControllerFactory` and `AppCompositionRoot` so the disabled renewed Settings path can lazily create `RenewedRestoreStatusViewController` from `RestorePreviewUseCase`.
- Added tests proving the restore status screen and Settings entry do not call restore preview/import behavior.
- Added `RenewedAuthReadinessViewController`, a read-only UIKit screen that renders `AuthLinkingReadinessUseCase.snapshot()` through `AuthLinkingReadinessPresentation`.
- Added an optional renewed Settings "계정 연결 상태" entry that appears only when an auth-readiness screen factory is injected.
- Wired `ProgrammaticRenewedShellViewControllerFactory` and `AppCompositionRoot` so the disabled renewed Settings path can lazily create `RenewedAuthReadinessViewController` from `AuthLinkingReadinessUseCase`.
- Added tests proving the auth-readiness screen reads snapshot state only and does not start account linking.
- Added `docs/RENEWED_ROOT_QA_PLAN.md` to define the manual QA gate before enabling the renewed UIKit root for production-facing builds.
- Added `RenewedAboutViewController`, a read-only UIKit boundary for the legacy Settings About screen's version/privacy/contact labels.
- Added an optional renewed Settings "앱 정보" entry that appears only when an about screen factory is injected.
- Wired `ProgrammaticRenewedShellViewControllerFactory` and `AppCompositionRoot` so the disabled renewed Settings path can lazily create `RenewedAboutViewController` from the legacy `version` user default.
- Added tests proving the renewed About screen renders `AppVersionPresentation` output and static privacy/contact labels.

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
- `SceneDelegate` still requests the existing `PasswordVC` from the legacy storyboard root factory; the presenter only centralizes current modal setup.
- `SceneDelegate` still replaces the root with the same `FirstLaunch` storyboard controller and reloads all widget timelines at the same lifecycle points.
- `SceneDelegate` still applies the selected category to the existing `HomeViewController` and still prepares the same legacy Home data through `DateManager`.
- `SceneDelegate` still selects the first legacy tab and still sends the same start/stop/category calls to `HomeViewController`; those calls now pass through `LegacySceneHomeViewControllerDispatcher`.
- `SceneDelegate` still schedules the same 2.5 second repeating always-on timer and calls the same `HomeViewController.locationManager` methods for background recording.
- `SceneDelegate` still reads the same `UserState` and `alwaysOn` keys from standard defaults; those reads now pass through `SceneUserStateStore`.
- `SceneDelegate` still invalidates the always-on timer and performs the same password unlock / first-launch foreground routes; those calls now pass through `LegacySceneForegroundRouteDispatcher`.
- `SceneDelegate` still uses the storyboard-selected Home tab for category and tracking dispatch; the removed `homeVC` property was not referenced.
- Moving Scene helper types changed source placement only; production launch still uses the existing `Main` storyboard path and the same helper implementations.
- Moving legacy storyboard bridge/root factory types changed source placement only; the same storyboard identifiers and direct Map provider remain in use.
- Moving renewed shell composition types changed source placement only; the disabled-by-default UIKit shell still has no production launch path.
- Adding the placeholder controller changed only the disabled-by-default renewed shell fallback path; production launch still uses the existing storyboard root.
- Moving `RenewedShellCoordinator` changed source placement only; the coordinator remains disabled by default and is not wired into production launch.
- Adding the programmatic renewed shell factory changed only disabled-by-default scaffolding; existing runtime navigation still uses the storyboard launch path.
- Adding `AppRootViewControllerFactory` changed only disabled-by-default routing scaffolding; `SceneDelegate` still uses the existing launch path.
- Moving app root routing types changed source placement only; the default feature flags and launch behavior remain unchanged.
- Adding composition-root factory methods changed only construction boundaries; `SceneDelegate` still uses the existing launch path.
- Adding the Scene app-root install policy changed pure planning only; `SceneDelegate` does not consume it yet, so production launch still uses the existing storyboard root.
- Adding the Today dashboard changed only the disabled renewed shell path; `SceneDelegate`, the legacy Home storyboard screen, recording controls, widget files, and launch configuration were not changed.
- The Xcode project ID collision was corrected before commit; `AppRootRouting.swift` remains in the App group and `RenewedTodayDashboardViewController.swift` is the separate Presentation file.
- Adding the Settings dashboard changed only the disabled renewed shell path; legacy Settings storyboards, preference mutation flows, auth/password flows, and backup behavior were not changed.
- Adding the Stats overview changed only the disabled renewed shell path; legacy Stats storyboards, ranking detail navigation, Realm schema, and existing Stats runtime behavior were not changed.
- Adding the Timeline screen changed only the disabled renewed shell path; legacy Date storyboard, preview image collection view, journey navigation, and current archive runtime behavior were not changed.
- Adding the Map canvas changed only the disabled renewed shell path; legacy Map storyboard, live route rendering, annotations, map bottom sheet, and location behavior were not changed.
- Wiring the app-root installer into `SceneDelegate` changed the initial connection path only to ask the disabled-by-default router first; with default flags, it returns `.keepStoryboardRoot`, does not replace the root, and continues existing legacy Home preparation.
- Combining initial launch planning changed only the shape of the decision boundary; default root, widget URL, and legacy Home preparation behavior remain the same.
- The renewed root replacement path remains behind `FeatureFlags.isNewUIRunwayEnabled` and is not enabled by default.
- The renewed-root smoke test changes tests only; no feature flag default, `SceneDelegate`, storyboard, or production route behavior was changed.
- The initial launch parity matrix changes tests only; it does not enable the renewed UI flag, alter `SceneDelegate`, or change widget URL side effects.
- The backup status screen is standalone and not wired into production navigation or the renewed shell tabs yet.
- The backup status screen calls `status()` only; it does not call `prepare(...)`, upload data, change opt-in, start networking, auth, or restore work.
- The backup status Settings entry is limited to the disabled renewed Settings path and is created lazily on tap; default production launch and legacy Settings remain unchanged.
- Adding the backup status Settings entry did not add a new tab and did not change `SceneDelegate`, feature flag defaults, Storyboards, signing, entitlements, bundle identifiers, widget files, or Realm schema.
- The restore status Settings entry is limited to the disabled renewed Settings path and is created lazily on tap; it calls `status()` only and does not fetch manifests, preview imports, import data, access tokens, start auth, or perform networking.
- Adding the restore status Settings entry did not add a new tab and did not change `SceneDelegate`, feature flag defaults, Storyboards, signing, entitlements, bundle identifiers, widget files, or Realm schema.
- The auth-readiness Settings entry is limited to the disabled renewed Settings path and is created lazily on tap; it calls `snapshot()` only and does not start linking, request provider tokens, process authorization codes, or perform networking.
- Adding the auth-readiness Settings entry did not add a new tab and did not change `SceneDelegate`, feature flag defaults, Storyboards, signing, entitlements, bundle identifiers, widget files, or Realm schema.
- The renewed root QA plan is documentation-only and does not enable the renewed root route or change app runtime behavior.
- The renewed About screen is limited to the disabled renewed Settings path and is display-only; it does not change legacy About, mail composer, privacy navigation, Storyboards, or production Settings behavior.
- `Info.plist`, Storyboards, widget target files, signing, entitlements, bundle identifiers, app group keys, Realm schema, backup, restore, and auth behavior were not changed.
- A sandboxed `xcodebuild test` run failed before test execution with CoreSimulator access errors and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.` The workspace directory and `contents.xcworkspacedata` were inspected and valid, then the same command succeeded with external Xcode/Simulator permissions.
- One `xcodebuild test` run failed on `UseCasesTests.testAppCompositionRootBuildsRenewedRootForEnabledRouteWithoutLoadingViews()` because the test incorrectly assumed `RenewedShellViewController.isViewLoaded` would remain false after root construction. The assertion was narrowed to route/root identity and non-first-launch root identity, and the next `xcodebuild test` succeeded.
- The latest `xcodebuild test` succeeded after adding `UseCasesTests.testInitialLaunchParityMatrixKeepsDefaultAndFirstLaunchRoutesSafe()`.
- The latest `xcodebuild test` succeeded after adding `RenewedBackupStatusViewController`.
- A sandboxed `xcodebuild test` attempt failed before compilation with CoreSimulator permission errors and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.` The same command succeeded after rerunning with external Xcode/Simulator permissions.
- The latest `xcodebuild test` succeeded after adding the optional renewed Settings backup-status entry.
- A sandboxed `xcodebuild test` attempt failed before compilation with CoreSimulator permission errors and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.` The same command succeeded after rerunning with external Xcode/Simulator permissions.
- The latest `xcodebuild test` succeeded after adding the read-only renewed Settings restore-status entry.
- A sandboxed `xcodebuild test` attempt failed before compilation with CoreSimulator permission errors and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.` The same command succeeded after rerunning with external Xcode/Simulator permissions.
- The latest `xcodebuild test` succeeded after adding the read-only renewed Settings auth-readiness entry.
- A sandboxed `xcodebuild test` attempt failed before compilation with CoreSimulator permission errors and `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.` The same command succeeded after rerunning with external Xcode/Simulator permissions.
- The latest `xcodebuild test` succeeded after adding the read-only renewed Settings About boundary.

## What Remains

- Execute the renewed root manual QA plan before enabling the renewed root route.
- Continue storyboard-removal runway by extracting one more legacy screen boundary after the QA gate is documented.
- Keep the default app launch on the existing UIKit/Storyboard shell until manual QA proves parity.
