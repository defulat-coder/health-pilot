import SwiftUI

struct ComposerView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $state.chatInput)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.text)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .frame(height: 54)

                if state.chatInput.isEmpty {
                    Text("发消息...")
                        .font(.system(size: 16))
                        .foregroundStyle(DS.tertiary)
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .allowsHitTesting(false)
                }
            }

            if !state.pendingAttachments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(state.pendingAttachments) { attachment in
                            HStack(spacing: 6) {
                                Image(systemName: "doc")
                                    .font(.system(size: 12, weight: .semibold))
                                Text(attachment.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(DS.text)
                            .padding(.horizontal, 10)
                            .frame(height: 28)
                            .background(DS.chip)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                }
            }

            HStack(spacing: 8) {
                Button {
                    state.openAttachmentImporter()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(DS.text)
                        .frame(width: 34, height: 34)
                        .background(DS.chip)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Button {
                    state.activeOverlay = state.activeOverlay == .chatModel ? nil : .chatModel
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                        Text(state.selectedModel.title)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(DS.text)
                    .padding(.horizontal, 10)
                    .frame(height: 34)
                    .background(DS.chip)
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    state.activeOverlay = state.activeOverlay == .chatTools ? nil : .chatTools
                } label: {
                    HStack(spacing: 4) {
                        Text("更多")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(DS.text)
                    .padding(.horizontal, 10)
                    .frame(height: 34)
                    .background(DS.chip)
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 4)

                Button {
                    if state.chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        state.startVoiceInput()
                    } else {
                        state.sendChat()
                    }
                } label: {
                    Image(systemName: state.chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "mic.fill" : "arrow.up")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(state.chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? DS.text : Color.white)
                        .frame(width: 34, height: 34)
                        .background(state.chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? DS.chip : DS.blue)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .frame(height: state.pendingAttachments.isEmpty ? 100 : 134)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DS.composerRadius, style: .continuous))
        .cardShadow()
        .accessibilityIdentifier("chat.composer")
    }
}
