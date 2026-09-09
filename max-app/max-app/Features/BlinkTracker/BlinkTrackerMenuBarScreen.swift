//
//  BlinkTrackerMenuBarScreen.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: SurfacePanel, VStack, Toggle, Divider, @AppStorage — no third-party code.
//
//  Along with max_appApp, one of only two places that touch BlinkTrackerViewModel
//  directly — BlinkStatusRow and BreakTimerRow below take only plain values.
//
//  Two independent mechanisms, two independent rows/toggles: blink-rate
//  monitoring addresses reduced blink rate during screen use (dry eye risk);
//  the 20-20-20 timer addresses continuous near-focus (accommodative fatigue).
//  They don't share state and shouldn't be visually merged.
//

import SwiftUI

struct BlinkTrackerMenuBarScreen: View {
    let viewModel: BlinkTrackerViewModel

    // First use of @AppStorage in this codebase — the toggles are the source of
    // truth for "enabled", read by both this view and (via plain UserDefaults,
    // not @AppStorage) BlinkTrackerViewModel at launch/wake.
    @AppStorage(Constants.BlinkTracker.blinkEnabledDefaultsKey)
    private var blinkTrackerEnabled = true
    @AppStorage(Constants.BlinkTracker.breakTimerEnabledDefaultsKey)
    private var breakTimerEnabled = true

    var body: some View {
        SurfacePanel {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                Text("Eye Care")
                    .font(AppFont.sidebarSectionHeader)

                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    BlinkStatusRow(
                        status: viewModel.blinkStatus,
                        cameraStatus: viewModel.cameraStatus,
                        lastBlinkRate: viewModel.lastBlinkRate,
                        lastCheckedAt: viewModel.lastCheckedAt
                    )
                    Toggle("Monitor blink rate", isOn: $blinkTrackerEnabled)
                        .toggleStyle(.switch)
                        .font(AppFont.caption)
                }

                Divider()

                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    BreakTimerRow(nextBreakAt: viewModel.nextBreakAt)
                    Toggle("20-20-20 break reminders", isOn: $breakTimerEnabled)
                        .toggleStyle(.switch)
                        .font(AppFont.caption)
                }
            }
            .padding(AppSpacing.l)
        }
        .frame(width: 280)
        .onChange(of: blinkTrackerEnabled) { _, newValue in
            viewModel.setBlinkTrackerEnabled(newValue)
        }
        .onChange(of: breakTimerEnabled) { _, newValue in
            viewModel.setBreakTimerEnabled(newValue)
        }
    }
}
