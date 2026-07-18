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
        VStack(spacing: 20) {
            // logo + welcome message
            HStack(spacing: 10) {
                Image(Constants.logoString)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 36, maxHeight: 36)

                Text("Hello, \(Constants.userNameString)")
                    .font(.system(size: 22, weight: .medium))
                    .tracking(-0.3)
                    .foregroundStyle(.primary)
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

#Preview {
    @Previewable @State var text = ""
    GeometryReader { geo in
        NewChatView(viewModel: ChatViewModel(), text: $text, geo: geo)
    }
}
