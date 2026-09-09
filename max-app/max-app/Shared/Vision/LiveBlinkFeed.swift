//
//  LiveBlinkFeed.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: AVCaptureSession/AVCaptureVideoDataOutput, VNDetectFaceLandmarksRequest —
//  same building blocks as BlinkSamplingSession's BurstCapture, restructured to run
//  continuously instead of for one bounded burst.
//
//  Exists only for EyeCareDebugScreen — a temporary, explicitly-requested
//  always-on mode for watching the detection pipeline live (video + EAR/blink
//  graphs) while testing. The production feature (BlinkSamplingSession) stays
//  duty-cycled; this file doesn't change that design, it's a separate debug-only
//  engine that the debug screen starts instead of, never alongside, the
//  production loop — see BlinkTrackerViewModel.pauseForLiveDebugSession().
//

import AVFoundation
import Vision

/// One processed frame's result. All value types — safe to hand across the
/// actor boundary from the (nonisolated) capture delegate to a MainActor
/// view model without needing Sendable gymnastics.
struct LiveBlinkSample: Sendable {
    let ear: Double?
    let isBlink: Bool
    let timestamp: Date
}

// nonisolated: same reasoning as BlinkSamplingSession — AVFoundation calls the
// capture delegate synchronously from its own queue, not the main actor.
nonisolated final class LiveBlinkFeed: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    /// Exposed so CameraPreviewView can attach an AVCaptureVideoPreviewLayer
    /// directly to this session — the preview taps the session independently
    /// of the AVCaptureVideoDataOutput branch used for Vision below, so
    /// showing live video doesn't require decoding frames into images by hand.
    let session = AVCaptureSession()

    private let processingQueue = DispatchQueue(label: "com.max-app.blinktracker.livedebug")
    private var eyesCurrentlyClosed = false
    private var onSample: (@Sendable (LiveBlinkSample) -> Void)?

    /// Starts continuous capture. `onSample` is called once per processed
    /// frame, on `processingQueue` — callers must hop to their own isolation
    /// domain themselves (see EyeCareDebugViewModel.start()).
    func start(onSample: @escaping @Sendable (LiveBlinkSample) -> Void) throws {
        self.onSample = onSample
        try configure()
        session.startRunning()
    }

    func stop() {
        session.stopRunning()
        onSample = nil
    }

    private func configure() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .medium

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
            throw BlinkSamplingSession.SessionError.noCameraAvailable
        }
        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            throw BlinkSamplingSession.SessionError.noCameraAvailable
        }
        session.addInput(input)

        // Same throttle as the production burst — a live debug feed doesn't
        // need full sensor rate to be watchable, and this keeps Vision's cost
        // comparable to what the production feature actually sees.
        if let range = device.activeFormat.videoSupportedFrameRateRanges.first {
            // Clamp into [minFrameRate, maxFrameRate] — see BlinkSamplingSession's
            // configure() for why capping below maxFrameRate alone crashed on a
            // real device (its minimum supported rate was above processingFPS).
            let fps = min(max(Constants.BlinkTracker.processingFPS, range.minFrameRate), range.maxFrameRate)
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

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = Date()

        guard let observation = try? detectFace(in: pixelBuffer),
              let landmarks = observation.landmarks,
              let leftEye = landmarks.leftEye?.normalizedPoints,
              let rightEye = landmarks.rightEye?.normalizedPoints,
              let ear = EARCalculator.averageEAR(leftEye: leftEye, rightEye: rightEye) else {
            onSample?(LiveBlinkSample(ear: nil, isBlink: false, timestamp: timestamp))
            return
        }

        let closed = ear < Constants.BlinkTracker.earBlinkThreshold
        let isBlink = closed && !eyesCurrentlyClosed
        eyesCurrentlyClosed = closed

        onSample?(LiveBlinkSample(ear: ear, isBlink: isBlink, timestamp: timestamp))
    }

    private func detectFace(in pixelBuffer: CVPixelBuffer) throws -> VNFaceObservation? {
        let request = VNDetectFaceLandmarksRequest()
        try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        return request.results?.first
    }
}
