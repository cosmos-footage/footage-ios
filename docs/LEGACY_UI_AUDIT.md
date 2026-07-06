# Legacy UI Audit

Date: 2026-07-05

Scope: documentation-only audit of the legacy UIKit UI layer. This file inventories
ViewControllers, storyboard screens, direct persistence and platform dependencies,
do-not-delete surfaces, and a recommended extraction order for turning
ViewControllers into thin shells.

No app source, project files, signing, entitlements, Pods, Realm models, widget
files, storyboards, or assets were changed for this audit.

## Validation Baseline

- `git status --short` before the audit showed one pre-existing modified file:
  `footage.xcworkspace/xcuserdata/nyeok.xcuserdatad/UserInterfaceState.xcuserstate`.
  This audit does not own or modify it.
- `rg --files` was used for lightweight repository inspection.
- `find . -name '*.xcworkspace' -o -name '*.xcodeproj' -o -name '*.entitlements'`
  found:
  - `footage.xcworkspace`
  - `footage.xcodeproj`
  - `footage.xcodeproj/project.xcworkspace`
  - `Pods/Pods.xcodeproj`
  - `Entitlements/footage.entitlements`
  - `Entitlements/footageRelease.entitlements`
  - `Entitlements/MainWidgetExtension.entitlements`
  - `Entitlements/MainWidgetExtensionRelease.entitlements`
- `xcodebuild -list -workspace footage.xcworkspace` was attempted because Xcode is
  installed at `/Applications/Xcode.app/Contents/Developer`, but it failed before
  listing schemes. The command reported simulator/cache permission noise and ended
  with `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.`
  Do not claim build or list success from this audit.

## Storyboard And Navigation Inventory

### Main Shell

- `Footage/Storyboard/Base.lproj/Main.storyboard`
  - Initial controller: `TabBarController`.
  - Relationships:
    - Home placeholder -> `Home.storyboard`, `HomeViewController`.
    - Map tab -> inline `MapViewController`.
    - Stats placeholder -> `Stats.storyboard`, `StatsViewController`.
    - Date placeholder -> `Date.storyboard`, `DateViewController`.
    - Settings placeholder -> `Settings.storyboard`, `SettingsViewController`.
  - Also owns `PasswordVC`, presented from `SceneDelegate` when lock state requires it.

### Renewed UIKit Shell Bridge

The R14 programmatic UIKit bridge keeps the production launch on `Main.storyboard`, but defines a disabled-by-default host path for gradual Storyboard removal.

| Renewed tab | Legacy source | Identifier or construction | Notes |
| --- | --- | --- | --- |
| Home | `Home.storyboard` | `HomeViewController` | Storyboard-backed to preserve outlets, EFCountingLabel wiring, and recording UI. |
| Map | Programmatic class | `MapViewController()` | Inline in `Main.storyboard` today and has no storyboard identifier. Do not load its view before it is inside a tab bar. |
| Stats | `Stats.storyboard` | `StatsViewController` | Storyboard-backed to preserve segues and report/detail flows. |
| Date | `Date.storyboard` | `DateViewController` | Must remain at index `3` while map flows still assume that tab index. |
| Settings | `Settings.storyboard` | `SettingsViewController` | Storyboard-backed to preserve settings segues. |

The future IA can reorder tabs after map navigation and date routing stop relying on legacy tab indexes.

### First Launch Flow

- `Footage/Storyboard/FirstLaunch.storyboard`
  - Initial controller: `FL_VideoVC`.
  - Screens:
    - `FL_VideoVC`: intro video playback.
    - `FL_ProfileSettingsVC`: first-run profile name and photo choice.
    - `FL_NameColorVC`: first-run category color names stored in app group defaults.
    - `ProfileSelectionVC`: reusable photo-library grid.
    - `ProfileEditVC`: reusable crop/edit surface for selected profile image.
    - `FL_LetsStartVC`: sets first-run lock state and switches root to `TabBarController`.
  - Navigation relies on storyboard segues and a placeholder back into `Main`.

### Home Tab

