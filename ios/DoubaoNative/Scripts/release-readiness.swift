#!/usr/bin/env swift

import Foundation

struct Check: Encodable {
    let name: String
    let status: String
    let detail: String
}

func path(_ relative: String) -> String {
    FileManager.default.currentDirectoryPath + "/" + relative
}

func exists(_ relative: String) -> Bool {
    FileManager.default.fileExists(atPath: path(relative))
}

func read(_ relative: String) -> String {
    (try? String(contentsOfFile: path(relative), encoding: .utf8)) ?? ""
}

func pass(_ name: String, _ detail: String) -> Check {
    Check(name: name, status: "pass", detail: detail)
}

func fail(_ name: String, _ detail: String) -> Check {
    Check(name: name, status: "fail", detail: detail)
}

let requiredFiles = [
    "ios/DoubaoNative/DoubaoNative.xcodeproj/project.pbxproj",
    "ios/DoubaoNative/DoubaoNative.xcodeproj/xcshareddata/xcschemes/DoubaoNative.xcscheme",
    "ios/DoubaoNative/DoubaoNative/DoubaoNativeApp.swift",
    "ios/DoubaoNative/DoubaoNative/AppState.swift",
    "ios/DoubaoNative/DoubaoNative/ChatView.swift",
    "ios/DoubaoNative/DoubaoNative/ComposerView.swift",
    "ios/DoubaoNative/DoubaoNative/CreationView.swift",
    "ios/DoubaoNative/DoubaoNative/DesignSystem.swift",
    "ios/DoubaoNative/DoubaoNative/MenuOverlays.swift",
    "ios/DoubaoNative/DoubaoNative/Models.swift",
    "ios/DoubaoNative/DoubaoNative/RootView.swift",
    "ios/DoubaoNative/DoubaoNative/SharedComponents.swift",
    "ios/DoubaoNative/DoubaoNative/SidebarView.swift",
    "ios/DoubaoNative/DoubaoNative/MockAssistantService.swift",
    "ios/DoubaoNative/DoubaoNative/HTTPStreamingAssistantService.swift",
    "ios/DoubaoNative/DoubaoNative/AppleHealthService.swift",
    "ios/DoubaoNative/DoubaoNative/HealthDataView.swift",
    "ios/DoubaoNative/Scripts/capture-ios-screenshots.sh",
    "ios/DoubaoNative/Scripts/compare-screenshots.swift",
    "ios/DoubaoNative/Scripts/release-readiness.swift",
    "ios/DoubaoNative/Scripts/validate-visual-manifest.swift",
    "ios/DoubaoNative/Scripts/verify-state-scenarios.sh",
    "ios/DoubaoNative/Scripts/verify-local.sh",
    "ios/DoubaoNative/Scripts/visual-manifest-list.swift",
    "ios/DoubaoNative/Scripts/visual-qa.sh",
    "ios/DoubaoNative/Scripts/build-release.sh",
    "ios/DoubaoNative/Tests/StateScenarioTests.swift",
    "ios/DoubaoNative/ExportOptions.plist.example",
    "design/reference/doubao-mobile/manifest.json",
    "docs/research/2026-06-19-doubao-mobile-cdp-analysis.md"
]

let requiredExecutableScripts = [
    "ios/DoubaoNative/Scripts/build-release.sh",
    "ios/DoubaoNative/Scripts/capture-ios-screenshots.sh",
    "ios/DoubaoNative/Scripts/compare-screenshots.swift",
    "ios/DoubaoNative/Scripts/release-readiness.swift",
    "ios/DoubaoNative/Scripts/validate-visual-manifest.swift",
    "ios/DoubaoNative/Scripts/verify-state-scenarios.sh",
    "ios/DoubaoNative/Scripts/verify-local.sh",
    "ios/DoubaoNative/Scripts/visual-manifest-list.swift",
    "ios/DoubaoNative/Scripts/visual-qa.sh"
]

var checks: [Check] = []

