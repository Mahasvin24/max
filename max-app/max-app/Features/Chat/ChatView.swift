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
                    
                    Text("Hello, \(Constants.useNameString)")
                        .font(.largeTitle)
                }
                
                ChatBox(text: $text, onSend: {
                    // tbd
                    print("Send message clicked!")
                })
                .frame(width: 0.7 * geo.size.width, height: 0.2 * geo.size.height)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                let res = await APIClient.checkConnectionHealth()
                print("[\(Date.now.formatted(date: .omitted, time: .shortened))] Connecetion is healthy? \(res)")
            }
        }
    }
}

#Preview {
    ChatView()
}
