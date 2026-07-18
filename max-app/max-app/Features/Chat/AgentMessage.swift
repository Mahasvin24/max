//
//  AgentMessage.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/17/26.
//

import SwiftUI

struct AgentMessage: View {
    let content: String

    var body: some View {
        HStack {
            Text(content)
                .font(.system(size: 14))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(white: 0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Spacer(minLength: 40)
        }
    }
}

#Preview {
    AgentMessage(content: "Sure! Here's how you could approach that...")
        .padding()
}
