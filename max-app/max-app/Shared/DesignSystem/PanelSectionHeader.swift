//
//  PanelSectionHeader.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Text — no third-party code.
//
//  Inspired by vorssaint-utils' `sectionTitle` (Sources/Vorssaint/UI/Theme.swift):
//  an uppercased, kerned, secondary micro-label above each panel card. Borrowed as
//  a pattern, not as code — the size comes from this app's own scale (AppFont), not
//  Vorssaint's 10pt, which reads too small next to the rest of Max.
//
//  A View rather than a ViewModifier because it uppercases the string, which a
//  modifier can't do — modifiers style a rendered Text, they can't transform it.
//

import SwiftUI

struct PanelSectionHeader: View {
    private let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(AppFont.panelSectionHeader)
            .kerning(0.6)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(alignment: .leading) {
        PanelSectionHeader("Eye Care")
    }
    .padding()
}
