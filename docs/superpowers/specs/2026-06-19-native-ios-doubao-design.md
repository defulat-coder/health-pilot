# Native iOS Doubao Parity Design

Date: 2026-06-19
Status: approved for first implementation slice
Target: iOS native, mobile-first, no Taro, no WebView shell

## Objective

Build a production-ready native iOS app that mirrors the mobile Doubao chat experience closely enough for iterative screenshot comparison, while using local mock services for protected Doubao APIs. The first slice covers the logged-out mobile chat surface, sidebar navigation, authentication prompts, model and tool menus, and the AI creation image/video entry point.

## Platform Decision

- Use Swift and SwiftUI as the primary implementation stack.
- Use SF Symbols and native controls where they match the observed interaction.
- Avoid Taro, React, cross-platform shells, and WebView-based cloning.
- Keep all proprietary network calls mocked behind a service protocol so the product can later connect to first-party APIs.
- Represent streamed chat responses as an `AsyncStream` boundary to match the observed `text/event-stream` behavior.

## Chrome/CDP Findings To Match

### Chat Home

- Mobile viewport baseline: 390 x 844 points.
- Header:
  - Left sidebar icon around x=16, y=15.
  - Conversation state has a second compact icon that opens `编辑对话名称`.
  - Conversation state has a compact share icon; logged-out sharing shows a small `分享对话` tooltip and opens the login modal without an intermediate share sheet.
  - Center title `新对话`, subtitle `AI 生成可能有误 请核实`.
  - Right buttons: Apple-icon `下载电脑版` pill and black `登录`.
  - Current CDP retest shows `下载电脑版` produces no visible state change in the mobile web page, while `登录` opens the login modal.
- Main empty state:
  - Primary title `有什么我能帮你的吗？`.
  - Multi-row horizontal suggestion chips with 42 point height, 12 point radius, subtle gray background.
  - Suggestion chips send immediately and leave the composer empty.
- Reply state:
  - User message bubbles use a light gray fill with dark text in the observed mobile UI.
  - Short assistant replies show follow-up chips and a `下载豆包电脑版，体验更强大的 AI 能力` promo card.
  - Tapping the assistant reply body keeps the reply area unchanged; no copy, like/dislike, or read-aloud action bar appears in the observed mobile state.
  - Tapping `你能做些什么？` sends immediately in the same conversation, calls `/chat/completion`, keeps the current `/chat/{id}` route, and does not require login.
  - Long follow-up answers show a floating down-arrow affordance above the composer and, at the bottom, suggested next prompts plus the same download promo.
  - Tapping the reply-level download promo does not open login or navigate in the observed mobile state.
- Title edit modal:
  - Opens as a centered dialog over a darkened conversation page.
  - 390 x 844 CDP capture measured a 350 x 168 white surface at x=20, y=338 with 12 point radius.
  - Header text is `编辑对话名称`, with a right-aligned x close affordance.
  - Name field uses placeholder `输入名称`, 14 point text, 30 point height, and a thin gray rectangular border.
  - Bottom actions are right-aligned `取消` and blue `确定` buttons, each 80 x 38 with 10 point radius.
- Composer:
  - Fixed bottom white panel, 24 point radius, shadow.
  - Placeholder `发消息...`.
  - Toolbar: add, model selector `快速`, more selector `更多`, mic/send.
  - Add opens native iOS file import for documents and images; it is not a logged-out login gate.
  - Empty-state mic opens the login modal when logged out; no recording panel appears before login.
  - If anonymous usage is exhausted, sending keeps the composer text, shows `已达使用上限，请登录以解锁该限制。`, and opens login.
  - When text exists, mic becomes blue circular send button.

### Sidebar

- Width: 280 points, left-aligned.
- Light gray background.
- Items:
  - `豆包`
  - `新对话`
  - `新办公任务`
  - `AI 创作`
  - `历史对话` conversation history rows when history is available
  - Bottom `关于豆包` and download icon.
- Current item uses white selected background.
- `新办公任务` closes the drawer and returns to an empty `新对话` chat; current CDP shows `/chat/?from_logout=1` with no visible login or office-only panel.
- `AI 创作` navigates to the creation screen.
- `新办公任务` returns to chat in the logged-out observed state.
- History rows open their corresponding chat locally and close the drawer.
- The footer `关于豆包` icon opens the legal popover; the adjacent footer icon collapses the drawer in the observed mobile layout.

### Menus

- More menu appears above composer with 12 tool rows:
  - PPT 生成
  - 图像生成
  - 帮我写作
  - 视频生成
  - 翻译
  - 编程
  - 深入研究
  - AI 播客
  - 录音转写
  - 音乐生成
  - 解题答疑
  - 数据分析
