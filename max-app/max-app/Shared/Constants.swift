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

    // BreakTimer
    // Was Constants.BlinkTracker — also held camera/Vision sampling constants
    // for a blink-rate monitor that's since been cut (the camera indicator
    // light made you self-conscious about blinking, defeating the point).
    struct BreakTimer {
        /// 20-20-20 rule: every 20 minutes, a 20-second reminder to look at
        /// something ~20 feet away.
        ///
        /// Renamed from `breakIntervalMinutes`, which was misleading: the value is
        /// and always was 1200 *seconds*, and every call site treats it that way
        /// (`.seconds(...)`, `addingTimeInterval(...)`). The name was the only
        /// thing claiming minutes. A `TimeInterval` is seconds by definition, so
        /// no unit suffix is the honest spelling.
        static let breakInterval: TimeInterval = 20 * 60
        static let breakDurationSeconds: TimeInterval = 20

        /// Treat a minute without keyboard, mouse, or tablet input as time away
        /// from the Mac. While away, the next interval stays at a full 20
        /// minutes and begins only after input resumes.
        static let idleThreshold: TimeInterval = 60
        static let activityCheckInterval: TimeInterval = 1

        /// UserDefaults key shared between BreakTimerMenuBarScreen's
        /// @AppStorage-backed Toggle and BreakTimerViewModel's own reads at
        /// startup.
        static let enabledDefaultsKey = "breakTimerEnabled"
    }
}
