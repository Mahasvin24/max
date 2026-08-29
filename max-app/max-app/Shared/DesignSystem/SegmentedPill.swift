//
//  SegmentedPill.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Button, Capsule, matchedGeometryEffect, Namespace.
//
//  Apple's .segmented Picker can't produce this shape — a dark capsule track with a
//  raised capsule thumb — so this is deliberately custom. The thumb slides between
//  segments via matchedGeometryEffect rather than animating a offset by hand.
//

import SwiftUI

struct SegmentedPill: View {
    let options: [String]
    @Binding var selection: String

    @Namespace private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection

                Button {
                    withAnimation(reduceMotion ? .none : .snappy(duration: 0.25)) {
                        selection = option
                    }
                } label: {
                    Text(option)
                        .font(AppFont.segment)
                        .foregroundStyle(isSelected ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 7)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color.surfaceElevated)
                                    .matchedGeometryEffect(id: "segmentedPillThumb", in: namespace)
                            }
                        }
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
            }
        }
        .padding(3)
        .background(Capsule().fill(Color.surfaceSecondary))
    }
}

#Preview {
    @Previewable @State var selection = "Chat"
    SegmentedPill(options: ["Chat", "Work"], selection: $selection)
        .padding(40)
}
