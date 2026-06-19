#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/DoubaoNative.xcodeproj"
SCHEME="DoubaoNative"
ARCHIVE_DIR="$ROOT_DIR/Archives"
ARCHIVE_PATH="$ARCHIVE_DIR/DoubaoNative.xcarchive"
EXPORT_PATH="$ROOT_DIR/Export"

mkdir -p "$ARCHIVE_DIR" "$EXPORT_PATH"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  archive

if [[ -f "$ROOT_DIR/ExportOptions.plist" ]]; then
  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$ROOT_DIR/ExportOptions.plist" \
    -exportPath "$EXPORT_PATH"
else
  echo "Archive created at $ARCHIVE_PATH"
  echo "Add ExportOptions.plist to export an IPA for your signing method."
fi
