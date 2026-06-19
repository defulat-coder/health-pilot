import SwiftUI

struct CreationView: View {
    @EnvironmentObject private var state: AppState

    private let templateTitles = [
        "极简产品海报",
        "城市夜景插画",
        "清新头像",
        "品牌视觉稿",
        "电影感分镜",
        "社媒封面"
    ]

    var body: some View {
        if state.creationMode == .video {
            videoGenerationScreen
        } else {
            imageCreationScreen
        }
    }

    private var imageCreationScreen: some View {
        VStack(spacing: 0) {
            TopHeaderView(title: "AI 创作", showNewChat: true)

            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    Text("AI 创作")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(DS.text)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    Text("让创作随灵感而生")
                        .font(.system(size: 16))
                        .foregroundStyle(DS.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    creationComposer
                        .padding(.top, 26)

                    featureStrip
                        .padding(.top, 28)

                    resultSection
                        .padding(.top, 22)

                    templateGrid
                        .padding(.top, 28)
                        .padding(.bottom, 28)
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
        .background(DS.background.ignoresSafeArea())
        .accessibilityIdentifier("screen.creation")
    }

    private var videoGenerationScreen: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopHeaderView(title: "视频生成", showNewChat: true)

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "video")
                                .font(.system(size: 13, weight: .bold))
                            Text("视频生成")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(DS.text)
                        .padding(.top, 10)

                        Text("自由运镜，图片文字一键成片")
                            .font(.system(size: 19, weight: .regular))
                            .foregroundStyle(DS.text)
                            .padding(.bottom, 10)

                        ForEach(videoTemplateCards, id: \.title) { item in
                            videoTemplateCard(title: item.title)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 190)
                }
                .scrollIndicators(.hidden)
            }

            videoGenerationComposer
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
        }
        .background(DS.background.ignoresSafeArea())
        .accessibilityIdentifier("screen.creation-video")
    }

    private var creationComposer: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $state.creationPrompt)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.text)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .frame(height: 76)

                if state.creationPrompt.isEmpty {
                    Text(state.creationMode.placeholder)
                        .font(.system(size: 16))
                        .foregroundStyle(DS.tertiary)
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: 8) {
                if state.creationMode == .video {
                    videoComposerControls
                } else {
                    imageComposerControls
                }

                Spacer(minLength: 2)

                sendCreationButton
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .frame(height: 124)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DS.composerRadius, style: .continuous))
        .cardShadow()
        .accessibilityIdentifier("creation.composer")
    }

    private var imageComposerControls: some View {
        HStack(spacing: 8) {
            Picker("", selection: $state.creationMode) {
                ForEach(CreationMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 112, height: 34)

            referenceImagePill

            creationPill("", symbol: "ellipsis") {
                state.activeOverlay = state.activeOverlay == .creationMore ? nil : .creationMore
            }
            .frame(width: 42)
        }
    }

    private var videoComposerControls: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Picker("", selection: $state.creationMode) {
                    ForEach(CreationMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 112, height: 34)

                creationPill("上传图片", symbol: "photo") {
                    state.requestCreationVideoUpload()
                }
                .frame(width: 102)

                creationPill("Seedance 2.0 Fast", symbol: "sparkles") {
                    state.activeOverlay = state.activeOverlay == .creationModel ? nil : .creationModel
                }
                .frame(width: 150)

                creationPill(state.creationVideoDuration, symbol: "clock") {
                    state.activeOverlay = state.activeOverlay == .creationVideoDuration ? nil : .creationVideoDuration
                }
                .frame(width: 72)

                creationPill("", symbol: "ellipsis") {
                    state.activeOverlay = state.activeOverlay == .creationVideoMore ? nil : .creationVideoMore
                }
                .frame(width: 42)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var videoGenerationComposer: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                state.requestCreationVideoUpload()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DS.tertiary)
                    Text("上传图片")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DS.secondary)
                }
                .frame(width: 162, height: 52)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DS.divider, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $state.creationPrompt)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.text)
                    .scrollContentBackground(.hidden)
                    .frame(height: 48)

                if state.creationPrompt.isEmpty {
                    Text(CreationMode.video.placeholder)
                        .font(.system(size: 16))
                        .foregroundStyle(DS.tertiary)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: 8) {
                creationPill("Seedance 2.0 Fast", symbol: "sparkles") {
                    state.activeOverlay = state.activeOverlay == .creationModel ? nil : .creationModel
                }
                .frame(width: 168)

                creationPill("", symbol: "ellipsis") {
                    state.activeOverlay = state.activeOverlay == .creationVideoMore ? nil : .creationVideoMore
                }
                .frame(width: 42)

                Spacer()

                sendCreationButton
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .frame(height: 166)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DS.composerRadius, style: .continuous))
        .cardShadow()
        .accessibilityIdentifier("creation.video-composer")
    }

    private var referenceImagePill: some View {
        ZStack(alignment: .top) {
            creationPill("参考图", symbol: "plus") {
                state.requestCreationReferenceImage()
            }

            if state.showCreationReferenceTooltip {
                Text("最多支持上传 10 张图片")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color.black.opacity(0.88))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .offset(y: -36)
                    .transition(.opacity)
                    .accessibilityIdentifier("creation.reference-tooltip")
            }
        }
    }

    private var sendCreationButton: some View {
        Button {
            let isEmpty = state.creationPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if state.creationMode == .image && isEmpty {
                state.requestCreationVoiceInput()
            } else {
                state.sendCreation()
            }
        } label: {
            let isEmpty = state.creationPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            Image(systemName: state.creationMode == .video || !isEmpty ? "arrow.up" : "mic.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isEmpty ? DS.text.opacity(0.45) : Color.white)
                .frame(width: 34, height: 34)
                .background(isEmpty ? DS.chip : DS.blue)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(state.creationMode == .video && state.creationPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private func creationPill(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .semibold))
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
            .foregroundStyle(DS.text)
            .padding(.horizontal, title.isEmpty ? 0 : 9)
            .frame(height: 34)
            .frame(minWidth: title.isEmpty ? 34 : nil)
            .background(DS.chip)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var featureStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(CreationFeatureItem.defaults.enumerated()), id: \.element.title) { index, item in
                    featureCard(title: item.title, symbol: item.symbol, index: index)
                }
            }
        }
    }

    private func featureCard(title: String, symbol: String, index: Int) -> some View {
        Button {
            state.requestCreationFeatureAction()
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DS.text)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    generatedTile(index: index + 2)
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .frame(width: 54, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .frame(width: 132, height: 70)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(DS.divider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var resultSection: some View {
        if state.isCreating || !state.creationResults.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("生成结果")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DS.text)

                if state.isCreating {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("正在生成...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DS.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .center)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                ForEach(state.creationResults) { result in
                    HStack(spacing: 12) {
                        generatedThumbnail(for: result)
                            .frame(width: 74, height: 74)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(result.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(DS.text)
                            Text(result.prompt)
                                .font(.system(size: 13))
                                .foregroundStyle(DS.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .accessibilityIdentifier("creation.results")
        }
    }

    private var templateGrid: some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Array(templateTitles.enumerated()), id: \.offset) { index, title in
                    ZStack(alignment: .bottomLeading) {
                        generatedTile(index: index)
                            .frame(height: index % 3 == 0 ? 238 : 194)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                            .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 1)
                            .padding(10)
                    }
                }
            }
        }
        .accessibilityIdentifier("creation.templates")
    }

    private var videoTemplateCards: [(title: String, height: CGFloat)] {
        [
            ("极速飞驰", 226),
            ("浪漫邂逅", 226),
            ("电影运镜", 226)
        ]
    }

    private func videoTemplateCard(title: String) -> some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.black)
                .frame(height: 186)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )

            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(DS.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(red: 0.985, green: 0.965, blue: 0.995))
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(red: 0.96, green: 0.90, blue: 0.99), lineWidth: 1)
        )
        .accessibilityIdentifier("creation.video-template-card")
    }

    private func generatedThumbnail(for result: CreationResult) -> some View {
        ZStack {
            LinearGradient(
                colors: result.mode == .image ? [Color.cyan.opacity(0.8), Color.indigo.opacity(0.7)] : [Color.orange.opacity(0.8), Color.pink.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: result.mode == .image ? "photo" : "video")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.white)
        }
    }

    private func generatedTile(index: Int) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: tileColors(index),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 74, height: 74)
                .offset(x: 56, y: -46)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.18))
                .frame(width: 92, height: 46)
                .rotationEffect(.degrees(-9))
                .offset(x: -12, y: -18)

            Text("AI")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(10)
        }
    }

    private func tileColors(_ index: Int) -> [Color] {
        switch index % 6 {
        case 0: [Color(red: 0.15, green: 0.38, blue: 0.95), Color(red: 0.33, green: 0.76, blue: 0.88)]
        case 1: [Color(red: 0.08, green: 0.12, blue: 0.22), Color(red: 0.56, green: 0.38, blue: 0.82)]
        case 2: [Color(red: 0.20, green: 0.62, blue: 0.44), Color(red: 0.96, green: 0.78, blue: 0.42)]
        case 3: [Color(red: 0.78, green: 0.24, blue: 0.34), Color(red: 0.98, green: 0.72, blue: 0.38)]
        case 4: [Color(red: 0.18, green: 0.48, blue: 0.55), Color(red: 0.86, green: 0.92, blue: 0.78)]
        default: [Color(red: 0.42, green: 0.27, blue: 0.74), Color(red: 0.95, green: 0.47, blue: 0.66)]
        }
    }
}
