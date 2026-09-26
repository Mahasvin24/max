//
//  BreakTimerRow.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: TimelineView, ProgressView, HStack — no third-party code.
//
//  Deliberately independent of BlinkStatusRow — the 20-20-20 timer addresses
//  accommodative fatigue, not blink suppression. Don't merge these into one row.
//
//  Layout follows vorssaint-utils' panel rows (icon column, label, trailing
//  monospaced value, progress underneath) but at this app's type scale.
//
//  One TimelineView drives BOTH the countdown text and the bar. The countdown
//  could have stayed `Text(_:style: .timer)`, which self-updates for free, but the
//  bar needs a tick anyway, and two independent update mechanisms would let the
//  number and the bar disagree by up to a second.
//

import SwiftUI

struct BreakTimerRow: View {
    /// `nil` means the break timer is off.
    let nextBreakAt: Date?
    let isPausedForInactivity: Bool

    private let iconColumnWidth: CGFloat = 22

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.s) {
            Image(systemName: "timer")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(nextBreakAt == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.accentColor))
                .frame(width: iconColumnWidth, alignment: .leading)
                // Nudge the icon onto the label's baseline rather than the top of
                // the taller countdown text below it.
                .padding(.top, 1)

            if let nextBreakAt {
                activeCountdown(nextBreakAt)
            } else {
                idleState
            }

            Spacer(minLength: 0)
        }
    }

    private func activeCountdown(_ nextBreakAt: Date) -> some View {
        // .periodic re-renders this subtree once a second; `context.date` is the
        // tick's own timestamp, so it stays correct if a tick is delivered late.
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = isPausedForInactivity
                ? Constants.BreakTimer.breakInterval
                : max(0, nextBreakAt.timeIntervalSince(context.date))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(isPausedForInactivity ? "Waiting for activity" : "Next break")
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)

                Text(Self.countdownText(remaining))
                    .font(AppFont.panelMetric)
                    .monospacedDigit()
                    // Without this the row's width twitches as digits change
                    // even with monospaced digits, because "9:59" is one glyph
                    // narrower than "19:59".
                    .contentTransition(.numericText())

                ProgressView(value: Self.elapsedFraction(remaining: remaining))
                    .progressViewStyle(.linear)
                    .controlSize(.small)
                    .tint(.accentColor)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isPausedForInactivity ? "Waiting for activity" : "Next break")
            .accessibilityValue(Self.accessibilityText(remaining))
        }
    }

    private var idleState: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Next break")
                .font(AppFont.caption)
                .foregroundStyle(.secondary)

            Text("Off")
                .font(AppFont.panelMetric)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: Formatting

    /// `m:ss` — minutes are unpadded so the value reads as a duration rather than
    /// a clock time.
    private static func countdownText(_ remaining: TimeInterval) -> String {
        let whole = Int(remaining.rounded(.up))
        return String(format: "%d:%02d", whole / 60, whole % 60)
    }

    /// How far through the current interval we are, 0...1 — so the bar fills as the
    /// break approaches rather than draining.
    private static func elapsedFraction(remaining: TimeInterval) -> Double {
        let interval = Constants.BreakTimer.breakInterval
        guard interval > 0 else { return 0 }
        return min(1, max(0, 1 - remaining / interval))
    }

    private static func accessibilityText(_ remaining: TimeInterval) -> String {
        let whole = Int(remaining.rounded(.up))
        let minutes = whole / 60
        let seconds = whole % 60
        if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s"), \(seconds) second\(seconds == 1 ? "" : "s")"
        }
        return "\(seconds) second\(seconds == 1 ? "" : "s")"
    }
}

#Preview("Running") {
    BreakTimerRow(
        nextBreakAt: .now.addingTimeInterval(19 * 60 + 32),
        isPausedForInactivity: false
    )
        .padding()
        .frame(width: 260)
}

#Preview("Paused") {
    BreakTimerRow(
        nextBreakAt: .now.addingTimeInterval(Constants.BreakTimer.breakInterval),
        isPausedForInactivity: true
    )
        .padding()
        .frame(width: 260)
}

#Preview("Off") {
    BreakTimerRow(nextBreakAt: nil, isPausedForInactivity: false)
        .padding()
        .frame(width: 260)
}
