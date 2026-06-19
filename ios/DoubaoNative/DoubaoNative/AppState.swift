import Foundation
import UniformTypeIdentifiers

@MainActor
final class AppState: ObservableObject {
    @Published var route: AppRoute = .chat
    @Published var isSidebarOpen = false
    @Published var showAboutPopover = false
    @Published var showShareTooltip = false
    @Published var toastMessage: String?
    @Published var activeOverlay: ActiveOverlay?

    @Published var selectedModel = ModelOption.defaults[0]
    @Published var chatTitle = "新对话"
    @Published var chatInput = ""
    @Published var showTitleEditor = false
    @Published var titleDraft = ""
    @Published var showAttachmentImporter = false
    @Published var pendingAttachments: [AttachmentDraft] = []
    @Published var attachmentImportError: String?
    @Published var messages: [ChatMessage] = []
    @Published var isStreaming = false
    @Published var hasReachedAnonymousLimit = false
    @Published var chatTranscriptFocus: ChatTranscriptFocus = .normal
    @Published var selectedHealthCard: HealthCardKind?
    @Published var healthSummary: HealthSummary = .placeholder
    @Published var isLoadingHealthSummary = false
    @Published var healthSummaryError: String?
    @Published var healthData = HealthDataState()

    @Published var creationMode: CreationMode = .image
    @Published var creationPrompt = ""
    @Published var creationImageModel = "Seedream 4.5"
    @Published var creationImageRatio: String?
    @Published var creationImageStyle: String?
    @Published var creationVideoDuration = "时长"
    @Published var creationVideoRatio = "10"
    @Published var showCreationReferenceImporter = false
    @Published var showCreationVideoUploadImporter = false
    @Published var showCreationReferenceTooltip = false
    @Published var creationReferenceImages: [AttachmentDraft] = []
    @Published var creationVideoImage: AttachmentDraft?
    @Published var creationResults: [CreationResult] = []
    @Published var isCreating = false

    let models = ModelOption.defaults
    let tools = ToolOption.defaults
    let chatHistory = ChatHistoryItem.defaults
    private let service: any AssistantServicing
    private let appleHealthService: any AppleHealthServicing
    private let userID = "default"

    static var supportedAttachmentTypes: [UTType] {
        let explicitTypes: [UTType] = [.pdf, .plainText, .commaSeparatedText, .image]
        let extensionTypes = [
            "docx", "doc", "xlsx", "xls", "pptx", "ppt",
            "md", "mobi", "epub", "png", "jpeg", "jpg", "webp"
        ].compactMap { UTType(filenameExtension: $0) }
        return explicitTypes + extensionTypes
    }

    static var supportedCreationReferenceTypes: [UTType] {
        ["jpg", "jpeg", "png", "webp", "apng"].compactMap { UTType(filenameExtension: $0) }
    }

    static var supportedCreationVideoUploadTypes: [UTType] {
        ["jpg", "jpeg", "png", "webp"].compactMap { UTType(filenameExtension: $0) }
    }

    init(
        launchArguments: [String] = ProcessInfo.processInfo.arguments,
        service: any AssistantServicing = MockAssistantService(),
        appleHealthService: any AppleHealthServicing = AppleHealthService()
    ) {
        self.service = service
        self.appleHealthService = appleHealthService
        if let scenario = SnapshotScenario.from(arguments: launchArguments) {
            applySnapshotScenario(scenario)
        }
    }

    func closeTransientOverlays() {
        activeOverlay = nil
        showShareTooltip = false
        showCreationReferenceImporter = false
        showCreationVideoUploadImporter = false
        showCreationReferenceTooltip = false
        selectedHealthCard = nil
    }

    func navigate(to route: AppRoute) {
        self.route = route
        isSidebarOpen = false
        showAboutPopover = false
        showTitleEditor = false
        showShareTooltip = false
        toastMessage = nil
        closeTransientOverlays()
        if route == .healthData {
            Task {
                await loadHealthData()
            }
        }
    }

