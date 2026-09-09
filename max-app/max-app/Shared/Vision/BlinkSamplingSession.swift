//
//  BlinkSamplingSession.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: AVCaptureSession/AVCaptureVideoDataOutput (camera),
//  VNDetectFaceLandmarksRequest (Vision), AsyncThrowingStream — no third-party code.
//
//  Design follows prior art (BlinkMore, blinkEye, LazyEye — all Vision-based, none
//  needing an external ML model file): low-resolution capture, throttled frame
//  rate, full VNDetectFaceLandmarksRequest per processed frame.
//
//  Earlier draft of this file also tried VNTrackObjectRequest for cheap tracking
//  between periodic full re-detections (Apple's own real-time-face-tracking
//  pattern), re-running landmarks only every Nth frame. Dropped: VNTrackObjectRequest
//  tracks a generic bounding box, and its result isn't reliably castable back to a
//  VNFaceObservation with landmarks intact — riding on that without being able to
//  build+run and confirm it live wasn't worth the risk for a marginal saving. The
//  dominant CPU/battery win here is the duty-cycled outer loop (sleep 5min, capture
//  ~25s, repeat) plus low resolution and a throttled frame rate — see
//  Constants.BlinkTracker — not per-frame tracking tricks. Revisit if a burst's
//  measured CPU cost (see the plan's verification steps) turns out to need it.
//

import AVFoundation
import Vision

// nonisolated: AVFoundation calls the capture delegate below synchronously from
// its own background queue (processingQueue), not the main actor — matching
// APIClient's own "runs off the main actor" reasoning in Shared/Constants.swift.
// Under this project's SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor, leaving this
// unmarked would implicitly bind the delegate callback to the main actor, which
// AVFoundation's calling convention doesn't respect — it would be a real
// isolation violation, not just a style choice.
nonisolated enum BlinkSamplingSession {
    struct WindowResult {
        let blinkCount: Int
        let windowDuration: TimeInterval
        let framesWithFace: Int
    }

    enum SessionError: Error, LocalizedError {
        case cameraAccessDenied
        case noCameraAvailable

        var errorDescription: String? {
            switch self {
            case .cameraAccessDenied:
                return "Camera access denied — enable it in System Settings > Privacy & Security > Camera."
            case .noCameraAvailable:
                return "No camera is available on this Mac."
            }
        }
    }

    /// One long-lived loop: sleeps `sampleIntervalSeconds`, captures a burst,
    /// yields one `WindowResult` per burst. Runs until cancelled — modeled on
    /// APIClient.Chat.streamMessage's AsyncThrowingStream + Task + onTermination
    /// shape for a long-lived cancellable background operation.
    static func run() -> AsyncThrowingStream<WindowResult, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await ensureCameraAccess()
                    while true {
                        try await Task.sleep(for: .seconds(Constants.BlinkTracker.sampleIntervalSeconds))
                        try Task.checkCancellation()
                        continuation.yield(try await captureBurst())
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Not private: reused by the Eye Care debug screen's continuous
    /// LiveBlinkFeed, which needs the same permission check without
    /// duplicating it.
    static func ensureCameraAccess() async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return
        case .notDetermined:
            guard await AVCaptureDevice.requestAccess(for: .video) else {
                throw SessionError.cameraAccessDenied
            }
        case .denied, .restricted:
            throw SessionError.cameraAccessDenied
        @unknown default:
            throw SessionError.cameraAccessDenied
        }
    }

    private static func captureBurst() async throws -> WindowResult {
        try await BurstCapture().run(duration: Constants.BlinkTracker.sampleWindowSeconds)
    }
}

