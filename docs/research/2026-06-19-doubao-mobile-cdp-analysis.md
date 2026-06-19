# Doubao Mobile CDP Analysis

Date: 2026-06-19
Source: `https://www.doubao.com/chat`
Capture method: Chrome extension + CDP mobile emulation

## Capture Environment

- Viewport: 390 x 844
- Device scale factor: 3
- Touch emulation: enabled
- User agent: iPhone Safari style
- Reference assets: `design/reference/doubao-mobile/`

## Reference Screens

- `chat-home.png`: logged-out chat home; latest CDP retake for the current header copy is stored at `docs/research/artifacts/doubao-mobile-nav-home-2026-06-19.png`.
- `chat-send-ready.png`: chat composer with typed text and active send button.
- `chat-after-send.png`: chat after a benign `你好` test prompt.
- `chat-reply-actions.png`: short assistant reply state with follow-up chips and the download promo card.
- `chat-reply-tapped.png`: tapping the assistant reply body leaves the visible reply area unchanged.
- `chat-followup-after-click.png`: tapping `你能做些什么？` immediately sends that prompt and appends a long answer in the same conversation.
- `chat-followup-bottom.png`: long answer bottom with suggested next prompts and the download promo card.
- `chat-promo-download-tap.png`: tapping the reply download promo keeps the chat visible without opening login.
- `chat-title-edit.png`: conversation title edit modal opened from the conversation header; CDP corroboration is stored at `docs/research/artifacts/doubao-title-edit-modal-2026-06-19.png`.
- `chat-share-login.png`: selecting `分享对话` from a logged-out conversation header; CDP corroboration is stored at `docs/research/artifacts/doubao-header-share-login-2026-06-19.png`.
- `chat-mic-login.png`: selecting the empty composer voice input from logged-out chat.
- `chat-rate-limit-login.png`: sending after the anonymous usage limit opens login and a top toast.
- `sidebar.png`: left drawer opened from the header.
- `about.png`: about popover opened from the drawer.
- `sidebar-download-tooltip.png`: desktop download tooltip opened from the drawer footer icon.
- `login-account.png`: logged-out login modal in phone account mode.
- `login-phone-ready.png`: login modal after phone input and terms acceptance.
- `login-phone-code.png`: phone verification code modal after tapping enabled `下一步`; CDP ready/submit retakes are stored at `docs/research/artifacts/doubao-account-next-ready-retake-2026-06-19.png` and `docs/research/artifacts/doubao-account-next-submit-retake-2026-06-19.png`.
- `login-qr.png`: login modal in QR mode; CDP retake is stored at `docs/research/artifacts/doubao-login-qr-retake-2026-06-19.png`.
- `login-area-picker.png`: account login area code picker.
- `login-area-selected-hk.png`: account login after selecting `+852 中国香港`.
- `login-terms-checked.png`: account login after accepting terms with an empty phone field.
- `chat-model-menu.png`: bottom composer model menu.
- `chat-model-expert-login.png`: selecting the `专家` model from the logged-out model menu.
- `chat-model-office-login.png`: selecting the `办公任务` model from the logged-out model menu.
- `chat-tool-menu.png`: bottom composer more/tools menu.
- `chat-tool-ppt-login.png`: selecting `PPT 生成` from the logged-out tool menu.
- `chat-tool-image-login.png`: selecting `图像生成` from the logged-out tool menu.
- `chat-tool-video-login.png`: selecting `视频生成` from the logged-out tool menu.
- `chat-tool-recording-download.png`: selecting `录音转写` from the logged-out tool menu; CDP corroboration is stored at `docs/research/artifacts/doubao-tool-transcription-login-2026-06-19.png`.
- `creation-image.png`: AI creation image tab.
- `creation-prompt-ready.png`: AI creation image prompt with an active send button.
- `creation-image-send-login.png`: sending a logged-out image prompt opens login and retains the prompt.
- `creation-image-mic-login.png`: tapping the empty image composer voice input opens login; CDP corroboration is stored at `docs/research/artifacts/doubao-creation-image-empty-mic-2026-06-19.png`.
- `creation-reference-tooltip.png`: tapping `参考图` on the image tab; the page stays on `/chat/create-image` and shows the upload limit tip.
- `creation-ai-cut-login.png`: tapping `AI 抠图` in the logged-out feature strip opens login.
- `creation-video.png`: AI creation video generation workspace.
- `creation-video-model-menu.png`: AI creation video model menu.
- `creation-video-duration-menu.png`: AI creation video duration menu.
- `creation-video-ratio-menu.png`: AI creation video ratio submenu.
- `creation-video-prompt-ready.png`: AI creation video prompt with an active send button.
- `creation-video-upload-login.png`: tapping video `上传图片` while logged out opens login and keeps the empty prompt; CDP corroboration is stored at `docs/research/artifacts/doubao-video-upload-click-2026-06-19.png`.
- `creation-video-send-login.png`: sending a logged-out video prompt opens login.
- `creation-more-menu.png`: AI creation image more/options menu.
- `creation-image-model-menu.png`: AI creation image model submenu.
- `creation-ratio-menu.png`: AI creation image ratio submenu.
- `creation-style-menu.png`: AI creation image style submenu.
- `creation-image-model-selected.png`: selecting `Seedream 5.0 Lite` updates the more menu model row.
- `creation-ratio-selected.png`: selecting `16:9` updates the more menu ratio row to `比例 16:9`.
- `creation-style-selected.png`: selecting `动漫` updates the more menu style row to `风格 动漫`.

