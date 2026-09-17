// Return/Shift-Return handling adapted from gluonfield/enchanted (Apache-2.0).
// Original: Enchanted/UI/macOS/Chat/Components/InputFields_macOS.swift
// Copyright Augustinas Malinauskas and Enchanted contributors.
// Licence: THIRD_PARTY/enchanted-LICENSE.txt. Layout and styling are Max's own.

import SwiftUI
import AppKit

struct ComposerView: View {
    @Binding var text: String
    var isSending = false
    var isLoading = false
    var isFocused: FocusState<Bool>.Binding
    var onSend: () -> Void

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending && !isLoading
    }

    var body: some View {
        SurfacePanel(cornerRadius: AppRadius.composer) {
            VStack(alignment: .leading, spacing: AppSpacing.s) {
                TextField("Message Max", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(AppFont.message)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2...6)
                    .focused(isFocused)
                    .accessibilityLabel("Message Max")
                    .onSubmit {
                        // Native multiline TextField handles Return before onKeyPress.
                        // This modifier check preserves Shift-Return without replacing the editor.
                        if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
                            text += "\n"
                        } else if canSend {
                            onSend()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                HStack(spacing: AppSpacing.m) {
                    Button("Add attachment", systemImage: "plus") {}
                        .disabled(true).help("Attachments — not available yet")
                    Label("Ask anything", systemImage: "sparkles")
                        .labelStyle(.titleAndIcon)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Button("Voice input", systemImage: "mic") {}
                        .disabled(true).help("Voice input — not available yet")
                    sendButton
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.icon)
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.l)
        }
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Group {
                if isSending {
                    ProgressView().controlSize(.small).tint(Color.textSecondary)
                } else {
                    Image(systemName: "arrow.up").font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundStyle(canSend ? Color.surface : Color.textSecondary)
            .frame(width: 32, height: 32)
            .background(canSend ? Color.accentColor : Color.surfaceSelected, in: .circle)
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .accessibilityLabel(isSending ? "Waiting for response to finish" : "Send message")
        .help(isSending ? "Max is responding" : "Send message")
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var focused: Bool
    ComposerView(text: $text, isFocused: $focused, onSend: {})
        .padding().frame(width: 720).background(Color.surface).preferredColorScheme(.dark)
}
