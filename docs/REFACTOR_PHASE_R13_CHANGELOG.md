# Refactor Phase R13 Changelog

Date: 2026-07-05.

## Goal

Start the presentation-model layer so the legacy UIKit shell can become thinner without changing visible behavior or rewriting screens yet.

## Commands Run

```sh
git status --short
rg --files Footage/Domain Footage/Scene/Date Footage/App FootageTests docs
sed -n '1,240p' Footage/Scene/Date/DateViewController.swift
sed -n '1,340p' Footage/Scene/Date/JourneyViewController.swift
sed -n '1,260p' Footage/Domain/UseCases.swift
sed -n '140,190p' docs/UI_REWRITE_REFACTOR_PLAN.md
rg -n "C0D830|PresentationModels" footage.xcodeproj/project.pbxproj Footage FootageTests
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
sed -n '1,320p' Footage/Scene/Home/HomeViewController.swift
sed -n '1,260p' Footage/Scene/Date/JourneyAnimation.swift
sed -n '1,260p' Footage/Scene/Date/JourneyManager.swift
sed -n '320,760p' Footage/Scene/Home/HomeViewController.swift
sed -n '1,220p' Footage/Scene/Home/HomeAnimation.swift
rg -n "String\(format: \"%\.2f\"|String\(format: \"%\.f\"|date / 100|date % 100|countFrom\(2000|countFrom\(0, to: CGFloat\(date" Footage/Scene/Home Footage/Scene/Date Footage/Presentation FootageTests
rg --files Footage/Scene/Stats Footage/Scene/Map Footage/Presentation FootageTests
sed -n '1,280p' Footage/Scene/Stats/StatsViewController.swift
sed -n '1,280p' Footage/Scene/Stats/ReportVC.swift
sed -n '1,280p' Footage/Scene/Stats/ReportDetailVC.swift
sed -n '1,240p' Footage/Scene/Stats/ColorVC.swift
sed -n '1,240p' Footage/Scene/Stats/PlaceVC.swift
sed -n '1,120p' Footage/Scene/Stats/Place_DetailVC.swift
rg -n "String\(format: \"%\.2f\"|String\(format: \"%\.f\"|getCityImage|setCityImage|ReportButtonPresentation|DistanceTextPresentation|CityPresentation" Footage/Scene/Stats Footage/Presentation FootageTests
sed -n '1,260p' Footage/Scene/Map/MapViewController.swift
sed -n '1,260p' Footage/Scene/Map/MapCollectionVC.swift
sed -n '1,260p' Footage/Scene/Map/MapTableVC.swift
sed -n '1,220p' Footage/Scene/Map/MapCollectionCell.swift
sed -n '1,220p' Footage/Scene/Map/MapTableCell.swift
sed -n '1,240p' Footage/Scene/Map/MapBottomVC.swift
rg -n "String\(format: \"%\.2f\"|date / 10000|사진:|글:|MapFootstepPresentation" Footage/Scene/Map Footage/Presentation FootageTests
sed -n '1,260p' Footage/Scene/Settings/Settings_GeneralVC.swift
sed -n '1,280p' Footage/Scene/Settings/Settings_General_PushVC.swift
sed -n '1,160p' Footage/Scene/Settings/Settings_AboutVC.swift
rg -n "struct LocalBackupStatus|LocalBackupStatus|cloudBackupStatusText|showValue|버전정보" Footage FootageTests docs
sed -n '1,320p' Footage/Presentation/PresentationModels.swift
sed -n '1,360p' FootageTests/PresentationModelsTests.swift
git diff -- Footage/Presentation/PresentationModels.swift Footage/Scene/Settings/Settings_GeneralVC.swift Footage/Scene/Settings/Settings_General_PushVC.swift Footage/Scene/Settings/Settings_AboutVC.swift FootageTests/PresentationModelsTests.swift
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
rg --files Footage | rg 'Restore|Auth|Backup|Settings|Presentation'
sed -n '1,340p' Footage/Services/Restore/RestoreModels.swift
sed -n '1,320p' Footage/Services/Auth/AuthModels.swift
sed -n '1,320p' Footage/Services/Auth/Linking/AuthLinkingService.swift
sed -n '1,340p' FootageTests/UseCasesTests.swift
git diff -- Footage/Presentation/PresentationModels.swift FootageTests/PresentationModelsTests.swift
git diff --check
xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO
```