let missing = requiredFiles.filter { !exists($0) }
checks.append(missing.isEmpty ? pass("required_files", "\(requiredFiles.count) files present") : fail("required_files", "Missing: \(missing.joined(separator: ", "))"))

let project = read("ios/DoubaoNative/DoubaoNative.xcodeproj/project.pbxproj")
let sourceDirectory = URL(fileURLWithPath: path("ios/DoubaoNative/DoubaoNative"))
let sourceURLs = (try? FileManager.default.contentsOfDirectory(at: sourceDirectory, includingPropertiesForKeys: nil)) ?? []
let swiftSources = sourceURLs
    .filter { $0.pathExtension == "swift" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
let sourceFiles = swiftSources
    .compactMap { try? String(contentsOf: $0, encoding: .utf8) }
    .joined(separator: "\n")

checks.append(project.contains("PRODUCT_BUNDLE_IDENTIFIER = com.healthpilot.DoubaoNative") ? pass("bundle_id", "com.healthpilot.DoubaoNative") : fail("bundle_id", "Bundle identifier missing or changed"))
checks.append(project.contains("IPHONEOS_DEPLOYMENT_TARGET = 17.0") ? pass("deployment_target", "iOS 17.0") : fail("deployment_target", "iOS 17.0 target missing"))
checks.append(project.contains("TARGETED_DEVICE_FAMILY = 1") ? pass("iphone_only", "TARGETED_DEVICE_FAMILY = 1") : fail("iphone_only", "Project is not configured as iPhone-only"))
let swiftSourceNames = swiftSources.map(\.lastPathComponent)
checks.append(swiftSources.isEmpty ? fail("swift_source_inventory", "No native Swift source files found") : pass("swift_source_inventory", "\(swiftSources.count) native Swift source files scanned: \(swiftSourceNames.joined(separator: ", "))"))

let sourceMembershipMissing = swiftSources
    .map(\.lastPathComponent)
    .filter { !project.contains("/* \($0) in Sources */") }
checks.append(sourceMembershipMissing.isEmpty ? pass("xcode_source_membership", "All Swift files are in the app target Sources phase") : fail("xcode_source_membership", "Missing from Sources phase: \(sourceMembershipMissing.joined(separator: ", "))"))

let nonExecutableScripts = requiredExecutableScripts.filter { !FileManager.default.isExecutableFile(atPath: path($0)) }
checks.append(nonExecutableScripts.isEmpty ? pass("executable_scripts", "\(requiredExecutableScripts.count) scripts are executable") : fail("executable_scripts", "Not executable: \(nonExecutableScripts.joined(separator: ", "))"))

checks.append(sourceFiles.contains("protocol AssistantServicing") && sourceFiles.contains("AsyncStream<String>") ? pass("streaming_boundary", "AssistantServicing uses AsyncStream") : fail("streaming_boundary", "Streaming service boundary missing"))
checks.append(sourceFiles.contains("HTTPStreamingAssistantService") && !sourceFiles.contains("https://www.doubao.com") ? pass("no_protected_doubao_calls", "No protected Doubao URL in native source") : fail("no_protected_doubao_calls", "Native source references protected Doubao URL"))

let forbidden = ["Taro", "React", "WebView", "WKWebView", "taro"]
let forbiddenHits = forbidden.filter { sourceFiles.contains($0) }
checks.append(forbiddenHits.isEmpty ? pass("native_stack_only", "No Taro/React/WebView references in native source") : fail("native_stack_only", "Forbidden references: \(forbiddenHits.joined(separator: ", "))"))

let manifestData = try Data(contentsOf: URL(fileURLWithPath: path("design/reference/doubao-mobile/manifest.json")))
let manifestObject = (try JSONSerialization.jsonObject(with: manifestData) as? [String: Any]) ?? [:]
let scenarios = manifestObject["scenarios"] as? [[String: Any]] ?? []
checks.append(scenarios.count == 52 ? pass("visual_manifest", "52 visual parity scenarios") : fail("visual_manifest", "Expected 52 scenarios, found \(scenarios.count)"))

let research = read("docs/research/2026-06-19-doubao-mobile-cdp-analysis.md")
let requiredResearchTerms = ["text/event-stream", "/chat/completion", "creation-image.png", "creation-prompt-ready.png", "creation-image-send-login.png", "creation-image-mic-login.png", "creation-reference-tooltip.png", "creation-ai-cut-login.png", "chat-model-office-login.png", "creation-video-duration-menu.png", "creation-video-ratio-menu.png", "creation-video-prompt-ready.png", "creation-video-upload-login.png", "creation-video-send-login.png", "变清晰", "from_logout=1", "login-area-picker.png", "login-area-selected-hk.png", "login-terms-checked.png", "login-phone-code.png", "login-douyin-consent.png", "login-douyin-oauth.png", "chat-tool-image-login.png", "chat-tool-video-login.png", "chat-tool-recording-download.png", "hidden multi-file input", "chat-title-edit.png", "chat-share-login.png", "chat-mic-login.png", "chat-rate-limit-login.png", "chat-reply-actions.png", "chat-followup-after-click.png", "chat-followup-bottom.png", "chat-promo-download-tap.png", "creation-image-model-selected.png", "creation-ratio-selected.png", "creation-style-selected.png", "Seedream 5.0 Lite", "风格 动漫", "抖音账号授权绑定", "/passport/web/send_code/", "doubao-login-dismissed-2026-06-19.png", "doubao-login-qr-retake-2026-06-19.png", "doubao-account-next-ready-retake-2026-06-19.png", "doubao-account-next-submit-retake-2026-06-19.png", "输入 6 位验证码", "重新发送 57s", "账号登录", "doubao-account-next-ready-2026-06-19.png", "doubao-account-next-submit-2026-06-19.png", "doubao-title-edit-modal-2026-06-19.png", "350 x 168", "输入名称", "doubao-header-share-login-2026-06-19.png", "doubao-mobile-nav-home-2026-06-19.png", "下载电脑版", "doubao-creation-image-empty-mic-2026-06-19.png", "doubao-video-upload-click-2026-06-19.png", "accept=\".jpg,.png,.jpeg,.webp\"", "single-image video upload", "doubao-tool-coding-login-2026-06-19.png", "doubao-tool-transcription-login-2026-06-19.png", "下载豆包电脑版，一键生成录音笔记", "doubao-douyin-one-click-2026-06-19.png", "doubao-douyin-disagree-after-2026-06-19.png", "doubao-douyin-agree-2026-06-19.png", "doubao-writing-tool-login-2026-06-19.png", "doubao-translate-tool-login-2026-06-19.png"]
let missingResearchTerms = requiredResearchTerms.filter { !research.contains($0) }
checks.append(missingResearchTerms.isEmpty ? pass("cdp_research", "Core CDP findings documented") : fail("cdp_research", "Missing terms: \(missingResearchTerms.joined(separator: ", "))"))

let stateTests = read("ios/DoubaoNative/Tests/StateScenarioTests.swift")
let verifyLocal = read("ios/DoubaoNative/Scripts/verify-local.sh")
let stateTestTerms = ["StateScenarioTests", "verifySnapshotFallbacks", "verifyToolRouting", "verifyModelSelection", "verifyAttachmentImport", "verifyCreationReferenceImage", "verifyCreationFeatureAction", "verifyCreationImageOptionSelection", "verifyCreationVideoControls", "verifyTitleEditing", "verifyShareAction", "verifyVoiceInputAction", "verifyRateLimitMessage", "verifyHistoryRouting", "sendSuggestedPrompt", "verifyAsyncActions", "sendCreation()", "requestCreationVideoUpload", "requestCreationVoiceInput", "showShareTooltip", "profile card should open profile details", "recording tool should open reminders", "creationImageModel", "creationImageRatio", "creationImageStyle", "showCreationVideoUploadImporter"]
let missingStateTestTerms = stateTestTerms.filter { !stateTests.contains($0) }
let stateTestsHooked = verifyLocal.contains("ios/DoubaoNative/Scripts/verify-state-scenarios.sh")
if missingStateTestTerms.isEmpty && stateTestsHooked {
    checks.append(pass("state_scenario_tests", "Snapshot and interaction state tests are wired into local verification"))
} else {
    var details: [String] = []
    if !missingStateTestTerms.isEmpty {
        details.append("Missing terms: \(missingStateTestTerms.joined(separator: ", "))")
    }
    if !stateTestsHooked {
        details.append("verify-local.sh does not run verify-state-scenarios.sh")
    }
    checks.append(fail("state_scenario_tests", details.joined(separator: "; ")))
}

let requiredCreationFeatures = ["AI 抠图", "擦除", "区域重绘", "扩图", "变清晰"]
let missingCreationFeatures = requiredCreationFeatures.filter { !sourceFiles.contains($0) }
checks.append(missingCreationFeatures.isEmpty ? pass("creation_feature_inventory", "Creation feature strip includes CDP-observed tools") : fail("creation_feature_inventory", "Missing features: \(missingCreationFeatures.joined(separator: ", "))"))

let requiredImageOptionTerms = ["CreationImageOptions", "Seedream 5.0 Lite", "Seedream 4.0", "16:9", "动漫", "绘本", "selectCreationImageModel", "selectCreationImageRatio", "selectCreationImageStyle"]
let missingImageOptionTerms = requiredImageOptionTerms.filter { !sourceFiles.contains($0) }
checks.append(missingImageOptionTerms.isEmpty ? pass("creation_image_options", "Image model, ratio, and style options match CDP-observed controls") : fail("creation_image_options", "Missing terms: \(missingImageOptionTerms.joined(separator: ", "))"))

let removedAuthTerms = ["enum LoginPrompt", "LoginModalView", "DouyinOAuthView", "openLogin", "showLogin", "LoginModeCornerSwitcher", "PhoneCodeModalView", "showDouyinOAuthPage"]
let remainingAuthTerms = removedAuthTerms.filter { sourceFiles.contains($0) || project.contains($0) }
checks.append(remainingAuthTerms.isEmpty ? pass("login_logic_removed", "Login and third-party OAuth UI logic is absent") : fail("login_logic_removed", "Remaining terms: \(remainingAuthTerms.joined(separator: ", "))"))

let removedDownloadTerms = ["下载电脑版", "showDownloadTooltip", "RecordingDownloadPromptView", "DownloadTooltipView", "requestHeaderDownload", "requestReplyDownloadPromo"]
let remainingDownloadTerms = removedDownloadTerms.filter { sourceFiles.contains($0) || project.contains($0) }
checks.append(remainingDownloadTerms.isEmpty ? pass("desktop_download_removed", "Desktop download entry points and prompts are absent") : fail("desktop_download_removed", "Remaining terms: \(remainingDownloadTerms.joined(separator: ", "))"))

let requiredVideoControlTerms = ["creationVideoDuration", "creationVideoRatio", "CreationVideoDurationMenuView", "CreationVideoRatioMenuView", "showCreationVideoUploadImporter", "supportedCreationVideoUploadTypes", "添加照片，描述你想生成的视频", "\"5s\"", "\"10s\"", "\"21:9\""]
let missingVideoControlTerms = requiredVideoControlTerms.filter { !sourceFiles.contains($0) }
checks.append(missingVideoControlTerms.isEmpty ? pass("creation_video_controls", "Video duration and ratio menus match CDP-observed controls") : fail("creation_video_controls", "Missing terms: \(missingVideoControlTerms.joined(separator: ", "))"))

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
print(String(data: try encoder.encode(checks), encoding: .utf8)!)

if checks.contains(where: { $0.status != "pass" }) {
    exit(1)
}
