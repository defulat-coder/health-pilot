# Apple Health Integration PRD

## Problem Statement

Health Pilot users already record meals, weight, exercise, and health notes through chat, but important daily signals also live in Apple Health. Without Apple Health integration, Health Pilot has an incomplete view of the user's activity, sleep, vitals, and body metrics. Users cannot inspect those imported signals on a dedicated page, cannot get consistent analysis reports from them, and cannot continue a chat conversation grounded in a generated report.

## Solution

Health Pilot will add a native iOS Apple Health integration that imports authorized HealthKit data into the backend, presents a dedicated Health Data page, generates daily and weekly analysis reports, and lets Chat answer questions using the latest report context.

The first implementation will support a broad, expandable Apple Health data model and fully implement the core Health Pilot metric set: steps, active energy, exercise minutes, workouts, weight, body fat percentage, height, heart rate, resting heart rate, sleep intervals, date of birth, and biological sex. The system will be designed so additional HealthKit types can be added through descriptors without changing the storage or report-chat architecture.

## User Stories

1. As a Health Pilot user, I want to connect Apple Health, so that Health Pilot can use my activity, sleep, body, and vital signs data.
2. As a Health Pilot user, I want to see whether Apple Health is connected, so that I know if my data is available.
3. As a Health Pilot user, I want clear HealthKit permission copy, so that I understand what data is being read before granting access.
4. As a Health Pilot user, I want the app to keep working when HealthKit is unavailable, so that I can still use manual records and chat.
5. As a Health Pilot user, I want to sync Apple Health data on demand, so that I can refresh the app after new Apple Health records appear.
6. As a Health Pilot user, I want Health Pilot to avoid duplicate imported samples, so that repeated syncs do not inflate metrics.
7. As a Health Pilot user, I want to see my steps and active energy, so that I understand daily movement.
8. As a Health Pilot user, I want to see exercise minutes and workouts, so that planned and actual activity are visible.
9. As a Health Pilot user, I want to see sleep duration and coverage, so that recovery can be considered in coaching.
10. As a Health Pilot user, I want to see heart rate and resting heart rate, so that changes in vital signs can be surfaced cautiously.
11. As a Health Pilot user, I want to see weight, body fat, and height data imported from Apple Health, so that my profile and trends stay current.
12. As a Health Pilot user, I want to see which metric families are missing, so that I understand why a report may be incomplete.
13. As a Health Pilot user, I want a dedicated Health Data page, so that Apple Health data is inspectable outside a chat message.
14. As a Health Pilot user, I want Health Data page summaries to be compact and readable, so that the page does not feel like a hospital dashboard.
15. As a Health Pilot user, I want daily reports, so that I can understand today's activity, sleep, and health signals.
16. As a Health Pilot user, I want weekly reports, so that I can see trends across several days.
17. As a Health Pilot user, I want reports to include data coverage, so that I can trust what the analysis is based on.
18. As a Health Pilot user, I want reports to distinguish findings from recommendations, so that I can act on them without confusing observation for advice.
19. As a Health Pilot user, I want non-diagnostic caution around unusual patterns, so that the product remains trustworthy and safe.
20. As a Health Pilot user, I want to open a chat from a report, so that I can ask follow-up questions without manually copying context.
21. As a Health Pilot user, I want Chat to know the latest report, so that it can answer questions based on my synced data.
22. As a Health Pilot user, I want Chat to mention missing data when relevant, so that it does not overstate certainty.
23. As a Health Pilot user, I want existing meal and manual exercise records to still matter, so that Apple Health augments rather than replaces Health Pilot tracking.
24. As a Health Pilot user, I want sync errors to preserve the last good state, so that a temporary backend issue does not erase useful data.
25. As a Health Pilot user, I want generated reports to be saved, so that I can revisit them and continue analysis later.

## Implementation Decisions

- iOS owns all HealthKit interactions through an `AppleHealthServicing` boundary. App state and views depend on the protocol, not directly on HealthKit APIs.
- iOS normalizes HealthKit reads into backend payloads before upload. Payloads use stable metric types, categories, units, source, time ranges, values, and metadata.
- Backend stores Apple Health samples separately from existing manual meals, weights, exercises, and notifications.
- Backend sample ingestion uses idempotent upsert semantics keyed by user, metric type, source, start time, and end time.
- Backend exposes Health Data endpoints for sample sync, dashboard summary, report generation, report listing, and latest report context.
- Reports are persisted as structured records with kind, period, summary, metrics, findings, recommendations, risks, and coverage.
- Report generation is deterministic and rules-based for the first implementation so tests can verify behavior without a live LLM.
- Coach Agent instructions inject a compact latest-report context block when a report exists.
- The dedicated iOS Health Data route replaces the current "健康分析" sidebar destination, which currently points to the creation screen.
- Report chat actions open Chat and send a suggested prompt referencing the selected report.
- HealthKit authorization, sync status, dashboard state, and report state are explicit app state properties so state tests can cover the user flow.
- The UI follows the existing Health Pilot product system: near-white surfaces, SF Symbols, compact rows, existing blue accent, no health-green dashboard palette, no oversized metric-card layout.

## Testing Decisions

- Backend tests should validate public behavior through API and module calls, not private implementation details.
- Backend ingestion tests cover first sync, duplicate sync, and mixed metric payloads.
- Backend dashboard tests cover aggregation for activity, sleep, body, and vitals.
- Backend report tests cover daily and weekly report generation, data coverage, recommendations, and missing-data handling.
- Backend Chat tests cover latest report context injection into Coach Agent instructions.
- iOS state tests use fake HealthKit and assistant services, not real HealthKit data.
- iOS tests cover Health Data route navigation, authorization states, sync success, sync failure, report loading, and report-to-chat prompt dispatch.
- Existing state scenario verification remains a regression gate.
- Visual behavior should be verified by building/running the iOS app or state scenario script enough to ensure the new page compiles and key states are reachable.

## Out of Scope

- Writing samples back to Apple Health.
- Clinical diagnosis, medication advice, or emergency interpretation.
- Full Apple Health type coverage in the first UI implementation.
- Background delivery observers and long-running background sync.
- Cloud account identity beyond the existing `user_id` model.
- A chart-heavy analytics dashboard that replaces chat as the main product experience.

## Further Notes

The phrase "Apple Health data integration" is interpreted as an expandable HealthKit integration architecture plus a complete first version for the Health Pilot core data families. Additional HealthKit types should be added through the same sample contract and descriptors, not by creating new bespoke tables and UI flows for each metric.
