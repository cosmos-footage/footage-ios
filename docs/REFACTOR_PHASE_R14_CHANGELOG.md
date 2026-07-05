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
```

## Results

- `git diff --check` succeeded.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- A second `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding the SwiftUI shell scaffold.

## Changed

- Added `FeatureFlags.isNewUIRunwayEnabled`, defaulting to `false`.
- Added `AppRootDestination`, `AppRootRoute`, and `AppRootRouter`.
- Chose the R14 runway direction as a renewed SwiftUI shell, but only behind the disabled feature flag.
- Added tests proving the legacy Storyboard route remains the default.
- Added tests proving the renewed shell route can be selected behind the flag without skipping first-launch onboarding.
- Added `RenewedShellView`, a minimal internal SwiftUI `TabView` shell.
- Added `RenewedShellPresentation`, `RenewedShellTab`, and `RenewedShellTabKind`.
- Added the new SwiftUI file to the app target in `footage.xcodeproj`.
- Added tests for the default internal shell tabs.

## Safety Notes

- No SceneDelegate, Storyboard, root controller, widget, signing, entitlement, bundle identifier, asset, Realm schema, network, auth, restore, or backup runtime behavior was changed.
- The renewed shell route is not wired into app launch yet.
- First-launch users still route to the existing FirstLaunch Storyboard in the router.
- The SwiftUI shell is compiled but not reachable from the production launch path.

## What Remains

- Add routing/coordinator adapters that can host existing UIKit controllers from the new shell.
- Keep the default app launch on the existing UIKit/Storyboard shell until manual QA proves parity.
