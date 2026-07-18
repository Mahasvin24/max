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
                .padding()
            }

            ChatBox(text: $text, onSend: {
                Task {
                    let str: String = text
                    text = ""
                    await viewModel.sendMessage(text: str)
                }
            })
            .frame(width: 0.7 * geo.size.width, height: 0.2 * geo.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
