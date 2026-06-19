import SwiftUI

struct HealthDataView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            TopHeaderView(title: "健康数据", subtitle: "Apple Health 与 Health Pilot 记录", showNewChat: true)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    connectionSection
                    metricSection
                    reportSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .background(DS.background.ignoresSafeArea())
        .task {
            state.refreshHealthData()
        }
        .accessibilityIdentifier("screen.health-data")
    }

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: connectionSymbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DS.blue)
                    .frame(width: 34, height: 34)
                    .background(DS.softBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple 健康")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(DS.text)
                    Text(connectionSubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(DS.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            if let error = state.healthData.error {
                Text(error)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DS.text)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DS.chip)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            HStack(spacing: 10) {
                healthActionButton(
                    title: state.healthData.isSyncing ? "同步中" : "同步 Apple 健康",
                    symbol: "arrow.triangle.2.circlepath"
                ) {
                    state.syncAppleHealthData()
                }
                .disabled(state.healthData.isSyncing)

                healthActionButton(title: "生成日报", symbol: "doc.text.magnifyingglass") {
                    state.generateAppleHealthReport(kind: "daily")
                }
                .disabled(state.healthData.isGeneratingReport)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(DS.divider, lineWidth: 0.5)
        )
    }

    private var metricSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("概览")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DS.text)

            metricRow(symbol: "figure.walk", title: "活动", primary: "\(state.healthData.dashboard.metrics.activity.steps) 步", detail: "活动能量 \(rounded(state.healthData.dashboard.metrics.activity.activeEnergyKcal)) kcal · 运动 \(state.healthData.dashboard.metrics.activity.exerciseMinutes) 分钟", coverage: state.healthData.dashboard.coverage["activity"])
            metricRow(symbol: "bed.double", title: "睡眠", primary: sleepText, detail: "来自 Apple 健康睡眠记录", coverage: state.healthData.dashboard.coverage["sleep"])
            metricRow(symbol: "heart.text.square", title: "生命体征", primary: restingHeartText, detail: "平均心率 \(optionalValue(state.healthData.dashboard.metrics.vitals.heartRateAvg, unit: "次/分"))", coverage: state.healthData.dashboard.coverage["vitals"])
            metricRow(symbol: "scalemass", title: "身体", primary: optionalValue(state.healthData.dashboard.metrics.body.weightKG, unit: "kg"), detail: "体脂 \(optionalValue(state.healthData.dashboard.metrics.body.bodyFatPct, unit: "%")) · 身高 \(optionalValue(state.healthData.dashboard.metrics.body.heightCM, unit: "cm"))", coverage: state.healthData.dashboard.coverage["body"])
        }
        .padding(.vertical, 2)
    }

    private var reportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("分析报告")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.text)
                Spacer()
                if state.healthData.isLoading {
                    ProgressView()
                }
            }

            if state.healthData.reports.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("还没有分析报告")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DS.text)
                    Text("同步 Apple 健康后生成日报，Chat 会基于报告继续分析。")
                        .font(.system(size: 13))
                        .foregroundStyle(DS.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                ForEach(state.healthData.reports) { report in
                    reportRow(report)
                }
            }
        }
    }

    private func metricRow(symbol: String, title: String, primary: String, detail: String, coverage: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DS.blue)
                .frame(width: 30, height: 30)
                .background(DS.softBlue)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    Text(coverage == "present" ? "已同步" : "缺数据")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DS.secondary)
                        .padding(.horizontal, 7)
                        .frame(height: 22)
                        .background(DS.chip)
                        .clipShape(Capsule())
                }
                Text(primary)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DS.text)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(DS.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func reportRow(_ report: HealthAnalysisReport) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DS.text)
                    Text("\(report.periodStart) ~ \(report.periodEnd)")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.secondary)
                }
                Spacer()
                Button {
                    state.chatAboutReport(report)
                } label: {
                    Image(systemName: "message.badge.waveform")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DS.blue)
                        .frame(width: 34, height: 34)
                        .background(DS.softBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Text(report.summary)
                .font(.system(size: 14))
                .foregroundStyle(DS.text)
                .lineLimit(3)

            if let first = report.recommendations.first {
                Text(first)
                    .font(.system(size: 13))
                    .foregroundStyle(DS.secondary)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func healthActionButton(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(DS.text)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(DS.chip)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var connectionSymbol: String {
        state.healthData.authorization == .authorized ? "heart.circle.fill" : "heart.circle"
    }

    private var connectionSubtitle: String {
        if let lastSync = state.healthData.dashboard.connection.lastSyncAt {
            return "\(state.healthData.authorization.label) · \(state.healthData.dashboard.connection.sampleCount) 条样本 · 最近同步 \(lastSync)"
        }
        return "\(state.healthData.authorization.label) · 授权后读取活动、睡眠、身体和生命体征数据"
    }

    private var sleepText: String {
        let minutes = state.healthData.dashboard.metrics.sleep.asleepMinutes
        return "\(minutes / 60) 小时 \(minutes % 60) 分钟"
    }

    private var restingHeartText: String {
        optionalValue(state.healthData.dashboard.metrics.vitals.restingHeartRate, unit: "次/分")
    }

    private func rounded(_ value: Double) -> String {
        String(format: "%.0f", value)
    }

    private func optionalValue(_ value: Double?, unit: String) -> String {
        guard let value else { return "暂无" }
        return "\(String(format: "%.1f", value)) \(unit)"
    }
}
