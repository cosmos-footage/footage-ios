# Phase 7 Changelog: Auth Linking Scaffold

Date: 2026-07-04.

## Scope

Phase 7 added an auth-linking scaffold that can represent linking a future provider identity to the existing anonymous `ownerId`.

Added:

- `Footage/Services/Auth/AuthModels.swift`
- `Footage/Services/Auth/Providers/AuthProviderAdapter.swift`
- `Footage/Services/Auth/Providers/AppleAuthProviderAdapter.swift`
- `Footage/Services/Auth/Providers/CognitoAuthProviderAdapter.swift`
- `Footage/Services/Auth/Linking/AuthLinkingService.swift`

Changed:

- `CloudBackupAPIClient` now has a `POST /v1/auth/link` helper.
- The main app target now includes the Auth scaffold files.

Not changed:

- No login UI.
- No required login.
- No Sign in with Apple entitlement/capability changes.
- No bundle identifier, signing, or entitlement changes.
- No Auth token persistence.
- No Realm migration.
- No local data deletion or owner reassignment.

## Behavior

`AuthLinkingService` refuses to run unless cloud backup configuration is explicitly enabled and a bearer token is supplied.

It reads the current anonymous `ownerId` from `DeviceIdentityRepository`, sends that same owner to `/v1/auth/link`, and rejects responses that return a different `ownerId`.

`LocalAuthIdentityStore` persists linked identity metadata only. It does not store raw provider tokens.

## Providers

`AppleAuthProviderAdapter` is scaffold-only and returns unavailable until capability/UI work is reviewed.

`CognitoAuthProviderAdapter` is placeholder-only.

## Validation

Commands run:

```sh
git status --short
xcodebuild -list -workspace footage.xcworkspace
scripts/phase1-build-baseline.sh
```

Results:

- Workspace listing succeeded.
- `scripts/phase1-build-baseline.sh` succeeded after Phase 7 changes.

## Next Step

Next recommended phase: TestFlight/App Store readiness documentation and privacy/release checklist review.