/// Runs exactly one webcam capture burst, then tears itself down completely —
/// nothing here stays alive between bursts. The outer 5-minute gap (owned by
/// BlinkSamplingSession.run) is what makes this a duty-cycled feature rather than
/// a continuously-running one.
nonisolated private final class BurstCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let session = AVCaptureSession()
    private let processingQueue = DispatchQueue(label: "com.max-app.blinktracker.processing")

    // Confined to `processingQueue`; read back via a final `processingQueue.sync`
    // after `stopRunning()` so nothing races the read.
    private var blinkCount = 0
    private var framesWithFace = 0
    private var eyesCurrentlyClosed = false

    func run(duration: TimeInterval) async throws -> BlinkSamplingSession.WindowResult {
        try configure()

        session.startRunning()
        try await Task.sleep(for: .seconds(duration))
        session.stopRunning()

        // `stopRunning()` stops future frame delivery but doesn't guarantee an
        // in-flight delegate call on `processingQueue` has finished — this sync
        // hop flushes that before we read the counters it wrote.
        return processingQueue.sync {
            BlinkSamplingSession.WindowResult(
                blinkCount: blinkCount,
                windowDuration: duration,
                framesWithFace: framesWithFace
            )
        }
    }

    private func configure() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        // Landmark detection doesn't need more than this — matches the common
        // choice across the prior-art apps researched for this feature.
        session.sessionPreset = .medium

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
            throw BlinkSamplingSession.SessionError.noCameraAvailable
        }
        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            throw BlinkSamplingSession.SessionError.noCameraAvailable
        }
        session.addInput(input)

        // Hardware frame-rate throttling: this reduces sensor/ISP work, not just
        // the Vision work downstream of it, which is the more expensive half of
        // "camera always on" per the research behind this feature.
        if let range = device.activeFormat.videoSupportedFrameRateRanges.first {
            // Clamp into [minFrameRate, maxFrameRate], not just capped below
            // maxFrameRate — some cameras' minimum supported rate is *above*
            // Constants.BlinkTracker.processingFPS (observed: a device whose
            // only supported range was 15–30fps). Setting activeVideoMinFrameDuration
            // outside the supported range raises an Objective-C exception, which
            // Swift's try/catch cannot catch — it crashes the process rather than
            // failing gracefully, so this must never be allowed to happen instead
            // of being caught after the fact.
            let fps = min(max(Constants.BlinkTracker.processingFPS, range.minFrameRate), range.maxFrameRate)
            // Setting these properties without holding the configuration lock
            // can throw at runtime — only proceed if the lock actually succeeded,
            // rather than swallowing the error and mutating unlocked.
            if fps > 0, let scale = Int32(exactly: fps.rounded()), (try? device.lockForConfiguration()) != nil {
                device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: scale)
                device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: scale)
                device.unlockForConfiguration()
            }
        }

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: processingQueue)
        guard session.canAddOutput(output) else {
            throw BlinkSamplingSession.SessionError.noCameraAvailable
        }
        session.addOutput(output)
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate — called on processingQueue

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Every throttled frame gets full landmark detection — see the file
        // header for why this isn't split into cheap-tracking + periodic
        // re-detection. `activeVideoMinFrameDuration` in configure() is what
        // keeps this frame rate low, not per-frame logic here.
        guard let observation = try? detectFace(in: pixelBuffer),
              let landmarks = observation.landmarks,
              let leftEye = landmarks.leftEye?.normalizedPoints,
              let rightEye = landmarks.rightEye?.normalizedPoints else { return }

        framesWithFace += 1
        guard let ear = EARCalculator.averageEAR(leftEye: leftEye, rightEye: rightEye) else { return }
        registerEAR(ear)
    }

    private func detectFace(in pixelBuffer: CVPixelBuffer) throws -> VNFaceObservation? {
        let request = VNDetectFaceLandmarksRequest()
        try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        return request.results?.first
    }

    /// Debounced: counts one blink per contiguous EAR dip below threshold, not
    /// once per low-EAR checkpoint frame in a row.
    private func registerEAR(_ ear: Double) {
        let closed = ear < Constants.BlinkTracker.earBlinkThreshold
        if closed && !eyesCurrentlyClosed {
            blinkCount += 1
        }
        eyesCurrentlyClosed = closed
    }
}