## Results

- `git diff --check` succeeded.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- New `PresentationModelsTests` passed, including year/month/day legacy date-key formatting and preview-data retention.
- A second `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding Home distance and Journey detail presentation models.
- A third `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding Stats/Report presentation models.
- A fourth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding Map archive presentation models.
- A fifth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding Settings presentation models.
- A sixth `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` run succeeded after adding Restore/Auth presentation models.

## Changed

- Added `Footage/Presentation/PresentationModels.swift`.
- Added `JourneyDatePresentation` for legacy date-key formatting.
- Added `JourneyTimelineItemPresentation` for the Date timeline cell's title and preview payload.
- Updated `DateViewController` cell binding to use `JourneyTimelineItemPresentation` instead of inline date-formatting logic.
- Added `FootageTests/PresentationModelsTests.swift`.
- Added `JourneyDateDetailPresentation` for Journey detail date animation state.
- Updated `JourneyAnimation` to use `JourneyDateDetailPresentation` instead of inline legacy date decomposition.
- Added `HomeDistancePresentation` for Home start/stop distance text, counter value, and Korean heading text.
- Updated `HomeAnimation` to use `HomeDistancePresentation`.
- Updated Home live distance label assignment to use `HomeDistancePresentation`.
- Added `CityPresentation` for shared city image names and nickname text.
- Added `DistanceTextPresentation` for legacy integer, decimal, and `km`-suffixed distance labels.
- Added `ReportButtonPresentation` for legacy enabled/alpha state.
- Updated `StatsViewController`, `ColorVC`, `PlaceVC`, `Place_DetailVC`, `ReportVC`, and `ReportDetailVC` to use presentation models for formatting-only display state.
- Added `MapFootstepPresentation` for map archive selected-footstep and nearby-table cell labels.
- Updated `MapTableCell` and `SelectedView` in `MapBottomVC` to use `MapFootstepPresentation`.
- Added `CloudBackupStatusPresentation`, `SettingsPushTimePresentation`, and `AppVersionPresentation`.
- Updated `Settings_GeneralVC`, `Settings_General_PushVC`, and `Settings_AboutVC` to use presentation models for display-only string formatting.
- Added `RestoreStatusPresentation`, `RestoreImportPlanPresentation`, `AuthLinkStatePresentation`, and `AuthLinkingReadinessPresentation`.
- Kept Restore/Auth presentation models disconnected from UI because Restore/Auth are still disabled scaffolds without production UX.

## Safety Notes

- No Storyboard, XIB, asset, widget, signing, entitlement, bundle identifier, app group, Pod, Realm model, Realm migration, network, S3, auth, restore, or recording behavior was changed.
- The Date screen keeps the same Korean labels for year, month, and day keys.
- Journey detail keeps the existing legacy date-counter behavior, including the two-digit year counter for day-level journeys.
- Home keeps the same recording-today distance format (`%.2f`) and total-archive distance format (`%.f`).
- Stats/Report/Color/Place screens keep the same distance formats, city image fallbacks, and report button alpha behavior.
- Map archive keeps the same date, distance, category, photo count, and note count labels.
- Settings keeps the same cloud backup status text, push time row text, zero-padded picker row titles, and version label text.
- Restore/Auth presentation models only expose read-only state text and action availability; no restore import, auth linking, network, or token behavior was enabled.
- This is a read-only presentation extraction only; persistence and navigation behavior are unchanged.

## What Remains

- Continue R13 by reviewing remaining first-launch and level/badge display formatting, or move on to R14 once those are intentionally deferred.
- Move remaining formatting and empty-state logic out of controllers in small tested slices.
- Keep UIKit controllers responsible for outlets, gestures, layout, animation, map binding, and navigation until the replacement UI is planned separately.
