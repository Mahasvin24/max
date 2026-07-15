//
//  HomeView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/8/26.
//

import SwiftUI

struct HomeView: View {
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
                
                // textarea
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("Type / for skills")
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
                    HStack {
                        Button {
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                        } label: {
                            Image(systemName: "mic")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)

                        Button {
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                }
                .frame(width: 0.7 * geo.size.width, height: 0.25 * geo.size.height)
                .background(Color(white: 0.15))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    HomeView()
}
