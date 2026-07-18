//
//  UserMessage.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/17/26.
//

import SwiftUI

struct UserMessage: View {
    let content: String

    var body: some View {
        HStack {
            Spacer(minLength: 40)
            Text(content)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Constants.Design.userBubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: Constants.Design.bubbleCornerRadius))
        }
    }
}

#Preview {
    UserMessage(content: "Hey, can you help me with something?")
        .padding()
}
