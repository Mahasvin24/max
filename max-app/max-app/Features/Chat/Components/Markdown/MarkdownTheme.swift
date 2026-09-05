//
//  MarkdownTheme.swift
//  max-app
//
//  Provenance: ADAPTED — gonzalezreal/swift-markdown-ui (MIT), Theme+GitHub.swift.
//  Changes from the original: swapped the bundled `.gitHub` theme's own font sizes and
//  colors for this app's existing tokens (AppFont, AppSpacing, AppRadius, and the
//  Surface*/BorderSubtle asset colors already used by SurfacePanel) — same block/text
//  style structure, different values. Table borders/backgrounds, header-row bolding,
//  and code block chrome all follow the reference theme's approach.
//
//  Built from: MarkdownUI's Theme, TextStyle, and BlockStyle types — no other
//  third-party code.
//
//  Assistant replies render through this theme (see AssistantMessageView). As
//  "formatting nicely" grows into more of a feature (syntax-highlighted code,
//  blockquote styling, etc.), extend it here rather than hand-building new renderers —
//  MarkdownUI already does the parsing and block-level SwiftUI rendering.
//

import MarkdownUI
import SwiftUI

extension Theme {
    static let max = Theme()
        .text {
            ForegroundColor(.primary)
            FontSize(15) // matches AppFont.message
        }
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.9))
            BackgroundColor(.surfaceSecondary)
        }
        .link {
            ForegroundColor(.accentColor)
        }
        .paragraph { configuration in
            configuration.label
                .fixedSize(horizontal: false, vertical: true)
                .relativeLineSpacing(.em(0.33)) // ~ MessageTextStyle's .lineSpacing(5) at 15pt
                .markdownMargin(top: 0, bottom: AppSpacing.m)
        }
        .codeBlock { configuration in
            ScrollView(.horizontal) {
                configuration.label
                    .fixedSize(horizontal: false, vertical: true)
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.9))
                    }
                    .padding(AppSpacing.m)
            }
            .background(Color.surfaceElevated)
            // AppRadius has no "subtle" radius token yet, only .composer (pill) and
            // .bubble (18) — reusing .bubble here rather than a new magic number; eyeball
            // this against the #Preview and introduce a smaller named radius if 18pt
            // reads too round for a code block.
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.bubble))
            .markdownMargin(top: 0, bottom: AppSpacing.m)
        }
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: AppSpacing.xs)
        }
        .table { configuration in
            configuration.label
                .fixedSize(horizontal: false, vertical: true)
                .markdownTableBorderStyle(.init(color: .borderSubtle))
                .markdownTableBackgroundStyle(
                    .alternatingRows(.clear, Color.surfaceSecondary, header: .clear)
                )
                .markdownMargin(top: 0, bottom: AppSpacing.m)
        }
        .tableCell { configuration in
            configuration.label
                .markdownTextStyle {
                    if configuration.row == 0 {
                        FontWeight(.semibold) // header row
                    }
                    BackgroundColor(nil) // let the table's alternating-row style show through
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, AppSpacing.s)
                .padding(.horizontal, AppSpacing.m)
        }
        .thematicBreak {
            Divider()
                .overlay(Color.borderSubtle)
                .markdownMargin(top: AppSpacing.l, bottom: AppSpacing.l)
        }
}
