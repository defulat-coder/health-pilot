#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

SDK_PATH="$(xcrun --sdk iphonesimulator --show-sdk-path)"

xcrun swiftc \
  -typecheck \
  -sdk "$SDK_PATH" \
  -target arm64-apple-ios17.0-simulator \
  ios/DoubaoNative/DoubaoNative/*.swift

plutil -lint ios/DoubaoNative/DoubaoNative/Info.plist
xmllint --noout ios/DoubaoNative/DoubaoNative.xcodeproj/xcshareddata/xcschemes/DoubaoNative.xcscheme
bash -n ios/DoubaoNative/Scripts/capture-ios-screenshots.sh
bash -n ios/DoubaoNative/Scripts/build-release.sh
bash -n ios/DoubaoNative/Scripts/verify-state-scenarios.sh
bash -n ios/DoubaoNative/Scripts/visual-qa.sh

ios/DoubaoNative/Scripts/verify-state-scenarios.sh
ios/DoubaoNative/Scripts/validate-visual-manifest.swift
ios/DoubaoNative/Scripts/release-readiness.swift
ios/DoubaoNative/Scripts/compare-screenshots.swift \
  --reference design/reference/doubao-mobile \
  --candidate design/reference/doubao-mobile \
  --manifest design/reference/doubao-mobile/manifest.json \
  --fail-on-extra-candidates

if rg -n "Taro|React|WebView|WKWebView|taro" ios/DoubaoNative/DoubaoNative; then
  echo "Unexpected web/Taro runtime reference found in native iOS project." >&2
  exit 1
fi

if rg -n "msToken|a_bogus|device_id|web_id|tea_uuid|web_tab_id|765296|iFKW" design/reference/doubao-mobile docs/research/2026-06-19-doubao-mobile-cdp-analysis.md; then
  echo "Sensitive transient Doubao request parameter leaked into reference files." >&2
  exit 1
fi

echo "Local verification passed."