- Selecting logged-out chat tools, including PPT, image generation, video generation, writing, translation, coding, deep research, AI podcast, music generation, problem solving, and data analysis, opens the login modal.
- Tool-gated login states close the menu and leave the user on `/chat`; the phone field may be focused in the web reference screenshot.
- `录音转写` is a desktop-only exception in the observed mobile web state: it keeps `/chat`, leaves the tool menu visible behind the overlay, does not request passport/login or `/chat/completion`, and opens a centered prompt titled `下载豆包电脑版，一键生成录音笔记`.
- The recording prompt shows three bullets: `自动识别录音，实时转写文字`, `智能整理成结构化笔记，方便回顾`, and `随时提问，基于转写内容快速答疑`, plus the CTA `请在电脑上下载使用`.
- Model menu has:
  - 快速 / 适用于大部分情况
  - 专家 / 深度思考/研究级智能模型
  - 办公任务 / 能执行任务的模型
- Logged-out `专家` and `办公任务` selections both open account login and keep `快速` selected.

### Login Modal

- Full-screen dark overlay.
- Centered white card, 24 point radius.
- Account mode:
  - Title `登录以解锁更多功能`.
  - Phone field row with area selector, default `+86`, placeholder `请输入手机号`.
  - Disabled `下一步` until input is valid.
  - Terms checkbox and legal text.
  - Douyin one-click entry.
- Accepted terms alone keeps `下一步` disabled until a valid phone number is present.
- Tapping enabled `下一步` requests the phone verification-code boundary, keeps `/chat`, and replaces the account form with a centered verification-code modal. The modal shows `输入 6 位验证码`, `验证码已发送至 +86 13800138000`, six code boxes, and `重新发送 57s`; it must not mark the user logged in.
- Tapping the dark backdrop closes the modal, clears nested login popovers, and leaves the current route unchanged.
- Tapping `抖音一键登录` before accepting terms opens a service confirmation dialog titled `服务协议及隐私保护`.
- The service confirmation shows `不同意` and `同意`. CDP verified that `不同意` returns to the unchecked login form without navigation.
- `同意` navigates away from `/chat` to the mobile Douyin authorization page (`抖音账号授权绑定`) with phone, verification code, `发送验证码`, pink `抖音登录`, and a separate Douyin-side agreement checkbox. The native app mirrors this as a full-screen safety-boundary view and must not submit a real third-party authorization flow.
- QR mode:
  - Same title.
  - Opened by the top-right folded blue QR corner.
  - Large QR block centered in the modal.
  - Text `打开 豆包 App - 点击扫一扫`.
  - The folded corner switches to account-login mode and shows the black tooltip `账号登录`.
- Area dropdown:
  - `+86 中国大陆`
  - `+852 中国香港`
  - `+853 中国澳门`
  - `+886 中国台湾`
- Selecting `+852 中国香港` closes the dropdown and keeps the account login modal open with the selector showing `+852`.

### About Popover

- Opens from sidebar bottom.
- Contains links and filing/company text:
  - 联系我们
  - 用户协议
  - 隐私政策
  - 侵权投诉
  - 北京市西城区阜成门外大街31号4层408D
  - 京ICP备2023020373号-1
  - 京B2-20241987
  - 京网文〔2024〕4578-215号
  - 北京春田知韵科技有限公司
  - 京公网安备11010802045808

### AI Creation And Video Generation

- Image creation header title `AI 创作`.
- Image creation main copy:
  - Title `AI 创作`
  - Subtitle `让创作随灵感而生`
- Image creation main copy is centered in the mobile viewport.
- Image creation composer:
  - White rounded card with placeholder `描述你想要的图片`.
  - Segmented control `图像` / `视频`.
  - Image mode toolbar includes `参考图`, options, mic/send.
  - `参考图` opens the native image picker/importer and shows `最多支持上传 10 张图片`; it is not a logged-out login gate.
  - Empty image-mode mic opens `登录以解锁更多功能`; CDP observed no microphone permission prompt, file chooser, or `/chat/completion` before login.
  - Typed image prompts switch the right composer control to the active blue send arrow.
  - Logged-out image send keeps `/chat/create-image`, retains the typed prompt, opens `登录以解锁更多功能`, and does not create a local result before login.
- Image creation options:
  - More menu starts with `Seedream 4.5`, `比例`, and `风格`.
  - The image model submenu contains `Seedream 5.0 Lite`, `Seedream 4.5`, and `Seedream 4.0`.
  - The image ratio submenu contains `1:1`, `2:3`, `3:4`, `4:3`, `9:16`, and `16:9` rows with observed usage copy.
  - The style submenu contains thumbnail rows for the observed current style list through `绘本`.
  - Selecting model, ratio, or style closes the submenu, keeps `/chat/create-image`, does not open login, and updates the more-menu row label, e.g. `Seedream 5.0 Lite`, `比例 16:9`, `风格 动漫`.
- Feature strip uses horizontal tool cards:
  - AI 抠图
  - 擦除
  - 区域重绘
  - 扩图
  - 变清晰
