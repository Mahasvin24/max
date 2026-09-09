//
//  EyeCareDebugViewModel.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: @Observable, Task — no third-party code.
//
//  Temporary debug view model for EyeCareDebugScreen: owns a continuous
//  LiveBlinkFeed (unlike the production BlinkTrackerViewModel, which stays
//  duty-cycled) and keeps rolling history for the three graphs the screen shows.
//

import AVFoundation
import Foundation

@Observable
final class EyeCareDebugViewModel {
    struct EARPoint: Identifiable {
        let id = UUID()
        let time: Date
        let ear: Double
    }

    struct BlinkEvent: Identifiable {
        let id = UUID()
        let time: Date
    }

    struct RatePoint: Identifiable {
        let id = UUID()
        let time: Date
        let bpm: Double
    }

    /// Kept for the EAR chart's window — not private: EyeCareDebugScreen reads
    /// this directly so the blink-strip chart's window label stays in sync
    /// with the EAR chart's, instead of duplicating the number.
    static let earHistoryWindow: TimeInterval = 30
    /// Kept longer than earHistoryWindow: recomputeRate() looks back 60s, and
    /// the blink-strip chart only shows a shorter recent slice of this same
    /// array — pruning it to 30s would starve the rate calculation.
    private static let blinkEventRetention: TimeInterval = 300
    private static let rateHistoryWindow: TimeInterval = 300
    private static let rateRecomputeInterval: TimeInterval = 5

    private(set) var earHistory: [EARPoint] = []
    private(set) var blinkEvents: [BlinkEvent] = []
    private(set) var rateHistory: [RatePoint] = []
    private(set) var isRunning = false
    private(set) var errorMessage: String?

    /// For CameraPreviewView.
    var captureSession: AVCaptureSession { feed.session }

    private let feed = LiveBlinkFeed()
    private var rateTimerTask: Task<Void, Never>?

    func start() {
        guard !isRunning else { return }
        errorMessage = nil
        Task {
            do {
                try await BlinkSamplingSession.ensureCameraAccess()
                try feed.start { [weak self] sample in
                    // Hop to MainActor explicitly — this closure is called
                    // from LiveBlinkFeed's nonisolated capture-delegate queue,
                    // same reasoning as BlinkTrackerViewModel's NSWorkspace fix.
                    Task { @MainActor in self?.record(sample) }
                }
                isRunning = true
                startRateTimer()
            } catch {
                isRunning = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func stop() {
        isRunning = false
        feed.stop()
        rateTimerTask?.cancel()
        rateTimerTask = nil
    }

    private func record(_ sample: LiveBlinkSample) {
        if let ear = sample.ear {
            earHistory.append(EARPoint(time: sample.timestamp, ear: ear))
        }
        let earCutoff = sample.timestamp.addingTimeInterval(-Self.earHistoryWindow)
        earHistory.removeAll { $0.time < earCutoff }

        if sample.isBlink {
            blinkEvents.append(BlinkEvent(time: sample.timestamp))
        }
        let blinkCutoff = sample.timestamp.addingTimeInterval(-Self.blinkEventRetention)
        blinkEvents.removeAll { $0.time < blinkCutoff }
    }

    private func startRateTimer() {
        rateTimerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Self.rateRecomputeInterval))
                guard !Task.isCancelled, let self else { return }
                self.recomputeRate()
            }
        }
    }

    /// Blinks in the trailing 60s, recomputed periodically — since the window
    /// is exactly 60s, the count already is the per-minute rate.
    private func recomputeRate() {
        let now = Date()
        let windowStart = now.addingTimeInterval(-60)
        let recentBlinks = blinkEvents.filter { $0.time >= windowStart }.count
        rateHistory.append(RatePoint(time: now, bpm: Double(recentBlinks)))
        let cutoff = now.addingTimeInterval(-Self.rateHistoryWindow)
        rateHistory.removeAll { $0.time < cutoff }
    }
}
