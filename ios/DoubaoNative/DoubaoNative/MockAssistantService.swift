import Foundation

protocol AssistantServicing {
    func chatStream(for prompt: String) -> AsyncStream<String>
    func healthSummary(userID: String) async throws -> HealthSummary
    func syncAppleHealthSamples(userID: String, samples: [AppleHealthSamplePayload]) async throws -> AppleHealthSyncResult
    func healthDashboard(userID: String) async throws -> HealthDataDashboard
    func healthReports(userID: String) async throws -> [HealthAnalysisReport]
    func generateHealthReport(userID: String, kind: String) async throws -> HealthAnalysisReport
    func create(mode: CreationMode, prompt: String) async -> CreationResult
}

struct MockAssistantService: AssistantServicing {
    func chatStream(for prompt: String) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                let chunks: [String]
                if prompt == "你好" {
                    chunks = ["你好呀～", "我是你的 Health Pilot 健康助手，可以帮你记录饮食、体重和运动。"]
                } else if prompt == "你能做些什么？" {
                    chunks = [ChatReplyFixture.capabilitiesAnswer]
                } else {
                    chunks = [
                        "我会先理解你的目标：",
                        prompt,
                        "。接下来可以把它拆成今天可执行的步骤，并在需要时继续细化。"
                    ]
                }

                for chunk in chunks {
                    try? await Task.sleep(nanoseconds: 220_000_000)
                    continuation.yield(chunk)
                }
                continuation.finish()
            }
        }
    }

    func healthSummary(userID: String) async throws -> HealthSummary {
        HealthSummary.placeholder
    }

    func syncAppleHealthSamples(userID: String, samples: [AppleHealthSamplePayload]) async throws -> AppleHealthSyncResult {
        AppleHealthSyncResult(
            userID: userID,
            received: samples.count,
            inserted: samples.count,
            updated: 0,
            total: samples.count,
            syncedAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func healthDashboard(userID: String) async throws -> HealthDataDashboard {
        HealthDataDashboard(
            userID: userID,
            connection: HealthDataConnection(status: "connected", sampleCount: 4, lastSyncAt: "2026-06-19T08:00:00"),
            metrics: HealthDataMetrics(
                activity: HealthActivityMetrics(steps: 8600, activeEnergyKcal: 320, exerciseMinutes: 28, workouts: 1),
                sleep: HealthSleepMetrics(asleepMinutes: 420),
                vitals: HealthVitalsMetrics(heartRateAvg: 72, restingHeartRate: 62),
                body: HealthBodyMetrics(weightKG: 72.4, bodyFatPct: 21.4, heightCM: 175)
            ),
            coverage: ["activity": "present", "sleep": "present", "vitals": "present", "body": "present"]
        )
    }

    func healthReports(userID: String) async throws -> [HealthAnalysisReport] {
        [.sample]
    }

    func generateHealthReport(userID: String, kind: String) async throws -> HealthAnalysisReport {
        HealthAnalysisReport.sample
    }

    func create(mode: CreationMode, prompt: String) async -> CreationResult {
        try? await Task.sleep(nanoseconds: 320_000_000)
        let title = mode == .image ? "已生成图像方案" : "已生成视频脚本"
        return CreationResult(mode: mode, prompt: prompt, title: title)
    }
}
