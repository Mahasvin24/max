//
//  EARCalculator.swift
//  max-app
//
//  Provenance: ADAPTED — oxremy/BlinkMore (MIT), EyeTrackingService.swift.
//  Changes from the original: BlinkMore indexes fixed points (1/5, 2/4 for the
//  vertical pairs, 0/3 for the horizontal span), which assumes the classic dlib
//  6-point eye layout the EAR paper (Soukupová & Čech, 2016) was written against.
//  Apple's Vision framework doesn't guarantee that exact point count/order for
//  VNFaceLandmarks2D.leftEye/.rightEye (it varies by request revision) — indexing
//  into it the same way risks computing a ratio from the wrong points. Replaced
//  with a bounding-box openness ratio (max Y spread / max X spread across however
//  many points Vision returns) that measures the same "how open is the eye"
//  signal without assuming a fixed layout. Everything else (the overall EAR-style
//  ratio-and-threshold approach) is the idea being reused from BlinkMore.
//
//  Built from: CoreGraphics (CGPoint) — no SwiftUI/Vision types, so this stays
//  testable independent of a live camera/VNFaceObservation.
//

import CoreGraphics

/// Computes an eye-openness ratio from Vision's per-eye landmark point arrays
/// (`VNFaceLandmarks2D.leftEye`/`.rightEye`, via `.normalizedPoints`).
///
/// The ratio stays roughly constant while an eye is open and drops sharply during
/// a blink, which is what makes a single threshold crossing a usable blink signal
/// without per-user calibration. Values are on the same rough scale as the
/// EAR literature's ~0.3 (open) / ~0.1 (blink), though not numerically identical
/// since this uses a bounding-box measure rather than the fixed 6-point formula —
/// `Constants.BlinkTracker.earBlinkThreshold` is tuned against this ratio, not the
/// literal EAR formula.
// nonisolated: called synchronously from BurstCapture's (nonisolated) capture
// delegate callback, on the camera's own processing queue — must not require an
// actor hop back to MainActor under this project's default MainActor isolation.
nonisolated enum EARCalculator {
    /// - Parameter eyePoints: the eye-region points Vision returns for one eye,
    ///   in normalized [0,1] coordinates (point count varies by Vision revision,
    ///   deliberately not assumed here).
    /// - Returns: `nil` if there aren't enough points, or the span is degenerate
    ///   (a face turned edge-on to the camera, near-zero width).
    static func ear(for eyePoints: [CGPoint]) -> Double? {
        guard eyePoints.count >= 4 else { return nil }

        let xs = eyePoints.map(\.x)
        let ys = eyePoints.map(\.y)
        guard let minX = xs.min(), let maxX = xs.max(),
              let minY = ys.min(), let maxY = ys.max() else { return nil }

        let width = Double(maxX - minX)
        guard width > 0 else { return nil }
        return Double(maxY - minY) / width
    }

    /// Averages both eyes into one reading for a frame. `nil` if neither eye
    /// produced a usable value (e.g. a profile view where one eye is occluded).
    static func averageEAR(leftEye: [CGPoint], rightEye: [CGPoint]) -> Double? {
        let readings = [ear(for: leftEye), ear(for: rightEye)].compactMap { $0 }
        guard !readings.isEmpty else { return nil }
        return readings.reduce(0, +) / Double(readings.count)
    }
}
