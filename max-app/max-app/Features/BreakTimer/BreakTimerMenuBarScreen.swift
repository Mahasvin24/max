//
//  BreakTimerMenuBarScreen.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: SurfacePanel, VStack, Toggle, @AppStorage — no third-party code.
//
//  Was BlinkTrackerMenuBarScreen: also showed live blink-rate status above this
//  row. Cut along with the camera-based monitoring — see BreakTimerViewModel.
//

import SwiftUI

struct BreakTimerMenuBarScreen: View {
    let viewModel: BreakTimerViewModel

    @AppStorage(Constants.BreakTimer.enabledDefaultsKey)
    private var breakTimerEnabled = true

    var body: some View {
        SurfacePanel {
            VStack(alignment: .leading, spacing: AppSpacing.m) {
                Text("Eye Care")
                    .font(AppFont.sidebarSectionHeader)

                BreakTimerRow(nextBreakAt: viewModel.nextBreakAt)
                Toggle("20-20-20 break reminders", isOn: $breakTimerEnabled)
                    .toggleStyle(.switch)
                    .font(AppFont.caption)
            }
            .padding(AppSpacing.l)
        }
        .frame(width: 280)
        .onChange(of: breakTimerEnabled) { _, newValue in
            viewModel.setBreakTimerEnabled(newValue)
        }
    }
}
