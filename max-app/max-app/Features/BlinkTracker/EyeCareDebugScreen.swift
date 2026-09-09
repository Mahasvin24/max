//
//  EyeCareDebugScreen.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Chart/LineMark/RuleMark/BarMark (Charts), ScrollView, VStack — no
//  third-party code.
//
//  Temporary, explicitly-requested debug view: continuous camera + Vision,
//  always tracking while this screen is open (unlike the production feature's
//  duty-cycled sampling). Live video + three graphs, for watching the pipeline
//  work in real time while tuning it — not part of the shipped always-on
//  feature. See EyeCareDebugViewModel and LiveBlinkFeed.
//

import Charts
import SwiftUI

struct EyeCareDebugScreen: View {
    /// The shared production view model — touched only to pause/resume its
    /// duty-cycled monitoring while this screen's own continuous session is
    /// running, so the two never contend for the camera. Never read its
    /// blink/break state here; this screen has its own.
    let blinkTrackerViewModel: BlinkTrackerViewModel

    @State private var debugViewModel = EyeCareDebugViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                header

                CameraPreviewView(session: debugViewModel.captureSession)
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .background(Color.black)
                    .clipShape(.rect(cornerRadius: AppRadius.bubble))

                if let errorMessage = debugViewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppFont.caption)
                        .foregroundStyle(.red)
                }

                earChart
                blinkStrip
                rateChart
            }
            .padding(AppSpacing.l)
            .frame(maxWidth: AppSpacing.readableWidth, alignment: .leading)
        }
        .background(Color.surface)
        .task {
            blinkTrackerViewModel.pauseForLiveDebugSession()
            debugViewModel.start()
        }
        .onDisappear {
            debugViewModel.stop()
            blinkTrackerViewModel.resumeAfterLiveDebugSession()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Eye Care — Debug")
                .font(AppFont.greeting)
            Text("Always tracking while this page is open, for testing the blink pipeline live. The shipped feature only samples in short bursts every few minutes — see Constants.BlinkTracker.")
                .font(AppFont.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var earChart: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("EAR (eye-openness ratio)")
                .font(AppFont.sidebarSectionHeader)
            Chart {
                ForEach(debugViewModel.earHistory) { point in
                    LineMark(x: .value("Time", point.time), y: .value("EAR", point.ear))
                }
                RuleMark(y: .value("Blink threshold", Constants.BlinkTracker.earBlinkThreshold))
                    .foregroundStyle(.red.opacity(0.6))
                    .lineStyle(StrokeStyle(dash: [4, 4]))
            }
            .chartXAxis(.hidden)
            .frame(height: 140)
        }
    }

    /// Recent blink events as tick marks — correlates by eye against the EAR
    /// dips above, over the same trailing window.
    private var blinkStrip: some View {
        let cutoff = Date().addingTimeInterval(-EyeCareDebugViewModel.earHistoryWindow)
        let recentBlinks = debugViewModel.blinkEvents.filter { $0.time >= cutoff }

        return VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Blinks (last \(Int(EyeCareDebugViewModel.earHistoryWindow))s)")
                .font(AppFont.sidebarSectionHeader)
            Chart(recentBlinks) { event in
                BarMark(x: .value("Time", event.time), y: .value("Blink", 1), width: 3)
                    .foregroundStyle(.orange)
            }
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .frame(height: 44)
        }
    }

    private var rateChart: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Blink rate (per minute, trailing 60s)")
                .font(AppFont.sidebarSectionHeader)
            Chart {
                ForEach(debugViewModel.rateHistory) { point in
                    LineMark(x: .value("Time", point.time), y: .value("Blinks/min", point.bpm))
                }
                RuleMark(y: .value("Low threshold", Constants.BlinkTracker.lowBlinkRateThreshold))
                    .foregroundStyle(.orange.opacity(0.6))
                    .lineStyle(StrokeStyle(dash: [4, 4]))
            }
            .frame(height: 140)
        }
    }
}
