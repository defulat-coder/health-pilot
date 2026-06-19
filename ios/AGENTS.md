# iOS Agent Guide

本文件适用于 `ios/` 目录。当前原生客户端位于 `ios/DoubaoNative`。

## 项目定位

`DoubaoNative` 是 Health Pilot 的原生 iOS 首个移动端切片：用 SwiftUI 实现类似 Doubao mobile 的聊天壳、侧边栏、工具菜单、AI 创作页、登录/受限能力提示和健康数据卡片。它是原生 iOS 项目，不是 Taro、React、WebView 或小程序运行时。

## 技术与结构

- 语言/框架：Swift、SwiftUI、iOS 17+。
- 工程：`ios/DoubaoNative/DoubaoNative.xcodeproj`，scheme 为 `DoubaoNative`。
- 入口：`DoubaoNative/DoubaoNativeApp.swift`。
- 状态容器：`DoubaoNative/AppState.swift`，`@MainActor ObservableObject` 管理路由、overlay、聊天、创作和健康摘要状态。
- 服务边界：`AssistantServicing`，默认使用 `MockAssistantService`；`HTTPStreamingAssistantService` 是可替换的一方后端适配层。
- 视觉参考：`design/reference/doubao-mobile/manifest.json` 和同目录截图。
- 截图/验证脚本：`ios/DoubaoNative/Scripts/`。

## 编码规则

- 保持 SwiftUI 原生实现；不要引入 WebView、WKWebView、React、Taro 或小程序运行时。
- 不要调用或硬编码 Doubao 受保护接口、cookie、token 或瞬态请求参数。
- 新状态优先放入 `AppState`，让 view 只表达布局和交互绑定；避免在多个 view 中复制业务状态。
- 网络/后端调用必须通过 `AssistantServicing` 边界，便于 mock、截图场景和后端联调切换。
- 截图场景需要确定性。新增可截图状态时，同时更新 `SnapshotScenario`、`AppState.applySnapshotScenario`、manifest 和脚本覆盖。
- 保持 `accessibilityIdentifier` 用于关键 root、overlay 和截图自动化节点。

## UI 与产品规则

- 遵守根目录 `PRODUCT.md` 与 `DESIGN.md`：聊天优先、轻量、克制、移动端原生节奏。
- 使用接近白色的画布、白色面板、灰色 chips、黑色主文字和单一蓝色强调。
- 不使用紫蓝渐变、金色装饰、重仪表盘、医疗后台视觉或高压打卡风格。
- Health Pilot 可以复用 Doubao mobile 的交互模式，但不要复制 Doubao 品牌资产。
- 文案保持简洁、温和、明确；健康建议避免诊断式表达。

## 常用命令

从仓库根目录运行：

```bash
xcodebuild -project ios/DoubaoNative/DoubaoNative.xcodeproj -list

ios/DoubaoNative/Scripts/verify-local.sh

SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
xcrun swiftc -typecheck \
  -sdk "$SDK_PATH" \
  -target arm64-apple-ios17.0-simulator \
  ios/DoubaoNative/DoubaoNative/*.swift
```

有 iOS Simulator runtime 时可构建：

```bash
xcodebuild \
  -project ios/DoubaoNative/DoubaoNative.xcodeproj \
  -scheme DoubaoNative \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath ios/DoubaoNative/.derivedData \
  build
```

视觉 QA：

```bash
ios/DoubaoNative/Scripts/capture-ios-screenshots.sh
ios/DoubaoNative/Scripts/visual-qa.sh
```

`verify-local.sh` 会做 Swift typecheck、plist/scheme lint、脚本语法检查、状态场景测试、manifest 校验、release readiness 和参考集 compare。改 UI 时优先跑它；如果环境缺少 iOS SDK 或 simulator，要在最终说明中明确。

## 生成物

不要提交 `ios/DoubaoNative/.derivedData/`、临时 probe 截图、未审阅的新 PNG 或本机 Xcode 用户状态。确实需要更新截图基准时，说明来源、场景名和 manifest 变更。
