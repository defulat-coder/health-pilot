import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.72, green: 0.90, blue: 1.0), Color(red: 0.16, green: 0.43, blue: 0.98)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("H")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 22, height: 22)

                    Text("Health Pilot")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(DS.text)
                }
                .padding(.horizontal, 18)
                .frame(height: 48, alignment: .leading)

                sidebarRow(symbol: "plus.message", title: "新对话", selected: state.route == .chat) {
                    state.startNewChat()
                }

                sidebarRow(symbol: "doc.badge.plus", title: "新健康记录", shortcut: "⌘K") {
                    state.startOfficeTask()
                }

                sidebarRow(symbol: "chart.line.uptrend.xyaxis", title: "健康分析", selected: state.route == .healthData) {
                    state.navigate(to: .healthData)
                }

                Text("历史对话")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DS.tertiary)
                    .padding(.horizontal, 22)
                    .padding(.top, 22)
                    .padding(.bottom, 8)

                VStack(spacing: 2) {
                    ForEach(state.chatHistory) { item in
                        historyRow(item)
                    }
                }

                Spacer()

                if state.showAboutPopover {
                    AboutPopoverView()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                }

                HStack(spacing: 12) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.16)) {
                            state.showAboutPopover.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                            Text("关于 Health Pilot")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DS.secondary)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(height: 48)
            }
            .frame(width: 280)
            .frame(maxHeight: .infinity)
            .padding(.top, 6)
            .padding(.bottom, 12)
            .background(DS.sidebar.ignoresSafeArea())
        }
        .accessibilityIdentifier("sidebar.drawer")
    }

    private func historyRow(_ item: ChatHistoryItem) -> some View {
        Button {
            state.openHistoryConversation(item)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "message")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 18)
                    .foregroundStyle(DS.secondary)

                Text(item.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.text)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(item.title == state.chatTitle && state.route == .chat ? Color.white : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))
            .padding(.horizontal, 10)
        }
        .buttonStyle(.plain)
    }

    private func sidebarRow(
        symbol: String,
        title: String,
        shortcut: String? = nil,
        selected: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                if let shortcut {
                    Text(shortcut)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.tertiary)
                }
            }
            .foregroundStyle(DS.text)
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(selected ? Color.white : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous))
            .padding(.horizontal, 10)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 1)
    }
}

struct AboutPopoverView: View {
    private let legalLines = [
        "北京市西城区阜成门外大街31号4层408D",
        "京ICP备2023020373号-1",
        "京B2-20241987",
        "京网文〔2024〕4578-215号",
        "北京春田知韵科技有限公司",
        "京公网安备11010802045808"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(["联系我们", "用户协议", "隐私政策", "侵权投诉"], id: \.self) { item in
                Text(item)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.text)
                    .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
            }

            Rectangle()
                .fill(DS.divider)
                .frame(height: 1)
                .padding(.vertical, 8)

            ForEach(legalLines, id: \.self) { line in
                Text(line)
                    .font(.system(size: 11))
                    .foregroundStyle(DS.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 3)
            }
        }
        .padding(14)
        .frame(width: 252, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .smallShadow()
        .accessibilityIdentifier("sidebar.about-popover")
    }
}
