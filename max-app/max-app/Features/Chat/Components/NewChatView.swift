//
//  NewChatView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/17/26.
//

import SwiftUI

struct NewChatView: View {
    let viewModel: ChatViewModel
    @Binding var text: String
    let geo: GeometryProxy

    var body: some View {
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
    }
}

#Preview {
    @Previewable @State var text = ""
    GeometryReader { geo in
        NewChatView(viewModel: ChatViewModel(), text: $text, geo: geo)
    }
}
