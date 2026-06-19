import Foundation

enum AppRoute: Equatable {
    case chat
    case creation
    case healthData
}

enum ActiveOverlay: Equatable {
    case chatModel
    case chatTools
    case creationModel
    case creationVideoDuration
    case creationVideoMore
    case creationVideoRatio
    case creationMore
    case creationImageModel
    case creationRatio
    case creationStyle
}

enum CreationMode: String, CaseIterable, Identifiable {
    case image = "图像"
    case video = "视频"

    var id: String { rawValue }

    var placeholder: String {
        switch self {
        case .image: "描述你想要的图片"
        case .video: "添加照片，描述你想生成的视频"
        }
    }
}

enum ChatTranscriptFocus {
    case normal
    case followupTop
    case followupBottom
}

enum SnapshotScenario: String, CaseIterable {
    case chatHome = "chat-home"
    case chatWithMessage = "chat-message"
    case chatSendReady = "chat-send-ready"
    case chatAfterSend = "chat-after-send"
    case chatReplyActions = "chat-reply-actions"
    case chatReplyTapped = "chat-reply-tapped"
    case chatFollowupAfterClick = "chat-followup-after-click"
    case chatFollowupBottom = "chat-followup-bottom"
    case chatPromoDownloadTap = "chat-promo-download-tap"
    case chatTitleEdit = "chat-title-edit"
    case chatShareLogin = "chat-share-login"
    case chatMicLogin = "chat-mic-login"
    case chatRateLimitLogin = "chat-rate-limit-login"
    case sidebar = "sidebar"
    case about = "about"
    case sidebarDownloadTooltip = "sidebar-download-tooltip"
    case loginAccount = "login-account"
    case loginPhoneReady = "login-phone-ready"
    case loginPhoneCode = "login-phone-code"
    case loginQR = "login-qr"
    case loginAreaPicker = "login-area-picker"
    case loginAreaSelectedHK = "login-area-selected-hk"
    case loginTermsChecked = "login-terms-checked"
    case loginDouyinConsent = "login-douyin-consent"
    case loginDouyinOAuth = "login-douyin-oauth"
    case chatModelMenu = "chat-model-menu"
    case chatModelExpertLogin = "chat-model-expert-login"
    case chatModelOfficeLogin = "chat-model-office-login"
    case chatToolMenu = "chat-tool-menu"
    case chatToolPPTLogin = "chat-tool-ppt-login"
    case chatToolImageLogin = "chat-tool-image-login"
    case chatToolVideoLogin = "chat-tool-video-login"
    case chatToolRecordingDownload = "chat-tool-recording-download"
    case creationImage = "creation-image"
    case creationPromptReady = "creation-prompt-ready"
    case creationImageSendLogin = "creation-image-send-login"
    case creationImageMicLogin = "creation-image-mic-login"
    case creationReferenceTooltip = "creation-reference-tooltip"
    case creationAiCutLogin = "creation-ai-cut-login"
    case creationVideo = "creation-video"
    case creationVideoModelMenu = "creation-video-model-menu"
    case creationVideoDurationMenu = "creation-video-duration-menu"
    case creationVideoRatioMenu = "creation-video-ratio-menu"
    case creationVideoPromptReady = "creation-video-prompt-ready"
    case creationVideoUploadLogin = "creation-video-upload-login"
    case creationVideoSendLogin = "creation-video-send-login"
    case creationMoreMenu = "creation-more-menu"
    case creationImageModelMenu = "creation-image-model-menu"
    case creationRatioMenu = "creation-ratio-menu"
    case creationStyleMenu = "creation-style-menu"
    case creationImageModelSelected = "creation-image-model-selected"
    case creationRatioSelected = "creation-ratio-selected"
    case creationStyleSelected = "creation-style-selected"

    static func from(arguments: [String]) -> SnapshotScenario? {
        guard let index = arguments.firstIndex(of: "--snapshot"),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        return SnapshotScenario(rawValue: arguments[index + 1])
    }
}

struct ChatMessage: Identifiable, Equatable {
    enum Role {
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    var text: String