All reference captures are 390 x 844 PNG files and should be compared against native iOS screenshots generated by `ios/DoubaoNative/Scripts/capture-ios-screenshots.sh`.
The canonical comparison set is declared in `design/reference/doubao-mobile/manifest.json`; capture, validation, comparison, and `visual-qa.sh` all use this manifest.

## Chat Home Layout

Observed in `chat-home.png`.

- Header height is roughly 56 points.
- Left header action is a compact sidebar icon.
- Conversation pages show a second compact icon that opens `编辑对话名称`.
- Conversation pages show a compact `分享对话` header button after the assistant response is available; selecting it while logged out shows a small black `分享对话` tooltip and opens the login modal.
- Center title is `新对话` with the subtitle `AI 生成可能有误 请核实`.
- Right header actions are an Apple-icon `下载电脑版` pill and black `登录` in the current 390 x 844 iPhone reference screenshot.
- Tapping `下载电脑版` showed no visible UI change in the mobile web page, kept `/chat`, emitted `/samantha/user/setting/get` plus analytics, and did not open login or a dialog; tapping the adjacent `登录` button opened the login modal and kept the URL on `/chat`.
- Main empty state centers `有什么我能帮你的吗？` with a 28 point bold visual weight.
- Suggestion chips use light gray fill, 12 point radius, horizontal overflow, and multiple stacked rows.
- Tapping a suggestion chip immediately creates/opens a conversation and renders the answer; it does not prefill the composer.
- A suggestion-created conversation lazily loads the conversation route bundle, updates the URL to `/chat/{id}`, and exposes the conversation header actions.
- Tapping the conversation title edit icon opens a centered `role=dialog` titled `编辑对话名称`; the 390 x 844 capture measured a 350 x 168 white dialog at x=20, y=338, a 30 point high name input with placeholder `输入名称`, a right-aligned close x, and bottom-right `取消` / blue `确定` buttons.
- Tapping the logged-out conversation header share button kept the current `/chat/{id}` URL, showed the `分享对话` tooltip, loaded login modal assets, requested `/passport/web/get_qrcode/`, and started QR polling; no intermediate share sheet or native browser share prompt was observed.
- After a short `你好` reply, mobile shows follow-up chips and a `下载豆包电脑版，体验更强大的 AI 能力` promo card below the answer. No copy, like/dislike, or read-aloud action bar was visible, and tapping the assistant reply body did not reveal one.
- Tapping the `你能做些什么？` follow-up chip sends the prompt immediately inside the same conversation, keeps the URL on the current `/chat/{id}` route, and calls `/chat/completion`; it does not require login.
- The long follow-up answer auto-scrolls to the new answer and shows a floating down-arrow affordance above the composer. Its bottom state shows suggested next prompts plus the same desktop-download promo card.
- Tapping the reply-level desktop-download promo card did not open login, a modal, or a route change in the observed mobile state. CDP observed a hover/background asset request, `/samantha/user/setting/get`, and analytics/monitoring calls while the chat stayed visible.
- Bottom composer is fixed, white, rounded around 24 points, and elevated with shadow.
- Composer placeholder is `发消息...`.
- Toolbar includes plus, `快速`, `更多`, and mic/send.
- Tapping the plus button does not open login or a web modal. It activates a hidden multi-file input.
- Accepted attachment extensions observed from the input include PDF, TXT, CSV, Word, Excel, PowerPoint, Markdown, MOBI, EPUB, PNG, JPEG, JPG, and WEBP.
- Tapping the mic button with an empty logged-out composer opens the login modal. No recording panel or browser microphone permission prompt was observed before login.

