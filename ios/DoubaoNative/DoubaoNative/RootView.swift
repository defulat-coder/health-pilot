import SwiftUI

struct RootView: View {
    @StateObject private var state: AppState

    @MainActor
    init(state: AppState) {
        _state = StateObject(wrappedValue: state)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            routedContent
                .environmentObject(state)
                .accessibilityIdentifier("root.routed-content")

            if state.isSidebarOpen {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            state.isSidebarOpen = false
                            state.showAboutPopover = false
                        }
                    }

                SidebarView()
                    .environmentObject(state)
                    .accessibilityIdentifier("overlay.sidebar")
                    .transition(.move(edge: .leading))
                    .zIndex(2)
            }

            menuLayer
                .environmentObject(state)
                .zIndex(3)

            if state.showTitleEditor {
                TitleEditModalView()
                    .environmentObject(state)
                    .accessibilityIdentifier("overlay.title-editor")
                    .zIndex(4)
            }

            if let selectedHealthCard = state.selectedHealthCard {
                HealthInfoPanelView(card: selectedHealthCard)
                    .environmentObject(state)
                    .accessibilityIdentifier("overlay.health-info")
                    .zIndex(4)
            }

            if let toastMessage = state.toastMessage {
                VStack {
                    ToastBannerView(message: toastMessage)
                        .padding(.top, 16)
                    Spacer()
                }
                .padding(.horizontal, 42)
                .allowsHitTesting(false)
                .zIndex(5)
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.88), value: state.isSidebarOpen)
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .fileImporter(
            isPresented: $state.showAttachmentImporter,
            allowedContentTypes: AppState.supportedAttachmentTypes,
            allowsMultipleSelection: true
        ) { result in
            state.handleAttachmentImport(result)
        }
        .fileImporter(
            isPresented: $state.showCreationReferenceImporter,
            allowedContentTypes: AppState.supportedCreationReferenceTypes,
            allowsMultipleSelection: true
        ) { result in
            state.handleCreationReferenceImport(result)
        }
        .fileImporter(
            isPresented: $state.showCreationVideoUploadImporter,
            allowedContentTypes: AppState.supportedCreationVideoUploadTypes,
            allowsMultipleSelection: false
        ) { result in
            state.handleCreationVideoUpload(result)
        }
    }

    @ViewBuilder
    private var routedContent: some View {
        switch state.route {
        case .chat:
            ChatView()
        case .creation:
            CreationView()
        case .healthData:
            HealthDataView()
        }
    }

    @ViewBuilder
    private var menuLayer: some View {
        if let overlay = state.activeOverlay {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { state.activeOverlay = nil }

                switch overlay {
                case .chatModel:
                    VStack {
                        Spacer()
                        HStack {
                            ModelMenuView()
                                .frame(width: 178)
                            Spacer()
                        }
                        .padding(.leading, 82)
                        .padding(.bottom, 64)
                    }
                case .chatTools:
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ToolMenuView()
                                .frame(width: 268)
                            Spacer()
                        }
                        .padding(.bottom, 64)
                    }
                case .creationModel:
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            CreationModelMenuView()
                                .frame(width: 178)
                            Spacer()
                        }
                        .padding(.bottom, 468)
                    }
                case .creationVideoDuration:
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            CreationVideoDurationMenuView()
                                .frame(width: 140)
                            Spacer()
                        }
                        .padding(.bottom, 468)
                    }
                case .creationVideoMore:
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            CreationVideoMoreMenuView()
                                .frame(width: 136)
                            Spacer()
                        }
                        .padding(.bottom, 468)
                    }
                case .creationVideoRatio:
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            CreationVideoRatioMenuView()
                                .frame(width: 140)
                            Spacer()
                        }
                        .padding(.leading, 26)
                        .padding(.bottom, 468)
                    }
                case .creationMore:
                    VStack {
                        Spacer()
                        HStack {
                            CreationMoreMenuView()
                                .frame(width: 160)
                            Spacer()
                        }
                        .padding(.leading, 88)
                        .padding(.bottom, 422)
                    }
                case .creationImageModel:
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            CreationMoreMenuView(selectedItem: .model)
                                .frame(width: 160)
                            ImageModelMenuView()
                                .frame(width: 194)
                            Spacer()
                        }
                        .padding(.leading, 88)
                        .padding(.bottom, 422)
                    }
                case .creationRatio:
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            CreationMoreMenuView(selectedItem: .ratio)
                                .frame(width: 160)
                            RatioMenuView()
                                .frame(width: 194)
                            Spacer()
                        }
                        .padding(.leading, 88)
                        .padding(.bottom, 422)
                    }
                case .creationStyle:
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            CreationMoreMenuView(selectedItem: .style)
                                .frame(width: 160)
                            StyleMenuView()
                                .frame(width: 194)
                            Spacer()
                        }
                        .padding(.leading, 88)
                        .padding(.bottom, 422)
                    }
                }
            }
        }
    }
}