- `Footage/Storyboard/Home.storyboard`
  - Initial controller: `HomeViewController`.
  - Uses `EFCountingLabel`, MapKit map, category buttons, tracking start/stop UI, alert dot,
    and first-use explanatory image.

### Map Tab

- `Footage/Storyboard/Base.lproj/Main.storyboard`
  - Inline `MapViewController`.
- Runtime child controllers created through `Footage/Scene/Map/MapBridge.swift`:
  - `MapBottomVC`
  - `MapTableVC`
  - `MapCollectionVC`

### Stats Tab

- `Footage/Storyboard/Stats.storyboard`
  - Initial controller: `StatsViewController`.
  - Screens:
    - `StatsViewController`: summary dashboard.
    - `LevelVC`: badge grid and today badge selector.
    - `ColorVC`: color ranking.
    - `ColoredJourneyVC`: route map filtered by color.
    - `PlaceVC`: place ranking top cards.
    - `Place_DetailVC`: place ranking detail table.
    - `ReportVC`: monthly report selector.
    - `ReportDetailVC`: monthly report detail, badge/color/place summaries.
  - Supporting UI:
    - `PopUpCard.xib` / `PopUpCard`
    - `PlaceAnimation`
    - badge/report cells declared in controller files.

### Date Tab

- `Footage/Storyboard/Date.storyboard`
  - Initial controller: `DateViewController`.
  - Screens:
    - `DateViewController`: day/month/year journey list.
    - `JourneyViewController`: route detail map, slider, photo/note entry points.
    - `PhotoSelectionVC`: photo-library picker for a footstep.
  - Runtime child:
    - `PhotoCollectionVC` embedded by `JourneyViewController` through `JourneyManager`.
  - Supporting cells/layouts:
    - `MapCell.xib` / `MapCell`
    - `PhotoCell`
    - `GroupCell`
    - `CardCell`
    - `SectionHeader`
    - `BadgeSupplementaryView`
    - `PhotoCollectionLayout`
    - `JourneyAnimation`

### Settings Tab

- `Footage/Storyboard/Settings.storyboard`
  - Initial controller: `SettingsViewController`.
  - Screens:
    - `SettingsViewController`: menu hub.
    - `Settings_GeneralVC`: profile, notification, lock, biometric, cloud backup settings.
    - `Settings_General_ProfileVC`: profile name and image editor entry point.
    - `Settings_General_PasswordVC`: passcode create/change screen.
    - `Settings_General_PushVC`: notification toggles and time picker.
    - `Settings_NameColorVC`: category display names in app group defaults.
    - `Settings_DonateVC`: StoreKit donation purchases.
    - `Settings_AboutVC`: app version, privacy page, mail contact.
    - `Settings_About_PersonalInformationVC`: privacy information screen.

## ViewController Inventory

### Home And First Launch

| ViewController | Role | Direct dependencies |
| --- | --- | --- |
| `HomeViewController` | Main recording surface; starts/stops tracking, renders current route, updates distance labels, handles migration/version defaults and notification alerts. | `CLLocationManager`, `MKMapView`, `DateManager`, `LocationUpdate`, `UserDefaults.standard`, app group `UserDefaults(suiteName: "group.footage")`, `UNUserNotificationCenter`, `UIApplication.openSettingsURLString`, `EFCountingLabel`. Imports `StoreKit` but no direct StoreKit use was found in the inspected file. |
| `PasswordVC` | Full-screen unlock passcode/biometric gate. | `UserDefaults` keys `Password` and `UserState`, `LAContext` / `LocalAuthentication`. |
| `FL_VideoVC` | Intro video. | `AVPlayer`, `AVPlayerLayer`, `NotificationCenter` player-end observer, bundled `Intro.mp4`. |
| `FL_ProfileSettingsVC` | First-run name/profile setup. | `PHPhotoLibrary`, `UserDefaults` keys `userName` and `profileImage`, `UIApplication.openSettingsURLString`, `ProfileSelectionVC`. |
| `FL_NameColorVC` | First-run color/category naming. | App group defaults `group.footage`, color keys `#EADE4Cff`, `#F5A997ff`, `#F0E7CFff`, `#FF6B39ff`, `#206491ff`. |
| `FL_LetsStartVC` | Completes onboarding and opens main tab shell. | `UserDefaults.standard` key `UserState`, `LegacyRootViewControllerFactory`, legacy `Main/TabBarController` destination. |
| `ProfileSelectionVC` | Reusable photo-library grid. | `Photos`, `PHAsset`, `PHCachingImageManager`, `ProfileEditVC`. Imports `MapKit` but no route/location dependency was found. |
| `ProfileEditVC` | Reusable profile crop/editor. | `Photos` / `PHAsset`, `UserDefaults.standard` key `profileImage`, parent view controller coupling to first-run, settings, or date profile flows. |

