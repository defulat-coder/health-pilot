import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var state: AppState

    private let suggestionRows = [
        ["帮我建立减脂健康档案"],
        ["今天还剩多少热量？", "帮我记录午餐：一碗黄焖鸡米饭"],
        ["本周体重趋势怎么样？", "今晚适合做什么运动？"]
    ]

    var body: some View {
        VStack(spacing: 0) {
            TopHeaderView(
                title: state.chatTitle,
                subtitle: "AI 生成可能有误 请核实",
                showTitleEdit: !state.messages.isEmpty,
                showShare: !state.messages.isEmpty
            )

            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        if state.messages.isEmpty {
                            emptyState
                        } else if state.chatTranscriptFocus == .followupTop {
                            followupTopSnapshot
                        } else if state.chatTranscriptFocus == .followupBottom {
                            followupBottomSnapshot
                        } else {
                            messageList
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 140)
                }
                .scrollIndicators(.hidden)

                ComposerView()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                if state.chatTranscriptFocus == .followupTop {
                    scrollToBottomButton
                        .padding(.bottom, 128)
                }
            }
        }
        .background(DS.background.ignoresSafeArea())
        .accessibilityIdentifier("screen.chat")
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 194)

            Text("有什么我能帮你的吗？")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(DS.text)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                ForEach(suggestionRows, id: \.self) { row in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { item in
                                suggestionChip(item)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }

            Spacer(minLength: 260)
        }
        .accessibilityIdentifier("chat.empty-state")
    }

    private func suggestionChip(_ item: String) -> some View {
        Button {
            state.sendSuggestedPrompt(item)
        } label: {
            Text(item)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(DS.text)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .frame(height: 42)
                .background(DS.chip)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var messageList: some View {
        LazyVStack(spacing: 16) {
            ForEach(state.messages) { message in
                HStack {
                    if message.role == .assistant {
                        VStack(alignment: .leading, spacing: 12) {
                            assistantBubble(message.text)
                            if let followups = greetingFollowups(for: message.text) {
                                replyFollowups(followups)
                            }
                        }
                        Spacer(minLength: 42)
                    } else {
                        Spacer(minLength: 42)
                        userBubble(message.text)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 18)
        .accessibilityIdentifier("chat.message-list")
    }

    private func userBubble(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundStyle(DS.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(DS.chip)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func assistantBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(text.isEmpty ? "正在思考..." : text)
                .font(.system(size: 16))
                .foregroundStyle(DS.text)
                .lineSpacing(4)
                .padding(.top, 4)
        }
    }

    private func shouldShowGreetingFollowups(_ text: String) -> Bool {
        greetingFollowups(for: text) != nil
    }

    private func greetingFollowups(for text: String) -> [String]? {
        if text.contains(ChatReplyFixture.greetingShort) {
            return ChatReplyFixture.shortFollowups
        }
        if text.contains("Health Pilot 健康助手") {
            return ChatReplyFixture.helpfulFollowups
        }
        return nil
    }

    private func replyFollowups(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items, id: \.self) { item in
                followupButton(item)
            }

            healthInfoButton
        }
        .accessibilityIdentifier("chat.greeting-followups")
    }

    private func followupButton(_ item: String) -> some View {
        Button {
            state.sendSuggestedPrompt(item)
        } label: {
            HStack(spacing: 8) {
                Text(item)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
            }
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(DS.chip)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var healthInfoButton: some View {
        Button {
            state.openHealthCard(.profile)
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(DS.softBlue)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(DS.blue)
                    )
                Text("打开更多里的健康信息卡片，查看当前档案")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(Color.white.opacity(0.86))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var followupTopSnapshot: some View {
        VStack(alignment: .leading, spacing: 0) {
            capabilitiesTopView
                .padding(.horizontal, 16)
        }
        .padding(.top, 12)
        .accessibilityIdentifier("chat.followup-top")
    }

    private var followupBottomSnapshot: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("1. 今日热量、蛋白质、碳水和脂肪摄入；")
            Text("2. 运动时长、运动消耗和热量缺口；")
            Text("3. 主动提醒、打卡提示和未读关怀。")

            Text("五、健康建议")
                .fontWeight(.semibold)
                .padding(.top, 10)
            Text("1. 根据当前档案给出饮食、运动和作息建议；")
            Text("2. 信息不足时会追问份量、时间和目标；")
            Text("3. 涉及医疗诊断或用药时会建议咨询医生。")

            Text("六、信息入口")
                .fontWeight(.semibold)
                .padding(.top, 10)
            Text("• 输入框下方的“更多”里可以查看个人档案、今日健康、营养摄入、运动消耗和主动提醒；")
            Text("• 你也可以直接在聊天里补充或更新健康信息。")
            Text("你想先记录一餐，还是先完善个人档案？")
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(ChatReplyFixture.capabilityFollowups, id: \.self) { item in
                    followupButton(item)
                }
                healthInfoButton
            }
            .padding(.top, 6)
        }
        .font(.system(size: 16))
        .foregroundStyle(DS.text)
        .lineSpacing(4)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .accessibilityIdentifier("chat.followup-bottom")
    }

    private var capabilitiesTopView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("我是 Health Pilot 健康助手，可以帮你围绕减脂目标记录、分析和提醒。\n分大类给你说清楚：")
            Text("一、健康档案")
                .fontWeight(.semibold)
                .padding(.top, 10)
            Text("1. 身高、体重、年龄、性别、活动量和目标体重；")
            Text("2. 自动估算 TDEE 和建议每日摄入；")
            Text("3. 支持在聊天中持续更新个人信息。")
            Text("二、饮食记录")
                .fontWeight(.semibold)
                .padding(.top, 10)
            Text("1. 用自然语言记录三餐、加餐和饮品；")
            Text("2. 估算热量、蛋白质、碳水和脂肪；")
            Text("3. 图片、菜单或外卖截图可辅助分析。")
            Text("三、体重与运动")
                .fontWeight(.semibold)
                .padding(.top, 10)
            Text("1. 记录体重、体脂和运动消耗；")
            Text("2. 分析趋势体重和阶段进展；")
            Text("3. 根据当天数据给出下一步建议。")
        }
        .font(.system(size: 16))
        .foregroundStyle(DS.text)
        .lineSpacing(4)
    }

    private var scrollToBottomButton: some View {
        Button { } label: {
            Image(systemName: "arrow.down")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DS.text)
                .frame(width: 38, height: 38)
                .background(Color.white)
                .clipShape(Circle())
                .smallShadow()
        }
        .buttonStyle(.plain)
    }
}
