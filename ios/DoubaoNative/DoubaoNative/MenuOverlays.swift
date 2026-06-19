import SwiftUI

struct ToolMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        MenuSurface {
            VStack(alignment: .leading, spacing: 8) {
                Text("健康信息")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 2)

                ForEach(state.tools) { tool in
                    Button {
                        state.selectTool(tool)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: tool.symbol)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(DS.blue)
                                .frame(width: 28, height: 28)
                                .background(DS.softBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(tool.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(DS.text)
                                    .lineLimit(1)
                                Text(tool.subtitle)
                                    .font(.system(size: 11))
                                    .foregroundStyle(DS.secondary)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(DS.tertiary)
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 50)
                        .background(DS.chip)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .accessibilityIdentifier("menu.chat-tools")
    }
}

struct ModelMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        MenuSurface {
            VStack(spacing: 0) {
                ForEach(state.models) { model in
                    IconLabelRow(
                        symbol: model.id == "fast" ? "bolt.fill" : model.id == "expert" ? "brain.head.profile" : "briefcase",
                        title: model.title,
                        subtitle: model.subtitle,
                        selected: state.selectedModel == model
                    ) {
                        state.selectModel(model)
                    }
                }
            }
        }
        .accessibilityIdentifier("menu.chat-models")
    }
}

struct CreationModelMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        MenuSurface {
            VStack(alignment: .leading, spacing: 4) {
                Text("模型")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
                    .padding(.horizontal, 14)
                    .padding(.top, 2)

                IconLabelRow(
                    symbol: "sparkles",
                    title: "Seedance 2.0 Fast",
                    selected: true
                ) {
                    state.activeOverlay = nil
                }
            }
        }
        .accessibilityIdentifier("menu.creation-model")
    }
}

struct CreationVideoDurationMenuView: View {
    @EnvironmentObject private var state: AppState
    private let durations = ["5s", "10s"]

