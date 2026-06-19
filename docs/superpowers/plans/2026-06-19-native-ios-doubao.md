# Native iOS Doubao First Slice Implementation Plan

> **For xbjt:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a from-scratch native iOS SwiftUI project under `ios/DoubaoNative` that implements the first mobile Doubao parity slice: chat home, sidebar, login modal, menus, AI creation image/video surface, mock interactions, and build verification.

**Architecture:** A single SwiftUI app target with a small state container and mock domain services. Views are decomposed by feature area: shell, chat, sidebar, login, menus, and creation. Protected Doubao calls are represented by protocols and local mocks.

**Tech Stack:** Swift, SwiftUI, XCTest-compatible Xcode project, iOS 17+ deployment target.

---

### Task 1: Scaffold Native iOS Project

**Files:**
- Create: `ios/DoubaoNative/DoubaoNative.xcodeproj/project.pbxproj`
- Create: `ios/DoubaoNative/DoubaoNative/Info.plist`
- Create: `ios/DoubaoNative/DoubaoNative/DoubaoNativeApp.swift`
- Create: `ios/DoubaoNative/DoubaoNative/Assets.xcassets/Contents.json`
- Create: `ios/DoubaoNative/DoubaoNative/Preview Content/Preview Assets.xcassets/Contents.json`

**Step 1: Create project directories**

Make the source, assets, preview, and project directories.

**Step 2: Add the Xcode project**

Create a minimal iOS application project with one app target named `DoubaoNative`, bundle id `com.healthpilot.DoubaoNative`, SwiftUI lifecycle, and iOS 17 deployment target.

**Step 3: Add app entry point**

Create `DoubaoNativeApp` with a `WindowGroup` that hosts `RootView`.

**Step 4: Verify project discovery**

Run:

```bash
xcodebuild -project ios/DoubaoNative/DoubaoNative.xcodeproj -list
```

**Expected:** The `DoubaoNative` scheme appears.

---

### Task 2: Implement App State And Mock Services

**Files:**
- Create: `ios/DoubaoNative/DoubaoNative/AppState.swift`
- Create: `ios/DoubaoNative/DoubaoNative/Models.swift`
- Create: `ios/DoubaoNative/DoubaoNative/MockAssistantService.swift`

**Step 1: Define routes and models**

Add route, chat message, model option, tool option, area code, and creation mode types.

**Step 2: Define state**

Add observable state for current route, modal visibility, menu visibility, login mode, selected model, selected area code, chat input, creation prompt, and generated mock results.

**Step 3: Add mock service**

Implement async streaming chat and mock creation generation with deterministic local text.

**Step 4: Wire state actions**

Expose methods for sending chat, selecting gated tools, toggling login mode, and submitting creation prompts.

**Expected:** Views can drive all required interactions without real network calls.

---

### Task 3: Implement Design System And Shared Components

**Files:**
- Create: `ios/DoubaoNative/DoubaoNative/DesignSystem.swift`
- Create: `ios/DoubaoNative/DoubaoNative/RootView.swift`
- Create: `ios/DoubaoNative/DoubaoNative/SharedComponents.swift`

**Step 1: Add colors, spacing, radii, shadows**

Match observed Doubao mobile surfaces: near-white app background, subtle gray chips, black login button, blue active send.

**Step 2: Add root shell**

Layer routed content, sidebar overlay, login modal, and transient menus with SwiftUI `ZStack`.

**Step 3: Add reusable buttons and rows**

Create icon buttons, header button style, chip style, and menu row components.

**Expected:** Screen views share consistent geometry and visual treatment.

---

### Task 4: Build Chat Screen

**Files:**
- Create: `ios/DoubaoNative/DoubaoNative/ChatView.swift`
- Create: `ios/DoubaoNative/DoubaoNative/ComposerView.swift`
- Create: `ios/DoubaoNative/DoubaoNative/MenuOverlays.swift`

**Step 1: Header**

Implement mobile header with sidebar button, centered title/subtitle, download button, and login button.

**Step 2: Empty and message states**

Add the empty title and multi-row horizontal suggestion chips. Show messages after mock send.

Add the observed greeting send state with conversation title, assistant follow-up chips, and the download promotion row.

**Step 3: Composer**

Implement bottom composer card with placeholder, toolbar buttons, model menu trigger, more menu trigger, mic/send state, and mock streaming.

**Step 4: Menus**

Implement more menu and model menu with observed labels and gated login behavior.

**Expected:** Chat home and composer states match observed mobile Doubao behavior.

---

### Task 5: Build Sidebar, About, And Login

