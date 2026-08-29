//
//  SurfacePanel.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: RoundedRectangle, ShapeStyle — no third-party code.
//
//  Replaces the earlier GlassPanel. The look is flat and opaque on purpose: an
//  elevated surface separated from the background by ~15 hex points and a hairline
//  border, which is how the reference UI creates depth without translucency.
//

import SwiftUI

struct SurfacePanel<Content: View>: View {
    var cornerRadius: CGFloat = AppRadius.composer
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
