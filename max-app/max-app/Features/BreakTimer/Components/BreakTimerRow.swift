//
//  BreakTimerRow.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: HStack, VStack, Text(_:style:) — no third-party code.
//
//  Deliberately independent of BlinkStatusRow — the 20-20-20 timer addresses
//  accommodative fatigue, not blink suppression. Don't merge these into one row.
//

import SwiftUI

struct BreakTimerRow: View {
    /// `nil` means the break timer is off.
    let nextBreakAt: Date?

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: "timer")
                .foregroundStyle(nextBreakAt == nil ? Color.secondary : Color.accentColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text("20-20-20 break")
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)

                if let nextBreakAt {
                    // .timer style live-updates its own countdown — no manual
                    // refresh timer needed just to keep this text current.
                    Text(nextBreakAt, style: .timer)
                        .font(AppFont.message)
                        .monospacedDigit()
                } else {
                    Text("Reminders off")
                        .font(AppFont.message)
                }
            }

            Spacer(minLength: 0)
        }
    }
}
