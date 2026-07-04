# Phase 8 Changelog: TestFlight and App Store Readiness

Date: 2026-07-04.

## Scope

Phase 8 added release-readiness documentation and audited release-sensitive settings.

Added:

- `docs/APP_STORE_READINESS.md`
- `docs/PRIVACY_REVIEW.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/PHASE8_CHANGELOG.md`

No app source, signing, bundle identifier, entitlement, Realm schema, Storyboard, asset, widget source, cloud default, restore default, or auth requirement was changed.

## Findings

- iOS 18.0 baseline is configured.
- App and widget schemes list successfully.
- App and widget Debug/Release simulator builds pass through `scripts/phase1-build-baseline.sh`.
- App has background location mode and Korean location/photo/Face ID permission strings.
- Cloud Backup, Restore, and Auth remain scaffold-only and disabled/not automatic.
- Archive readiness is documented but not verified because signing was intentionally not changed.

## Commands Run

```sh
git status --short
find . -maxdepth 4 \( -name 'Info.plist' -o -name '*.entitlements' -o -name 'PrivacyInfo.xcprivacy' -o -name 'Podfile' -o -name '*.xcworkspace' -o -name '*.xcodeproj' \) -print | sort
plutil -p Footage/Resource/Info.plist
plutil -p MainWidget/Info.plist
plutil -p Entitlements/footage.entitlements
plutil -p Entitlements/MainWidgetExtension.entitlements
rg -n "CloudBackupConfiguration|isCloudBackupEnabled|isDevelopmentUploadEnabled|RestoreService|AuthLinkingService|footage-cloud-backup|AWS|SECRET|TOKEN|Bearer|NSLocation|NSPhoto|NSCamera|UIBackgroundModes|group\\.footage" Footage MainWidget Entitlements docs/API_SPEC.md docs/MODERNIZATION_PLAN.md
xcodebuild -list -workspace footage.xcworkspace
scripts/phase1-build-baseline.sh
```

Validation result:

- Workspace listing succeeded.
- Baseline build succeeded.

## Next Step

Next recommended phase: final release candidate hardening, unsafe-default audit, sensitive-string audit, and Go/No-Go documentation.
