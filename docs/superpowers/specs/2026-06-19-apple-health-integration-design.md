# Apple Health Integration Design

## Context

Health Pilot is a chat-first personal health manager. The current app already has a native iOS shell, a health summary endpoint, health info panels, and backend tools for meals, weight, exercise, summaries, and proactive reminders. The Apple Health work should extend that system instead of replacing it with a heavy dashboard.

The approved direction is: iOS reads Apple Health through HealthKit, the backend stores normalized samples and generates reports, and Chat can answer against those reports.

## Goals

- Import Apple Health data into Health Pilot through native iOS HealthKit authorization and sync.
- Provide a dedicated Health Data page where users can inspect connected status, recent metrics, source coverage, and generated reports.
- Generate analysis reports from synced Apple Health samples and existing Health Pilot records.
- Let Chat answer follow-up questions using the latest analysis report and key health metrics.
- Keep the first implementation complete and testable while leaving the data model open to more HealthKit types.

## Data Scope

The storage and API model must support arbitrary HealthKit categories through a generic sample shape:

- `type`: stable metric identifier, such as `step_count`, `active_energy_burned`, `sleep_analysis`, or `heart_rate`.
- `category`: `activity`, `body`, `vitals`, `sleep`, `profile`, `nutrition`, or future categories.
- `unit`: original unit received from iOS.
- `value`: numeric value when applicable.
- `start_at` and `end_at`: sample interval.
- `source`: HealthKit source bundle/name where available.
- `metadata`: JSON for values that do not fit the common numeric shape, including sleep stage or workout details.

The first implementation reads and syncs the Health Pilot core set:

- Activity: steps, active energy, exercise minutes, workouts.
- Body: weight, body fat percentage, height.
- Vitals: heart rate, resting heart rate.
- Sleep: asleep and in-bed intervals.
- Profile: date of birth and biological sex when authorized and available.

Future HealthKit types such as blood oxygen, HRV, respiratory rate, blood pressure, blood glucose, menstruation, and nutrition can be added by registering new type descriptors without changing the backend storage contract.

## Architecture

### iOS

Add an `AppleHealthService` boundary that owns HealthKit usage. It checks HealthKit availability, requests authorization, reads samples, tracks sync windows, and produces normalized DTOs for the backend. UI and app state should depend on a protocol so tests can use a fake service without HealthKit.

App state gains a Health Data route and health data state: authorization status, sync status, synced metric summaries, report list, selected report, and error copy. The route loads the current backend summary and can trigger a HealthKit sync.

### Backend

Add a Health Data module with three responsibilities:

- Ingest normalized samples from iOS with idempotent upsert behavior.
- Query samples into dashboard summaries and report inputs.
- Generate report records that Chat can cite.

The backend stores Apple Health samples separately from manually entered meals, exercise, weight, and notifications. Reports may combine both sources, but raw sample provenance remains intact.

### Chat

Coach Agent instructions include a compact "latest health report context" block when one exists for the user. Chat should know report title, period, key findings, risks, recommendations, and data coverage. It should not claim diagnosis or certainty when data coverage is partial.

Health Data page report actions send suggested prompts into the existing chat flow, for example "基于这份周报，帮我安排明天的饮食和运动".

## Data Flow

1. User opens Health Data page.
2. The page shows connection status and calls backend dashboard/report endpoints.
3. If HealthKit is not authorized, the page offers a connect action with plain privacy copy.
4. User grants HealthKit permissions.
5. iOS reads recent samples for the configured HealthKit type set.
6. iOS POSTs normalized samples to the backend.
7. Backend upserts samples and returns sync counts plus latest sync time.
8. iOS refreshes the dashboard and report list.
9. User generates or opens a report.
10. Backend computes analysis from Apple Health samples and Health Pilot records, persists the report, and returns structured output.
11. User taps a report chat action, which opens Chat and sends a prompt that references the report.
12. Coach Agent receives latest report context and answers against the report.

## Dedicated Health Data Page

The page should feel like a compact product work surface, not a medical portal. It uses the existing near-white background, white panels only where content needs grouping, SF Symbols, chip controls, and the existing blue accent.

Top content:

- Header: "健康数据" with sidebar and refresh/sync actions.
- Connection strip: HealthKit availability, authorization status, last sync time, and action button.
- Three compact summary rows: activity, sleep, vitals/body. Each row shows a primary metric, coverage label, and freshness.

Main content:

- Metric sections for activity, sleep, body, and vitals.
- Report section with latest daily/weekly report cards.
- A "去聊天分析" action on each report.

Empty states:

- Before authorization: explain that Health Pilot reads selected Apple Health data after permission and does not diagnose.
- Authorized but no samples: show missing-data copy and a sync retry.
- Partial coverage: show which metrics are missing without blaming the user.

## Reports

Reports are structured, not just prose. Each report includes:

- `kind`: daily or weekly for the first implementation.
- `period_start` and `period_end`.
- `title` and short summary.
- `metrics`: key numbers used by the report.
- `findings`: trend or pattern observations.
- `recommendations`: practical next actions.
- `risks`: non-diagnostic cautions such as low sleep coverage or unusual resting heart rate trend.
- `coverage`: which metric families were present, partial, or missing.

Reports should be deterministic enough for tests. The first implementation can use rules-based report generation with clear thresholds. LLM-generated coaching can be layered on top later, but the core report shape and report-chat bridge should not depend on a live LLM call.

## Error Handling

- HealthKit unavailable: show an iOS-only unsupported message and keep backend page data readable.
- Permission denied or partial: show available metrics and list missing families.
- Sync failure: preserve last successful data and show retry copy.
- Backend failure: show current local sync state if available and a concise service error.
- Duplicate samples: backend upsert keeps one canonical sample per user/type/source/start/end.
- Sensitive data: all HealthKit access starts from explicit iOS permission, and Chat context uses summarized reports rather than dumping raw samples.

## Testing

Backend tests cover sample ingestion, idempotency, dashboard aggregation, report generation, and Chat context injection.

iOS state tests cover Health Data route navigation, authorization states, sync success/failure, report action to Chat, and fake HealthKit services. HealthKit itself is behind a protocol so simulator and CI can test without real Apple Health data.

Build verification should include the existing iOS state scenario script and backend unit tests. Visual verification should confirm the Health Data page renders in the established Health Pilot style with no clipped text or nested-card dashboard look.

## Out of Scope

- Writing data back to Apple Health.
- Medical diagnosis, medication advice, or clinical interpretation.
- Cloud multi-device identity and account sync beyond existing `user_id`.
- Full historical import of every HealthKit data type in one pass.
- Push notification changes beyond existing report/chat integration.

## Self-Review

- No placeholders remain.
- The architecture aligns with the approved native HealthKit plus backend report direction.
- Scope is broad enough to satisfy Apple Health integration and report-chat flow, while keeping the first implementation testable.
- The design explicitly separates expandable data storage from the first HealthKit metric set.