### Map

| ViewController | Role | Direct dependencies |
| --- | --- | --- |
| `MapViewController` | Global map of footsteps/assets, clustering, current-location recenter, overlay toggle, bottom sheet coordination. | `MKMapView`, `CLLocationManager`, `RealmRouteRepository`, `UIApplication.openSettingsURLString`, static `M` bridge. |
| `MapBottomVC` | Draggable bottom panel and selected-footstep summary; jumps to journey detail. | Static `M.mapVC`, `DateManager.loadFromRealm(rangeOf: "day")`, tab index `3`, `DateViewController.performSegue`, `UserDefaults.standard` for color labels. |
| `MapTableVC` | Nearby footstep table. | `MapKit` distance calculation, `Footstep`, parent `M.mapVC`. |
| `MapCollectionVC` | Photo/note cards for selected map footstep. | `Footstep`, `Asset`, collection layout/cells. |

### Date And Journey

| ViewController | Role | Direct dependencies |
| --- | --- | --- |
| `DateViewController` | Journey list by day/month/year; profile entry point. | `RealmRouteRepository`, static `DateViewController.journeys`, `UserDefaults` keys `profileImage` and `userName`, `EFCountingLabel`, `MapCell.xib`, storyboard segues to `ProfileSelectionVC` and `JourneyViewController`. |
| `JourneyViewController` | Journey detail map, slider, screenshots/previews, add/remove photo groups. | `MKMapView`, `RealmSwift` direct writes for preview updates, `JourneyManager`, `DateViewController.journeys`, `DrawOnMap`, `PhotoSelectionVC`. |
| `PhotoCollectionVC` | Horizontal photo/note carousel for a journey. | `Photos`, `RealmSwift` import, `JourneyManager`, `CardCell`, `GroupCell`. |
| `PhotoSelectionVC` | Selects images from photo library for a footstep. | `Photos`, `PHAsset.fetchAssets`, `PHCachingImageManager`, `JourneyManager.saveNewPhotos`. |

### Stats

| ViewController | Role | Direct dependencies |
| --- | --- | --- |
| `StatsViewController` | Dashboard totals, monthly distance, top color/place, current badge. | `RealmDaySummaryRepository`, `RealmColorRepository`, `RealmPlaceRepository`, `UserDefaults.standard` key `todayBadge`, `EFCountingLabel`, storyboards to `LevelVC`, `ColorVC`, `PlaceVC`. |
| `LevelVC` | Badge collection and today badge selector. | `RealmBadgeRepository`, `UserDefaults.standard` key `todayBadge`, mutates parent `StatsViewController.currentBadge`. |
| `ColorVC` | Color ranking list. | `ColorRepository`, segues to `ColoredJourneyVC`, image/color mapping assets. |
| `ColoredJourneyVC` | Map of footsteps filtered by selected color. | `MapKit`, `RealmColorRepository`, `DrawOnMap`, `List<Footstep>` from repository. |
| `PlaceVC` | Top place ranking cards. | `PlaceRepository`, city image assets, `PlaceAnimation`, segue to `Place_DetailVC`. |
| `Place_DetailVC` | Place ranking table. | Ranking array passed from `PlaceVC`. |
| `ReportVC` | Month selector and report data preparation. | `RealmColorRepository`, `RealmPlaceRepository`, `DateConverter`, segue to `ReportDetailVC`. |
| `ReportDetailVC` | Monthly report detail. | `RealmBadgeRepository`, passed color/place ranking data, city/badge assets. |

