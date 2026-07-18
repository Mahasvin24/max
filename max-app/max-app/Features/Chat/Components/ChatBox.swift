//
//  ChatBox.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/14/26.
//

import SwiftUI

struct ChatBox: View {
    @Binding var text: String
    var onSend: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(Constants.chatPlaceholderString)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 5)
                }
                TextEditor(text: $text)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary)
                
                    .scrollContentBackground(.hidden)
                    .background(.clear)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 12)
            .padding(.top, 12)

            // action items
            HStack(spacing: 10) {
                Button {
                } label: {
                    Image(systemName: Constants.plusIconString)
                        .font(.system(size: Constants.Design.iconSize))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                // TODO: wire up to real mode/model selection
                Text("Manual")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                } label: {
                    Image(systemName: Constants.micIconString)
                        .font(.system(size: Constants.Design.iconSize))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Button {
                    onSend()
                } label: {
                    Image(systemName: Constants.sendIconString)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .frame(height: Constants.Design.bottomBarHeight)
        }
        .background(Constants.Design.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Design.boxCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Design.boxCornerRadius)
                .stroke(Constants.Design.borderColor, lineWidth: 1)
        )

    }
}

// no longer previewable
// too many fake dependencies (text str, send function)
// for it to be woorth maintaining
//
// preview instead: ChatView.swift
