//
//  BreakTimerMenuBarScreen.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: SurfacePanel, PanelSectionHeader, Toggle, @AppStorage — no
//  third-party code.
//
//  Was BlinkTrackerMenuBarScreen: also showed live blink-rate status above this
//  row. Cut along with the camera-based monitoring — see BreakTimerViewModel.
//
//  Structure is modelled on vorssaint-utils' menu panel: an uppercased section
//  label, then a bordered card holding the section's rows, with a Divider between
//  the readout and the control that governs it. Colors and type are this app's own
//  (SurfacePanel / AppFont), so it reads as Max rather than as a copy.
//
//  Note SurfacePanel is given an EXPLICIT radius. Its default is AppRadius.composer
//  (999), which SwiftUI clamps to half the shortest side — that turned this panel
//  into a full stadium/pill, which is what made the old popover look broken.
//

import SwiftUI

struct BreakTimerMenuBarScreen: View {
    let viewModel: BreakTimerViewModel

    @AppStorage(Constants.BreakTimer.enabledDefaultsKey)
    private var breakTimerEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            PanelSectionHeader("Eye Care")

            SurfacePanel(cornerRadius: AppRadius.panelCard) {
                VStack(alignment: .leading, spacing: AppSpacing.m) {
                    BreakTimerRow(nextBreakAt: viewModel.nextBreakAt)

                    Divider()

                    Toggle("Break reminders", isOn: $breakTimerEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                        .font(AppFont.caption)
                }
                .padding(AppSpacing.m)
            }

            Text("Every 20 minutes, look at something 20 feet away for 20 seconds.")
                .font(AppFont.caption)
                // .secondary, not .tertiary: tertiary tested too faint to read
                // against both the light and dark popover backgrounds.
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, AppSpacing.xs)
        }
        .padding(AppSpacing.l)
        .frame(width: 280)
        .onChange(of: breakTimerEnabled) { _, newValue in
            viewModel.setBreakTimerEnabled(newValue)
        }
    }
}

#Preview {
    BreakTimerMenuBarScreen(viewModel: BreakTimerViewModel())
}
