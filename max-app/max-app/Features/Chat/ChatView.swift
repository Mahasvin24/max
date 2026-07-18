//
//  HomeView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/8/26.
//

import SwiftUI

struct ChatView: View {
    let viewModel = ChatViewModel()
    
    @State private var text: String = ""
    
    var body: some View {
        GeometryReader { geo in
            if viewModel.conversation.conversationId == Conversation().conversationId {
                NewChatView(viewModel: viewModel, text: $text, geo: geo)
            } else {
                ConversationView(viewModel: viewModel, text: $text, geo: geo)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(
                        viewModel.conversationList.conversations,
                        id: \.conversationId)
                    { convo in
                        Button("\(convo.conversationId)") {
                            Task {
                                await viewModel.fetchConversation(id: convo.conversationId)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: Constants.Design.iconSize))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            // health check
            let time = Date.now.formatted(date: .omitted, time: .shortened)
            let isHealthy = await APIClient.checkConnectionHealth()
            print("[\(time)] Connection is healthy? \(isHealthy)")
            
            await viewModel.refresh()
        }
    }
}

#Preview {
    ChatView()
}
