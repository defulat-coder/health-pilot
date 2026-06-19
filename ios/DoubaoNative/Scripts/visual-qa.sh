#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
REFERENCE_DIR="$REPO_ROOT/design/reference/doubao-mobile"
MANIFEST="$REFERENCE_DIR/manifest.json"
CANDIDATE_DIR="${1:-$ROOT_DIR/Screenshots}"
REPORT_DIR="$ROOT_DIR/Reports"
REPORT_PATH="$REPORT_DIR/visual-compare.json"

mkdir -p "$REPORT_DIR"

"$ROOT_DIR/Scripts/validate-visual-manifest.swift" \
  --manifest "$MANIFEST" \
  --models "$ROOT_DIR/DoubaoNative/Models.swift" \
  --app-state "$ROOT_DIR/DoubaoNative/AppState.swift" \
  --capture-script "$ROOT_DIR/Scripts/capture-ios-screenshots.sh"

"$ROOT_DIR/Scripts/capture-ios-screenshots.sh" "$CANDIDATE_DIR"

"$ROOT_DIR/Scripts/compare-screenshots.swift" \
  --reference "$REFERENCE_DIR" \
  --candidate "$CANDIDATE_DIR" \
  --manifest "$MANIFEST" \
  --fail-on-extra-candidates | tee "$REPORT_PATH"

echo "Visual QA report: $REPORT_PATH"