### Settings

| ViewController | Role | Direct dependencies |
| --- | --- | --- |
| `SettingsViewController` | Settings menu hub. | Storyboard-only menu actions to settings subflows. |
| `Settings_GeneralVC` | General settings table, lock/biometric toggles, cloud backup opt-in status. | `UserDefaults.standard` key `UserState`, `CloudBackupSettingsStore`, `AppCompositionRoot().makeManualCloudBackupRunner()`, `UserNotificationSchedulingService`, table cell switch side effects. |
| `Settings_General_ProfileVC` | Settings profile name/photo editor entry. | `PHPhotoLibrary`, `UserDefaults` keys `userName` and `profileImage`, `UIApplication.openSettingsURLString`, `ProfileSelectionVC`. |
| `Settings_General_PasswordVC` | Passcode setup/change. | `UserDefaults` keys `Password` and `UserState`, parent `Settings_GeneralVC` table reload coupling. |
| `Settings_General_PushVC` | Notification enablement and time picker. | `UserDefaults` keys `everydayPush`, `etcPush`, `everydayPushHour`, `everydayPushMinute`, legacy `wantPush`; `UNUserNotificationCenter.current().removeAllPendingNotificationRequests()`. |
| `Settings_NameColorVC` | Edit category names. | App group defaults `group.footage`, color keys, confirmation alert before save. |
| `Settings_DonateVC` | Donation purchases. | StoreKit 2 `Product.products(for:)`, `product.purchase()`, `Transaction.finish()`, product IDs `co.nyeok.iap.bike`, `co.nyeok.iap.coffee`, `co.nyeok.iap.rice`. |
| `Settings_AboutVC` | Version/privacy/contact menu. | `UserDefaults.standard` key `version`, `MessageUI` / `MFMailComposeViewController`. |
| `Settings_About_PersonalInformationVC` | Static personal information/privacy screen. | UIKit/storyboard content. |

## Direct Persistence And Platform Dependencies

### Realm

Direct Realm access still exists in legacy managers and a few UI-adjacent classes:

- `DateManager`: creates and updates `DayData`, `Month`, `Year`, `Distance`; loads journeys
  by day/month/year; calculates distances.
- `LocationUpdate`: creates `Footstep` and calls `DateManager`, `ColorManager`, and
  `PlaceManager`.
- `ColorManager`: updates/query `Color`.
- `PlaceManager`: reverse geocodes with `CLGeocoder`, updates/query `Place`.
- `LevelManager`: creates/query/delete `Badge`.
- `JourneyViewController`: directly opens `Realm()` for preview persistence.
- `JourneyManager`: imports `RealmSwift` and uses `List<Footstep>` while media writes now
  pass through `MediaRepository`.
- `RealmRepositories`: repository wrappers exist for route, day summary, color, place,
  media, badge, migration export, and app group widget state. Several wrappers still
  delegate to legacy static managers, so they are adapter seams rather than full
  persistence isolation.

Realm model classes under `Footage/Model` are release-critical user data surfaces:
`Asset`, `Badge`, `Color`, `DayData`, `Distance`, `Footstep`, `Journey`, `Month`,
`Place`, `PlaceLocalityNumber`, `WidgetRealm`, `Year`.

### UserDefaults

Standard defaults keys directly read or written by UI/app lifecycle:

- First-run and versioning: `UserState`, `startedBefore`, `version`, `isUpdated`.
- Recording behavior: `alwaysOn`, `alwaysOnCount`, `launchingCount`.
- Notifications: `everydayPush`, `etcPush`, `everydayPushHour`, `everydayPushMinute`,
  legacy `wantPush`.
