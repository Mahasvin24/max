//
//  HomeView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/8/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            HStack {
                Image(Constants.logoString)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 50, maxHeight: 50)
                
                Text("Hello, Mahasvin")
                
            }
        }
    }
}

#Preview {
    HomeView()
}
