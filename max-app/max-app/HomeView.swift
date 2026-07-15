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
                VStack {
                    TextEditor(text: $text)
                        .frame(width: .infinity, height: .infinity)
                        .scrollContentBackground(.hidden)
                        .background(.black)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 8)
                    
                    // action items
                    HStack {
                        Button {
                        } label: {
                            Text("Send")
                        }
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                        
                }
                .frame(width: 0.7 * geo.size.width, height: 0.2 * geo.size.height)
                .opacity(0.95)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 1)
                )
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    HomeView()
}