Native mapping:

- `ChatView` implements the header, empty state, multi-row suggestions, and message list.
- `TopHeaderView` preserves the observed logged-out share tooltip while opening the login gate from a conversation header.
- `ChatView` implements the observed reply follow-up chips, long follow-up answer states, and reply-level download promo without treating the promo as a login gate.
- `TitleEditModalView` implements the observed conversation title editor geometry, close affordance, input placeholder, and cancel/confirm actions.
- `ComposerView` implements the bottom input card and toolbar.
- The native plus button opens an iOS file importer with the observed document and image type coverage.
- `AppState.requestHeaderDownload()` mirrors the current visible mobile behavior for the header `下载电脑版` action: it closes transient overlays without opening login.
- `AppState.startVoiceInput()` gates logged-out voice input behind the login modal.
- `AssistantServicing` is the service boundary for streaming-style chat responses through `AsyncStream`.
- `AppState.sendChat()` consumes deterministic mock stream chunks from `MockAssistantService`.

## Sidebar Interaction

Observed in `sidebar.png`, `about.png`, and `sidebar-download-tooltip.png`.

- Drawer opens from the left and occupies around 280 points.
- Backdrop dims the remaining viewport.
- Top brand text is `豆包`.
- Primary rows are `新对话`, `新办公任务`, and `AI 创作`.
- Tapping `新办公任务` while logged out closes the drawer and returns to the empty chat home. The URL becomes `/chat/?from_logout=1`; no login modal, office-specific panel, or visible route-specific state appears.
- Logged-in/remembered browser state can also show a `历史对话` conversation list below the primary rows. The visible rows are normal `/chat/{id}` links, and selecting one loads that conversation and closes the drawer.
- Selected row uses a white rounded background.
- Bottom actions include `关于豆包` and a download icon.
- Tapping the bottom download icon shows a small black tooltip, `下载 豆包 电脑版`.
- Opening the sidebar triggered `mcs.doubao.com/list`, used for experiment/analytics rather than chat content rendering.
- The bottom `关于豆包` action opens the legal/about popover; the adjacent icon collapses the sidebar.

Native mapping:

- `SidebarView` implements drawer geometry, route changes, close behavior, the about popover, and the desktop download tooltip.
- `SidebarView` renders a local `历史对话` history list for parity with the observed mobile drawer.
- `AppState.navigate(to:)` owns route transitions.
- `AppState.startOfficeTask()` mirrors the observed `新办公任务` behavior by closing drawer UI and returning to an empty `新对话` chat instead of preserving any currently opened conversation.
- `AppState.openHistoryConversation(_:)` loads a deterministic local conversation and closes the drawer.

## Login Interaction

Observed in `login-account.png`, `login-qr.png`, `login-area-picker.png`, `login-area-selected-hk.png`, `login-terms-checked.png`, `login-douyin-consent.png`, `login-douyin-oauth.png`, `docs/research/artifacts/doubao-login-dismissed-2026-06-19.png`, `docs/research/artifacts/doubao-account-next-ready-2026-06-19.png`, `docs/research/artifacts/doubao-account-next-submit-2026-06-19.png`, `docs/research/artifacts/doubao-account-next-ready-retake-2026-06-19.png`, `docs/research/artifacts/doubao-account-next-submit-retake-2026-06-19.png`, `docs/research/artifacts/doubao-douyin-one-click-2026-06-19.png`, `docs/research/artifacts/doubao-douyin-disagree-after-2026-06-19.png`, and `docs/research/artifacts/doubao-douyin-agree-2026-06-19.png`.

