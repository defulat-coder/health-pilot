#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

cd "$REPO_ROOT"

xcrun swiftc \
  ios/DoubaoNative/DoubaoNative/Models.swift \
  ios/DoubaoNative/DoubaoNative/AppleHealthService.swift \
  ios/DoubaoNative/DoubaoNative/MockAssistantService.swift \
  ios/DoubaoNative/DoubaoNative/AppState.swift \
  ios/DoubaoNative/Tests/StateScenarioTests.swift \
  -o "$TMP_DIR/StateScenarioTests"

"$TMP_DIR/StateScenarioTests"
