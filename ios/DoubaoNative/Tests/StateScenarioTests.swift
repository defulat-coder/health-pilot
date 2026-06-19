import Foundation

private struct ImmediateAssistantService: AssistantServicing {
    func chatStream(for prompt: String) -> AsyncStream<String> {
        AsyncStream { continuation in
            if prompt == "你好" {
                continuation.yield("你好呀～")
                continuation.yield("我是你的 Health Pilot 健康助手，可以帮你记录饮食、体重和运动。")
            } else if prompt == "你能做些什么？" {
                continuation.yield(ChatReplyFixture.capabilitiesAnswer)
            } else {
                continuation.yield("已收到：")
                continuation.yield(prompt)
            }
            continuation.finish()
        }
    }

    func healthSummary(userID: String) async throws -> HealthSummary {
        HealthSummary.placeholder
    }

    func syncAppleHealthSamples(userID: String, samples: [AppleHealthSamplePayload]) async throws -> AppleHealthSyncResult {
        AppleHealthSyncResult(userID: userID, received: samples.count, inserted: samples.count, updated: 0, total: samples.count, syncedAt: "2026-06-19T08:00:00")
    }

    func healthDashboard(userID: String) async throws -> HealthDataDashboard {
        HealthDataDashboard(
            userID: userID,
            connection: HealthDataConnection(status: "connected", sampleCount: 3, lastSyncAt: "2026-06-19T08:00:00"),
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
        CreationResult(
            mode: mode,
            prompt: prompt,
            title: mode == .image ? "测试图像结果" : "测试视频结果"
        )
    }
}

private struct ImmediateAppleHealthService: AppleHealthServicing {
    func authorizationState() async -> AppleHealthAuthorizationState {
        .authorized
    }

    func requestAuthorization() async throws -> AppleHealthAuthorizationState {
        .authorized
    }

    func collectSamples() async throws -> [AppleHealthSamplePayload] {
        [
            AppleHealthSamplePayload(
                type: "step_count",
                category: "activity",
                unit: "count",
                value: 8600,
                source: "com.apple.Health",
                startAt: Date(timeIntervalSince1970: 1_781_866_400),
                endAt: Date(timeIntervalSince1970: 1_781_870_000),
                metadata: [:]
            )
        ]
    }
}

@main
enum StateScenarioTests {
    private static var failures: [String] = []

    static func main() async {
        await MainActor.run {
            verifySnapshotFallbacks()
            verifyToolRouting()
            verifyModelSelection()
            verifyAttachmentImport()
            verifyCreationReferenceImage()
            verifyCreationFeatureAction()
            verifyCreationImageOptionSelection()
            verifyCreationVideoControls()
            verifyTitleEditing()
            verifyShareAction()
            verifyVoiceInputAction()
            verifyRateLimitMessage()
            verifyHistoryRouting()
        }

        await verifyAsyncActions()
        await verifyHealthDataActions()

        if failures.isEmpty {
            print("State scenario tests passed.")
        } else {
            FileHandle.standardError.write(Data((failures.joined(separator: "\n") + "\n").utf8))
            exit(1)
        }
    }

    @MainActor
    private static func verifySnapshotFallbacks() {
        verify("chat-share-login") { state in
            expect(state.route == .chat, "legacy share snapshot should stay on chat")
            expect(state.showShareTooltip, "share action should still expose share feedback")
            expect(state.messages.count == 2, "legacy share snapshot should keep conversation content")
        }

        verify("chat-rate-limit-login") { state in
            expect(state.route == .chat, "legacy rate-limit snapshot should stay on chat")
            expect(state.chatInput == "请用三句话介绍 Health Pilot。", "rate-limit snapshot should retain composer text")
            expect(state.toastMessage == "已达使用上限，请稍后再试。", "rate-limit snapshot should use non-login copy")
        }

        verify("chat-model-expert-login") { state in
            expect(state.selectedModel.id == "expert", "legacy expert snapshot should select expert model")
        }

        verify("chat-model-office-login") { state in
            expect(state.selectedModel.id == "office", "legacy office snapshot should select office model")
        }

        verify("creation-image-send-login") { state in
            expect(state.route == .creation, "legacy image send snapshot should stay on creation")
            expect(state.creationPrompt == "生成一张蓝色机器人产品海报", "legacy image send snapshot should retain prompt")
        }

        verify("creation-video-send-login") { state in
            expect(state.route == .creation, "legacy video send snapshot should stay on creation")
            expect(state.creationPrompt == "生成一个蓝色机器人产品演示视频", "legacy video send snapshot should retain prompt")
        }
    }

