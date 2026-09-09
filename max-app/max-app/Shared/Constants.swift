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
        static let breakIntervalMinutes: TimeInterval = 20 * 60
        static let breakDurationSeconds: TimeInterval = 20

        /// UserDefaults key shared between BreakTimerMenuBarScreen's
        /// @AppStorage-backed Toggle and BreakTimerViewModel's own reads at
        /// startup.
        static let enabledDefaultsKey = "breakTimerEnabled"
    }
}
