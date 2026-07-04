# Technical Audit

Audit date: 2026-07-04.

This audit is based on static repository inspection and one attempted workspace listing command. No app code, project settings, signing settings, Pods, assets, Storyboards, or models were modified.

## Validation Commands

Succeeded:

```sh
git status --short
rg --files -g '!*Pods*' -g '!*.xcuserdata*'
find . -maxdepth 3 \( -name '*.xcodeproj' -o -name '*.xcworkspace' -o -name 'Podfile' -o -name '*.entitlements' -o -name 'Info.plist' \) -print
rg -n "Realm|UserDefaults\\(suiteName|CLLocation|MKMap|MKPolyline|EFCountingLabel|Widget" Footage MainWidget Entitlements footage.xcodeproj/project.pbxproj Podfile
plutil -p Footage/Resource/Info.plist
plutil -p MainWidget/Info.plist
plutil -p Entitlements/footage.entitlements
plutil -p Entitlements/MainWidgetExtension.entitlements
```

Attempted but did not run:

```sh
xcodebuild -list -workspace footage.xcworkspace
```

Result:

```text
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance
```

Build success is not established.

## Phase 1 Build Recovery Baseline

Baseline date: 2026-07-04.

Commands run:

```sh
git status --short
```

Result:

```text
?? AGENTS.md
?? docs/
?? server/
```

Interpretation: the renewal documentation is currently untracked. No app source, project settings, signing settings, entitlements, Pods, assets, Storyboards, Realm models, or widget files were modified during this baseline pass.

```sh
xcode-select -p
```

Result:

```text
/Library/Developer/CommandLineTools
```

Interpretation: the active developer directory is Command Line Tools, not full Xcode.

```sh
rg --files
```

Result: repository file enumeration succeeded. The output is large; key build and release-critical surfaces are present, including `footage.xcworkspace`, `footage.xcodeproj`, `Podfile`, `Podfile.lock`, `Footage/`, `MainWidget/`, and `Entitlements/`.

```sh
find . -name '*.xcworkspace' -o -name '*.xcodeproj' -o -name '*.entitlements'
```

Result:

```text
./footage.xcworkspace
./footage.xcodeproj
./footage.xcodeproj/project.xcworkspace
./Entitlements/MainWidgetExtension.entitlements
./Entitlements/footageRelease.entitlements
./Entitlements/MainWidgetExtensionRelease.entitlements
./Entitlements/footage.entitlements
```

```sh
xcodebuild -list -workspace footage.xcworkspace
```

Result:

```text
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance
```

Interpretation: workspace listing did not run, so available schemes could not be inspected through `xcodebuild`. No simulator build was attempted because the workspace list failed.

```sh
ls /Applications
```

Result: command succeeded; `Xcode.app` was not listed in `/Applications`.

Likely cause:

- Full Xcode is not installed in `/Applications` or is not selected as the active developer directory.
- The current environment only exposes Command Line Tools, which cannot perform iOS workspace listing or simulator builds.

Smallest proposed fixes:

1. Install full Xcode, or locate the existing Xcode installation if it lives outside `/Applications`.
2. Select full Xcode with `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` or the actual Xcode developer directory.
3. Accept the Xcode license and install first-launch components if prompted.
4. Re-run `xcodebuild -list -workspace footage.xcworkspace`.
5. If the list succeeds, use the listed app scheme for the first simulator build without changing signing, bundle identifiers, entitlements, Pods, Realm, Storyboards, assets, or widget target.

### Post-Xcode-Install Follow-up

Follow-up date: 2026-07-04.

Commands run:

```sh
git status --short
```

Result:

```text
 M footage.xcworkspace/xcuserdata/nyeok.xcuserdatad/UserInterfaceState.xcuserstate
?? AGENTS.md
?? docs/
?? server/
```

Interpretation: Xcode/user workspace state is modified outside the app source. The renewal documentation remains untracked.

```sh
xcode-select -p
```

Result:

```text
/Library/Developer/CommandLineTools
```

Interpretation: full Xcode is installed, but the active developer directory still points to Command Line Tools.

```sh
ls /Applications
```

Result: command succeeded and `Xcode.app` is present.

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Result:

```text
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
```

```sh
xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Result:

```text
xcode-select: error: --switch must be run as root (e.g. `sudo xcode-select --switch <xcode_folder_path>`).
```

Interpretation: the system developer directory switch must be performed locally with an interactive sudo password.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -list -workspace footage.xcworkspace
```

Result:

```text
xcodebuild: error: 'footage.xcworkspace' is not a workspace file.
```

Relevant preceding diagnostics included sandbox/user-environment warnings about CoreSimulator and log paths, but the actionable workspace-list error was the workspace file failure.

Workspace inspection:

```sh
ls -la footage.xcworkspace
file footage.xcworkspace footage.xcworkspace/contents.xcworkspacedata footage.xcodeproj/project.xcworkspace/contents.xcworkspacedata
sed -n '1,120p' footage.xcworkspace/contents.xcworkspacedata
ruby -e 'require "rexml/document"; REXML::Document.new(File.read("footage.xcworkspace/contents.xcworkspacedata")); puts "xml ok"'
ls -la Pods
find Pods -maxdepth 2 -name 'Pods.xcodeproj' -o -name 'Manifest.lock'
```

Results:

- `footage.xcworkspace` exists and contains `contents.xcworkspacedata`.
- `contents.xcworkspacedata` is valid XML and references `group:footage.xcodeproj` and `group:Pods/Pods.xcodeproj`.
- `Pods/` does not exist.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -list -project footage.xcodeproj
```

Result: project listing succeeded. Available schemes:

```text
footage
MainWidgetExtension
WidgetColorSelection
```

Relevant environment diagnostics:

```text
CoreSimulatorService connection became invalid. Simulator services will no longer be available.
Unable to discover any Simulator runtimes. Developer Directory is /Applications/Xcode.app/Contents/Developer.
Unable to create log store directory at '/Users/nyeok/Library/Developer/Xcode/DerivedData/...': (513) You don’t have permission...
```

Interpretation: project scheme discovery works through Xcode when `DEVELOPER_DIR` is set, but the sandboxed command cannot use normal simulator/log locations. Future local commands should run in Terminal after selecting full Xcode, or continue using `DEVELOPER_DIR` with a repo-local `-derivedDataPath`.

```sh
pod --version
```

Result:

```text
zsh:1: command not found: pod
```

```sh
ruby --version
gem list cocoapods
```

Results:

```text
ruby 2.6.10p210 (2022-04-12 revision 67958) [universal.arm64e-darwin25]
```

`gem list cocoapods` produced no installed CocoaPods gem output.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project footage.xcodeproj -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
```

Result: build failed.

Exact build errors:

