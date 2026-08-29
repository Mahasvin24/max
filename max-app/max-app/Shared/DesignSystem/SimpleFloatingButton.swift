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
//    - Icon height 16 rather than 18, to match our composer's scale.
//  Structure is otherwise unchanged.
//
//  Built from: Button, Image(systemName:).
//

import SwiftUI

struct SimpleFloatingButton: View {
    var systemImage: String
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            Image(systemName: systemImage)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.primary)
                .frame(height: 16)
        }
        .buttonStyle(.icon)
        .contentShape(.rect)
    }
}

#Preview {
    SimpleFloatingButton(systemImage: "arrow.up", onClick: {})
        .frame(width: 100, height: 100)
}