    init(id: UUID = UUID(), role: Role, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}

struct ModelOption: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
}

struct ToolOption: Identifiable, Equatable {
    let id: String
    let title: String
    let symbol: String
    var subtitle: String = ""
}

enum HealthCardKind: String, CaseIterable, Identifiable {
    case profile
    case today
    case nutrition
    case activity
    case reminders

    var id: String { rawValue }

    var title: String {
        switch self {
        case .profile: "个人档案"
        case .today: "今日健康"
        case .nutrition: "营养摄入"
        case .activity: "运动消耗"
        case .reminders: "主动提醒"
        }
    }

    var subtitle: String {
        switch self {
        case .profile: "身高、体重、目标和 TDEE"
        case .today: "热量缺口和目标进度"
        case .nutrition: "蛋白质、碳水、脂肪"
        case .activity: "训练时长和消耗"
        case .reminders: "未读关怀和打卡提醒"
        }
    }

    var symbol: String {
        switch self {
        case .profile: "person.text.rectangle"
        case .today: "heart.text.square"
        case .nutrition: "fork.knife.circle"
        case .activity: "figure.run.circle"
        case .reminders: "bell.badge"
        }
    }
}

struct AttachmentDraft: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let fileExtension: String
}

struct ChatHistoryItem: Identifiable, Equatable {
    let id: String
    let title: String
    let messages: [ChatMessage]
}

struct CreationResult: Identifiable, Equatable {
    let id = UUID()
    let mode: CreationMode
    let prompt: String
    let title: String
}

struct HealthSummary: Decodable, Equatable {
    let userID: String
    let profile: HealthProfileSummary
    let today: HealthTodaySummary
    let notifications: [HealthNotificationSummary]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case profile
        case today
        case notifications
    }

    static let placeholder = HealthSummary(
        userID: "default",
        profile: HealthProfileSummary(
            isComplete: false,
            heightCM: nil,
            weightKG: nil,
            age: nil,
            gender: nil,
            activityLevel: nil,
            targetWeightKG: nil,
            targetRateKGPerWeek: 0.5,
            tdeeKcal: nil,
            dailyCalorieTargetKcal: nil
        ),
        today: HealthTodaySummary(
            date: "",
            caloriesConsumedKcal: 0,
            calorieTargetKcal: nil,
            remainingCaloriesKcal: nil,
            proteinG: 0,
            proteinTargetG: 112,
            carbsG: 0,
            fatG: 0,
            exerciseCaloriesKcal: 0,
            exerciseMinutes: 0,
            mealCount: 0
        ),
        notifications: []
    )
}

struct HealthProfileSummary: Decodable, Equatable {
    let isComplete: Bool
    let heightCM: Double?
    let weightKG: Double?
    let age: Int?
    let gender: String?
    let activityLevel: String?
    let targetWeightKG: Double?
    let targetRateKGPerWeek: Double?
    let tdeeKcal: Double?
    let dailyCalorieTargetKcal: Double?

    enum CodingKeys: String, CodingKey {
        case isComplete = "is_complete"
        case heightCM = "height_cm"
        case weightKG = "weight_kg"
        case age
        case gender
        case activityLevel = "activity_level"
        case targetWeightKG = "target_weight_kg"
        case targetRateKGPerWeek = "target_rate_kg_per_week"
        case tdeeKcal = "tdee_kcal"
        case dailyCalorieTargetKcal = "daily_calorie_target_kcal"
    }
}

struct HealthTodaySummary: Decodable, Equatable {
    let date: String
    let caloriesConsumedKcal: Double
    let calorieTargetKcal: Double?
    let remainingCaloriesKcal: Double?
    let proteinG: Double
    let proteinTargetG: Double
    let carbsG: Double
    let fatG: Double
    let exerciseCaloriesKcal: Double
    let exerciseMinutes: Int
    let mealCount: Int

    enum CodingKeys: String, CodingKey {
        case date
        case caloriesConsumedKcal = "calories_consumed_kcal"
        case calorieTargetKcal = "calorie_target_kcal"
        case remainingCaloriesKcal = "remaining_calories_kcal"
        case proteinG = "protein_g"
        case proteinTargetG = "protein_target_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
        case exerciseCaloriesKcal = "exercise_calories_kcal"
        case exerciseMinutes = "exercise_minutes"
        case mealCount = "meal_count"
    }
}

