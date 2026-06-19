# DoubaoNative

Native iOS first slice for the Doubao mobile parity product.

## Stack

- Swift
- SwiftUI
- iOS 17+
- Native Xcode project
- Local mock assistant and creation service
- Optional HTTP `text/event-stream` assistant service boundary

This project intentionally does not use Taro, React, WebView, or a mini-program runtime.
It also does not call protected Doubao endpoints from the native app.

## Open

Open the project in Xcode:

```bash
open ios/DoubaoNative/DoubaoNative.xcodeproj
```

Run the `DoubaoNative` scheme on an iPhone simulator or device with an installed iOS platform runtime.

## Verify

List the scheme:

```bash
xcodebuild -project ios/DoubaoNative/DoubaoNative.xcodeproj -list
```

Run local verification that does not require a simulator runtime:

```bash
ios/DoubaoNative/Scripts/verify-local.sh
```

This includes a pure Swift state regression test for every screenshot manifest snapshot plus the core local chat, attachment import, creation, login, and tool-routing actions:

```bash
ios/DoubaoNative/Scripts/verify-state-scenarios.sh
```

Run the release readiness audit by itself:

```bash
ios/DoubaoNative/Scripts/release-readiness.swift
```

It checks native-only stack constraints, required delivery files, bundle/deployment settings, Xcode source membership, executable script permissions, visual manifest coverage, and CDP research coverage.
It scans the full `ios/DoubaoNative/DoubaoNative/*.swift` source inventory, not a hand-picked subset.

Type-check all SwiftUI source against the iOS Simulator SDK:

```bash
SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
xcrun swiftc -typecheck -sdk "$SDK_PATH" -target arm64-apple-ios17.0-simulator ios/DoubaoNative/DoubaoNative/*.swift
```

Build when an iOS runtime/platform is installed:

```bash
xcodebuild \
  -project ios/DoubaoNative/DoubaoNative.xcodeproj \
  -scheme DoubaoNative \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath ios/DoubaoNative/.derivedData \
  build
```

## Screenshot QA Targets

Use an iPhone portrait simulator and capture:

- Chat empty state
- Chat reply actions and follow-up chips
- Chat follow-up long answer top and bottom states
- Chat reply download promo tap
- Sidebar open
- Sidebar download tooltip
- Conversation title edit modal
- Conversation share gated login
- Empty composer mic gated login
- Anonymous usage-limit gated login
- Login account mode
- Login phone ready mode
- Login QR mode
- Login Douyin service agreement confirmation
- Chat model menu
- Chat model gated login
- Chat model office gated login
- Chat tool menu
- Chat tool PPT gated login
- Chat tool image gated login
- AI Creation image tab
- AI Creation image send gated login
- AI Creation reference-image upload limit tooltip
- AI Creation AI cut gated login
- AI Creation video generation workspace
- AI Creation video model menu
- AI Creation video duration menu
- AI Creation video ratio submenu
- AI Creation video prompt/send login states
- AI Creation image more menu
- AI Creation image model submenu
- AI Creation image ratio submenu
- AI Creation image style submenu
- AI Creation image model/ratio/style selected states

The screenshot script defaults to an iPhone 13 Simulator because its 3x screenshot output maps cleanly to the 390 x 844 reference viewport. It normalizes captured screenshots to the manifest dimensions before comparison.

Run:

```bash
ios/DoubaoNative/Scripts/capture-ios-screenshots.sh
```

The app supports deterministic launch scenarios for screenshot capture:

```bash
xcrun simctl launch booted com.healthpilot.DoubaoNative --args --snapshot chat-home
xcrun simctl launch booted com.healthpilot.DoubaoNative --args --snapshot login-qr
xcrun simctl launch booted com.healthpilot.DoubaoNative --args --snapshot creation-video
```

Supported scenario names:

- `chat-home`
- `chat-send-ready`
- `chat-after-send`
- `chat-reply-actions`
- `chat-reply-tapped`
- `chat-followup-after-click`
- `chat-followup-bottom`
- `chat-promo-download-tap`
- `chat-title-edit`
- `chat-share-login`
- `chat-mic-login`
- `chat-rate-limit-login`
- `sidebar`
- `about`
- `sidebar-download-tooltip`
- `login-account`
- `login-phone-ready`
- `login-phone-code`
- `login-qr`
- `login-area-picker`
- `login-area-selected-hk`
- `login-terms-checked`
- `login-douyin-consent`
- `login-douyin-oauth`
- `chat-model-menu`
- `chat-model-expert-login`
- `chat-model-office-login`
- `chat-tool-menu`
- `chat-tool-ppt-login`
- `chat-tool-image-login`
- `chat-tool-video-login`
- `chat-tool-recording-download`
- `creation-image`
- `creation-prompt-ready`
- `creation-image-send-login`
- `creation-image-mic-login`
- `creation-reference-tooltip`
- `creation-ai-cut-login`
- `creation-video`
- `creation-video-model-menu`
- `creation-video-duration-menu`
- `creation-video-ratio-menu`
- `creation-video-prompt-ready`
- `creation-video-upload-login`
- `creation-video-send-login`
- `creation-more-menu`
- `creation-image-model-menu`
- `creation-ratio-menu`
- `creation-style-menu`
- `creation-image-model-selected`
- `creation-ratio-selected`
- `creation-style-selected`

`chat-message` is also available as a native-only launch scenario for checking a longer mock conversation rendering.

## Visual Compare

Reference captures from Doubao mobile Chrome/CDP live under:

```bash
design/reference/doubao-mobile
```

After capturing native screenshots, compare them with:

```bash
ios/DoubaoNative/Scripts/compare-screenshots.swift \
  --reference design/reference/doubao-mobile \
  --candidate ios/DoubaoNative/Screenshots \
  --manifest design/reference/doubao-mobile/manifest.json
```

The comparison script checks image dimensions and reports mean/max RGB pixel differences for each screenshot. It ignores the bottom 18 pixels by default to avoid treating the iOS Home indicator as product UI. Treat it as an iteration aid; final acceptance still requires visual inspection because image content in the native app intentionally uses local placeholders rather than copied Doubao assets.

## Service Boundary

`AssistantServicing` exposes chat responses as `AsyncStream<String>`, matching the CDP observation that Doubao chat completion is delivered as `text/event-stream`. The app uses `MockAssistantService` by default. `HTTPStreamingAssistantService` is a replaceable first-party backend adapter and intentionally has no built-in Doubao URL.

The composer plus button uses native iOS file import instead of a web upload control. It accepts the observed Doubao mobile attachment categories: PDF, text/CSV, Office documents, Markdown, EPUB/MOBI, and common image formats.

Home suggestion chips and assistant follow-up chips submit immediately through the same local streaming boundary as typed chat messages; they do not prefill the composer. The reply-level desktop-download promo is modeled as a non-login, non-navigating tap in the observed mobile state.

The sidebar includes deterministic local `历史对话` rows that mirror the observed mobile `/chat/{id}` links. Selecting a history row loads local messages and closes the drawer without calling Doubao endpoints.

Validate the screenshot manifest itself:

```bash
ios/DoubaoNative/Scripts/validate-visual-manifest.swift
```

Run the full simulator visual QA loop:

```bash
ios/DoubaoNative/Scripts/visual-qa.sh
```

This captures native screenshots, compares only manifest-declared screens, and writes `ios/DoubaoNative/Reports/visual-compare.json`.
`capture-ios-screenshots.sh` also reads scenario names and screenshot filenames from the same manifest, so adding or removing a visual state starts with `design/reference/doubao-mobile/manifest.json`.
The visual QA compare step fails on extra candidate PNGs, which prevents stale screenshots from being mistaken for part of the reviewed set.
The manifest validator also checks that each manifest snapshot has a matching `SnapshotScenario` raw value and an `AppState.applySnapshotScenario` case.

Latest run on 2026-06-19 captured all 52 scenarios; 8 passed and 44 failed. `chat-home.png` now passes against the refreshed CDP reference, while the remaining failures are tracked in `design-qa.md` and should be iterated screen by screen.

## Release Build

Archive for iOS on a machine with Xcode iOS platform components and signing configured:

```bash
ios/DoubaoNative/Scripts/build-release.sh
```

If `ios/DoubaoNative/ExportOptions.plist` exists, the script also exports an IPA to `ios/DoubaoNative/Export`.

Start from `ios/DoubaoNative/ExportOptions.plist.example` and adjust `method`, team, and provisioning values for your signing setup.
