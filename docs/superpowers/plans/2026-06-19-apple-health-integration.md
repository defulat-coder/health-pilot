# Apple Health Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Apple Health sync, a dedicated Health Data page, generated reports, and report-grounded Chat.

**Architecture:** iOS reads HealthKit through a protocol-backed service and uploads normalized samples. The backend stores idempotent Apple Health samples, generates deterministic analysis reports, and injects latest report context into Coach Agent instructions. The iOS Health Data page displays connection, metrics, reports, and chat actions.

**Tech Stack:** SwiftUI, HealthKit, URLSession, FastAPI, SQLAlchemy, SQLite, Python unittest/pytest-compatible tests, existing iOS state scenario tests.

---

## File Structure

- Create `backend/tools/apple_health_analyzer.py`: deterministic aggregation and report generation helpers.
- Modify `backend/models/database.py`: add Apple Health sample and report tables.
- Modify `backend/main.py`: add sync, dashboard, report, and latest-report endpoints.
- Modify `backend/agents/coach.py`: inject latest report context into Coach Agent instructions.
- Create `backend/tests/test_apple_health_api.py`: API-level backend coverage.
- Create `ios/DoubaoNative/DoubaoNative/AppleHealthService.swift`: HealthKit authorization and sample sync boundary.
- Create `ios/DoubaoNative/DoubaoNative/HealthDataView.swift`: dedicated Health Data page.
- Modify `ios/DoubaoNative/DoubaoNative/Models.swift`: add health data/report DTOs and route.
- Modify `ios/DoubaoNative/DoubaoNative/AppState.swift`: add health data state, sync actions, report chat action.
- Modify `ios/DoubaoNative/DoubaoNative/HTTPStreamingAssistantService.swift`: add sync/dashboard/report API calls.
- Modify `ios/DoubaoNative/DoubaoNative/MockAssistantService.swift`: add fake health data behavior.
- Modify `ios/DoubaoNative/DoubaoNative/RootView.swift`: route Health Data page.
- Modify `ios/DoubaoNative/DoubaoNative/SidebarView.swift`: route "健康分析" to Health Data.
- Modify `ios/DoubaoNative/Tests/StateScenarioTests.swift`: cover navigation, sync, reports, and report chat.
- Modify `ios/DoubaoNative/DoubaoNative.xcodeproj/project.pbxproj`: include new Swift files.

## Task 1: Backend Models and Analyzer

**Files:**
- Modify: `backend/models/database.py`
- Create: `backend/tools/apple_health_analyzer.py`
- Test: `backend/tests/test_apple_health_api.py`

- [ ] **Step 1: Add failing tests for sample sync and reports**

Create tests that POST samples, repeat the same POST, fetch the dashboard, generate a daily report, and assert duplicate samples are not counted twice.

- [ ] **Step 2: Add database models**

Add `AppleHealthSample` and `HealthAnalysisReport` tables. `AppleHealthSample` stores user, type, category, unit, value, source, start/end timestamps, and metadata JSON. `HealthAnalysisReport` stores user, report kind, period, title, summary, metrics, findings, recommendations, risks, and coverage JSON.

- [ ] **Step 3: Implement analyzer helpers**

Implement `build_health_dashboard`, `generate_health_report`, and `latest_report_context`. These functions must be deterministic and independent of LLM calls.

- [ ] **Step 4: Verify backend model/analyzer tests**

Run: `cd backend && uv run python -m pytest tests/test_apple_health_api.py -q`

Expected: tests pass after API endpoints are implemented in Task 2.

## Task 2: Backend API and Chat Context

**Files:**
- Modify: `backend/main.py`
- Modify: `backend/agents/coach.py`
- Test: `backend/tests/test_apple_health_api.py`

- [ ] **Step 1: Add Apple Health API endpoints**

Add endpoints:

- `POST /api/v1/apple-health/samples`
- `GET /api/v1/apple-health/dashboard`
- `POST /api/v1/apple-health/reports`
- `GET /api/v1/apple-health/reports`
- `GET /api/v1/apple-health/reports/latest-context`

