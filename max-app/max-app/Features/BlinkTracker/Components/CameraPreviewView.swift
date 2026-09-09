//
//  CameraPreviewView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: NSViewRepresentable, AVCaptureVideoPreviewLayer — no third-party code.
//
//  Attaches directly to the session rather than decoding each CVPixelBuffer into
//  an NSImage — cheaper, and independent of the AVCaptureVideoDataOutput branch
//  LiveBlinkFeed uses for Vision analysis on the same session.
//

import AVFoundation
import AppKit
import SwiftUI

struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> PreviewNSView {
        let view = PreviewNSView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateNSView(_ nsView: PreviewNSView, context: Context) {
        nsView.previewLayer.session = session
    }

    final class PreviewNSView: NSView {
        let previewLayer = AVCaptureVideoPreviewLayer()

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer = previewLayer
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