- Profile: `userName`, `profileImage`.
- Locking: `Password`, `UserState`.
- Badges: `todayBadge`, `minimumTotalDistance`, `minimumTotalRecord`.
- Legacy color labels may also be read from standard defaults during version migration.
- Cloud backup opt-in: `Footage.CloudBackup.isOptedIn` through `CloudBackupSettingsStore`.
- Auth/linking and sync repositories also use standard defaults for local identity and
  outbox state. Those are not ViewController-owned but are platform state surfaces.

### App Group Defaults And Widget

App group `group.footage` is used by app, widget, and recording state code. Preserve it
until an app-and-widget migration plan exists.

Known app group keys:

- `isTracking`
- `distanceToday`
- `distanceTotal`
- `selectedColor`
- Color label keys:
  - `#EADE4Cff`
  - `#F5A997ff`
  - `#F0E7CFff`
  - `#FF6B39ff`
  - `#206491ff`

Writers/readers include `SceneDelegate`, `HomeViewController`, `HomeAnimation`,
`FL_NameColorVC`, `Settings_NameColorVC`, `RecordingStateStore`,
`AppGroupWidgetStateStore`, `MainWidget/MainWidget.swift`, and `MainWidget/SmallView.swift`.

### Location And MapKit

- Primary recording flow: `HomeViewController` -> `CLLocationManagerDelegate` ->
  `LocationUpdate` -> `DateManager` / color/place managers.
- Background and widget-driven start/stop behavior is in `SceneDelegate`.
- Global map flow: `MapViewController` owns its own `CLLocationManager`, map annotations,
  and route overlays.
- Journey route detail: `JourneyViewController` and `DrawOnMap`.
- Place stats: `PlaceManager` uses `CLGeocoder().reverseGeocodeLocation`.

Privacy note: do not add logging for raw latitude/longitude, photos, notes, object identifiers,
internal storage keys, tokens, or presigned URLs while extracting these dependencies.

### Notifications

- `HomeViewController` directly creates local notifications for recording stopped by speed
  or no-speed cases when `etcPush` is enabled.
- `Settings_GeneralVC` still exposes static scheduling helpers that use
  `UserNotificationSchedulingService`.
- `Settings_General_PushVC` toggles notification state and removes all pending requests.
- `BadgeGiver` sends a badge notification when `etcPush` is enabled.
- `NotificationScheduling.swift` is the newer service boundary to prefer.

### StoreKit

- `Settings_DonateVC` is StoreKit 2 based and owns donation purchase UI state.
- Product IDs are hard-coded:
  - `co.nyeok.iap.bike`
  - `co.nyeok.iap.coffee`
  - `co.nyeok.iap.rice`
- Keep purchase UI local and avoid analytics or external logging.

### Biometric And Locking

- `PasswordVC` uses `LAContext` to authenticate when `UserState == "hasBioId"`.
- `Settings_GeneralVC` toggles between `noPassword`, `hasPassword`, and `hasBioId`.
- `Settings_General_PasswordVC` writes `Password` and `UserState`.
- `SceneDelegate` presents `PasswordVC` on foreground when lock state requires it.

### Photos, Media, And Notes

- Profile image flows store PNG data in `UserDefaults.standard` key `profileImage`.
- Journey photos and notes are stored inside Realm `Footstep.photos` and
  `Footstep.notes`.
- Photo selection/editing depends on `Photos`, `PHAsset`, `PHCachingImageManager`, and
  `PHImageRequestOptions`.
- Do not migrate these without an explicit Realm/photo rollback plan.

### Cloud Backup And Sync

- `Settings_GeneralVC` reads/writes opt-in with `CloudBackupSettingsStore` and displays
  local backup status through `ManualCloudBackupRunning`.
- Existing repository/sync surfaces include `LocalSyncOutboxRepository`,
  `LocalDeviceIdentityRepository`, `AuthLinkingService`, `CloudBackupTokenStore`,
  `CloudBackupService`, and `AppCompositionRoot`.
- UI modernization should preserve local-first behavior: route points must be written
  locally before cloud or network work.

## Extraction Candidates

### Highest Value Boundaries