struct HealthNotificationSummary: Decodable, Equatable, Identifiable {
    let id: Int
    let triggerType: String
    let triggerName: String
    let content: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case triggerType = "trigger_type"
        case triggerName = "trigger_name"
        case content
        case createdAt = "created_at"
    }
}

enum AppleHealthAuthorizationState: String, Codable, Equatable {
    case notDetermined = "not_determined"
    case unavailable
    case sharingDenied = "sharing_denied"
    case authorized

    var label: String {
        switch self {
        case .notDetermined: "未连接"
        case .unavailable: "不可用"
        case .sharingDenied: "未授权"
        case .authorized: "已连接"
        }
    }
}

struct AppleHealthSamplePayload: Codable, Equatable {
    let type: String
    let category: String
    let unit: String
    let value: Double?
    let source: String
    let startAt: Date
    let endAt: Date
    let metadata: [String: String]

    enum CodingKeys: String, CodingKey {
        case type
        case category
        case unit
        case value
        case source
        case startAt = "start_at"
        case endAt = "end_at"
        case metadata
    }
}

struct AppleHealthSyncResult: Decodable, Equatable {
    let userID: String
    let received: Int
    let inserted: Int
    let updated: Int
    let total: Int
    let syncedAt: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case received
        case inserted
        case updated
        case total
        case syncedAt = "synced_at"
    }

    static let empty = AppleHealthSyncResult(
        userID: "default",
        received: 0,
        inserted: 0,
        updated: 0,
        total: 0,
        syncedAt: ""
    )
}

struct HealthDataState: Equatable {
    var authorization: AppleHealthAuthorizationState = .notDetermined
    var dashboard: HealthDataDashboard = .empty
    var reports: [HealthAnalysisReport] = []
    var lastSyncResult: AppleHealthSyncResult = .empty
    var isLoading = false
    var isSyncing = false
    var isGeneratingReport = false
    var error: String?
}

struct HealthDataDashboard: Decodable, Equatable {
    let userID: String
    let connection: HealthDataConnection
    let metrics: HealthDataMetrics
    let coverage: [String: String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case connection
        case metrics
        case coverage
    }

    static let empty = HealthDataDashboard(
        userID: "default",
        connection: HealthDataConnection(status: "not_connected", sampleCount: 0, lastSyncAt: nil),
        metrics: HealthDataMetrics.empty,
        coverage: ["activity": "missing", "sleep": "missing", "vitals": "missing", "body": "missing"]
    )
}

struct HealthDataConnection: Decodable, Equatable {
    let status: String
    let sampleCount: Int
    let lastSyncAt: String?

    enum CodingKeys: String, CodingKey {
        case status
        case sampleCount = "sample_count"
        case lastSyncAt = "last_sync_at"
    }
}

struct HealthDataMetrics: Decodable, Equatable {
    let activity: HealthActivityMetrics
    let sleep: HealthSleepMetrics
    let vitals: HealthVitalsMetrics
    let body: HealthBodyMetrics

    static let empty = HealthDataMetrics(
        activity: HealthActivityMetrics(steps: 0, activeEnergyKcal: 0, exerciseMinutes: 0, workouts: 0),
        sleep: HealthSleepMetrics(asleepMinutes: 0),
        vitals: HealthVitalsMetrics(heartRateAvg: nil, restingHeartRate: nil),
        body: HealthBodyMetrics(weightKG: nil, bodyFatPct: nil, heightCM: nil)
    )
}

struct HealthActivityMetrics: Decodable, Equatable {
    let steps: Int
    let activeEnergyKcal: Double
    let exerciseMinutes: Int
    let workouts: Int

    enum CodingKeys: String, CodingKey {
        case steps
        case activeEnergyKcal = "active_energy_kcal"
        case exerciseMinutes = "exercise_minutes"
        case workouts
    }
}

struct HealthSleepMetrics: Decodable, Equatable {
    let asleepMinutes: Int

    enum CodingKeys: String, CodingKey {
        case asleepMinutes = "asleep_minutes"
    }
}