- Modal uses a full-screen dark overlay.
- Card is white with 24 point radius and nearly full mobile width.
- Account mode contains:
  - Title `登录以解锁更多功能`.
  - Area code selector, default `+86`.
  - Phone input placeholder `请输入手机号`.
  - Disabled `下一步` button before valid phone and terms acceptance.
  - Terms checkbox and Douyin one-click login.
- After entering a valid phone number and checking the terms checkbox, `下一步` becomes enabled with a black fill.
- Tapping the enabled `下一步` button with a synthetic phone-shaped value kept the URL on `/chat`, emitted `POST /passport/web/send_code/`, analytics, and QR polling requests, then replaced the account form with a centered 358 x 266 verification-code modal. The visible modal has top-left back affordance, top-right help icon, title `输入 6 位验证码`, subtitle `验证码已发送至 +86 13800138000`, six code boxes, and disabled resend text `重新发送 57s`.
- Checking the terms checkbox while the phone input is empty turns the checkbox blue but keeps `下一步` disabled.
- QR mode is opened from the top-right folded blue QR corner. It keeps the same title, swaps form fields for a roughly 200 point QR block, shows `打开 豆包 App - 点击扫一扫`, and changes the folded corner affordance to account-login mode with a black `账号登录` tooltip.
- The 2026-06-19 retake found the previous `login-qr.png` capture was an account-mode duplicate; the reference PNG now uses the real QR mode screenshot from `docs/research/artifacts/doubao-login-qr-retake-2026-06-19.png`.
- Opening the area picker shows `+86 中国大陆`, `+852 中国香港`, `+853 中国澳门`, and `+886 中国台湾`.
- Selecting `+852 中国香港` closes the picker and updates the selector label to `+852`.
- Opening login from the header kept the URL on `/chat`, loaded `component-login-modal`, requested `/passport/web/get_qrcode/`, and started `/passport/web/check_qrconnect/` polling.
- Tapping the dark backdrop outside the login card dismissed the modal, left the URL on `/chat`, returned to the chat home, and did not emit additional passport/login request events in the sampled CDP window.
- Tapping `抖音一键登录` before checking the agreement did not close the login modal and did not open a new tab or navigate away from `/chat`.
- The Douyin entry opened a centered service confirmation dialog titled `服务协议及隐私保护`, with copy `已阅读并同意 用户协议、隐私政策、豆包账号服务须知` and buttons `不同意` / `同意`.
- In the sampled CDP window, the Douyin click emitted analytics and ongoing `/passport/web/check_qrconnect/` polling only; no external Douyin/OAuth navigation was observed before accepting the service confirmation.
- Tapping `不同意` closed only the service confirmation, kept the account login modal open, left the agreement checkbox unchecked, preserved `/chat`, and did not trigger any external login navigation in the sampled CDP window.
- Tapping `同意` left `/chat` and navigated the same mobile tab to `open.douyin.com/platform/oauth/mobile/auth...`; the new page title was `抖音账号授权绑定`.
- The first visible Douyin authorization state showed `使用抖音账号登录 豆包`, a Douyin-to-account icon row, phone and verification-code fields, `发送验证码`, a pink `抖音登录` button, a separate Douyin-side agreement checkbox, and footer copy `由抖音提供个人信息安全保障`.

Native mapping:

- `LoginModalView` implements account mode, QR mode, area picker, terms state, and phone validation.
- `AppState.loginPrompt` preserves the CDP-observed title difference: normal logged-out gates use `登录以解锁更多功能`, while model gates use `登录后使用专家模式`.
- `AppState.toggleLoginMode()` mirrors the folded-corner account/QR switch and clears nested login popovers while keeping the modal open.
- `AppState.selectAreaCode(_:)` stores the selected area code and closes the picker.
- `AppState.toggleTermsAccepted()` mirrors the checkbox toggle and preserves the phone requirement for `下一步`.
- `AppState.requestPhoneCode()` mirrors the phone-code request boundary by keeping the modal visible and not marking the user logged in.
- `PhoneCodeModalView` mirrors the post-`下一步` verification-code modal and lets the back affordance return to the phone form without logging in.
- `AppState.dismissLogin()` mirrors the observed backdrop dismissal by hiding the modal, clearing nested login popovers, and leaving the current route intact.
- `AppState.requestDouyinLogin()`, `rejectDouyinConsent()`, and `acceptDouyinConsent()` mirror the local service-confirmation layer; accepting or pre-accepting the Doubao agreement opens `DouyinOAuthView`, a native safety-boundary rendition of the mobile Douyin authorization page without submitting a real third-party authorization flow.
- Gated logged-out actions call `AppState.openLogin(prompt:)` so later gates do not inherit stale modal copy from earlier entrances.