    func startNewChat() {
        messages.removeAll()
        chatInput = ""
        chatTitle = "新对话"
        pendingAttachments.removeAll()
        navigate(to: .chat)
    }

    func startOfficeTask() {
        startNewChat()
    }

    func openHistoryConversation(_ item: ChatHistoryItem) {
        route = .chat
        chatTitle = item.title
        messages = item.messages
        chatInput = ""
        pendingAttachments.removeAll()
        isStreaming = false
        isSidebarOpen = false
        showAboutPopover = false
        showTitleEditor = false
        showShareTooltip = false
        closeTransientOverlays()
    }

    func openTitleEditor() {
        closeTransientOverlays()
        titleDraft = chatTitle
        showTitleEditor = true
    }

    func confirmTitleEdit() {
        let trimmed = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            chatTitle = trimmed
        }
        showTitleEditor = false
    }

    func shareConversation() {
        toastMessage = nil
        closeTransientOverlays()
        showTitleEditor = false
        showShareTooltip = true
    }

    func startVoiceInput() {
        closeTransientOverlays()
    }

    func selectTool(_ tool: ToolOption) {
        if let card = HealthCardKind(rawValue: tool.id) {
            openHealthCard(card)
            return
        }

        if tool.id == "recording" {
            openHealthCard(.reminders)
            return
        }

        activeOverlay = nil
        closeTransientOverlays()
    }

    func openHealthCard(_ card: HealthCardKind) {
        activeOverlay = nil
        selectedHealthCard = card
        healthSummaryError = nil

        Task {
            await loadHealthSummary()
        }
    }

    func dismissHealthCard() {
        selectedHealthCard = nil
    }

    func refreshHealthSummary() {
        Task {
            await loadHealthSummary()
        }
    }

    func refreshHealthData() {
        Task {
            await loadHealthData()
        }
    }

    func syncAppleHealthData() {
        Task {
            await syncAppleHealthDataNow()
        }
    }

    func generateAppleHealthReport(kind: String = "daily") {
        Task {
            await generateAppleHealthReportNow(kind: kind)
        }
    }

    func chatAboutReport(_ report: HealthAnalysisReport) {
        route = .chat
        isSidebarOpen = false
        let prompt = "基于《\(report.title)》这份 Apple Health 分析报告，帮我解释关键发现，并给出今天接下来饮食、运动和恢复建议。"
        sendSuggestedPrompt(prompt)
    }

    private func loadHealthData() async {
        guard !healthData.isLoading else { return }
        healthData.isLoading = true
        defer { healthData.isLoading = false }

        healthData.authorization = await appleHealthService.authorizationState()
        do {
            async let dashboard = service.healthDashboard(userID: userID)
            async let reports = service.healthReports(userID: userID)
            healthData.dashboard = try await dashboard
            healthData.reports = try await reports
            healthData.error = nil
        } catch {
            healthData.error = "暂时无法读取健康数据，请确认后端已启动。"
        }
    }

    private func syncAppleHealthDataNow() async {
        guard !healthData.isSyncing else { return }
        healthData.isSyncing = true
        defer { healthData.isSyncing = false }

        do {
            let authorization = try await appleHealthService.requestAuthorization()
            healthData.authorization = authorization
            guard authorization == .authorized else {
                healthData.error = "Apple 健康未授权，已保留现有健康数据。"
                return
            }
            let samples = try await appleHealthService.collectSamples()
            healthData.lastSyncResult = try await service.syncAppleHealthSamples(userID: userID, samples: samples)
            healthData.dashboard = try await service.healthDashboard(userID: userID)
            healthData.reports = try await service.healthReports(userID: userID)
            healthData.error = nil
            toastMessage = "Apple 健康同步完成"
        } catch {
            healthData.error = "Apple 健康同步失败，请稍后重试。"
        }
    }

    private func generateAppleHealthReportNow(kind: String) async {
        guard !healthData.isGeneratingReport else { return }
        healthData.isGeneratingReport = true
        defer { healthData.isGeneratingReport = false }

        do {
            let report = try await service.generateHealthReport(userID: userID, kind: kind)
            healthData.reports.removeAll { $0.id == report.id }
            healthData.reports.insert(report, at: 0)
            healthData.error = nil
        } catch {
            healthData.error = "暂时无法生成分析报告，请稍后再试。"
        }
    }

    private func loadHealthSummary() async {
        guard !isLoadingHealthSummary else { return }
        isLoadingHealthSummary = true
        defer { isLoadingHealthSummary = false }

        do {
            healthSummary = try await service.healthSummary(userID: userID)
            healthSummaryError = nil
        } catch {
            healthSummaryError = "暂时无法连接健康数据服务，请确认后端已启动。"
        }
    }

    func openAttachmentImporter() {
        closeTransientOverlays()
        showAttachmentImporter = true
        attachmentImportError = nil
    }

    func handleAttachmentImport(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            pendingAttachments = urls.prefix(50).map { url in
                AttachmentDraft(
                    name: url.lastPathComponent,
                    fileExtension: url.pathExtension.lowercased()
                )
            }
            attachmentImportError = nil
        case .failure(let error):
            attachmentImportError = error.localizedDescription
        }
    }

    func requestCreationReferenceImage() {
        closeTransientOverlays()
        attachmentImportError = nil
        showCreationReferenceTooltip = true
        showCreationReferenceImporter = true
    }

    func handleCreationReferenceImport(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            creationReferenceImages = urls.prefix(10).map { url in
                AttachmentDraft(
                    name: url.lastPathComponent,
                    fileExtension: url.pathExtension.lowercased()
                )
            }
            attachmentImportError = nil
        case .failure(let error):
            attachmentImportError = error.localizedDescription
        }
    }

    func requestCreationVideoUpload() {
        creationMode = .video
        closeTransientOverlays()
        attachmentImportError = nil
        showCreationVideoUploadImporter = true
    }

    func requestCreationVoiceInput() {
        creationMode = .image
        closeTransientOverlays()
    }

    func handleCreationVideoUpload(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            creationVideoImage = urls.first.map { url in
                AttachmentDraft(
                    name: url.lastPathComponent,
                    fileExtension: url.pathExtension.lowercased()
                )
            }
            attachmentImportError = nil
        case .failure(let error):
            attachmentImportError = error.localizedDescription
        }
    }

    func requestCreationFeatureAction() {
        closeTransientOverlays()
    }

    func selectCreationImageModel(_ model: String) {
        creationImageModel = model
        activeOverlay = nil
    }

    func selectCreationImageRatio(_ ratio: String) {
        creationImageRatio = ratio
        activeOverlay = nil
    }

    func selectCreationImageStyle(_ style: String) {
        creationImageStyle = style
        activeOverlay = nil
    }

    func selectCreationVideoDuration(_ duration: String) {
        creationVideoDuration = duration
        activeOverlay = nil
    }

    func selectCreationVideoRatio(_ ratio: String) {
        creationVideoRatio = ratio
        activeOverlay = nil
    }

    func selectModel(_ model: ModelOption) {
        selectedModel = model
        activeOverlay = nil
    }

    func sendChat() {
        let prompt = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isStreaming else { return }
        if hasReachedAnonymousLimit {
            toastMessage = "已达使用上限，请稍后再试。"
            return
        }
        chatInput = ""
        sendPrompt(prompt)
    }

    func sendSuggestedPrompt(_ prompt: String) {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isStreaming else { return }
        chatInput = ""
        sendPrompt(trimmed)
    }

    private func sendPrompt(_ prompt: String) {
        if prompt == "你好" || prompt == "你能做些什么？" {
            chatTitle = prompt == "你好" ? "问候与帮助" : "问候"
        } else {
            chatTitle = "新对话"
        }
        messages.append(ChatMessage(role: .user, text: prompt))
        let assistantID = UUID()
        messages.append(ChatMessage(id: assistantID, role: .assistant, text: ""))
        isStreaming = true

        Task {
            for await chunk in service.chatStream(for: prompt) {
                guard let index = messages.firstIndex(where: { $0.id == assistantID }) else { continue }
                messages[index].text += chunk
            }
            isStreaming = false
        }
    }

    func submitCreation() {
        let prompt = creationPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isCreating else { return }
        creationPrompt = ""
        isCreating = true

        Task {
            let result = await service.create(mode: creationMode, prompt: prompt)
            creationResults.insert(result, at: 0)
            isCreating = false
        }
    }

    func sendCreation() {
        let prompt = creationPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isCreating else { return }
        submitCreation()
    }

    private func applySnapshotScenario(_ scenario: SnapshotScenario) {
        switch scenario {
        case .chatHome:
            route = .chat
            chatTitle = "新对话"
        case .chatWithMessage:
            route = .chat
            chatTitle = "健康计划"
            messages = [
                ChatMessage(role: .user, text: "帮我总结今天的健康计划"),
                ChatMessage(role: .assistant, text: "可以。今天的健康计划可以分成饮食、运动、睡眠三部分：午后补水，晚间轻量训练，睡前减少屏幕时间。")
            ]
        case .chatSendReady:
            route = .chat
            chatTitle = "新对话"
            chatInput = "帮我总结今天的健康计划"
        case .chatAfterSend:
            route = .chat
            chatTitle = "问候与帮助"
            messages = [
                ChatMessage(role: .user, text: "你好"),
                ChatMessage(role: .assistant, text: ChatReplyFixture.greetingHelpful)
            ]
        case .chatReplyActions:
            route = .chat
            chatTitle = "问候"
            messages = [
                ChatMessage(role: .user, text: "你好"),
                ChatMessage(role: .assistant, text: ChatReplyFixture.greetingShort)
            ]
        case .chatReplyTapped:
            route = .chat
            chatTitle = "问候"
            messages = [
                ChatMessage(role: .user, text: "你好"),
                ChatMessage(role: .assistant, text: ChatReplyFixture.greetingShort)
            ]
        case .chatFollowupAfterClick:
            route = .chat
            chatTitle = "问候"
            chatTranscriptFocus = .followupTop
            messages = [
                ChatMessage(role: .user, text: "你能做些什么？"),
                ChatMessage(role: .assistant, text: ChatReplyFixture.capabilitiesAnswer)
            ]
        case .chatFollowupBottom:
            route = .chat
            chatTitle = "问候"
            chatTranscriptFocus = .followupBottom
            messages = [
                ChatMessage(role: .user, text: "你能做些什么？"),
                ChatMessage(role: .assistant, text: ChatReplyFixture.capabilitiesAnswer)
            ]
        case .chatPromoDownloadTap:
            route = .chat
            chatTitle = "问候"
            chatTranscriptFocus = .followupBottom
            messages = [
                ChatMessage(role: .user, text: "你能做些什么？"),
                ChatMessage(role: .assistant, text: ChatReplyFixture.capabilitiesAnswer)
            ]
        case .chatTitleEdit:
            route = .chat
            chatTitle = "问候与帮助"
            titleDraft = "问候与帮助"
            showTitleEditor = true
            messages = [
                ChatMessage(role: .user, text: "你好"),
                ChatMessage(role: .assistant, text: ChatReplyFixture.greetingHelpful)
            ]
        case .chatShareLogin:
            route = .chat
            chatTitle = "问候"
            showShareTooltip = true
            messages = [
                ChatMessage(role: .user, text: "你好"),
                ChatMessage(role: .assistant, text: "你好呀😊")
            ]
        case .chatMicLogin:
            route = .chat
            chatTitle = "新对话"
        case .chatRateLimitLogin:
            route = .chat
            chatTitle = "新对话"
            chatInput = "请用三句话介绍 Health Pilot。"
            toastMessage = "已达使用上限，请稍后再试。"
        case .sidebar:
            route = .chat
            isSidebarOpen = true
        case .about:
            route = .chat
            isSidebarOpen = true
            showAboutPopover = true
        case .sidebarDownloadTooltip:
            route = .chat
            isSidebarOpen = true
        case .loginAccount:
            route = .chat
        case .loginPhoneReady:
            route = .chat
        case .loginPhoneCode:
            route = .chat
        case .loginQR:
            route = .chat
        case .loginAreaPicker:
            route = .chat
        case .loginAreaSelectedHK:
            route = .chat
        case .loginTermsChecked:
            route = .chat
        case .loginDouyinConsent:
            route = .chat
        case .loginDouyinOAuth:
            route = .chat
        case .chatModelMenu:
            route = .chat
            activeOverlay = .chatModel
        case .chatModelExpertLogin:
            route = .chat
            selectedModel = ModelOption.defaults[1]
        case .chatModelOfficeLogin:
            route = .chat
            selectedModel = ModelOption.defaults[2]
        case .chatToolMenu:
            route = .chat
            activeOverlay = .chatTools
        case .chatToolPPTLogin:
            route = .chat
            selectedHealthCard = .profile
        case .chatToolImageLogin:
            route = .chat
            selectedHealthCard = .today
        case .chatToolVideoLogin:
            route = .chat
            selectedHealthCard = .nutrition
        case .chatToolRecordingDownload:
            route = .chat
            selectedHealthCard = .reminders
        case .creationImage:
            route = .creation
            creationMode = .image
        case .creationPromptReady:
            route = .creation
            creationMode = .image
            creationPrompt = "生成一张蓝色机器人产品海报"
        case .creationImageSendLogin:
            route = .creation
            creationMode = .image
            creationPrompt = "生成一张蓝色机器人产品海报"
        case .creationImageMicLogin:
            route = .creation
            creationMode = .image
        case .creationReferenceTooltip:
            route = .creation
            creationMode = .image
            showCreationReferenceTooltip = true
        case .creationAiCutLogin:
            route = .creation
            creationMode = .image
        case .creationVideo:
            route = .creation
            creationMode = .video
        case .creationVideoModelMenu:
            route = .creation
            creationMode = .video
            activeOverlay = .creationModel
        case .creationVideoDurationMenu:
            route = .creation
            creationMode = .video
            activeOverlay = .creationVideoDuration
        case .creationVideoRatioMenu:
            route = .creation
            creationMode = .video
            activeOverlay = .creationVideoRatio
        case .creationVideoPromptReady:
            route = .creation
            creationMode = .video
            creationPrompt = "生成一个蓝色机器人产品演示视频"
        case .creationVideoUploadLogin:
            route = .creation
            creationMode = .video
        case .creationVideoSendLogin:
            route = .creation
            creationMode = .video
            creationPrompt = "生成一个蓝色机器人产品演示视频"
        case .creationMoreMenu:
            route = .creation
            creationMode = .image
            activeOverlay = .creationMore
        case .creationImageModelMenu:
            route = .creation
            creationMode = .image
            activeOverlay = .creationImageModel
        case .creationRatioMenu:
            route = .creation
            creationMode = .image
            activeOverlay = .creationRatio
        case .creationStyleMenu:
            route = .creation
            creationMode = .image
            activeOverlay = .creationStyle
        case .creationImageModelSelected:
            route = .creation
            creationMode = .image
            creationImageModel = "Seedream 5.0 Lite"
            activeOverlay = .creationMore
        case .creationRatioSelected:
            route = .creation
            creationMode = .image
            creationImageModel = "Seedream 5.0 Lite"
            creationImageRatio = "16:9"
            activeOverlay = .creationMore
        case .creationStyleSelected:
            route = .creation
            creationMode = .image
            creationImageModel = "Seedream 5.0 Lite"
            creationImageRatio = "16:9"
            creationImageStyle = "动漫"
            activeOverlay = .creationMore
        }
    }
}