1. `RecordingCoordinator` or `RecordingViewModel`
   - Move start/stop state, location delegate events, speed/no-speed validation, total/today
     distance updates, app group widget state, and local notification decisions out of
     `HomeViewController`.
   - Keep `HomeViewController` responsible for buttons, labels, map rendering, and alerts.
   - Preserve local-first write ordering: `LocationUpdate` or its replacement must write
     local Realm data before any cloud/outbox work.

2. `RecordingPersistenceService`
   - Replace `LocationUpdate` plus static `DateManager` / `ColorManager` / `PlaceManager`
     calls with an injected service backed by `RouteRepository`, `ColorRepository`, and
     `PlaceRepository`.
   - Keep legacy static managers behind repository adapters until migration tests exist.

3. `DefaultsStore`
   - Centralize `UserDefaults.standard` keys for profile, lock, notification, badge, version,
     and recording behavior.
   - Centralize app group widget defaults separately as `WidgetStateStore`.
   - Avoid changing key names without a migration and rollback note.

4. `NotificationSettingsService`
   - Route `HomeViewController`, `Settings_GeneralVC`, `Settings_General_PushVC`, and
     `BadgeGiver` through `UserNotificationSchedulingService`.
   - Keep request authorization, schedule, cancel, and badge clearing as explicit methods.

5. `JourneyDetailViewModel`
   - Move `JourneyManager` state, photo/note mutation, footstep section mapping, selected pin,
     and slider coordination into a testable model/coordinator.
   - Keep `JourneyViewController`, `PhotoCollectionVC`, and `PhotoSelectionVC` as renderers
     and event forwarders.

6. `StatsViewModel` family
   - `StatsViewController`, `ColorVC`, `PlaceVC`, `ReportVC`, `ReportDetailVC`, and `LevelVC`
     can mostly be fed by repository-backed summaries.
   - Existing `ColorRepository`, `PlaceRepository`, `DaySummaryRepository`, and
     `BadgeRepository` are good adapter entry points.

7. `ProfileService`
   - Unify `FL_ProfileSettingsVC`, `Settings_General_ProfileVC`, `ProfileSelectionVC`, and
     `ProfileEditVC` around photo authorization, selection, crop, and `userName` /
     `profileImage` persistence.

8. `PurchaseService`
   - Move StoreKit product loading/purchase calls out of `Settings_DonateVC`.
   - Keep UI messages and in-progress state in the controller or view model.

### Local Anti-Coupling Targets

- Replace static global `M` with an injected map coordinator or child-controller owner.
- Replace static `HomeViewController.locationManager`, `HomeViewController.distanceTotal`,
  and `DateViewController.journeys` with owned state in coordinators/view models.
- Avoid ViewController-to-parent mutation such as `LevelVC.statsVC.currentBadge` and
  `ProfileEditVC` branching on parent controller types.
- Move storyboard segue preparation data into typed route builders once screens have view
  models.

## Do-Not-Delete Surfaces

Preserve these unless a PR explicitly includes a migration, rollback plan, and widget impact
review:

- Storyboards and XIBs:
  - `Footage/Storyboard/Base.lproj/Main.storyboard`
  - `Footage/Storyboard/Home.storyboard`
  - `Footage/Storyboard/Date.storyboard`
  - `Footage/Storyboard/Stats.storyboard`
  - `Footage/Storyboard/Settings.storyboard`
  - `Footage/Storyboard/FirstLaunch.storyboard`
  - `Footage/Storyboard/Base.lproj/LaunchScreen.storyboard`
  - `Footage/Scene/Stats/PopUpCard.xib`
  - `Footage/Scene/Date/MapCell.xib`
- Widget target files and app group behavior:
  - `MainWidget/MainWidget.swift`
  - `MainWidget/SmallView.swift`
  - `MainWidget/Info.plist`
  - `MainWidget/Assets.xcassets`
  - app group `group.footage`
- Bundle identifiers and signing/entitlement files:
  - app bundle identifier `co.nyeok.footage`
  - widget bundle identifier `co.nyeok.footage.MainWidget`
  - `Entitlements/*.entitlements`
  - project signing settings in `footage.xcodeproj`