- Logged-out feature cards such as `AI 抠图` open the login modal over the creation page and keep the `/chat/create-image` context.
- Image masonry should use original generated/local placeholders, not copied Doubao assets.
- Video generation uses a separate `/chat/create-video` workspace:
  - Header title `视频生成`.
  - Main copy `自由运镜，图片文字一键成片`.
  - First viewport shows large video example cards above a fixed bottom composer.
  - Clean bottom composer shows `上传图片`, placeholder `添加照片，描述你想生成的视频`, `Seedance 2.0 Fast`, more/options, and a disabled send arrow.
  - Video upload is login-gated while logged out: tapping `上传图片` keeps `/chat/create-video`, opens `登录以解锁更多功能`, does not show the multi-reference tooltip, and does not open a file chooser before login.
  - The underlying video upload input is single-file and supports `jpg`, `jpeg`, `png`, and `webp` for the authenticated/future adapter path.
  - Logged-out video send opens login, retains the typed prompt, and does not create a local result before login.

## Interaction Model

- App state is local and deterministic in this slice.
- Chat send streams mock assistant text into the conversation.
- Empty composer voice input is a logged-out gated action and opens the native login modal.
- Empty image creation voice input is also a logged-out gated action and keeps the user on the creation image surface.
- Anonymous usage-limit state is deterministic in snapshots and preserves the typed composer text.
- Sending `你好` maps to the observed greeting flow, including `问候与帮助`, follow-up chips, and a download prompt row.
- Sidebar history is represented by deterministic local conversations, matching the observed `/chat/{id}` navigation shape without calling protected Doubao endpoints.
- Direct `submitCreation()` remains a local service-boundary helper, but the visible logged-out creation send path is login-gated for both image and video.
- Creation prompt-ready snapshot uses `生成一张蓝色机器人产品海报` to verify the active send control.
- Login, model choice, menu choice, selected area code, and route are held in observable state.
- Login account/QR switching uses the same state action as the folded-corner control and clears nested popovers without dismissing login.
- Login phone-code requesting uses a second visible modal state so the post-`下一步` boundary is testable without sending a real verification code.
- Header download uses `AppState.requestHeaderDownload()` and does not open login in the current mobile reference.
- Area code selection uses `AppState.selectAreaCode(_:)` so the visual snapshot and tap interaction share one state path.
- Terms acceptance uses `AppState.toggleTermsAccepted()` and remains independent from phone validation.
- All gated logged-out actions open the native login modal.

## Visual QA Targets

- Build for iPhone portrait first.
- The app should support deterministic launch scenarios for screenshot capture.
- `design/reference/doubao-mobile/manifest.json` is the source of truth for visual parity states.
- The screenshot capture script must read scenario names and output filenames from the manifest.
- The native snapshot enum and comparison script must stay in manifest alignment.
- Every manifest snapshot must have a matching `AppState.applySnapshotScenario` implementation.
- Reference and candidate screenshot directories must fail validation if they contain undeclared PNG files.
- `ios/DoubaoNative/Scripts/visual-qa.sh` should run the full capture-and-compare loop when an iOS Simulator runtime is installed.
- Capture baseline screens when an iOS Simulator runtime is available:
  - Chat empty state.
  - Chat with a mock answer.
  - Chat composer send-ready state.
  - Chat after sending a benign prompt.
  - Chat short reply actions.
  - Chat reply body tap unchanged state.
  - Chat follow-up prompt long answer.
  - Chat follow-up answer bottom.
  - Chat reply download promo tap.
  - Sidebar open.
  - About popover.
  - Login account mode.
  - Login QR mode.
  - Login area code picker.
  - Login after selecting the Hong Kong area code.
  - Login after checking terms with an empty phone input.
  - More menu.
  - Model menu.
  - AI Creation image tab.
  - AI Creation image prompt ready state.
  - AI Creation image send login state.
  - AI Creation empty image mic login state.
  - AI Creation reference-image upload limit tooltip.
  - AI Creation feature-card gated login.
  - AI Creation image model selected state.
  - AI Creation image ratio selected state.
  - AI Creation image style selected state.
  - AI Creation video generation workspace.
  - AI Creation video model menu.
- Compare layout by major geometry, text content, layering, radii, spacing, and interaction state.

## Non-Goals For First Slice

- No real Doubao authentication.
- No scraping or reusing proprietary image assets.
- No network traffic to protected Doubao endpoints from the native app.

## Deployment Requirements

- The iOS project must open directly in Xcode.
- Local verification that does not require a simulator runtime must be runnable through `ios/DoubaoNative/Scripts/verify-local.sh`.
- Release readiness must be auditable through `ios/DoubaoNative/Scripts/release-readiness.swift`.
- Release readiness must scan the full native Swift source inventory for forbidden stack references and service boundary coverage.
- Release archive generation must be available through `ios/DoubaoNative/Scripts/build-release.sh` on a machine with installed iOS platform components and signing configured.
- No Android, Taro, web, or mini-program runtime.
