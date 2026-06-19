#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
PROJECT="$ROOT_DIR/DoubaoNative.xcodeproj"
SCHEME="DoubaoNative"
BUNDLE_ID="com.healthpilot.DoubaoNative"
DERIVED_DATA="$ROOT_DIR/.derivedData"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/DoubaoNative.app"
OUTPUT_DIR="${1:-$ROOT_DIR/Screenshots}"
DEVICE_NAME="${DEVICE_NAME:-iPhone 13}"
DEVICE_TYPE="${DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-13}"
MANIFEST="${MANIFEST:-$REPO_ROOT/design/reference/doubao-mobile/manifest.json}"
CAPTURE_WIDTH="$(/usr/bin/python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["capture"]["width"])' "$MANIFEST")"
CAPTURE_HEIGHT="$(/usr/bin/python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["capture"]["height"])' "$MANIFEST")"

mkdir -p "$OUTPUT_DIR"

runtime_id="$(xcrun simctl list runtimes available | awk -F' - ' '/iOS/ {print $NF; exit}')"
if [[ -z "${runtime_id:-}" || "$runtime_id" == "== Runtimes ==" ]]; then
  echo "No available iOS Simulator runtime. Install an iOS runtime in Xcode Settings > Components, then rerun this script." >&2
  exit 2
fi

device_udid="$(xcrun simctl list devices available | awk -v name="$DEVICE_NAME" '$0 ~ name && match($0, /\([A-F0-9-]+\)/) {print substr($0, RSTART + 1, RLENGTH - 2); exit}')"
if [[ -z "${device_udid:-}" ]]; then
  device_udid="$(xcrun simctl create "$DEVICE_NAME" "$DEVICE_TYPE" "$runtime_id")"
fi

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "id=$device_udid" \
  -derivedDataPath "$DERIVED_DATA" \
  build

xcrun simctl boot "$device_udid" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$device_udid" -b
xcrun simctl install "$device_udid" "$APP_PATH"

while IFS=$'\t' read -r scenario file_name; do
  [[ -n "$scenario" ]] || continue
  xcrun simctl terminate "$device_udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$device_udid" "$BUNDLE_ID" --args --snapshot "$scenario" >/dev/null
  sleep 1.2
  xcrun simctl io "$device_udid" screenshot "$OUTPUT_DIR/$file_name" >/dev/null
  sips -z "$CAPTURE_HEIGHT" "$CAPTURE_WIDTH" "$OUTPUT_DIR/$file_name" >/dev/null
  echo "Captured $OUTPUT_DIR/$file_name"
done < <("$ROOT_DIR/Scripts/visual-manifest-list.swift" --manifest "$MANIFEST")

echo "Screenshot capture complete: $OUTPUT_DIR"