```text
/Users/nyeok/Documents/footage-ios/footage.xcodeproj: error: Unable to open base configuration reference file '/Users/nyeok/Documents/footage-ios/Pods/Target Support Files/Pods-MainWidgetExtension/Pods-MainWidgetExtension.debug.xcconfig'. (in target 'MainWidgetExtension' from project 'footage')
/Users/nyeok/Documents/footage-ios/footage.xcodeproj: error: Unable to open base configuration reference file '/Users/nyeok/Documents/footage-ios/Pods/Target Support Files/Pods-footage/Pods-footage.debug.xcconfig'. (in target 'footage' from project 'footage')
warning: Unable to read contents of XCFileList '/Target Support Files/Pods-footage/Pods-footage-frameworks-Debug-output-files.xcfilelist' (in target 'footage' from project 'footage')
error: Unable to load contents of file list: '/Target Support Files/Pods-footage/Pods-footage-frameworks-Debug-input-files.xcfilelist' (in target 'footage' from project 'footage')
error: Unable to load contents of file list: '/Target Support Files/Pods-footage/Pods-footage-frameworks-Debug-output-files.xcfilelist' (in target 'footage' from project 'footage')
** BUILD FAILED **
```

Likely cause:

- CocoaPods integration is expected by both the app and widget targets, but `Pods/` is missing.
- CocoaPods is not installed on PATH, so `pod install` cannot currently restore `Pods/Pods.xcodeproj` and the generated target support files.
- `xcode-select` still points to Command Line Tools, so local builds should either switch to full Xcode with sudo or set `DEVELOPER_DIR` explicitly.

Smallest proposed fixes:

1. Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` locally in Terminal.
2. Install CocoaPods in a controlled way compatible with this legacy lockfile, preferably starting with the locked generator version: `gem install cocoapods -v 1.10.0` or a repo-local Bundler setup that pins `cocoapods` to `1.10.0`.
3. Run `pod install` to restore `Pods/Pods.xcodeproj` and target support files without changing `Podfile`, `Podfile.lock`, app source, widget source, signing, bundle identifiers, or entitlements.
4. Re-run `xcodebuild -list -workspace footage.xcworkspace`.
5. If workspace listing succeeds, run the simulator build from the workspace using scheme `footage`.

### CocoaPods Restore Follow-up

Follow-up date: 2026-07-04.

Commands run:

```sh
which ruby
ruby --version
gem env home
ruby -rrubygems -e 'puts Gem.user_dir'
which brew
```

Results:

```text
/usr/bin/ruby
ruby 2.6.10p210 (2022-04-12 revision 67958) [universal.arm64e-darwin25]
/Library/Ruby/Gems/2.6.0
/Users/nyeok/.gem/ruby/2.6.0
brew not found
```

Interpretation: system Ruby cannot install gems into `/Library/Ruby/Gems/2.6.0` without sudo. Homebrew is not available. The least invasive CocoaPods path is a user-local gem install under `/Users/nyeok/.gem/ruby/2.6.0`.

```sh
gem install --user-install cocoapods -v 1.10.0
```

First result:

```text
ERROR:  Error installing cocoapods:
	The last version of public_suffix (>= 2.0.2, < 8.0) to support your Ruby & RubyGems was 5.1.1. Try installing it with `gem install public_suffix -v 5.1.1` and then running the current command again
	public_suffix requires Ruby version >= 3.2. The current ruby version is 2.6.10.210.
```

Follow-up dependency pins for Ruby 2.6:

```sh
gem install --user-install public_suffix -v 5.1.1
gem install --user-install ffi -v 1.17.4 --platform=ruby
gem install --user-install i18n -v 1.14.8
gem install --user-install cocoapods -v 1.10.0
```

Results:

- `public_suffix 5.1.1` installed.
- `ffi 1.17.4` installed after native extension compilation.
- `i18n 1.14.8` installed.
- `cocoapods 1.10.0` installed.
- RubyGems warned that `/Users/nyeok/.gem/ruby/2.6.0/bin` is not in `PATH`.

Verification:

```sh
/Users/nyeok/.gem/ruby/2.6.0/bin/pod --version
gem list cocoapods
gem list public_suffix ffi i18n
```

Results:

```text
1.10.0
cocoapods (1.10.0)
cocoapods-core (1.10.0)
public_suffix (5.1.1)
ffi (1.17.4)
i18n (1.14.8)
```

```sh
/Users/nyeok/.gem/ruby/2.6.0/bin/pod install
```

First result:

```text
Analyzing dependencies
Cloning spec repo `trunk` from `https://cdn.cocoapods.org/`
[!] Unable to add a source with url `https://cdn.cocoapods.org/` named `trunk`.
```

The command was re-run with network and user-home access. Result:

```text
Installing EFCountingLabel (5.1.2)
Installing Realm (10.1.2)
Installing RealmSwift (10.1.2)
Generating Pods project
Integrating client project
Pod installation complete! There are 2 dependencies from the Podfile and 3 total pods installed.
```

Warnings:

```text
[!] The `footage [Debug]` target overrides the `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` build setting defined in `Pods/Target Support Files/Pods-footage/Pods-footage.debug.xcconfig'. This can lead to problems with the CocoaPods installation
[!] The `footage [Release]` target overrides the `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` build setting defined in `Pods/Target Support Files/Pods-footage/Pods-footage.release.xcconfig'. This can lead to problems with the CocoaPods installation
```

Interpretation: Pods were restored without changing `Podfile`, `Podfile.lock`, app source, widget source, signing, bundle identifiers, or entitlements. `Pods/` is ignored by git.

```sh
find Pods -maxdepth 2 -name 'Pods.xcodeproj' -o -name 'Manifest.lock'
```

Result:

```text
Pods/Pods.xcodeproj
Pods/Manifest.lock
```

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -showsdks
```

Results:

```text
Xcode 26.6
Build version 17F113
iOS SDKs:
	iOS 26.5                      	-sdk iphoneos26.5
iOS Simulator SDKs:
	Simulator - iOS 26.5          	-sdk iphonesimulator26.5
```

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -list -workspace footage.xcworkspace
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -list -workspace /Users/nyeok/Documents/footage-ios/footage.xcworkspace
```

Result:

```text
xcodebuild: error: 'footage.xcworkspace' is not a workspace file.
xcodebuild: error: '/Users/nyeok/Documents/footage-ios/footage.xcworkspace' is not a workspace file.
```

Workspace package inspection:

```sh
ls -la footage.xcworkspace Pods/Pods.xcodeproj
xattr -l footage.xcworkspace footage.xcworkspace/contents.xcworkspacedata
sed -n '1,80p' footage.xcworkspace/contents.xcworkspacedata
```

Results:

- `footage.xcworkspace` exists with `contents.xcworkspacedata`, `xcshareddata`, and `xcuserdata`.
- `Pods/Pods.xcodeproj` exists.
- `contents.xcworkspacedata` references `group:footage.xcodeproj` and `group:Pods/Pods.xcodeproj`.
- Extended attributes include `com.apple.provenance` on the workspace and workspace data file, and `com.apple.lastuseddate#PS` on the workspace directory.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl list runtimes
```

Result:

```text
CoreSimulatorService connection became invalid. Simulator services will no longer be available.
Unable to locate device set: Error Domain=NSPOSIXErrorDomain Code=61 "Connection refused" ...
```

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project footage.xcodeproj -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
```

Result: build failed.

Primary errors:

```text
/Users/nyeok/Documents/footage-ios/MainWidget/Assets.xcassets: error: No available simulator runtimes for platform iphonesimulator. SimServiceContext supportedRuntimes=[]
/Users/nyeok/Documents/footage-ios/Footage/Model/WidgetRealm.swift:10:8: error: Unable to resolve module dependency: 'RealmSwift'
import RealmSwift
       ^ (in target 'MainWidgetExtension' from project 'footage')
```