struct HealthVitalsMetrics: Decodable, Equatable {
    let heartRateAvg: Double?
    let restingHeartRate: Double?

    enum CodingKeys: String, CodingKey {
        case heartRateAvg = "heart_rate_avg"
        case restingHeartRate = "resting_heart_rate"
    }
}

struct HealthBodyMetrics: Decodable, Equatable {
    let weightKG: Double?
    let bodyFatPct: Double?
    let heightCM: Double?

    enum CodingKeys: String, CodingKey {
        case weightKG = "weight_kg"
        case bodyFatPct = "body_fat_pct"
        case heightCM = "height_cm"
    }
}

struct HealthAnalysisReport: Decodable, Equatable, Identifiable {
    let id: Int
    let userID: String
    let kind: String
    let periodStart: String
    let periodEnd: String
    let title: String
    let summary: String
    let metrics: HealthDataMetrics
    let findings: [String]
    let recommendations: [String]
    let risks: [String]
    let coverage: [String: String]
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case kind
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case title
        case summary
        case metrics
        case findings
        case recommendations
        case risks
        case coverage
        case createdAt = "created_at"
    }

    static let sample = HealthAnalysisReport(
        id: 1,
        userID: "default",
        kind: "daily",
        periodStart: "2026-06-19",
        periodEnd: "2026-06-19",
        title: "Apple Health 日报",
        summary: "已读取活动、睡眠和身体数据。",
        metrics: .empty,
        findings: ["步数为 8600 步，活动能量约 320 kcal。"],
        recommendations: ["基于这份报告安排明天的饮食和运动。"],
        risks: ["以上是健康管理分析，非医疗诊断。"],
        coverage: ["activity": "present", "sleep": "present", "vitals": "missing", "body": "present"],
        createdAt: nil
    )
}

struct CreationFeatureItem: Equatable {
    let title: String
    let symbol: String
}

struct ImageRatioOption: Identifiable, Equatable {
    let value: String
    let usage: String

    var id: String { value }
    var label: String { "\(value) \(usage)" }
}

enum ChatReplyFixture {
    static let greetingShort = "你好呀😊"
    static let greetingHelpful = "你好呀～我是你的 Health Pilot 健康助手，可以帮你记录饮食、体重和运动。"

    static let shortFollowups = ["你能做些什么？", "帮我建立健康档案", "今天怎么安排饮食？"]
    static let helpfulFollowups = ["你能做些什么？", "查看今日健康", "帮我记录一餐"]
    static let capabilityFollowups = [
        "帮我记录午餐：一碗黄焖鸡米饭",
        "你能帮我制定一份一周的健身计划吗？",
        "帮我看看今天蛋白质够不够"
    ]

    static let capabilitiesAnswer = """
    我是 Health Pilot 健康助手，可以帮你围绕减脂目标记录、分析和提醒。

    一、健康档案

    1. 记录身高、体重、年龄、性别、活动量和目标体重；
    2. 计算 TDEE 和建议每日摄入；
    3. 在后续对话中持续更新个人信息。

    二、饮食追踪

    1. 用自然语言记录三餐、加餐和饮品；
    2. 估算热量、蛋白质、碳水和脂肪；
    3. 支持食物照片、菜单、外卖截图等视觉分析。

    三、体重与运动

    1. 记录体重、体脂和运动消耗；
    2. 分析趋势体重、周进展和蛋白质达标率；
    3. 根据当天数据给出下一步建议。

    四、主动关怀

    1. 早餐、午餐、晚餐和称重提醒；
    2. 热量预警、蛋白质补足、达标鼓励；
    3. 长时间未记录时主动唤醒。

    五、信息入口

    输入框下方的“更多”里可以查看个人档案、今日健康、营养摄入、运动消耗和主动提醒。
    你也可以直接在聊天里补充或更新健康信息。
    """
}

enum CreationImageOptions {
    static let models = [
        "Seedream 5.0 Lite",
        "Seedream 4.5",
        "Seedream 4.0"
    ]