## Chat Menus

Observed in `chat-model-menu.png`, `chat-model-expert-login.png`, `chat-tool-menu.png`, `chat-tool-ppt-login.png`, `chat-tool-image-login.png`, `chat-tool-video-login.png`, `chat-tool-recording-download.png`, `docs/research/artifacts/doubao-writing-tool-login-2026-06-19.png`, `docs/research/artifacts/doubao-translate-tool-login-2026-06-19.png`, `docs/research/artifacts/doubao-tool-coding-login-2026-06-19.png`, `docs/research/artifacts/doubao-tool-deep-research-login-2026-06-19.png`, `docs/research/artifacts/doubao-tool-ai-podcast-login-2026-06-19.png`, `docs/research/artifacts/doubao-tool-music-login-2026-06-19.png`, `docs/research/artifacts/doubao-tool-problem-solving-login-2026-06-19.png`, and `docs/research/artifacts/doubao-tool-data-analysis-login-2026-06-19.png`.

Model menu:

- Triggered from `快速`.
- Options:
  - `快速`
  - `专家`
  - `办公任务`
- Selected option shows a check.
- In the logged-out state, selecting `专家` opens the login modal instead of switching the selected model.
- Selecting `办公任务` while logged out has the same gate: URL remains `/chat`, the menu closes, and account login opens. The visible login modal title remains `登录后使用专家模式`.

Tool menu:

- Triggered from `更多`.
- Options include:
  - `PPT 生成`
  - `图像生成`
  - `帮我写作`
  - `视频生成`
  - `翻译`
  - `编程`
  - `深入研究`
  - `AI 播客`
  - `录音转写`
  - `音乐生成`
  - `解题答疑`
  - `数据分析`
- In the logged-out state, selecting gated tools such as `PPT 生成`, `图像生成`, `视频生成`, `帮我写作`, `翻译`, `编程`, `深入研究`, `AI 播客`, `音乐生成`, `解题答疑`, and `数据分析` opens the login modal while the URL remains `/chat`.
- The tool-gated login modal closes the tool menu and focuses the phone input, matching the visible caret in the captured PPT, image, and video tool login screenshots.
- Selecting `帮我写作` closed the menu, kept `/chat`, opened the account login modal titled `登录以解锁更多功能`, loaded the login modal assets, requested `/passport/web/get_qrcode/`, and started QR polling. No `/chat/completion` request was observed before login.
- Selecting `翻译` showed the same gate: the menu closed, `/chat` was preserved, generic account login opened, login modal assets and QR endpoints loaded, and no `/chat/completion` request was observed before login.
- CDP sampled `编程`, `深入研究`, `AI 播客`, `音乐生成`, `解题答疑`, and `数据分析`: each had a unique visible button, closed the tool menu, kept `/chat`, opened account login, requested `/passport/web/get_qrcode/` plus QR polling, and emitted no `/chat/completion` request before login.
- `录音转写` is the exception: selecting it keeps `/chat`, leaves the tool menu visible behind the overlay, emits no passport or `/chat/completion` request, and opens a desktop-download prompt titled `下载豆包电脑版，一键生成录音笔记` with bullets for automatic transcription, structured notes, and follow-up Q&A plus the CTA `请在电脑上下载使用`.
- AI Creation is still represented as an independent surface from its direct page state captures.

Native mapping:

- `MenuOverlays.swift` implements the model, tool, creation model, creation more/options, image model, ratio, and style popovers.
- `AppState.selectModel(_:)` keeps `快速` selectable while gating `专家` and `办公任务` behind login with the `登录后使用专家模式` modal title.
- `AppState.selectTool(_:)` gates logged-out chat tool actions behind login with the generic `登录以解锁更多功能` modal title.
- `AppState.selectTool(_:)` preserves the observed `录音转写` exception by keeping the tool menu open and showing `RecordingDownloadPromptView` instead of login.

## AI Creation Layout