Interpretation:

- The simulator runtime error is environment/sandbox related: `simctl` cannot talk to CoreSimulatorService even though Xcode reports the iOS Simulator 26.5 SDK.
- The `RealmSwift` error is expected for a project-only build because the Pods project is not part of `footage.xcodeproj`. A valid workspace build is still required before treating this as an app source failure.
- Workspace listing remains the next blocker. Because the workspace file contents look structurally valid, test the same command from a normal Terminal after switching Xcode globally before editing the workspace package.

Smallest proposed fixes:

1. In a normal Terminal session, run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`.
2. Add user-local CocoaPods to the shell path for convenience: `export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"` or call `/Users/nyeok/.gem/ruby/2.6.0/bin/pod` directly.
3. Re-run `/Users/nyeok/.gem/ruby/2.6.0/bin/pod install` only if `Pods/` is missing or stale.
4. Re-run `xcodebuild -list -workspace footage.xcworkspace` from normal Terminal. If it still says the workspace is not a workspace file, inspect whether Xcode 26.6 dislikes the existing workspace metadata or extended attributes before regenerating the workspace.
5. Do not treat the project-only `RealmSwift` failure as a source-code error until a workspace build has been attempted successfully.

### Workspace Build Recovery Follow-up

Follow-up date: 2026-07-04.

After full Xcode was selected outside the sandbox, workspace listing succeeded.

```sh
xcode-select -p
xcodebuild -list -workspace footage.xcworkspace
```

Results:

```text
/Applications/Xcode.app/Contents/Developer

Information about workspace "footage":
    Schemes:
        EFCountingLabel
        footage
        MainWidgetExtension
        Pods-footage
        Pods-MainWidgetExtension
        Realm
        RealmSwift
        WidgetColorSelection
```

First real workspace build attempt:

```sh
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
```

Result: build failed.

Primary error:

```text
/Users/nyeok/Documents/footage-ios/Footage/Model/WidgetRealm.swift:10:8: error: Unable to resolve module dependency: 'RealmSwift'
import RealmSwift
       ^ (in target 'MainWidgetExtension' from project 'footage')
```

Focused dependency checks:

```sh
xcodebuild -workspace footage.xcworkspace -scheme RealmSwift -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
```

Result: build failed.

Exact error:

```text
/Users/nyeok/Documents/footage-ios/Pods/RealmSwift/RealmSwift/Combine.swift:38:40: error: 'Identifiable' is only available in iOS 13.0 or newer
public protocol ObjectKeyIdentifiable: Identifiable, ObjectBase {
                                       ^
```

Likely cause:

- `Podfile` declares platform iOS 13.0, but generated Pods targets still built RealmSwift with iOS 9.0.
- RealmSwift 10.1.2 uses Combine/Identifiable APIs requiring iOS 13.0 availability.

Smallest build-only fix applied:

```ruby
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
```

This was added inside the existing `post_install` loop in `Podfile`, affecting generated Pods project build settings only.

Regeneration:

```sh
/Users/nyeok/.gem/ruby/2.6.0/bin/pod install
```

Result: succeeded, with existing warnings that the app target overrides `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES`.

Verification:

```sh
xcodebuild -workspace footage.xcworkspace -scheme RealmSwift -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
xcodebuild -workspace footage.xcworkspace -scheme Pods-MainWidgetExtension -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
```

Results:

- `RealmSwift` built successfully after the deployment-target fix.
- `Pods-MainWidgetExtension` built successfully after the deployment-target fix.
- Warnings remain from Realm/RealmSwift and EFCountingLabel, including deprecated APIs and Swift 6 future-compatibility warnings.

Second main app workspace build attempt:

```sh
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
```

Result: build failed.

Primary error:

```text
warning: module file '.../RealmSwift.framework/Modules/RealmSwift.swiftmodule/x86_64-apple-ios-simulator.swiftmodule' is incompatible with this Swift compiler: built for incompatible target
.../RealmSwift.framework/Headers/RealmSwift-Swift.h:543:2: error: unsupported Swift architecture
#error unsupported Swift architecture
 ^
```

Likely cause:

- The old Pods post-install hook excluded `arm64` for iPhone simulator builds.
- The app and widget targets compiled for `arm64` simulator under Xcode 26.6, but RealmSwift had only an x86_64 simulator module available.

Smallest build-only fix applied:

- Removed only this generated-Pods setting from `Podfile`:

```ruby
config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
```

- Left the existing watch simulator and Apple TV simulator exclusions unchanged because they are outside the current iOS build failure.

Regeneration and clean:

```sh
/Users/nyeok/.gem/ruby/2.6.0/bin/pod install
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet clean
```

Results: both succeeded.

Final build command:

```sh
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
```

Result: succeeded.

Remaining warnings observed:

- CocoaPods warning: app target overrides `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES`.
- EFCountingLabel warning: `class` protocol constraint is deprecated in favor of `AnyObject`.
- Realm/RealmSwift warnings: deprecated C APIs, duplicate `-lc++`, retroactive conformance warning, and Swift 6 future-compatibility warnings.
- Storyboard warning: `Date.storyboard` has prototype collection view cells without reuse identifiers.
- App source warning: `PasswordVC.swift` switch over `LABiometryType` is not exhaustive and needs `.opticID`.

No app source, signing settings, bundle identifiers, entitlements, Realm models, Storyboards, assets, or widget source files were changed during this build recovery step.

### Warning Cleanup Follow-up

Follow-up date: 2026-07-04.

Smallest build-warning fixes applied:

- Changed the app target Debug and Release `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` build setting from `YES` to `$(inherited)` so CocoaPods can own the setting through `Pods-footage.*.xcconfig`.
- Added the known `LABiometryType.opticID` case to `PasswordVC.swift` to satisfy the Xcode 26.6 exhaustive switch check.
- Added `unused-date-storyboard-cell` to the empty prototype collection view cell in `Date.storyboard`. `DateViewController` registers and dequeues `MapCell.xib` at runtime, so this identifier is only to satisfy Interface Builder's prototype-cell warning.

Commands run:

```sh
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
/Users/nyeok/.gem/ruby/2.6.0/bin/pod install
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
xcodebuild -workspace footage.xcworkspace -scheme MainWidgetExtension -configuration Debug -destination generic/platform=iOS\ Simulator -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
```

Results:

- The first build after edits succeeded.
- `pod install` succeeded and no longer emitted the app target `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` override warning.
- The final `footage` Debug simulator workspace build succeeded.
- The `MainWidgetExtension` Debug simulator workspace build succeeded.

### Repeatable Phase 1 Build Script

Follow-up date: 2026-07-04.

Added:

```text
scripts/phase1-build-baseline.sh
```

The script runs:

1. `/Users/nyeok/.gem/ruby/2.6.0/bin/pod install` by default, overridable with `POD_BIN`.
2. `xcodebuild -list -workspace footage.xcworkspace`.
3. `xcodebuild` Debug simulator build for scheme `footage` with `CODE_SIGNING_ALLOWED=NO`.
4. `xcodebuild` Debug simulator build for scheme `MainWidgetExtension` with `CODE_SIGNING_ALLOWED=NO`.

