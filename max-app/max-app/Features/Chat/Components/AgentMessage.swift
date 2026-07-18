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
        if let atrributed = try? AttributedString(markdown: content) {
            Text(atrributed)
                .task {
                    print("- - - - - - - - - - - - - - - -")
                    print(content)
                    print("- - - - - - - - - - - - - - - -")
                }
        } else {
            Text(content)
                .font(.system(size: 14))
                .lineSpacing(4)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .task {
                    print("regular string :(")
                }
        }
    }
}

#Preview {
    AgentMessage(content: "Sure! Here's how you could approach that... **Random stuff!**")
        .padding()
}
