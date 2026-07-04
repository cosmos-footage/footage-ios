# Footage iOS Agent Instructions

This repository contains the legacy iOS app `footage`, a private walking-route and life-map archive. Treat the route history, photos, notes, app group state, bundle identifiers, signing configuration, widget target, and Realm files as user data and release-critical surfaces.

## Safety Rules

- Do not delete or rewrite existing user data models, Realm classes, assets, entitlements, widget files, Storyboards/XIBs, bundle identifiers, app group identifiers, or signing settings unless the change is explicitly requested and justified in the PR or final response.
- Do not remove `Podfile`, `Podfile.lock`, CocoaPods integration, RealmSwift, EFCountingLabel, MapKit, or WidgetKit in Phase 0/Phase 1 work. Dependency removal requires a captured build baseline and a migration plan.
- Do not introduce analytics, tracking SDKs, ad SDKs, crash reporters that collect location, public route sharing, or public object storage.
- Do not log raw latitude/longitude, uploaded object keys containing sensitive identifiers, photos, notes, auth tokens, or presigned URLs.
- Do not make irreversible refactors before a build/audit baseline exists. Prefer additive adapters, repositories, and migration code.
- Preserve the app group `group.footage` and widget behavior unless a migration plan covers both app and widget.
- Preserve local-first behavior: location points must be written locally before any cloud or network operation.

## Implementation Style

- Prefer small, reviewable diffs with buildable checkpoints.
- Use doc-first migration for architecture changes: update PRD/audit/plan/API/data model before changing persistence or sync behavior.
- Prefer repository/service boundaries around existing Realm code before replacing Realm.
- Add tests or lightweight verification proportional to risk. For data migration or sync identity changes, include explicit migration and rollback notes.
- Keep UIKit/Storyboard screens stable while introducing SwiftUI incrementally behind clear boundaries.
- Use explicit privacy language for any server, S3, auth, or logging change.
- For modernizing dependencies, document the current version, target version, build result, and compatibility risks before changing package managers.

## Known Project Surfaces

- Main app target: `footage`
- Widget extension target: `MainWidgetExtension`
- Workspace: `footage.xcworkspace`
- Project: `footage.xcodeproj`
- Main app bundle identifier: `co.el.footage`
- Widget bundle identifier: `co.el.footage.MainWidget`
- App group: `group.footage`
- Current local persistence: RealmSwift models under `Footage/Model`
- Primary location flow: `Footage/Scene/Home/HomeViewController.swift` -> `LocationUpdate` -> `DateManager`/stats managers
- Widget state: app group `UserDefaults` keys such as `isTracking`, `distanceToday`, `distanceTotal`, `selectedColor`

## Validation Expectations

- First run lightweight inspection: `git status --short`, `rg --files`, `find` for workspaces/projects/entitlements, and targeted `rg` for touched APIs.
- If full Xcode is available, run `xcodebuild -list -workspace footage.xcworkspace` before project edits.
- Do not claim a build succeeded unless an actual build/list/test command succeeded.
- If Xcode is unavailable or `xcode-select` points to Command Line Tools, document that exact limitation.