Commands run:

```sh
chmod +x scripts/phase1-build-baseline.sh
scripts/phase1-build-baseline.sh
```

Result: script succeeded. It restored/integrated Pods, listed the workspace schemes, built the main app scheme, and built the widget extension scheme.

No signing settings, bundle identifiers, entitlements, Realm models, assets, or widget source files were changed during this warning cleanup step.

### Release Simulator Baseline Follow-up

Follow-up date: 2026-07-04.

Commands run:

```sh
xcodebuild -workspace footage.xcworkspace -scheme MainWidgetExtension -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
```

Results:

- The `MainWidgetExtension` Release simulator workspace build succeeded.
- The `footage` Release simulator workspace build succeeded.

Current build baseline:

- Workspace listing succeeds with full Xcode selected.
- Debug simulator workspace builds succeed for `footage` and `MainWidgetExtension`.
- Release simulator workspace builds succeed for `footage` and `MainWidgetExtension`.

Remaining warnings are dependency/toolchain warnings from EFCountingLabel and Realm/RealmSwift. These should be handled through documented dependency modernization, not direct edits to generated Pods.

### Dependency Modernization Baseline

Follow-up date: 2026-07-04.

Commands run:

```sh
sed -n '1,140p' Podfile.lock
sed -n '1,80p' Podfile
rg -n "EFCountingLabel|RealmSwift|import Realm|import RealmSwift" Footage MainWidget Podfile Podfile.lock
/Users/nyeok/.gem/ruby/2.6.0/bin/pod outdated --no-repo-update
ruby --version
/Users/nyeok/.gem/ruby/2.6.0/bin/pod --version
gem list cocoapods
```

Results:

```text
Podfile.lock:
  EFCountingLabel 5.1.2
  Realm 10.1.2
  RealmSwift 10.1.2
  COCOAPODS: 1.10.0
```

```text
pod outdated --no-repo-update:
  EFCountingLabel 5.1.2 -> 6.0.0.1 (latest version 6.0.0.1)
  Realm 10.1.2 -> 20.0.4 (latest version 20.0.4)
  RealmSwift 10.1.2 -> 20.0.4 (latest version 20.0.4)
```

```text
ruby --version:
  ruby 2.6.10p210 (2022-04-12 revision 67958) [universal.arm64e-darwin25]

pod --version:
  1.10.0

gem list cocoapods:
  cocoapods (1.10.0)
  cocoapods-core (1.10.0)
  cocoapods-deintegrate (1.0.5)
  cocoapods-downloader (1.6.3)
  cocoapods-plugins (1.0.0)
  cocoapods-search (1.0.1)
  cocoapods-trunk (1.6.0)
  cocoapods-try (1.2.0)
```

Usage findings:

- `RealmSwift` is imported throughout app models, map/date/stats flows, app delegate, and `WidgetRealm.swift`.
- `EFCountingLabel` is used in Swift files and Storyboards, including `Home.storyboard`, `Date.storyboard`, and `Stats.storyboard`.
- The widget target still depends on RealmSwift through the shared model target membership; do not remove RealmSwift from the widget until target membership and widget behavior are separately reviewed.

External source checks:

- CocoaPods.org lists `RealmSwift 20.0.4` and suggests `pod 'RealmSwift', '~> 20.0'`.
- The Realm Swift GitHub release page lists `v20.0.5` as latest and notes compatibility with CocoaPods 1.10 or later and Xcode 26.1-27.
- The Realm Swift README states that Atlas Device Sync and Realm SDKs were deprecated in September 2024, and that version 20 or the `community` branch is the path for Realm Swift without sync features.
- CocoaPods.org lists `EFCountingLabel 6.0.0.1` and suggests `pod 'EFCountingLabel', '~> 6.0'`.
- RubyGems.org lists `cocoapods 1.16.2` as the latest gem and Ruby `>= 2.6` as the required Ruby version.
- The CocoaPods project states that CocoaPods is in maintenance mode and that trunk is planned to become read-only on December 2, 2026.

Likely causes of remaining dependency warnings:

- `RealmSwift 10.1.2` predates the current Xcode 26.6 toolchain and emits Swift future-compatibility/deprecation warnings.
- `EFCountingLabel 5.1.2` predates the current Swift toolchain and emits the deprecated `class` protocol constraint warning.
- CocoaPods 1.10.0 is old but still meets Realm Swift `v20.0.5` release compatibility notes.

Smallest proposed dependency sequence:

1. Do not change dependency versions in the same patch as build-baseline recovery.
2. First candidate patch: pin `EFCountingLabel` to `~> 6.0`, run `pod install`, then run the Debug and Release simulator baselines for app and widget.
3. Second candidate patch: pin `RealmSwift` to `~> 20.0`, run `pod install`, then run the same baselines.
4. Do not introduce Realm schema migrations in the dependency update patch unless the app fails to open existing Realm files and the migration need is proven.
5. Do not adopt Realm Device Sync; the renewal plan should keep private cloud backup separate from Realm's deprecated sync service.
6. Consider CocoaPods 1.16.2 after pod dependency updates are tested, because changing the package manager and dependency versions together would widen the failure surface.

Rollback plan:

- Revert only `Podfile` and `Podfile.lock` for a failed dependency update.
- Run `/Users/nyeok/.gem/ruby/2.6.0/bin/pod install`.
- Re-run `scripts/phase1-build-baseline.sh` and the documented Release simulator builds.
- Do not delete user Realm files, assets, Storyboards, widget files, signing settings, bundle identifiers, or entitlements during rollback.

### EFCountingLabel 6.0.0.1 Update

Follow-up date: 2026-07-04.

Commands run:

```sh
git status --short
sed -n '1,90p' Podfile
sed -n '1,80p' Podfile.lock
/Users/nyeok/.gem/ruby/2.6.0/bin/pod update EFCountingLabel --no-repo-update
scripts/phase1-build-baseline.sh
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
xcodebuild -workspace footage.xcworkspace -scheme MainWidgetExtension -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
```

Dependency changes:

```text
EFCountingLabel 5.1.2 -> 6.0.0.1
Realm 10.1.2 unchanged
RealmSwift 10.1.2 unchanged
CocoaPods 1.10.0 unchanged
```

Smallest source compatibility fix:

- Added `@MainActor` to `HomeAnimation.homeStartAnimation(_:)`.
- Added `@MainActor` to `HomeAnimation.homeStopAnimation(_:)`.

Reason:

`EFCountingLabel 6.0.0.1` marks counting-label APIs and counter state as `@MainActor`. The app already calls these methods from UI animation paths, so annotating the two static animation helpers matches the existing UI-thread intent without changing app behavior, persistence, signing, bundle identifiers, entitlements, assets, Storyboards, Realm models, or widget source.

First Debug baseline result after the dependency update:

