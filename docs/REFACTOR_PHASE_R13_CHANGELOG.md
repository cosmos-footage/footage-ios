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
```

## Results

- `git diff --check` succeeded.
- `xcodebuild test -workspace footage.xcworkspace -scheme footage -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' CODE_SIGNING_ALLOWED=NO` succeeded.
- New `PresentationModelsTests` passed, including year/month/day legacy date-key formatting and preview-data retention.

## Changed

- Added `Footage/Presentation/PresentationModels.swift`.
- Added `JourneyDatePresentation` for legacy date-key formatting.
- Added `JourneyTimelineItemPresentation` for the Date timeline cell's title and preview payload.
- Updated `DateViewController` cell binding to use `JourneyTimelineItemPresentation` instead of inline date-formatting logic.
- Added `FootageTests/PresentationModelsTests.swift`.

## Safety Notes

- No Storyboard, XIB, asset, widget, signing, entitlement, bundle identifier, app group, Pod, Realm model, Realm migration, network, S3, auth, restore, or recording behavior was changed.
- The Date screen keeps the same Korean labels for year, month, and day keys.
- This is a read-only presentation extraction only; persistence and navigation behavior are unchanged.

## What Remains

- Continue R13 by adding presentation models for Home dashboard and Journey detail state.
- Move formatting and empty-state logic out of controllers in small tested slices.
- Keep UIKit controllers responsible for outlets, gestures, layout, animation, map binding, and navigation until the replacement UI is planned separately.
