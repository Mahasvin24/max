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
}
