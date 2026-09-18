// Provenance: HAND-BUILT. Built from: SwiftUI stacks and shapes.
import SwiftUI

struct EmptyChatView: View {
    var body: some View {
        ViewThatFits(in: .vertical) {
            content
            ScrollView { content }
        }
        .frame(maxWidth: AppSpacing.readableWidth)
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var content: some View {
        HStack(alignment: .center, spacing: AppSpacing.xl) {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                Text("Hi, \(Constants.userNameString).")
                    .font(AppFont.introduction)
                    .foregroundStyle(Color.textSecondary)
                Text("What’s on\nyour mind?")
                    .font(AppFont.greeting)
                    .tracking(-0.6)
                    .lineSpacing(-2)
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("A question, a rough idea, a new beginning.")
                    .font(AppFont.introduction)
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            brandArtwork
        }
        .padding(.vertical, AppSpacing.xl)
    }

    private var brandArtwork: some View {
        ZStack {
            Circle().strokeBorder(Color.borderSubtle, lineWidth: 1)
                .frame(width: 148, height: 148)
            Circle().strokeBorder(Color.borderSubtle, lineWidth: 1)
                .frame(width: 108, height: 108)
            LogoMark(size: 58)
                .foregroundStyle(Color.textPrimary)
                .rotationEffect(.degrees(-12))
            Circle().fill(Color.textPrimary)
                .frame(width: 6, height: 6)
                .offset(x: 64, y: -37)
        }
        .frame(width: 160, height: 160)
        .accessibilityHidden(true)
    }
}

#Preview {
    EmptyChatView()
        .frame(width: 760, height: 460).background(Color.surface).preferredColorScheme(.dark)
}