- [ ] **Step 2: Add idempotent ingest behavior**

Upsert samples by `user_id`, `type`, `source`, `start_at`, and `end_at`. Return received, inserted, updated, and total counts.

- [ ] **Step 3: Inject report context into Coach Agent**

Extend dynamic instructions so the latest report context appears when available. The context must include coverage and non-diagnostic caution.

- [ ] **Step 4: Run backend tests**

Run: `cd backend && uv run python -m pytest tests/test_apple_health_api.py -q`

Expected: all backend Apple Health tests pass.

## Task 3: iOS DTOs, Service Protocols, and App State

**Files:**
- Create: `ios/DoubaoNative/DoubaoNative/AppleHealthService.swift`
- Modify: `ios/DoubaoNative/DoubaoNative/Models.swift`
- Modify: `ios/DoubaoNative/DoubaoNative/AppState.swift`
- Modify: `ios/DoubaoNative/DoubaoNative/HTTPStreamingAssistantService.swift`
- Modify: `ios/DoubaoNative/DoubaoNative/MockAssistantService.swift`
- Test: `ios/DoubaoNative/Tests/StateScenarioTests.swift`

- [ ] **Step 1: Add failing state tests**

Test that Health Data navigation loads dashboard, sync success updates status/counts, sync failure sets an error, and report chat action opens Chat with a report prompt.

- [ ] **Step 2: Add DTOs and service methods**

Add `HealthDashboard`, `AppleHealthSyncResult`, `HealthAnalysisReport`, `AppleHealthAuthorizationState`, and service methods for dashboard, sync, report list, report generation, and report chat.

- [ ] **Step 3: Add HealthKit boundary**

Implement `AppleHealthServicing` and `AppleHealthService`. The real service uses HealthKit when available. Fake services used by tests do not import real HealthKit behavior.

- [ ] **Step 4: Add AppState health data actions**

Implement route navigation, load dashboard, connect/sync, generate reports, load reports, and send report to Chat.

## Task 4: Dedicated Health Data Page

**Files:**
- Create: `ios/DoubaoNative/DoubaoNative/HealthDataView.swift`
- Modify: `ios/DoubaoNative/DoubaoNative/RootView.swift`
- Modify: `ios/DoubaoNative/DoubaoNative/SidebarView.swift`
- Modify: `ios/DoubaoNative/DoubaoNative.xcodeproj/project.pbxproj`

- [ ] **Step 1: Route the page**

Add `.healthData` route and point the sidebar "健康分析" row to it.

- [ ] **Step 2: Build page UI**

Build a compact SwiftUI page with header, connection strip, metric sections, report list, loading/error states, and report chat actions. Use existing `DS` tokens and SF Symbols.

- [ ] **Step 3: Keep UI product-safe**

Avoid nested cards, oversized metrics, health-green palette, and decorative dashboards. Use compact rows and clear empty states.

## Task 5: Verification

**Files:**
- Test: `backend/tests/test_apple_health_api.py`
- Test: `ios/DoubaoNative/Tests/StateScenarioTests.swift`
- Script: `ios/DoubaoNative/Scripts/verify-state-scenarios.sh`

- [ ] **Step 1: Run backend tests**

Run: `cd backend && uv run python -m pytest tests/test_apple_health_api.py -q`

Expected: all tests pass.

- [ ] **Step 2: Run iOS state scenario tests**

Run: `cd ios/DoubaoNative && Scripts/verify-state-scenarios.sh`

Expected: state scenario tests pass.

- [ ] **Step 3: Build iOS app if Xcode tooling is available**

Run the project build through available Xcode tooling or `xcodebuild` for the `DoubaoNative` scheme.

Expected: new Swift files compile and HealthKit imports are guarded for simulator/test use.

## Self-Review

- The plan covers all PRD requirements: HealthKit sync, dedicated page, reports, report-grounded Chat, and tests.
- No "TBD" or "later" placeholders remain.
- File boundaries match the current repo structure and existing Health Pilot patterns.
- The first implementation is complete for the core Health Pilot Apple Health metric set and keeps future HealthKit type expansion in the generic sample contract.