- CocoaPods and dependencies:
  - `Podfile`
  - `Podfile.lock`
  - `Pods`
  - `RealmSwift`
  - `EFCountingLabel`
  - MapKit, WidgetKit, StoreKit, LocalAuthentication, Photos integrations.
- Realm user data models:
  - `Footage/Model/Asset.swift`
  - `Footage/Model/Badge.swift`
  - `Footage/Model/Color.swift`
  - `Footage/Model/DayData.swift`
  - `Footage/Model/Distance.swift`
  - `Footage/Model/Footstep.swift`
  - `Footage/Model/Journey.swift`
  - `Footage/Model/Month.swift`
  - `Footage/Model/Place.swift`
  - `Footage/Model/PlaceLocalityNumber.swift`
  - `Footage/Model/WidgetRealm.swift`
  - `Footage/Model/Year.swift`
- User data defaults:
  - profile image/name, passcode state, notification settings, selected category/color names,
    badge thresholds, cloud backup opt-in, local identity, sync outbox, widget tracking state.
- Assets:
  - route/category buttons, badge images, report/city images, month icons, profile images,
    widget button/color images, intro video, fonts.

## Recommended Thin-Shell Order

1. Baseline and key inventory
   - Add tests around existing repository adapters and defaults stores before changing UI
     behavior.
   - Capture a successful Xcode project/workspace list/build baseline when the workspace issue
     is resolved.

2. Defaults and widget state
   - Introduce typed stores for standard defaults and app group defaults.
   - Update `SceneDelegate`, Home/Settings first, using identical keys and values.
   - This is low UI risk and removes a large amount of stringly state.

3. Notifications
   - Move direct notification scheduling/removal from controllers and `BadgeGiver` into
     `UserNotificationSchedulingService` or a small facade.
   - Keep user-facing alert copy and switches unchanged.

4. Home recording shell
   - Extract recording state, speed validation, movement checks, and local persistence calls
     from `HomeViewController`.
   - Keep map drawing and UIKit animation in the controller until persistence behavior has
     tests.
   - Verify local Realm write precedes widget/cloud/outbox updates.

5. Map tab
   - Replace the static `M` bridge with an owned coordinator.
   - Inject route data and selected-footstep state into `MapBottomVC`, `MapTableVC`, and
     `MapCollectionVC`.

6. Date list
   - Move `DateViewController.journeys` into an instance view model.
   - Keep `MapCell.xib` and storyboard navigation stable.

7. Journey detail and media
   - Extract `JourneyManager` into a non-UIKit media/journey coordinator where possible.
   - Move Realm preview write from `JourneyViewController` into a repository method.
   - Keep photo and note storage in Realm until a migration plan exists.

8. Stats screens
   - Convert `StatsViewController`, `LevelVC`, `ColorVC`, `PlaceVC`, `ReportVC`, and
     `ReportDetailVC` to repository-fed view models.
   - Use existing repository protocols first, then retire static manager calls behind the
     adapters.

9. Profile and lock flows
   - Unify first-run and settings profile editing behind `ProfileService`.
   - Extract lock state/passcode/biometric operations into `LockSettingsService`, preserving
     `UserState` and `Password` migrations.

10. Settings donation and cloud backup UI
    - Move StoreKit calls to `PurchaseService`.
    - Keep `CloudBackupSettingsStore` and backup status display isolated from unrelated
      settings table logic.

11. Incremental SwiftUI or new UI shells
    - Only after the above seams exist, wrap individual screens or cells.
    - Keep UIKit/storyboard screens stable until each replacement has parity notes and
      rollback instructions.

## Review Notes

- Repository protocols are present and useful, but several implementations are still wrappers
  around static Realm managers. Treat them as the first seam, not as full decoupling.
- The highest-risk screen is `HomeViewController` because it mixes location tracking, local
  persistence, widget state, defaults migration, notifications, and map rendering.
- The second highest-risk area is journey media because photos/notes are user data stored
  directly inside Realm `Footstep` objects.
- App group defaults and widget timeline reloads are release-critical. Any recording-state
  extraction must include widget verification.
