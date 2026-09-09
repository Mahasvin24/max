//
//  Constants.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import Foundation
import SwiftUI

struct Constants {
    static let maxString = "Max"
    static let userNameString = "Mahasvin"

    // API
    // nonisolated: APIClient runs off the main actor, so it must be able to
    // read this without hopping back to MainActor.
    nonisolated struct API {
        static let baseURL = "http://127.0.0.1:8000"
    }

    // BlinkTracker
    // nonisolated: BlinkSamplingSession's capture/Vision work runs off the main
    // actor, same reasoning as API above.
    nonisolated struct BlinkTracker {
        /// Length of one webcam capture burst.
        static let sampleWindowSeconds: TimeInterval = 25
        /// Gap between the start of one burst and the next — this duty-cycled
        /// design (~25s on, ~5min off) is what keeps CPU/battery/privacy-light
        /// impact negligible compared to continuous capture.
        static let sampleIntervalSeconds: TimeInterval = 300
        /// Frame rate the capture session is throttled to during a burst — every
        /// frame at this rate gets full landmark detection (see
        /// BlinkSamplingSession's header comment for why this isn't split into
        /// cheap tracking + periodic re-detection).
        static let processingFPS: Double = 12
        /// Eye-openness ratio (see EARCalculator) below which a frame
        /// counts as "eyes closed". Starting point borrowed from prior art's EAR
        /// threshold, but EARCalculator measures a bounding-box ratio rather than
        /// the literal 6-point EAR formula, so this is a first guess, not a
        /// validated number — watch real readings (e.g. a temporary debug log of
        /// `lastBlinkRate`) during manual verification and adjust if blinks are
        /// consistently over/under-counted. Not user-adjustable in v1.
        static let earBlinkThreshold: Double = 0.19
        /// Blinks/minute below which a sample window counts as "low".
        static let lowBlinkRateThreshold: Double = 10
        /// Consecutive low windows required before warning — guards against a
        /// single window's natural blink suppression (reading, typing) reading
        /// as a real problem.
        static let consecutiveLowWindowsToWarn = 2

        /// 20-20-20 rule: independent of blink detection — a different
        /// mechanism (accommodative fatigue, not blink suppression).
        static let breakIntervalMinutes: TimeInterval = 20 * 60
        static let breakDurationSeconds: TimeInterval = 20

        /// UserDefaults keys shared between BlinkTrackerMenuBarScreen's
        /// @AppStorage-backed Toggles and BlinkTrackerViewModel's own reads at
        /// startup — one string literal each, not duplicated ad hoc.
        static let blinkEnabledDefaultsKey = "blinkTrackerEnabled"
        static let breakTimerEnabledDefaultsKey = "breakTimerEnabled"
    }
}
