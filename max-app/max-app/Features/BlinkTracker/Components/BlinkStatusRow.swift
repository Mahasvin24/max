//
//  BlinkStatusRow.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: HStack, VStack, Image(systemName:) — no third-party code.
//
//  Plain-values-only leaf component, per the Features/Chat convention — never
//  touches BlinkTrackerViewModel directly; BlinkTrackerMenuBarScreen hands it
//  whatever it needs to render.
//

import SwiftUI

struct BlinkStatusRow: View {
    let status: BlinkTrackerViewModel.BlinkStatus
    let cameraStatus: BlinkTrackerViewModel.CameraStatus
    let lastBlinkRate: Double?
    let lastCheckedAt: Date?

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text("Blink rate")
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
                Text(statusLine)
                    .font(AppFont.message)
            }

            Spacer(minLength: 0)
        }
    }

    private var iconName: String {
        switch cameraStatus {
        case .permissionDenied, .unavailable:
            return "video.slash"
        case .notStarted:
            return "eye.slash"
        case .monitoring:
            return status == .low ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch cameraStatus {
        case .permissionDenied, .unavailable, .notStarted:
            return .secondary
        case .monitoring:
            return status == .low ? .orange : .green
        }
    }

    private var statusLine: String {
        switch cameraStatus {
        case .permissionDenied:
            return "Camera access needed — open System Settings"
        case .unavailable(let message):
            return message
        case .notStarted:
            return "Monitoring off"
        case .monitoring:
            guard let lastBlinkRate else { return "Checking…" }
            let rate = Int(lastBlinkRate.rounded())
            return status == .low
                ? "\(rate) blinks/min — try blinking more"
                : "\(rate) blinks/min"
        }
    }
}
