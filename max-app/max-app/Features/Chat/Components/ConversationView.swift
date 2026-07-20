//
//  ConversationView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/13/26.
//

import SwiftUI

struct ConversationView: View {
    let viewModel: ChatViewModel
    @Binding var text: String
    let geo: GeometryProxy

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages, id: \.id) { message in
                        if message.role == "user" {
                            UserMessage(content: message.content)
                        } else {
                            AgentMessage(content: message.content)
                        }
                    }
                }
                .frame(maxWidth: Constants.Design.maxContentWidth)
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(duration: 0.4, bounce: 0), value: viewModel.messages.count)
            }

            ChatBox(text: $text, onSend: {
                Task {
                    if text == "" { return }
                    let str: String = text
                    text = ""
                    await viewModel.sendMessage(text: str)
                }
            })
            .frame(width: 0.7 * geo.size.width, height: 0.2 * geo.size.height)
            .padding(.bottom, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
