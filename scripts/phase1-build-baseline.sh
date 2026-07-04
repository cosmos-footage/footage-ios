#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POD_BIN="${POD_BIN:-$HOME/.gem/ruby/2.6.0/bin/pod}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/build/DerivedData}"

cd "$ROOT_DIR"

if [[ ! -x "$POD_BIN" ]]; then
  echo "error: CocoaPods executable not found at $POD_BIN" >&2
  echo "Install CocoaPods 1.10.0 or set POD_BIN to the pod executable." >&2
  exit 1
fi

"$POD_BIN" install

xcodebuild -list -workspace footage.xcworkspace

for configuration in Debug Release; do
  xcodebuild \
    -workspace footage.xcworkspace \
    -scheme footage \
    -configuration "$configuration" \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    -quiet \
    build

  xcodebuild \
    -workspace footage.xcworkspace \
    -scheme MainWidgetExtension \
    -configuration "$configuration" \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    -quiet \
    build
done
