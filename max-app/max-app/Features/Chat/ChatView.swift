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
    @State private var showConversationList: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            Group {
                if viewModel.conversation.conversationId == Conversation().conversationId {
                    NewChatView(viewModel: viewModel, text: $text, geo: geo)
                } else {
                    ConversationView(viewModel: viewModel, text: $text, geo: geo)
                }
            }
            .transition(.opacity)
            .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(duration: 0.4, bounce: 0), value: viewModel.conversation.conversationId)
        }
        .toolbar {
            Button {
                showConversationList = !showConversationList
            } label: {
                Image(systemName: "list.bullet")
            }
            .popover(isPresented: $showConversationList) {
                List(
                    viewModel.conversationList.conversations,
                    id: \.conversationId)
                { convo in
                    Button {
                        Task {
                            await viewModel.fetchConversation(id: convo.conversationId)
                        }
                    } label: {
                        Text("\(convo.conversationId)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        Spacer()
                        Button {
                            showDeleteConfirmation = !showDeleteConfirmation
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                        .buttonStyle(PressableIconButtonStyle())
                    }
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .alert("Delete this conversation?", isPresented: $showDeleteConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            Task { await viewModel.deleteConversation(id: convo.conversationId) }
                        }
                    } message: {
                        Text("This action cannot be undone.")
                    }
                }
                .frame(width: 250, height: 300)
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
