//
//  SimpleFloatingButton.swift
//  max-app
//
//  Provenance: ADAPTED — gluonfield/enchanted, Apache-2.0
//  Original: Enchanted/UI/Shared/Components/SimpleFloatingButton.swift
//            "Created by Augustinas Malinauskas on 18/02/2024."
//            Copyright Augustinas Malinauskas and Enchanted contributors.
//            Full licence: THIRD_PARTY/enchanted-LICENSE.txt
//
//  Changes from the original:
//    - Uses this app's IconButtonStyle in place of Enchanted's GrowingButton.
//    - Uses .primary in place of Enchanted's Color.label.
//    - Icon height 16 rather than 18, to match our composer's scale. Now a `height`
//      parameter (still defaulting to 16) rather than a hardcoded value, since the
//      composer's "+" and mic buttons ended up wanting different sizes.
//  Structure is otherwise unchanged.
//
//  Built from: Button, Image(systemName:).
//

import SwiftUI

struct SimpleFloatingButton: View {
    var systemImage: String
    var height: CGFloat = 16          // ← per-instance icon size; override at the call site
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            Image(systemName: systemImage)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.primary)
                .frame(height: height)
        }
        .buttonStyle(.icon)
        .contentShape(.rect)
    }
}

#Preview {
    HStack(spacing: 20) {
        SimpleFloatingButton(systemImage: "plus", height: 12, onClick: {})
        SimpleFloatingButton(systemImage: "arrow.up", onClick: {})
    }
    .frame(width: 150, height: 100)
}
