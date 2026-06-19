import SwiftUI

struct HeaderIconButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DS.text)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct CapsuleTextButton: View {
    let title: String
    var symbol: String?
    var dark = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: symbol == nil ? 0 : 5) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(dark ? Color.white : DS.text)
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(dark ? Color.black : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ToastBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 0.33, green: 0.46, blue: 0.68))

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DS.text)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 56)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(DS.divider, lineWidth: 0.5)
        )
        .smallShadow()
        .accessibilityIdentifier("toast.banner")
    }
}

struct TopHeaderView: View {
    @EnvironmentObject private var state: AppState
    var title: String
    var subtitle: String?
    var showNewChat: Bool = false
    var showTitleEdit: Bool = false
    var showShare: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            HeaderIconButton(symbol: "line.3.horizontal") {
                state.closeTransientOverlays()
                state.isSidebarOpen = true
            }

            if showNewChat {
                HeaderIconButton(symbol: "square.and.pencil") {
                    state.startNewChat()
                }
            }

            if showTitleEdit {
                HeaderIconButton(symbol: "square.and.pencil") {
                    state.openTitleEditor()
                }
            }

            if showShare {
                ZStack(alignment: .top) {
                    HeaderIconButton(symbol: "square.and.arrow.up") {
                        state.shareConversation()
                    }
                    .accessibilityLabel("分享对话")

                    if state.showShareTooltip {
                        Text("分享对话")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 9)
                            .frame(height: 32)
                            .background(Color.black.opacity(0.88))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .offset(y: 35)
                            .accessibilityIdentifier("header.share-tooltip")
                    }
                }
                .frame(width: 36, height: 36)
                .zIndex(2)
            }

            Spacer(minLength: 4)

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.text)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(DS.tertiary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 40)
        }
        .padding(.horizontal, 10)
        .frame(height: 58)
        .background(DS.background)
    }
}

struct TitleEditModalView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture { state.showTitleEditor = false }

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("编辑对话名称")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(DS.text)
                    Spacer()
                    Button {
                        state.showTitleEditor = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(DS.secondary)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 24)

                Spacer().frame(height: 5)

                TextField("输入名称", text: $state.titleDraft)
                    .font(.system(size: 14))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .stroke(Color.black.opacity(0.14), lineWidth: 0.5)
                    )

                Spacer().frame(height: 25)

                HStack(spacing: 12) {
                    Spacer()
                    Button {
                        state.showTitleEditor = false
                    } label: {
                        Text("取消")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(DS.text)
                            .frame(width: 80, height: 38)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        state.confirmTitleEdit()
                    } label: {
                        Text("确定")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.white)
                            .frame(width: 80, height: 38)
                            .background(Color(red: 0, green: 0.4, blue: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 22)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .frame(width: min(UIScreen.main.bounds.width - 40, 350))
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.10), lineWidth: 0.5)
            )
            .contentShape(Rectangle())
            .onTapGesture { }
            .accessibilityIdentifier("chat.title-editor")
        }
    }
}

struct HealthInfoPanelView: View {
    @EnvironmentObject private var state: AppState
    let card: HealthCardKind

    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture { state.dismissHealthCard() }