```text
BUILD FAILED

Footage/Scene/Home/HomeAnimation.swift:45:25: error: call to main actor-isolated instance method 'setUpdateBlock' in a synchronous nonisolated context
Footage/Scene/Home/HomeAnimation.swift:48:33: error: main actor-isolated property 'timingFunction' can not be mutated from a nonisolated context
Footage/Scene/Home/HomeAnimation.swift:49:25: error: call to main actor-isolated instance method 'countFrom(_:to:withDuration:)' in a synchronous nonisolated context
Footage/Scene/Home/HomeAnimation.swift:105:25: error: call to main actor-isolated instance method 'setUpdateBlock' in a synchronous nonisolated context
Footage/Scene/Home/HomeAnimation.swift:108:33: error: main actor-isolated property 'timingFunction' can not be mutated from a nonisolated context
Footage/Scene/Home/HomeAnimation.swift:109:25: error: call to main actor-isolated instance method 'countFrom(_:to:withDuration:)' in a synchronous nonisolated context
```

Final verification results after the `@MainActor` fix:

- `scripts/phase1-build-baseline.sh` succeeded. It ran `pod install`, listed workspace schemes, built the `footage` Debug simulator scheme, and built the `MainWidgetExtension` Debug simulator scheme.
- `footage` Release simulator workspace build succeeded with `CODE_SIGNING_ALLOWED=NO`.
- `MainWidgetExtension` Release simulator workspace build succeeded with `CODE_SIGNING_ALLOWED=NO`.

One intermediate widget Release build failed with:

```text
error: unable to attach DB: error: accessing build database ".../XCBuildData/build.db": database is locked Possibly there are two concurrent builds running in the same filesystem location.
```

Likely cause: the app and widget Release builds were launched concurrently with the same `-derivedDataPath`. The widget Release build succeeded when re-run serially.

### RealmSwift 20.0.4 Update

Follow-up date: 2026-07-04.

Commands run:

```sh
/Users/nyeok/.gem/ruby/2.6.0/bin/pod update RealmSwift Realm --no-repo-update
scripts/phase1-build-baseline.sh
xcodebuild -workspace footage.xcworkspace -scheme footage -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
xcodebuild -workspace footage.xcworkspace -scheme MainWidgetExtension -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO -quiet build
sed -n '1,110p' Podfile.lock
git diff -- Podfile Podfile.lock scripts/phase1-build-baseline.sh Footage/Scene/Home/HomeAnimation.swift
git status --short
```

Dependency changes:

```text
Realm 10.1.2 -> 20.0.4
RealmSwift 10.1.2 -> 20.0.4
EFCountingLabel 6.0.0.1 unchanged
CocoaPods 1.10.0 unchanged
```

Results:

- `pod update RealmSwift Realm --no-repo-update` succeeded and installed `Realm 20.0.4` and `RealmSwift 20.0.4`.
- `scripts/phase1-build-baseline.sh` succeeded after the Realm update.
- `footage` Release simulator workspace build succeeded with `CODE_SIGNING_ALLOWED=NO`.
- `MainWidgetExtension` Release simulator workspace build succeeded with `CODE_SIGNING_ALLOWED=NO`.

Observed workspace schemes after the Realm update:

```text
EFCountingLabel
footage
MainWidgetExtension
Pods-footage
Pods-MainWidgetExtension
Realm
Realm-realm_objc_privacy
RealmSwift
RealmSwift-realm_swift_privacy
WidgetColorSelection
```

Remaining warnings:

- Realm C++ warning: `ISO C++ requires field designators to be specified in declaration order`.
- RealmSwift warning: duplicate `Sendable` conformance for `RLMThreadSafeReference<Confined>`.
- Realm linker warning: duplicate `-lc++`.

These warnings come from generated Pods and should not be patched directly in `Pods/`. No Realm models, schema declarations, migrations, user data files, signing settings, bundle identifiers, entitlements, assets, Storyboards, or widget source files were changed for the Realm update.

### Full Phase 1 Baseline Script Update

Follow-up date: 2026-07-04.

Updated `scripts/phase1-build-baseline.sh` to run all baseline builds serially:

1. `pod install`.
2. `xcodebuild -list -workspace footage.xcworkspace`.
3. `footage` Debug simulator build.
4. `MainWidgetExtension` Debug simulator build.
5. `footage` Release simulator build.
6. `MainWidgetExtension` Release simulator build.

Command run:

```sh
scripts/phase1-build-baseline.sh
/Users/nyeok/.gem/ruby/2.6.0/bin/pod outdated --no-repo-update
```

Results:

- `scripts/phase1-build-baseline.sh` succeeded.
- `pod outdated --no-repo-update` reported `No pod updates are available.`

### Development Reset Repository Boundary

Follow-up date: 2026-07-04.

Commands run:

```sh
rg -n "try! Realm|Realm\\(|realm\\.write|realm\\.add|realm\\.delete|objects\\(" Footage MainWidget
rg --files Footage
scripts/phase1-build-baseline.sh
```

Smallest development step applied:

- Added `Footage/Domain/Identifiers.swift`.
- Added `Footage/Domain/RecordingDrafts.swift`.
- Added `Footage/Services/Sync/SyncOutboxDraft.swift`.
- Added `Footage/Data/Repositories/RepositoryProtocols.swift`.
- Added `Footage/Data/Repositories/RealmRepositories.swift`.
- Added `Footage/Data/Repositories/LocalDeviceIdentityRepository.swift`.
- Added `Footage/Data/Repositories/LocalSyncOutboxRepository.swift`.
- Added `Footage/Data/Migration/MigrationExportModels.swift`.
- Added the new files to the main app target only.
- Defined protocols for route, day summary, device identity, migration export, sync outbox, color, place, media, badge, and widget state boundaries.
- Added Realm-backed adapters that wrap existing managers where safe without changing current call sites.
- Added local `installationId` persistence through `UserDefaults`; no server, auth, or network call is involved.
- Added local sync outbox draft persistence through `UserDefaults`; no upload or S3 logic is involved.

Result:

- `scripts/phase1-build-baseline.sh` succeeded after the new repository protocol file was added.
- `scripts/phase1-build-baseline.sh` succeeded after the Realm-backed adapter file was added.

Interpretation:

- Development can proceed from a local app/widget simulator baseline.
- No existing Realm model, Realm schema, Realm migration, widget file, Storyboard, asset, app group, bundle identifier, entitlement, or signing setting was changed.
- Existing direct Realm access remains in place; the new protocols and adapters are additive boundaries for future call-site migration.
- `Photo` and `Note` are not separate Realm object classes in the current app; they remain represented by `Footstep.photos: List<Data>` and `Footstep.notes: List<String>`.

## Repository Structure

Top-level surfaces:

- `footage.xcworkspace`
- `footage.xcodeproj`
- `Podfile`
- `Podfile.lock`
- `Footage/`
- `MainWidget/`
- `Entitlements/`

Main app code:

- `Footage/Domain`: sync-ready plain Swift identifiers and draft models.
- `Footage/Data/Repositories`: repository protocols and local/Realm-backed adapter scaffolds.
- `Footage/Data/Migration`: read-only export draft types for future migration work.
- `Footage/Model`: Realm models and value structs.
- `Footage/Scene`: UIKit view controllers and managers by feature.
- `Footage/Services/Sync`: local sync status and outbox draft types.
- `Footage/Storyboard`: `Date.storyboard`, `FirstLaunch.storyboard`, `Home.storyboard`, `Settings.storyboard`, `Stats.storyboard`.
- `Footage/Tool`: date/map/constants helpers.
- `Footage/Resource`: app Info.plist, fonts, intro video, assets.