Observed in `creation-image.png`, `creation-prompt-ready.png`, `creation-image-mic-login.png`, `creation-reference-tooltip.png`, `creation-ai-cut-login.png`, `creation-more-menu.png`, `creation-image-model-menu.png`, `creation-ratio-menu.png`, and `creation-style-menu.png`.

- Header keeps left sidebar and new-chat style action icons.
- Main title is `AI 创作`.
- Subtitle is `让创作随灵感而生`.
- Creation composer is a white rounded card with blue focus outline in the source page.
- Image tab placeholder is `描述你想要的图片`.
- Entering `生成一张蓝色机器人产品海报` on `/chat/create-image` keeps the image tab selected and changes the right composer control from mic to a blue send arrow.
- Tapping the active image send arrow while logged out keeps `/chat/create-image`, retains the typed prompt, and opens the account login modal titled `登录以解锁更多功能`. CDP observed async login modal CSS/JS, `/passport/web/get_qrcode/`, QR polling, security/verification assets, and analytics requests; no image generation API was called before login.
- Tapping the empty image composer voice input while logged out keeps `/chat/create-image`, opens the same `登录以解锁更多功能` account modal, requests `/passport/web/get_qrcode/`, and starts QR polling. No browser microphone permission prompt, `Page.fileChooserOpened`, or `/chat/completion` request was observed before login.
- Image toolbar includes:
  - `图像`
  - `视频`
  - plus/reference image control
  - more/options
  - mic/send
- Tapping `参考图` while logged out does not open login. CDP shows the URL remains `/chat/create-image`, no login copy appears, and the DOM contains hidden image file inputs with `accept=".jpg,.png,.jpeg,.webp,.apng,"`; one input is multi-file. The visible response is a black tooltip: `最多支持上传 10 张图片`.
- Image more/options menu contains:
  - `Seedream 4.5`
  - `比例`
  - `风格`
- The image model submenu is a second-level panel with:
  - `Seedream 5.0 Lite`
  - `Seedream 4.5`
  - `Seedream 4.0`
- Selecting `Seedream 5.0 Lite` closes the submenu, keeps the URL at `/chat/create-image`, does not open login, and when the more menu is reopened its first row is `Seedream 5.0 Lite`.
- The ratio submenu is a second-level panel with:
  - `1:1 正方形，头像`
  - `2:3 社交媒体，自拍`
  - `3:4 经典比例，拍照`
  - `4:3 文章配图，插画`
  - `9:16 手机壁纸，人像`
  - `16:9 桌面壁纸，风景`
- Selecting `16:9 桌面壁纸，风景` closes the submenu, keeps the URL at `/chat/create-image`, does not open login, and when the more menu is reopened its ratio row is `比例 16:9`.
- The style submenu is a second-level scroll panel with thumbnail rows:
  - `人像摄影`
  - `电影写真`
  - `中国风`
  - `动漫`
  - `3D渲染`
  - `赛博朋克`
  - `CG 动画`
  - `水墨画`
  - `油画`
  - `古典`
  - `水彩画`
  - `卡通`
  - `平面插画`
  - `风景`
  - `港风动漫`
  - `像素风格`
  - `荧光绘画`
  - `彩铅画`
  - `手办`
  - `儿童绘画`
  - `抽象`
  - `锐笔插画`
  - `二次元`
  - `油墨印刷`
  - `版画`
  - `莫奈`
  - `毕加索`
  - `伦勃朗`
  - `马蒂斯`
  - `巴洛克`
  - `复古动漫`
  - `绘本`
- Selecting `动漫` closes the submenu, keeps the URL at `/chat/create-image`, does not open login, and when the more menu is reopened its style row is `风格 动漫`.
- CDP observed image-ratio SVG asset requests when opening/selecting ratios, style thumbnail image requests when opening the style submenu, and `mcs.doubao.com/list` analytics requests. No image generation API was called by option selection alone.
Video generation workspace:

- Observed in `creation-video.png`, `creation-video-duration-menu.png`, `creation-video-ratio-menu.png`, `creation-video-prompt-ready.png`, and `creation-video-send-login.png`.
- URL `/chat/create-video` renders a dedicated `视频生成` workspace, not the older `AI 创作` grid shell.
- The first viewport shows header actions, title `视频生成`, subtitle `自由运镜，图片文字一键成片`, large video example cards, and a bottom composer.
- The clean bottom composer shows `上传图片`, placeholder `添加照片，描述你想生成的视频`, `Seedance 2.0 Fast`, a more/options button, and a disabled send arrow.
- The video page exposes one single-image video upload input with `accept=".jpg,.png,.jpeg,.webp"` and no `multiple` attribute. This differs from image reference upload, which accepts APNG and supports multiple files.
- Tapping video `上传图片` while logged out keeps `/chat/create-video`, does not show the image-reference upload tip, and opens the account login modal titled `登录以解锁更多功能`. CDP observed async login modal CSS/JS, `/passport/web/get_qrcode/`, and QR polling; no `Page.fileChooserOpened` event and no `/chat/completion` request were observed before login. The state is captured in `creation-video-upload-login.png`.
- Opening the video model selector shows a single `Seedance 2.0 Fast` item. CDP observed only `mcs.doubao.com/list` analytics calls; no login modal and no URL change.
- Opening `时长` shows `5s` and `10s`. Selecting `10s` updates the bottom control label to `10s`, keeps the URL at `/chat/create-video`, and does not open login.
- Opening the video `更多` control lazy-loads `ondemand-more` CSS/JS, then shows one `比例 10` row. Opening that row shows video ratios `1:1`, `3:4`, `4:3`, `9:16`, `16:9`, and `21:9`. The `creation-video-duration-menu.png` and `creation-video-ratio-menu.png` reference PNG files are included in `design/reference/doubao-mobile/manifest.json`.
- Entering `生成一个蓝色机器人产品演示视频` enables the blue send arrow and switches the visible video controls to `Seedance 2.0 Fast` plus more/options. The state is captured in `creation-video-prompt-ready.png`.
- Tapping send while logged out keeps `/chat/create-video`, retains the typed prompt, and opens the account login modal titled `登录以解锁更多功能`. CDP observed async login modal CSS/JS, `/passport/web/get_qrcode/`, QR polling, and analytics requests; no video generation API was called before login. The state is captured in `creation-video-send-login.png`.
- Feature strip order is `AI 抠图`, `擦除`, `区域重绘`, `扩图`, `变清晰`. CDP bounds show `变清晰` is the fifth horizontal card, initially positioned to the right of the 390 px viewport.
- Tapping `AI 抠图` while logged out keeps the URL at `/chat/create-image` and opens the login modal with `登录以解锁更多功能`. CDP shows the async login CSS/JS modules and `/passport/web/get_qrcode/` loading, plus analytics calls; no creation sub-route is entered before login.
- Tapping `变清晰` while logged out has the same gate: URL remains `/chat/create-image`, login modal opens, and no reference-image upload tip appears.
- Source page uses remote example assets; the native app uses local generated placeholder tiles instead of copying proprietary assets.

Native mapping:

- `CreationView` implements the image creation shell and a separate video generation workspace with bottom composer, upload/login gating, and video option controls.
- `AppState.selectCreationImageModel(_:)`, `selectCreationImageRatio(_:)`, and `selectCreationImageStyle(_:)` update image creation options locally, close menus, and do not open login, matching the observed logged-out web behavior.
- `SnapshotScenario.creationPromptReady` preserves the active image prompt state for visual QA.
- `SnapshotScenario.creationImageSendLogin` preserves the logged-out image send login gate and retained prompt.
- `SnapshotScenario.creationImageMicLogin` preserves the logged-out empty image voice-input login gate.
- `SnapshotScenario.creationVideoPromptReady`, `creationVideoUploadLogin`, and `creationVideoSendLogin` preserve the typed video prompt, upload login gate, and send login gate states for visual QA.
- `AppState.requestCreationVideoUpload()` mirrors the observed logged-out upload boundary by opening login before file selection; `supportedCreationVideoUploadTypes` and `handleCreationVideoUpload(_:)` preserve the first-party single-image adapter shape for an authenticated future path.
- `AppState.selectCreationVideoDuration(_:)` and `selectCreationVideoRatio(_:)` update the video option controls locally and close their menus without login.
- `AppState.sendCreation()` gates logged-out image and video generation behind login and retains the typed prompt.
- `AppState.submitCreation()` provides deterministic local generation.

## CDP Network Findings

Raw signed query strings were not retained. Stored files keep only method, status, type, host, and path:

- `design/reference/doubao-mobile/chat-home.network.json`
- `design/reference/doubao-mobile/chat-send.network.json`
- `design/reference/doubao-mobile/creation-image.network.json`

Chat home endpoint categories:

- User/session bootstrap: `/alice/user/get_web_anon_id`, `/alice/user/launch`.
- Phone login code request: `/passport/web/send_code/`.
- Conversation state: `/im/chain/recent_conv`.
- Skill and onboarding content: `/samantha/skill/recommend`, `/biz/onboarding/get_nexpulse`.
- Settings and rate limits: `/service/settings/v3/`, `/im/message/send_rate_limit`.
- Experiment/analytics: `mcs.doubao.com/service/2/abtest_config/`, `mcs.doubao.com/list`, `opt.doubao.com/monitor_browser/collect/batch/`.
- Remote config: `lf3-config.bytetcc.com/obj/tcc-config-web/tcc-v2-data-flow.web.doubao-default`.

AI Creation endpoint categories:

- Skill pack and recommendation: `/samantha/skill/pack`, `/samantha/skill/recommend`.
- User/session bootstrap: `/alice/user/launch`.
- Settings and rate limits: `/service/settings/v3/`, `/im/message/send_rate_limit`.
- Subscription/fission surfaces: `/alice/commerce/sale/subscription/entry/config/`, `/samantha/fission/entrance`.
- Experiment/analytics: `mcs.doubao.com/list`, `opt.doubao.com/monitor_browser/collect/batch/`.
- Reference image selection is page-local file input behavior. The click observed for `creation-reference-tooltip.png` produced an `mcs.doubao.com/list` analytics request and no login/network gate before a file is chosen.
- Empty image composer voice input is login gated. The click observed for `creation-image-mic-login.png` loaded `component-login-modal` assets, requested `/passport/web/get_qrcode/`, started QR polling, and produced no microphone permission prompt, file chooser event, or `/chat/completion` request before login.
- Feature-card selection is login gated for `AI 抠图` in the logged-out state. The click observed for `creation-ai-cut-login.png` loaded `component-login-modal` assets, requested `/passport/web/get_qrcode/`, and preserved `/chat/create-image`.

Chat send interaction:

- Sending a logged-out benign prompt produced `POST /chat/completion`.
- The response was observed as `text/event-stream`, so the native architecture should preserve a streaming boundary rather than only a single response callback.
- Follow-up state calls included `/im/chain/single`, `/im/message/mark_conv_read`, `/im/conversation/info`, and `/service/settings/v3/`.
- No WebSocket was observed for this flow.
- The visible conversation title changed to `问候与帮助`.
- The assistant greeting exposed follow-up chips such as `你能做些什么？`, `你是谁？`, and `你是怎样学会说话的？`.
- Tapping assistant follow-up chips immediately sends that follow-up as the next user turn while leaving the composer empty.
- A download promotion row appeared below the greeting follow-ups.
- When the anonymous usage limit is reached, sending a typed prompt does not create a message. The composer keeps the typed prompt, a top toast says `已达使用上限，请登录以解锁该限制。`, and the account login modal opens.

Implementation implication:

- The native app should not call protected Doubao endpoints.
- Product behavior should be represented behind local service protocols until a first-party backend is available.
- Network observations are used to infer state categories and interaction timing, not to clone private API traffic.

## Current Native Coverage

Implemented:

- Chat home and message state.
- Bottom composer and mock streaming.
- Anonymous usage-limit login gate with retained composer text and top toast.
- Send-after-greeting state with conversation title, follow-up chips, and download promotion.
- Sidebar route drawer and about popover.
- Login modal account/QR flows.
- Area code selection.
- Model and tool menus.
- AI Creation image/video flows.
- AI Creation image more/options and ratio submenu flows.
- Deterministic launch scenarios for screenshot QA.
- Reference/candidate image comparison script.
- Real iPhone 13 Simulator screenshot capture normalized to the 390 x 844 manifest size.

Remaining toward full objective:

- Iterate native layout differences screen by screen. The 2026-06-19 real Simulator QA run captured 52 scenarios; 8 passed and 44 failed, with the detailed report at `ios/DoubaoNative/Reports/visual-compare.json`.
- Add deeper authenticated-state analysis if the user provides or opens a logged-in Doubao session.