**Files:**
- Create: `ios/DoubaoNative/DoubaoNative/SidebarView.swift`
- Create: `ios/DoubaoNative/DoubaoNative/LoginModalView.swift`

**Step 1: Sidebar**

Implement 280 point drawer, selected rows, navigation actions, backdrop close, and bottom area.

**Step 2: About popover**

Implement in-drawer popover with observed link/company text.

**Step 3: Login modal**

Implement account mode, QR mode, area code dropdown, checkbox, phone validation, and outside-close behavior.

**Expected:** All logged-out account interactions are locally represented.

---

### Task 6: Build AI Creation Screen

**Files:**
- Create: `ios/DoubaoNative/DoubaoNative/CreationView.swift`

**Step 1: Header and hero**

Implement AI creation header, title, and subtitle.

Keep the AI creation title and subtitle centered to match the mobile reference.

**Step 2: Creation composer**

Implement image/video segmented tabs, prompt placeholder changes, reference/model/duration/ratio controls, and send button state.

**Step 3: Feature strip and masonry**

Add observed feature labels and local placeholder visual tiles.

Feature entries should render as horizontal tool cards, and the inspiration masonry should avoid extra section chrome that does not appear in the reference.

**Step 4: Creation submission**

Mock a generated result card after submit.

**Expected:** Creation image and video flows are interactive and visually close to the observed mobile surface.

---

### Task 7: Verify Build And Screenshot Readiness

**Files:**
- Update if needed: source files from previous tasks.
- Create: `ios/DoubaoNative/Scripts/capture-ios-screenshots.sh`
- Update: `ios/DoubaoNative/README.md`

**Step 1: Build**

Run:

```bash
xcodebuild -project ios/DoubaoNative/DoubaoNative.xcodeproj -scheme DoubaoNative -sdk iphonesimulator -derivedDataPath ios/DoubaoNative/.derivedData build
```

**Step 2: Simulator availability**

Run:

```bash
xcrun simctl list runtimes available
xcrun simctl list devices available
```

**Step 3: Screenshot if runtime exists**

Boot an iPhone simulator, install the app, launch it, and capture screenshots for the chat and creation states.

**Step 4: Deterministic screenshot launch states**

Support `--snapshot <scenario>` app launch arguments and a repeatable script that captures:

- `chat-home`
- `chat-after-send`
- `chat-message`
- `chat-send-ready`
- `sidebar`
- `about`
- `login-account`
- `login-qr`
- `login-area-picker`
- `chat-model-menu`
- `chat-tool-menu`
- `creation-image`
- `creation-video`

**Step 5: Release readiness checks**

Add a local verification script that checks required delivery files, native-only stack constraints, bundle/deployment settings, Xcode Sources membership for every Swift file, executable permissions for delivery scripts, visual manifest coverage, and CDP research coverage.
- `creation-video-model-menu`

**Expected:** Build passes when an iOS runtime is installed. If no iOS Simulator runtime is installed, the screenshot script exits clearly and documents that screenshot automation is blocked by local Xcode runtime availability.

---

### Task 8: Final Review

**Files:**
- Review all created files.
- Create: `ios/DoubaoNative/Scripts/verify-local.sh`
- Create: `ios/DoubaoNative/Scripts/release-readiness.swift`
- Create: `ios/DoubaoNative/Scripts/build-release.sh`
- Create: `ios/DoubaoNative/Scripts/visual-qa.sh`
- Create: `ios/DoubaoNative/ExportOptions.plist.example`
- Create: `design/reference/doubao-mobile/manifest.json`

**Step 1: Confirm no Taro dependency**

Search created iOS project for `Taro`, `React`, `WebView`, and web runtime references.

**Step 2: Verify visual manifest**

Run the local verifier to confirm Swift type-checking, plist/scheme validity, screenshot manifest consistency, reference image readability, self-comparison, and sensitive-parameter cleanup.

```bash
ios/DoubaoNative/Scripts/verify-local.sh
```

The capture script must read scenario order and output filenames from `manifest.json`. The visual manifest validator must enforce that the capture script uses the manifest reader, reject undeclared reference PNGs, verify `SnapshotScenario` and `AppState.applySnapshotScenario` coverage, and the screenshot comparison script must support `--manifest` plus strict extra-candidate detection.

The release readiness audit must verify required project artifacts, native-only constraints across the full Swift source inventory, bundle/deployment settings, streaming service boundary, visual manifest size, and core CDP research coverage.

**Step 3: Confirm release path**

Keep a release archive script and export options example so a signing-capable machine can produce an archive or IPA without changing project structure.

**Step 4: Summarize deliverable**

Report implemented screens, verification commands, and any environment limitation.

**Expected:** User receives a native iOS project path and exact verification status.