Widget code:

- `MainWidget/MainWidget.swift`
- `MainWidget/SmallView.swift`
- `MainWidget/Assets.xcassets`

## Targets and Project Settings

Native targets found in `footage.xcodeproj/project.pbxproj`:

- `footage`
- `MainWidgetExtension`

Identifiers and signing-sensitive settings:

- App bundle identifier: `co.el.footage`
- Widget bundle identifier: `co.el.footage.MainWidget`
- Development team: `M286K6KP2M`
- App entitlements: `Entitlements/footage.entitlements`
- Widget entitlements: `Entitlements/MainWidgetExtension.entitlements`
- App group: `group.footage`
- Marketing version: `1.2.2`
- Current project version: `4`

Deployment targets:

- Project: iOS 18.0
- App target: iOS 18.0
- Widget target: iOS 18.0

Swift:

- Swift version: 5.0

Build phases include CocoaPods script phases:

- `[CP] Check Pods Manifest.lock`
- `[CP] Embed Pods Frameworks`

## Dependencies

`Podfile`:

- Platform: iOS 18.0.
- `use_frameworks!` for app and widget.
- App target pods: `EFCountingLabel ~> 6.0`, `RealmSwift ~> 20.0`.
- Widget target pods: `EFCountingLabel ~> 6.0`, `RealmSwift ~> 20.0`.
- Post-install sets generated Pods deployment target to iOS 18.0.
- Post-install still excludes `arm64` for watch simulator and Apple TV simulator.
- The stale iPhone simulator `arm64` exclusion was removed to allow modern Apple Silicon iOS simulator builds.

`Podfile.lock`:

- `EFCountingLabel 6.0.0.1`
- `Realm 20.0.4`
- `RealmSwift 20.0.4`
- CocoaPods generated with `1.10.0`

Risks:

- CocoaPods 1.10.0 is old for 2026 toolchains, but the current dependency baseline builds with it.
- EFCountingLabel is used in Storyboards and code, so removing it blindly would break interface loading.
- Remaining Realm/RealmSwift warnings come from generated Pods and should not be edited directly in `Pods/`.

## Info.plist and Capabilities

App Info.plist includes:

- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSFaceIDUsageDescription`
- `UIBackgroundModes`: `location`
- URL scheme: `widget`
- Scene delegate configured with Storyboard `Main`
- `UIRequiredDeviceCapabilities`: `armv7`
- Portrait orientation for iPhone
- Light interface style

Widget Info.plist:

- WidgetKit extension point.

Entitlements:

- App and widget both include `com.apple.security.application-groups` with `group.footage`.
- Release entitlements also exist and must be preserved.

Risks:

- `UIRequiredDeviceCapabilities` includes `armv7`, which is suspicious for modern iOS submissions and should be reviewed after a baseline.
- Location permission strings should be reviewed for current App Store clarity.
- Background location behavior must remain user-controlled and privacy-reviewed.

## Persistence Layer

Realm model files:

- `Year`: `months: List<Month>`, `date`, `preview`.
- `Month`: `days: List<DayData>`, `date`, `preview`, linking owners from `Year`.
- `DayData`: `date`, `distance`, `preview`, `footsteps: List<Footstep>`, linking owners from `Month`.
- `Footstep`: `timestamp`, `latitude`, `longitude`, `color`, `setAsStart`, computed coordinate, `photos: List<Data>`, `notes: List<String>`, linking owners from `DayData`.
- `Distance`: `total`, `today`.
- `Color`: `date`, `distance`, `hex`.
- `Place`: date, distance, country/admin/locality fields from reverse geocoding.
- `Badge`: type/detail/image/date.
- `WidgetRealm`: `isTracking`, `snapshot`; present in the model folder and target, but current widget state primarily uses UserDefaults.

Characteristics:

- No primary keys are defined on the inspected Realm objects.
- No sync identifiers exist.
- Route points are embedded in `DayData.footsteps`, with time hierarchy through `Year` and `Month`.
- Photos are stored directly as `Data` on `Footstep`, which can make Realm files large and cloud migration expensive.
- Most Realm usage calls `try! Realm()` directly from controllers/managers.

Risks:

- Missing primary keys make idempotent sync, migration, and deduplication harder.
- Large binary photos inside Realm can increase backup, restore, and migration risk.
- Direct writes from many classes make it hard to reason about thread confinement, migration, testing, and future cloud sync.
- Some Realm writes occur from asynchronous photo callbacks using a Realm instance captured outside the callback path, which should be reviewed carefully for thread correctness.

## Location Tracking Flow

Primary flow:

1. `HomeViewController.startTracking()` sets app group `isTracking`, updates UI, checks authorization, applies first-run defaults, and calls `trackMapView()`.
2. `trackMapView()` configures the static `CLLocationManager`, draws today's existing route, and starts location updates.
3. `locationManager(_:didUpdateLocations:)` receives locations, filters with `checkForMovement` and `isValid`, writes points through `LocationUpdate.processNewLocation`, extends the map polyline, updates counters, and checks badges/place stats.
4. `LocationUpdate.processNewLocation` creates a `Footstep`, calls `DateManager.update`, updates color and place stats for non-start points, and tracks the last location.
5. `DateManager.update` writes into today's `DayData`, creating `Month` and `Year` hierarchy when needed.

Important constants/logic:

- `speedLimit`: 8 meters/second.
- `refreshRate`: 2.5 seconds.
- `distanceLimit`: speed limit multiplied by refresh rate.
- `distanceFilter`: 5 meters.
- `desiredAccuracy`: best.
- `activityType`: fitness.
- `allowsBackgroundLocationUpdates`: true.
- `pausesLocationUpdatesAutomatically`: true.

Risks:

- `HomeViewController` is monolithic and owns UI, recording, filtering, map rendering, distance counters, notifications, first-run behavior, widget state, and update migration flags.
- `configureInitialMapView()` and `trackMapView()` contain `while locationManager.location == nil { requestLocation() }`, which can block the main thread.
- `locations[0]` is used instead of the newest location; modern CoreLocation delegate arrays may contain multiple entries.
- Speed calculation divides by timestamp interval without guarding zero or negative intervals.
- Raw errors are printed. Avoid printing raw location context in future changes.
- `sceneDidDisconnect` sets `isTracking` false, which may conflict with expected background or widget state.

## Map Rendering

Map rendering uses:

- `MKMapView`
- `MKPolyline`
- `MKPolylineRenderer`
- Custom `PolylineWithColor`
- Helper `DrawOnMap.polylineFromFootsteps`

Rendering is spread across home, date, stats, and map scenes. This should stay stable during early modernization.

## Widget and App Group Usage

App group: `group.footage`.

Known keys:

- `isTracking`
- `distanceToday`
- `distanceTotal`
- `selectedColor`
- color-name keys such as `#EADE4Cff`, `#F5A997ff`, `#F0E7CFff`, `#FF6B39ff`, `#206491ff`

Widget:

- Reads app group UserDefaults in `MainWidgetProvider` and `SmallView`.
- Opens app through `widget://smallWidget`.
- App handles widget URL in `SceneDelegate` and toggles tracking.

Risks:

- Several app group reads force unwrap `UserDefaults(suiteName:)`.
- Widget state is not abstracted, so any key migration must preserve old keys until widget and app are updated together.

## Monolithic or Deprecated/Modernization-Risk Areas

Likely Phase 1/2 focus:

- `HomeViewController.swift`: monolithic recording and UI controller.
- `DateManager.swift`, `LocationUpdate.swift`, `ColorManager.swift`, `PlaceManager.swift`: direct Realm access and static global state.
- `JourneyManager.swift`: Realm photo/note mutations from async photo APIs; stores image data in Realm lists.
- `SceneDelegate.swift`: app state, first-launch routing, auth gate, widget URL handling, and background recording behavior are coupled.
- CocoaPods/Realm versions and simulator architecture exclusions.
- `UIApplication.shared.windows` usage appears in multiple controllers and should be modernized later.
- `CLLocationManager.authorizationStatus()` static API should be reviewed against current SDK recommendations.

## Baseline Risks Before Code Modernization

- Full Xcode is now active at `/Applications/Xcode.app/Contents/Developer`.
- A simulator workspace build baseline is captured for the main app and widget in Debug and Release.
- Existing project requires CocoaPods 1.10.0-compatible installation to match `Podfile.lock`.
- Modern Xcode/iOS SDK still flags Realm/RealmSwift generated-Pods warnings after the Realm 20.0.4 update.
- `armv7`, static authorization APIs, app extension restrictions, and storyboard custom class/module issues should be reviewed after preserving the build baseline.
- Widget extension includes RealmSwift dependency through Pods even though inspected widget UI primarily uses app group UserDefaults; do not remove until build and target membership are reviewed.

## Phase 3 Recording Extraction Audit

Phase 3 date: 2026-07-04.

Commands run:

```sh
git status --short
rg -n "CLLocationManager|didUpdateLocations|startTracking|stopTracking|checkForMovement|isValid|LocationUpdate\\.processNewLocation|UserDefaults\\(suiteName|isTracking|distanceToday|distanceTotal|selectedColor|group\\.footage" Footage/Scene/Home/HomeViewController.swift Footage/Scene/Stats Footage/Data/Repositories MainWidget
rg --files Footage | rg "(Footage/Scene/Home/HomeViewController.swift|Footage/Scene/Stats|Footage/Data|Footage/Domain|Footage/Services|Model)"
nl -ba Footage/Scene/Home/HomeViewController.swift | sed -n '1,210p'
nl -ba Footage/Scene/Home/HomeViewController.swift | sed -n '210,390p'
nl -ba Footage/Scene/Home/HomeViewController.swift | sed -n '520,630p'
nl -ba Footage/Scene/Stats/LocationUpdate.swift | sed -n '1,240p'
xcodebuild -list -workspace footage.xcworkspace
scripts/phase1-build-baseline.sh
```

Results:

- Initial `git status --short` showed only the existing Xcode user state file modified before Phase 3 edits.
- Static inspection succeeded and confirmed the current live recording path remains `HomeViewController` -> `LocationUpdate` -> `DateManager`/stats managers.
- Sandboxed `xcodebuild -list -workspace footage.xcworkspace` failed with `xcodebuild: error: 'footage.xcworkspace' is not a workspace file.` The surrounding diagnostics showed CoreSimulator/log/cache access failures, so the likely cause was sandboxed Xcode user-directory access rather than workspace corruption.
- Approved `xcodebuild -list -workspace footage.xcworkspace` succeeded and listed the workspace schemes.
- `scripts/phase1-build-baseline.sh` succeeded with exit code 0. The script runs `pod install`, workspace listing, and Debug/Release simulator builds for both `footage` and `MainWidgetExtension` with `CODE_SIGNING_ALLOWED=NO`.

Implementation result:

- Added `Footage/Services/Recording/DistanceCalculator.swift`.
- Added `Footage/Services/Recording/LocationFilter.swift`.
- Added `Footage/Services/Recording/RecordingStateStore.swift`.
- Added `Footage/Services/Recording/RecordingService.swift`.
- Registered the new files with the main app target.
- Routed existing `HomeViewController` widget tracking and distance writes through `RecordingStateStore` while preserving the existing keys.

Likely cause of remaining coupling:

- `HomeViewController.locationManager(_:didUpdateLocations:)` still coordinates filtering, Realm writes, map polyline rendering, badge/place checks, notifications, and UI state in one method. Moving all of it at once would be a broad behavior change.

Smallest proposed next fixes:

1. Replace `HomeViewController.checkSpeed` and distance calculations with `DistanceCalculator`.
2. Replace `HomeViewController.isValid` decision logic with `LocationFilter` while preserving the existing counters and UserDefaults side effects.
3. After parity is verified, move `LocationUpdate.processNewLocation` orchestration into `RecordingService`.
4. Keep map rendering and UI animation in `HomeViewController` until recording persistence is independently stable.

## Phase 4 Local Sync Outbox Audit

Phase 4 date: 2026-07-04.

Commands run:

```sh
git status --short
sed -n '1,260p' /Users/nyeok/.codex/attachments/9af4893a-5a04-4063-ab9d-29e81af9f4c3/pasted-text.txt
sed -n '1,220p' AGENTS.md
sed -n '1,260p' Footage/Data/Repositories/LocalSyncOutboxRepository.swift
sed -n '1,220p' Footage/Services/Sync/SyncOutboxDraft.swift
sed -n '1,220p' Footage/Data/Repositories/RepositoryProtocols.swift
sed -n '1,220p' Footage/Domain/Identifiers.swift
sed -n '1,220p' Footage/Data/Migration/MigrationExportModels.swift
sed -n '1,220p' Footage/Domain/RecordingDrafts.swift
sed -n '1,240p' docs/DATA_MODEL.md
rg -n "SyncOutbox|SyncStatus|syncBatch|outbox|Idempotency|idempotency" Footage docs
xcodebuild -list -workspace footage.xcworkspace
scripts/phase1-build-baseline.sh
```

Results:

- Initial `git status --short` showed Phase 3 changes still pending plus the existing Xcode user state file.
- Static inspection confirmed the Phase 2 outbox was a minimal `SyncOutboxDraft` UserDefaults store.
- `xcodebuild -list -workspace footage.xcworkspace` succeeded with approved Xcode access.
- `scripts/phase1-build-baseline.sh` succeeded with exit code 0 after Phase 4 changes.

Implementation result:

- Added `Footage/Services/Sync/SyncOutboxModels.swift`.
- Added `Footage/Services/Sync/RoutePointNDJSONSerializer.swift`.
- Added `Footage/Services/Sync/LocalSyncBatchBuilder.swift`.
- Extended `Footage/Data/Repositories/RepositoryProtocols.swift`.
- Extended `Footage/Data/Repositories/LocalSyncOutboxRepository.swift`.
- Registered the new files with the main app target.

Data safety:

- No existing Realm object class or field was changed.
- No Realm migration was added.
- No route/photo/note data is deleted, moved, uploaded, or rewritten.
- Outbox state is local Codable data in `UserDefaults`, separate from the existing Realm route hierarchy.

Known limitation:

- Route-point IDs generated for NDJSON are deterministic from installation, local date, timestamp, and sequence for preparation safety, but they are not yet persisted back onto Realm `Footstep` objects. A later additive migration should persist stable point IDs before production cloud backup.
- NDJSON currently exists as an in-memory/local Codable payload string. Gzip compression, file persistence, checksums, object keys, upload, and server metadata are intentionally deferred.

Smallest proposed next fixes:

1. Wire local outbox preparation after local route writes without changing recording UX.
2. Add lightweight tests around `LocalSyncOutboxRepository` state transitions and NDJSON serialization.
3. Persist stable recording and point identifiers through an additive migration only after backup/export rollback is ready.
4. Add cloud backup bootstrap only after explicit opt-in UI and privacy review.

## Phase 5 Cloud Backup Client Audit

Phase 5 date: 2026-07-04.

Commands run:

```sh
git status --short
sed -n '1,280p' /Users/nyeok/.codex/attachments/b681c48f-45cf-4ef6-8b75-1dec1ad342d6/pasted-text.txt
sed -n '1,220p' AGENTS.md
sed -n '1,240p' docs/API_SPEC.md
sed -n '240,380p' docs/API_SPEC.md
sed -n '1,260p' Footage/Services/Sync/SyncOutboxModels.swift
sed -n '1,260p' Footage/Data/Repositories/LocalSyncOutboxRepository.swift
rg -n "URLSession|Network|APIClient|Backup|Cloud|token|Bearer|URLRequest|presign|upload" Footage docs/API_SPEC.md docs/MODERNIZATION_PLAN.md
xcodebuild -list -workspace footage.xcworkspace
scripts/phase1-build-baseline.sh
```

Results:

- Initial `git status --short` showed Phase 3 and Phase 4 changes still pending plus the existing Xcode user state file.
- Static inspection confirmed there was no existing app network/API client surface.
- `xcodebuild -list -workspace footage.xcworkspace` succeeded with approved Xcode access.
- The first `scripts/phase1-build-baseline.sh` run failed with exit code 65 due to a Swift closure capture compile error in the new API client.
- After changing `decoder.decode(...)` to `self.decoder.decode(...)`, `scripts/phase1-build-baseline.sh` succeeded with exit code 0.

Implementation result:

- Added `Footage/Services/Backup/CloudBackupConfiguration.swift`.
- Added `Footage/Services/Backup/CloudBackupLogger.swift`.
- Added `Footage/Services/Backup/CloudBackupService.swift`.
- Added `Footage/Network/CloudBackupAPIClient.swift`.
- Added `Footage/Network/DTO/CloudBackupDTOs.swift`.
- Registered the new files with the main app target.

Safety result:

- Cloud backup defaults to disabled.
- A second `isDevelopmentUploadEnabled` flag must also be enabled before uploads can run through `CloudBackupService`.
- No app launch, recording, widget, or UI code invokes cloud backup.
- No AWS access key, AWS secret key, AWS SDK, public S3 URL, Auth flow, signing change, bundle identifier change, entitlement change, Pod removal, Storyboard change, asset deletion, widget target change, Realm schema change, or destructive migration was added.
- `anonymousDeviceToken` is not persisted; secure storage remains future work.

Privacy logging result:

- Debug logging is limited to operation names and coarse status.
- The scaffold does not log raw latitude/longitude, notes, photos, bearer tokens, anonymous device tokens, presigned URLs, object keys, or AWS credentials.

Known limitations:

- Real cloud backup cannot safely be enabled until opt-in UI, secure token storage, backend endpoint configuration, gzip/file staging, tests, and privacy review are complete.
- The outbox currently stores NDJSON payload strings locally; production backup should use file-backed staging with gzip and checksums.
- Route point IDs are still not persisted into Realm objects.

Smallest proposed next fixes:

1. Add tests for `CloudBackupAPIClient` request construction with a mock `URLProtocol`.
2. Add secure token storage before persisting `anonymousDeviceToken`.
3. Add explicit opt-in backup UI and privacy copy.
4. Add local file-backed gzip staging before enabling real uploads.

## iOS 18 Baseline Audit

Baseline update date: 2026-07-04.

Commands run:

```sh
git status --short
rg -n "IPHONEOS_DEPLOYMENT_TARGET|platform :ios|deployment target|iOS 13|iOS 14|iOS 18|MinimumOSVersion" Podfile footage.xcodeproj/project.pbxproj Footage MainWidget docs
sed -n '1,160p' Podfile
xcodebuild -list -workspace footage.xcworkspace
scripts/phase1-build-baseline.sh
git diff --check
```

Implementation result:

- `Podfile` platform is now iOS 18.0.
- `Podfile` post-install generated Pods deployment target is now iOS 18.0.
- Project Debug and Release deployment targets are now iOS 18.0.
- Main app Debug and Release deployment targets are now iOS 18.0.
- Widget extension Debug and Release deployment targets are now iOS 18.0.
- `Podfile.lock` changed only by `PODFILE CHECKSUM`.
- No signing setting, bundle identifier, entitlement, app group, Storyboard, asset, Realm model, or widget source file was changed for the iOS 18 baseline.

Validation result:

- `xcodebuild -list -workspace footage.xcworkspace` succeeded.
- `scripts/phase1-build-baseline.sh` succeeded with exit code 0 after `pod install`, workspace listing, and Debug/Release simulator builds for app and widget.

New or more visible warnings after setting iOS 18.0:

- `Settings_DonateVC` uses StoreKit 1 APIs deprecated/no longer supported in iOS 18: `SKPaymentQueue`, `SKPaymentTransaction`, `SKPaymentTransactionObserver`, `SKMutablePayment`, and `finishTransaction`.
- `HomeViewController` uses `UIApplication.shared.applicationIconBadgeNumber`, deprecated in iOS 17.
- `HomeViewController`, `FL_LetsStartVC`, and `SceneDelegate` use `UIApplication.shared.windows`, deprecated in iOS 15.
- `HomeViewController` and `MapViewController` use static `CLLocationManager.authorizationStatus()`, deprecated in iOS 14.
- `HomeViewController` uses `SKStoreReviewController.requestReview()`, deprecated in favor of scene-based/AppStore review APIs.
- Realm/RealmSwift generated Pods still emit duplicate-library, Sendable conformance, and C++ designated initializer ordering warnings.

Smallest proposed next fixes:

1. Replace StoreKit 1 donation code with StoreKit 2 behind an iOS 18-safe purchase service.
2. Replace badge count writes with `UNUserNotificationCenter.setBadgeCount`.
3. Replace `UIApplication.shared.windows` lookups with scene-local window access.
4. Replace static location authorization checks with `CLLocationManager.authorizationStatus` instance usage where appropriate.

## Recommended Immediate Next Steps

1. Keep `scripts/phase1-build-baseline.sh` as the repeatable Debug and Release simulator baseline for app and widget.
2. Do not update CocoaPods tooling unless a concrete build or install issue requires it; the dependency baseline now passes with CocoaPods 1.10.0.
3. Address iOS 18 deprecation warnings in small patches, starting with StoreKit 1 donation flow.
4. Add tests for outbox state transitions, idempotency key generation, NDJSON serialization, and API client request construction.
5. Add secure token storage and explicit opt-in UI before enabling any real cloud backup.