    static let ratios = [
        ImageRatioOption(value: "1:1", usage: "正方形，头像"),
        ImageRatioOption(value: "2:3", usage: "社交媒体，自拍"),
        ImageRatioOption(value: "3:4", usage: "经典比例，拍照"),
        ImageRatioOption(value: "4:3", usage: "文章配图，插画"),
        ImageRatioOption(value: "9:16", usage: "手机壁纸，人像"),
        ImageRatioOption(value: "16:9", usage: "桌面壁纸，风景")
    ]

    static let styles = [
        "人像摄影",
        "电影写真",
        "中国风",
        "动漫",
        "3D渲染",
        "赛博朋克",
        "CG 动画",
        "水墨画",
        "油画",
        "古典",
        "水彩画",
        "卡通",
        "平面插画",
        "风景",
        "港风动漫",
        "像素风格",
        "荧光绘画",
        "彩铅画",
        "手办",
        "儿童绘画",
        "抽象",
        "锐笔插画",
        "二次元",
        "油墨印刷",
        "版画",
        "莫奈",
        "毕加索",
        "伦勃朗",
        "马蒂斯",
        "巴洛克",
        "复古动漫",
        "绘本"
    ]
}

extension ModelOption {
    static let defaults: [ModelOption] = [
        ModelOption(id: "fast", title: "快速", subtitle: "适用于大部分情况"),
        ModelOption(id: "expert", title: "专家", subtitle: "深度思考/研究级智能模型"),
        ModelOption(id: "office", title: "办公任务", subtitle: "能执行任务的模型")
    ]
}

extension CreationFeatureItem {
    static let defaults: [CreationFeatureItem] = [
        CreationFeatureItem(title: "AI 抠图", symbol: "person.crop.rectangle"),
        CreationFeatureItem(title: "擦除", symbol: "eraser"),
        CreationFeatureItem(title: "区域重绘", symbol: "paintbrush"),
        CreationFeatureItem(title: "扩图", symbol: "arrow.up.left.and.arrow.down.right"),
        CreationFeatureItem(title: "变清晰", symbol: "wand.and.stars")
    ]
}

extension ToolOption {
    static let defaults: [ToolOption] = [
        ToolOption(id: "profile", title: HealthCardKind.profile.title, symbol: HealthCardKind.profile.symbol, subtitle: HealthCardKind.profile.subtitle),
        ToolOption(id: "today", title: HealthCardKind.today.title, symbol: HealthCardKind.today.symbol, subtitle: HealthCardKind.today.subtitle),
        ToolOption(id: "nutrition", title: HealthCardKind.nutrition.title, symbol: HealthCardKind.nutrition.symbol, subtitle: HealthCardKind.nutrition.subtitle),
        ToolOption(id: "activity", title: HealthCardKind.activity.title, symbol: HealthCardKind.activity.symbol, subtitle: HealthCardKind.activity.subtitle),
        ToolOption(id: "reminders", title: HealthCardKind.reminders.title, symbol: HealthCardKind.reminders.symbol, subtitle: HealthCardKind.reminders.subtitle)
    ]
}

extension ChatHistoryItem {
    static let defaults: [ChatHistoryItem] = [
        ChatHistoryItem(
            id: "greeting",
            title: "问候",
            messages: [
                ChatMessage(role: .user, text: "你好"),
                ChatMessage(role: .assistant, text: "你好呀😊")
            ]
        ),
        ChatHistoryItem(
            id: "daily-summary",
            title: "今日健康摘要",
            messages: [
                ChatMessage(role: .user, text: "帮我总结今天的健康计划"),
                ChatMessage(role: .assistant, text: "可以。今天可以重点关注饮食记录、蛋白质补足和晚间轻量运动。")
            ]
        ),
        ChatHistoryItem(
            id: "protein-status",
            title: "蛋白质达标情况",
            messages: [
                ChatMessage(role: .user, text: "今天蛋白质够了吗？"),
                ChatMessage(role: .assistant, text: "我会结合你的体重和今日饮食记录计算蛋白质进度，并给出下一餐建议。")
            ]
        ),
        ChatHistoryItem(
            id: "greeting-help",
            title: "问候与帮助",
            messages: [
                ChatMessage(role: .user, text: "你好"),
                ChatMessage(role: .assistant, text: "你好呀～有什么我可以帮你的吗？")
            ]
        )
    ]
}