    var body: some View {
        MenuSurface {
            VStack(spacing: 0) {
                Text("时长")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 2)
                    .frame(height: 30)

                ForEach(durations, id: \.self) { duration in
                    Button {
                        state.selectCreationVideoDuration(duration)
                    } label: {
                        HStack {
                            Text(duration)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DS.text)
                            Spacer()
                            if state.creationVideoDuration == duration {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(DS.text)
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityIdentifier("menu.creation-video-duration")
    }
}

struct CreationVideoMoreMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        MenuSurface {
            VStack(spacing: 0) {
                Button {
                    state.activeOverlay = .creationVideoRatio
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle")
                            .font(.system(size: 13, weight: .medium))
                            .frame(width: 16)
                        Text("比例 \(state.creationVideoRatio)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DS.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(DS.tertiary)
                    }
                    .foregroundStyle(DS.text)
                    .padding(.horizontal, 14)
                    .frame(height: 38)
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityIdentifier("menu.creation-video-more")
    }
}

struct CreationVideoRatioMenuView: View {
    @EnvironmentObject private var state: AppState
    private let ratios = ["1:1", "3:4", "4:3", "9:16", "16:9", "21:9"]

    var body: some View {
        MenuSurface {
            VStack(spacing: 0) {
                Text("比例")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 2)
                    .frame(height: 30)

                ForEach(ratios, id: \.self) { ratio in
                    Button {
                        state.selectCreationVideoRatio(ratio)
                    } label: {
                        HStack {
                            Text(ratio)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DS.text)
                            Spacer()
                            if state.creationVideoRatio == ratio {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(DS.text)
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityIdentifier("menu.creation-video-ratio")
    }
}

struct CreationMoreMenuView: View {
    enum SelectedItem {
        case model
        case ratio
        case style
    }

    @EnvironmentObject private var state: AppState
    let selectedItem: SelectedItem?

    init(selectedItem: SelectedItem? = nil) {
        self.selectedItem = selectedItem
    }

    var body: some View {
        MenuSurface {
            VStack(spacing: 0) {
                moreRow(symbol: "sparkles", title: state.creationImageModel, showsChevron: true, selected: selectedItem == .model) {
                    state.activeOverlay = .creationImageModel
                }
                moreRow(symbol: "rectangle", title: creationRatioTitle, showsChevron: true, selected: selectedItem == .ratio) {
                    state.activeOverlay = .creationRatio
                }
                moreRow(symbol: "circle.hexagongrid", title: creationStyleTitle, showsChevron: true, selected: selectedItem == .style) {
                    state.activeOverlay = .creationStyle
                }
            }
        }
        .accessibilityIdentifier("menu.creation-more")
    }

    private var creationRatioTitle: String {
        if let ratio = state.creationImageRatio {
            return "比例 \(ratio)"
        }
        return "比例"
    }

    private var creationStyleTitle: String {
        if let style = state.creationImageStyle {
            return "风格 \(style)"
        }
        return "风格"
    }

    private func moreRow(symbol: String, title: String, showsChevron: Bool, selected: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 16)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.text)
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(DS.tertiary)
                }
            }
            .foregroundStyle(DS.text)
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(selected ? Color.black.opacity(0.055) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

struct ImageModelMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        MenuSurface {
            VStack(spacing: 0) {
                Text("模型")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 2)
                    .frame(height: 32)

                ForEach(CreationImageOptions.models, id: \.self) { model in
                    Button {
                        state.selectCreationImageModel(model)
                    } label: {
                        HStack(spacing: 10) {
                            Text(model)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DS.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                            Spacer()
                            if model == state.creationImageModel {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(DS.text)
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityIdentifier("menu.creation-image-model")
    }
}

struct RatioMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        MenuSurface {
            VStack(spacing: 0) {
                Text("比例")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 2)
                    .frame(height: 30)

                ForEach(CreationImageOptions.ratios) { ratio in
                    Button {
                        state.selectCreationImageRatio(ratio.value)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: state.creationImageRatio == ratio.value ? "checkmark.square" : "square")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(state.creationImageRatio == ratio.value ? DS.blue : DS.text)

                            Text(ratio.label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DS.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.76)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityIdentifier("menu.creation-ratio")
    }
}

struct StyleMenuView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        MenuSurface {
            VStack(spacing: 0) {
                Text("风格")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 2)
                    .frame(height: 32)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(CreationImageOptions.styles.enumerated()), id: \.element) { index, style in
                            Button {
                                state.selectCreationImageStyle(style)
                            } label: {
                                HStack(spacing: 10) {
                                    styleThumb(index)
                                        .frame(width: 24, height: 24)
                                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                    Text(style)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(DS.text)
                                    Spacer()
                                    if state.creationImageStyle == style {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(DS.text)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .frame(height: 38)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 494)
                .scrollIndicators(.hidden)
            }
        }
        .accessibilityIdentifier("menu.creation-style")
    }

    private func styleThumb(_ index: Int) -> some View {
        LinearGradient(
            colors: thumbColors(index),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func thumbColors(_ index: Int) -> [Color] {
        switch index {
        case 0: [Color(red: 0.68, green: 0.42, blue: 0.28), Color(red: 0.18, green: 0.42, blue: 0.32)]
        case 1: [Color(red: 0.10, green: 0.20, blue: 0.32), Color(red: 0.80, green: 0.50, blue: 0.35)]
        case 2: [Color(red: 0.76, green: 0.15, blue: 0.13), Color(red: 0.96, green: 0.78, blue: 0.46)]
        case 3: [Color(red: 0.23, green: 0.48, blue: 0.95), Color(red: 0.98, green: 0.56, blue: 0.66)]
        case 4: [Color(red: 0.40, green: 0.34, blue: 0.28), Color(red: 0.86, green: 0.82, blue: 0.70)]
        default: [Color(red: 0.18, green: 0.12, blue: 0.34), Color(red: 0.80, green: 0.24, blue: 0.82)]
        }
    }
}