    @MainActor
    private static func verifyToolRouting() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())

        state.activeOverlay = .chatTools
        state.selectTool(ToolOption(id: "profile", title: "个人档案", symbol: "person.text.rectangle"))
        expect(state.route == .chat, "profile card should stay on chat")
        expect(state.selectedHealthCard == .profile, "profile card should open profile details")
        expect(state.activeOverlay == nil, "profile card should close menu overlay")

        state.navigate(to: .chat)
        state.activeOverlay = .chatTools
        state.selectTool(ToolOption(id: "recording", title: "录音转写", symbol: "mic"))
        expect(state.route == .chat, "recording tool should stay on chat")
        expect(state.selectedHealthCard == .reminders, "recording tool should open reminders instead of a desktop prompt")
        expect(state.activeOverlay == nil, "recording tool should close menu overlay")
    }

    @MainActor
    private static func verifyModelSelection() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())

        state.activeOverlay = .chatModel
        state.selectModel(ModelOption.defaults[1])
        expect(state.selectedModel.id == "expert", "expert model should be selectable")
        expect(state.activeOverlay == nil, "expert model selection should close menu overlay")

        state.activeOverlay = .chatModel
        state.selectModel(ModelOption.defaults[2])
        expect(state.selectedModel.id == "office", "office model should be selectable")
        expect(state.activeOverlay == nil, "office model selection should close menu overlay")
    }

    @MainActor
    private static func verifyAttachmentImport() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())

        state.openAttachmentImporter()
        expect(state.showAttachmentImporter, "plus button should open the attachment importer")
        expect(AppState.supportedAttachmentTypes.count >= 10, "attachment importer should support document and image types")

        state.handleAttachmentImport(.success([
            URL(fileURLWithPath: "/tmp/brief.pdf"),
            URL(fileURLWithPath: "/tmp/sketch.png")
        ]))
        expect(state.pendingAttachments.map(\.name) == ["brief.pdf", "sketch.png"], "attachment import should store selected file names")
        expect(state.attachmentImportError == nil, "successful attachment import should clear errors")
    }

    @MainActor
    private static func verifyCreationReferenceImage() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.navigate(to: .creation)
        state.activeOverlay = .creationMore

        state.requestCreationReferenceImage()

        expect(state.route == .creation, "reference image should stay on creation")
        expect(state.showCreationReferenceImporter, "reference image should open the image importer")
        expect(state.showCreationReferenceTooltip, "reference image should show the upload limit tooltip")
        expect(state.activeOverlay == nil, "reference image should close transient creation menus")

        state.handleCreationReferenceImport(.success([
            URL(fileURLWithPath: "/tmp/ref-1.png"),
            URL(fileURLWithPath: "/tmp/ref-2.webp")
        ]))
        expect(state.creationReferenceImages.map(\.name) == ["ref-1.png", "ref-2.webp"], "reference import should store selected image names")
    }

    @MainActor
    private static func verifyCreationFeatureAction() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.navigate(to: .creation)
        state.activeOverlay = .creationMore
        state.showCreationReferenceTooltip = true
        state.showCreationReferenceImporter = true

        state.requestCreationFeatureAction()

        expect(state.route == .creation, "creation feature action should stay on creation")
        expect(state.activeOverlay == nil, "creation feature action should close transient overlays")
        expect(!state.showCreationReferenceTooltip, "creation feature action should hide reference tooltip")
        expect(!state.showCreationReferenceImporter, "creation feature action should close reference importer")
    }

    @MainActor
    private static func verifyCreationImageOptionSelection() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.navigate(to: .creation)
        state.creationMode = .image

        state.activeOverlay = .creationImageModel
        state.selectCreationImageModel("Seedream 5.0 Lite")
        expect(state.creationImageModel == "Seedream 5.0 Lite", "image model selection should update main menu label")
        expect(state.activeOverlay == nil, "image model selection should close menu")

        state.activeOverlay = .creationRatio
        state.selectCreationImageRatio("16:9")
        expect(state.creationImageRatio == "16:9", "image ratio selection should update main menu label")
        expect(state.activeOverlay == nil, "image ratio selection should close menu")

        state.activeOverlay = .creationStyle
        state.selectCreationImageStyle("动漫")
        expect(state.creationImageStyle == "动漫", "image style selection should update main menu label")
        expect(state.activeOverlay == nil, "image style selection should close menu")
    }

    @MainActor
    private static func verifyCreationVideoControls() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.navigate(to: .creation)
        state.creationMode = .video

        state.activeOverlay = .creationVideoDuration
        state.selectCreationVideoDuration("10s")
        expect(state.creationVideoDuration == "10s", "video duration selection should update the control label")
        expect(state.activeOverlay == nil, "video duration selection should close the duration menu")

        state.activeOverlay = .creationVideoRatio
        state.selectCreationVideoRatio("16:9")
        expect(state.creationVideoRatio == "16:9", "video ratio selection should update the menu value")
        expect(state.activeOverlay == nil, "video ratio selection should close the ratio menu")

        state.activeOverlay = .creationVideoMore
        state.showCreationReferenceTooltip = true
        state.requestCreationVideoUpload()
        expect(state.showCreationVideoUploadImporter, "video upload should open importer directly")
        expect(!state.showCreationReferenceImporter, "video upload should not use the image reference importer")
        expect(!state.showCreationReferenceTooltip, "video upload should not show the multi-reference tooltip")
        expect(AppState.supportedCreationVideoUploadTypes.count == 4, "video upload should support jpg, jpeg, png, and webp")

        state.handleCreationVideoUpload(.success([
            URL(fileURLWithPath: "/tmp/frame.jpg"),
            URL(fileURLWithPath: "/tmp/ignored.png")
        ]))
        expect(state.creationVideoImage?.name == "frame.jpg", "video upload should store only the first selected image")

        state.activeOverlay = .creationMore
        state.requestCreationVoiceInput()
        expect(state.creationMode == .image, "creation voice input should switch back to image mode")
        expect(state.activeOverlay == nil, "creation voice input should close transient overlays")
    }

    @MainActor
    private static func verifyTitleEditing() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.chatTitle = "旧标题"

        state.openTitleEditor()
        expect(state.showTitleEditor, "openTitleEditor should show editor")
        expect(state.titleDraft == "旧标题", "openTitleEditor should seed draft")

        state.titleDraft = "新标题"
        state.confirmTitleEdit()
        expect(state.chatTitle == "新标题", "confirmTitleEdit should update title")
        expect(!state.showTitleEditor, "confirmTitleEdit should close editor")
    }

    @MainActor
    private static func verifyShareAction() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.activeOverlay = .chatTools
        state.showTitleEditor = true

        state.shareConversation()

        expect(state.showShareTooltip, "shareConversation should show the share tooltip")
        expect(state.activeOverlay == nil, "shareConversation should close transient overlays")
        expect(!state.showTitleEditor, "shareConversation should close title editor")
    }

    @MainActor
    private static func verifyVoiceInputAction() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.activeOverlay = .chatTools

        state.startVoiceInput()

        expect(state.activeOverlay == nil, "startVoiceInput should close transient overlays")
    }

    @MainActor
    private static func verifyRateLimitMessage() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.hasReachedAnonymousLimit = true
        state.chatInput = "请用三句话介绍 Health Pilot。"

        state.sendChat()

        expect(state.toastMessage == "已达使用上限，请稍后再试。", "rate-limited send should show non-login toast")
        expect(state.chatInput == "请用三句话介绍 Health Pilot。", "rate-limited send should keep composer text")
        expect(state.messages.isEmpty, "rate-limited send should not create messages")
    }

    @MainActor
    private static func verifyHistoryRouting() {
        let state = AppState(launchArguments: [], service: ImmediateAssistantService())
        state.isSidebarOpen = true
        state.showAboutPopover = true
        state.openHistoryConversation(state.chatHistory[1])

        expect(state.route == .chat, "history item should open chat route")
        expect(state.chatTitle == "今日健康摘要", "history item should set title")
        expect(state.messages.count == 2, "history item should load local messages")
        expect(!state.isSidebarOpen, "history item should close sidebar")
        expect(!state.showAboutPopover, "history item should close about popover")
    }

    private static func verifyAsyncActions() async {
        let chatState = await MainActor.run {
            let state = AppState(launchArguments: [], service: ImmediateAssistantService())
            state.chatInput = "你好"
            state.sendChat()
            return state
        }

        try? await Task.sleep(nanoseconds: 50_000_000)

        await MainActor.run {
            expect(chatState.chatTitle == "问候与帮助", "sendChat should set greeting title")
            expect(chatState.chatInput.isEmpty, "sendChat should clear input")
            expect(chatState.messages.count == 2, "sendChat should create user and assistant messages")
            expect(chatState.messages.last?.text == ChatReplyFixture.greetingHelpful, "sendChat should append streamed chunks")
            expect(!chatState.isStreaming, "sendChat should finish streaming")
        }

        let creationState = await MainActor.run {
            let state = AppState(launchArguments: [], service: ImmediateAssistantService())
            state.creationMode = .video
            state.creationPrompt = "生成一个产品演示视频"
            state.sendCreation()
            return state
        }

        try? await Task.sleep(nanoseconds: 50_000_000)

        await MainActor.run {
            expect(creationState.creationPrompt.isEmpty, "sendCreation should clear prompt")
            expect(!creationState.isCreating, "sendCreation should finish creating")
            expect(creationState.creationResults.count == 1, "sendCreation should insert one result")
            expect(creationState.creationResults.first?.mode == .video, "sendCreation should preserve selected mode")
        }

        let suggestionState = await MainActor.run {
            let state = AppState(launchArguments: [], service: ImmediateAssistantService())
            state.chatInput = "预填内容"
            state.sendSuggestedPrompt("帮我建立健康档案")
            return state
        }

        try? await Task.sleep(nanoseconds: 50_000_000)

        await MainActor.run {
            expect(suggestionState.chatInput.isEmpty, "sendSuggestedPrompt should leave composer empty")
            expect(suggestionState.messages.first?.text == "帮我建立健康档案", "sendSuggestedPrompt should send the chip text immediately")
            expect(suggestionState.messages.last?.text == "已收到：帮我建立健康档案", "sendSuggestedPrompt should stream assistant response")
        }
    }

    private static func verifyHealthDataActions() async {
        let state = await MainActor.run {
            let state = AppState(
                launchArguments: [],
                service: ImmediateAssistantService(),
                appleHealthService: ImmediateAppleHealthService()
            )
            state.navigate(to: .healthData)
            return state
        }

        try? await Task.sleep(nanoseconds: 80_000_000)

        await MainActor.run {
            expect(state.route == .healthData, "health data route should be selectable")
            expect(state.healthData.dashboard.connection.sampleCount == 3, "health data route should load dashboard")
            expect(state.healthData.reports.first?.title == "Apple Health 日报", "health data route should load reports")
        }

        await MainActor.run {
            state.syncAppleHealthData()
        }

        try? await Task.sleep(nanoseconds: 80_000_000)

        await MainActor.run {
            expect(state.healthData.authorization == .authorized, "Apple Health sync should request authorization")
            expect(state.healthData.lastSyncResult.inserted == 1, "Apple Health sync should upload collected samples")
            expect(state.toastMessage == "Apple 健康同步完成", "Apple Health sync should show completion feedback")
        }

        await MainActor.run {
            state.generateAppleHealthReport(kind: "daily")
        }

        try? await Task.sleep(nanoseconds: 80_000_000)

        await MainActor.run {
            expect(state.healthData.reports.first?.title == "Apple Health 日报", "report generation should insert latest report")
            state.chatAboutReport(.sample)
        }

        try? await Task.sleep(nanoseconds: 80_000_000)

        await MainActor.run {
            expect(state.route == .chat, "report chat action should open chat")
            expect(state.messages.first?.text.contains("Apple Health 分析报告") == true, "report chat action should send a report-grounded prompt")
            expect(state.messages.last?.text.contains("Apple Health 分析报告") == true, "report chat action should stream an answer to the report prompt")
        }
    }

    @MainActor
    private static func verify(_ rawSnapshot: String, assertions: (AppState) -> Void) {
        let state = AppState(
            launchArguments: ["StateScenarioTests", "--snapshot", rawSnapshot],
            service: ImmediateAssistantService()
        )
        assertions(state)
    }

    private static func expect(_ condition: Bool, _ message: String) {
        if !condition {
            failures.append("FAIL: \(message)")
        }
    }
}
