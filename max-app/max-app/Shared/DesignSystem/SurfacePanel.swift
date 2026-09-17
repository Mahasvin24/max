//
//  SurfacePanel.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: RoundedRectangle, ShapeStyle — no third-party code.
//
import SwiftUI

struct SurfacePanel<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(Color.surfaceElevated, in: .rect(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            )
    }
}
