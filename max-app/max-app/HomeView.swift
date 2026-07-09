//
//  HomeView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/8/26.
//

import SwiftUI

struct HomeView: View {
    @State private var text: String = ""
    
    var body: some View {
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
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("How can I help you today?")
                        .padding(.horizontal, 8)
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                        .foregroundStyle(.white)
                        .opacity(0.7)
                    
                }
                TextEditor(text: $text)
                    .padding(.horizontal, 5)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    .font(.headline)
                    .fontWeight(.regular)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
            }
            .frame(maxWidth: 675, maxHeight: 100)
            .opacity(0.95)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 30)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .frame(maxWidth: .infinity, maxHeight: 75)
                    .padding(.horizontal, 30)
            )
        }
    }
}

#Preview {
    HomeView()
}
