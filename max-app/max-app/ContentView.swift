//
//  ContentView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selected: Page? = .home
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

enum Page {
    case home
}

#Preview {
    ContentView()
}
