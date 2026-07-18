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
            VStack {
                // logo + welcome message
                HStack {
                    Image(Constants.logoString)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50, maxHeight: 50)
                    
                    Text("Hello, \(Constants.userNameString)")
                        .font(.largeTitle)
                }
                
                ChatBox(text: $text, onSend: {
                    Task {
                        await viewModel.sendMessage(text: text)
                    }
                    
                })
                .frame(width: 0.7 * geo.size.width, height: 0.2 * geo.size.height)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

#Preview {
    ChatView()
}