            VStack(alignment: .leading, spacing: 14) {
                header

                if state.isLoadingHealthSummary {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("正在读取健康信息...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DS.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    if let error = state.healthSummaryError {
                        errorBanner(error)
                    }
                    cardContent
                }

                Button {
                    state.refreshHealthSummary()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .semibold))
                        Text("刷新健康数据")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(DS.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(DS.softBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(width: min(UIScreen.main.bounds.width - 36, 356))
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
            )
            .smallShadow()
            .contentShape(Rectangle())
            .onTapGesture { }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: card.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DS.blue)
                .frame(width: 34, height: 34)
                .background(DS.softBlue)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(card.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.text)
                Text(card.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(DS.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                state.dismissHealthCard()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DS.secondary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        switch card {
        case .profile:
            profileContent
        case .today:
            todayContent
        case .nutrition:
            nutritionContent
        case .activity:
            activityContent
        case .reminders:
            remindersContent
        }
    }

    private var profileContent: some View {
        VStack(spacing: 8) {
            if !state.healthSummary.profile.isComplete {
                note("还没有完整健康档案。你可以在聊天里告诉我身高、体重、年龄、性别、活动量和目标体重，我会帮你建立档案。")
            }
            metricRow("身高", value(state.healthSummary.profile.heightCM, unit: "cm"))
            metricRow("体重", value(state.healthSummary.profile.weightKG, unit: "kg"))
            metricRow("年龄", state.healthSummary.profile.age.map { "\($0)岁" } ?? "未填写")
            metricRow("性别", genderText(state.healthSummary.profile.gender))
            metricRow("活动量", state.healthSummary.profile.activityLevel ?? "未填写")
            metricRow("TDEE", value(state.healthSummary.profile.tdeeKcal, unit: "kcal"))
            metricRow("建议每日摄入", value(state.healthSummary.profile.dailyCalorieTargetKcal, unit: "kcal"))
            metricRow("目标体重", value(state.healthSummary.profile.targetWeightKG, unit: "kg"))
        }
    }

    private var todayContent: some View {
        VStack(spacing: 8) {
            metricRow("日期", state.healthSummary.today.date.isEmpty ? "今天" : state.healthSummary.today.date)
            metricRow("已记录餐次", "\(state.healthSummary.today.mealCount)餐")
            metricRow("已摄入", value(state.healthSummary.today.caloriesConsumedKcal, unit: "kcal"))
            metricRow("目标摄入", value(state.healthSummary.today.calorieTargetKcal, unit: "kcal"))
            metricRow("剩余额度", value(state.healthSummary.today.remainingCaloriesKcal, unit: "kcal"))
            metricRow("运动消耗", value(state.healthSummary.today.exerciseCaloriesKcal, unit: "kcal"))
        }
    }

    private var nutritionContent: some View {
        VStack(spacing: 8) {
            metricRow("蛋白质", "\(rounded(state.healthSummary.today.proteinG))g / \(rounded(state.healthSummary.today.proteinTargetG))g")
            metricRow("碳水", value(state.healthSummary.today.carbsG, unit: "g"))
            metricRow("脂肪", value(state.healthSummary.today.fatG, unit: "g"))
            note("蛋白质目标会优先基于档案体重计算；未建档时默认按 70kg 估算。")
        }
    }

    private var activityContent: some View {
        VStack(spacing: 8) {
            metricRow("运动时长", "\(state.healthSummary.today.exerciseMinutes)分钟")
            metricRow("运动消耗", value(state.healthSummary.today.exerciseCaloriesKcal, unit: "kcal"))
            metricRow("热量缺口", value(state.healthSummary.today.remainingCaloriesKcal, unit: "kcal"))
            note("运动记录会和基础代谢、饮食记录一起影响当天热量缺口。")
        }
    }

    private var remindersContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if state.healthSummary.notifications.isEmpty {
                note("暂无未读主动提醒。后端产生定时打卡、热量预警或沉默唤醒后，会显示在这里。")
            } else {
                ForEach(state.healthSummary.notifications) { notification in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(notification.triggerName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(DS.text)
                        Text(notification.content)
                            .font(.system(size: 13))
                            .foregroundStyle(DS.secondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DS.chip)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
            }
        }
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(DS.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DS.text)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 36)
        .background(DS.chip)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(DS.secondary)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.chip)
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private func errorBanner(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color(red: 0.54, green: 0.20, blue: 0.16))
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 1.0, green: 0.94, blue: 0.92))
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private func value(_ number: Double?, unit: String) -> String {
        guard let number else { return "未填写" }
        return "\(rounded(number))\(unit)"
    }

    private func value(_ number: Double, unit: String) -> String {
        "\(rounded(number))\(unit)"
    }

    private func rounded(_ number: Double) -> String {
        if number.rounded() == number {
            return "\(Int(number))"
        }
        return String(format: "%.1f", number)
    }

    private func genderText(_ gender: String?) -> String {
        switch gender {
        case "male": "男"
        case "female": "女"
        case let value?: value
        case nil: "未填写"
        }
    }
}

struct MenuSurface<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: DS.menuRadius, style: .continuous))
            .smallShadow()
    }
}

struct IconLabelRow: View {
    let symbol: String
    let title: String
    var subtitle: String?
    var selected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 20)
                    .foregroundStyle(DS.text)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DS.text)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(DS.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(DS.blue)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: subtitle == nil ? 36 : 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
