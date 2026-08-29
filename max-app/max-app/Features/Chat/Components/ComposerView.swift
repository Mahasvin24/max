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
//    - The ZStack(alignment: .trailing) layout, where the text field reserves
//      trailing padding and the action button sits over it.
//    - Animating the text binding so the field grows smoothly as it wraps.
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
//  Built from: TextField(axis:), ZStack, FocusState, ProgressView.
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
            ZStack(alignment: .trailing) {
                TextField(placeholder, text: $text.animation(.easeOut(duration: 0.3)), axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(AppFont.message)
                    .lineLimit(1...8)
                    .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
                    .focused($isFocused)
                    .onSubmit {
                        if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
                            text += "\n"
                        } else {
                            send()
                        }
                    }
                    .padding(.trailing, 36)

                if isSending {
                    ProgressView()
                        .controlSize(.small)
                } else if canSend {
                    SimpleFloatingButton(systemImage: "arrow.up") { send() }
                        .accessibilityLabel("Send message")
                }
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.vertical, AppSpacing.m)
        }
        .onAppear { isFocused = true }
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
