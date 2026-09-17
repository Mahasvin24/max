// Provenance: HAND-BUILT. Built from: SwiftUI stacks, shapes, and native buttons.
import SwiftUI

struct EmptyChatView: View {
    var showsSuggestions = true
    var onSelectPrompt: (String) -> Void

    private let suggestions = [
        Suggestion(title: "Make a plan", detail: "Find your next step", icon: "point.topleft.down.to.point.bottomright.curvepath",
                   prompt: "Help me turn a goal into a simple, actionable plan. Start by asking what I want to accomplish."),
        Suggestion(title: "Explore an idea", detail: "Follow your curiosity", icon: "sparkle.magnifyingglass",
                   prompt: "Help me explore an idea. Ask me what's on my mind, then help me look at it from a fresh angle."),
        Suggestion(title: "Put it into words", detail: "Give a thought its shape", icon: "pencil.line",
                   prompt: "Help me turn my rough thoughts into clear writing. Ask me what I want to say and who it's for.")
    ]

    var body: some View {
        ViewThatFits(in: .vertical) {
            content
            ScrollView { content }
        }
        .frame(maxWidth: AppSpacing.readableWidth)
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxl) {
            HStack(alignment: .center, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.l) {
                    Text("Hi, \(Constants.userNameString).")
                        .font(AppFont.introduction)
                        .foregroundStyle(Color.textSecondary)
                    Text("What’s on\nyour mind?")
                        .font(AppFont.greeting)
                        .tracking(-0.8)
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

            HStack(spacing: AppSpacing.m) {
                ForEach(suggestions) { suggestion in
                    Button { onSelectPrompt(suggestion.prompt) } label: {
                        VStack(alignment: .leading, spacing: AppSpacing.l) {
                            HStack {
                                Image(systemName: suggestion.icon)
                                    .font(AppFont.toolbarIcon)
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(AppFont.caption)
                            }
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(suggestion.title)
                                    .font(AppFont.suggestionTitle)
                                    .foregroundStyle(Color.textPrimary)
                                Text(suggestion.detail).font(AppFont.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
                        .padding(AppSpacing.l)
                    }
                    .buttonStyle(SuggestionButtonStyle())
                    .accessibilityHint("Adds a suggested prompt to the message field")
                }
            }
            .opacity(showsSuggestions ? 1 : 0)
            .allowsHitTesting(showsSuggestions)
            .accessibilityHidden(!showsSuggestions)
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

    private struct Suggestion: Identifiable {
        var id: String { title }
        let title: String
        let detail: String
        let icon: String
        let prompt: String
    }
}

private struct SuggestionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Card(configuration: configuration)
    }

    private struct Card: View {
        let configuration: Configuration
        @State private var isHovered = false

        var body: some View {
            configuration.label
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.leading)
                .background(isHovered || configuration.isPressed ? Color.surfaceSelected : Color.surfaceSecondary,
                            in: .rect(cornerRadius: AppRadius.bubble))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.bubble)
                        .strokeBorder(isHovered ? Color.textSecondary : Color.borderSubtle, lineWidth: 1)
                }
                .contentShape(.rect(cornerRadius: AppRadius.bubble))
                .onHover { isHovered = $0 }
        }
    }
}

#Preview {
    EmptyChatView(onSelectPrompt: { _ in })
        .frame(width: 760, height: 460).background(Color.surface).preferredColorScheme(.dark)
}
