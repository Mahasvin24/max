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
        Text(content)
            .font(.system(size: 14))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
    }
}

#Preview {
    AgentMessage(content: "Sure! Here's how you could approach that...")
        .padding()
}
