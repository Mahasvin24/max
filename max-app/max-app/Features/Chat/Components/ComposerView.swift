//
//  ComposerView.swift
//  max-app
//
//  Provenance: ADAPTED — gluonfield/enchanted, Apache-2.0
//  Original: Enchanted/UI/macOS/Chat/Components/InputFields_macOS.swift
//            "Created by Augustinas Malinauskas on 10/02/2024."
//            Copyright Augustinas Malinauskas and Enchanted contributors.
//            Full licence: THIRD_PARTY/enchanted-LICENSE.txt
//
//  Kept from the original (the parts worth adopting):
//    - `.onSubmit` combined with an NSApp modifier-flag check, so Return sends and
//      Shift+Return inserts a newline. A multiline TextField swallows Return before
//      `.onKeyPress` can see it; this is the approach that actually works.
//    - Animating the text binding so the field grows smoothly as it wraps.
//    (The ZStack(alignment: .trailing) layout — text field reserving trailing
//    padding for an overlaid button — was kept at first, then replaced by the
//    HStack pill below; see "Later restyle".)
//
//  Changes from the original:
//    - Removed image attachment, voice recording, drag-and-drop and clipboard
//      hotkeys, along with their dependencies (LanguageModelSD, MessageSD,
//      ConversationState, RecordingView, RemovableImage, DragAndDrop).
//    - Send state is a plain `isSending` Bool rather than ConversationState.
//    - While sending we show a progress indicator, not Enchanted's stop button,
//      because this app has no way to cancel an in-flight request yet.
//    - Colours come from this app's tokens (SurfacePanel) rather than gray2Custom.
//    - Dropped the outer `.onTapGesture`; the text field's own frame covers the
//      panel, and a container tap gesture can intercept clicks meant for the button.
//
//  Later restyle (own pass, not from Enchanted): rebuilt as a full HStack pill —
//  leading "+", the field, mic, then a filled circular send button — to match a
//  ChatGPT-style composer reference. (An "Auto" model-picker label sat between the
//  field and mic briefly; removed — there's only one backend model right now, so it
//  had nothing to pick between.) The `+` and mic are inert placeholders (no
//  attachments/voice input built yet), same treatment as Scheduled/Plugins in the
//  sidebar. AppRadius.composer went from 22 to a value large enough to always clamp
//  into a capsule (see Spacing.swift).
//
//  Built from: TextField(axis:), HStack, FocusState, ProgressView, Circle.
//

import SwiftUI
import AppKit

struct ComposerView: View {
    @Binding var text: String
    var isSending: Bool = false
    var placeholder: String = "Message Max"
    var onSend: () -> Void

    @FocusState private var isFocused: Bool

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    var body: some View {
        SurfacePanel {
            HStack(alignment: .center, spacing: AppSpacing.m) {
                // Attachments — not built yet. Smaller than mic/send: this one reads
                // as an inline glyph next to the text rather than a primary action.
                SimpleFloatingButton(systemImage: "plus", height: 12) {}
                    .help("Attachments — not built yet")
                    .accessibilityLabel("Add attachment")

                TextField(placeholder, text: $text.animation(.easeOut(duration: 0.3)), axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(AppFont.message)
                    .lineLimit(1...8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .focused($isFocused)
                    .onSubmit {
                        if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
                            text += "\n"
                        } else {
                            send()
                        }
                    }

                // Voice input — not built yet.
                SimpleFloatingButton(systemImage: "mic") {}
                    .help("Voice input — not built yet")
                    .accessibilityLabel("Voice input")

                sendButton
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.m)
        }
        .onAppear { isFocused = true }
    }

    /// Always visible (unlike the icon buttons above, which do nothing yet) —
    /// dims and disables rather than hiding when there's nothing to send, and
    /// swaps to a progress spinner mid-request.
    ///
    /// Built with `.buttonStyle(.plain)` rather than the shared `.icon` style: this
    /// button needs its enabled/disabled state to swap the *circle's fill*, not just
    /// dim the whole thing, so it manages its own two-tone color instead of layering
    /// IconButtonStyle's opacity treatment on top.
    private var sendButton: some View {
        Group {
            if isSending {
                ProgressView()
                    .controlSize(.small)
                    .frame(width: 28, height: 28)
            } else {
                Button(action: send) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(canSend ? Color.surface : Color.secondary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(canSend ? Color.primary : Color.primary.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
            }
        }
        .accessibilityLabel("Send message")
    }

    private func send() {
        guard canSend else { return }
        onSend()
    }
}

#Preview("Empty") {
    @Previewable @State var text = ""
    ComposerView(text: $text) {}
        .padding()
        .frame(width: 560)
}

#Preview("Typed") {
    @Previewable @State var text = "What is the capital of Japan?"
    ComposerView(text: $text) {}
        .padding()
        .frame(width: 560)
}

#Preview("Sending") {
    @Previewable @State var text = ""
    ComposerView(text: $text, isSending: true) {}
        .padding()
        .frame(width: 560)
}
