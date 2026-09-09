//
//  BlinkTrackerViewModel.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: @Observable, Task, NSWorkspace notifications — no third-party code.
//
//  Owns two independent mechanisms — blink-rate monitoring and the 20-20-20
//  break timer — kept deliberately separate (separate tasks, separate state,
//  separate notification copy) because they address different physiological
//  causes of eye strain (blink suppression vs. accommodative fatigue). Never
//  merge them "to simplify" without re-reading why they're split.
//

import AppKit
import Foundation

@Observable
final class BlinkTrackerViewModel {
    // MARK: Blink status (in-memory only — no history persisted; v1 scope)

    enum BlinkStatus: Equatable {
        case unknown
        case normal
        case low
    }

    enum CameraStatus: Equatable {
        case notStarted
        case monitoring
        case permissionDenied
        case unavailable(String)
    }

    private(set) var blinkStatus: BlinkStatus = .unknown
    private(set) var cameraStatus: CameraStatus = .notStarted
    private(set) var lastBlinkRate: Double?
    private(set) var lastCheckedAt: Date?
    private var consecutiveLowWindows = 0

    // MARK: 20-20-20 timer

    private(set) var nextBreakAt: Date?

    // MARK: Menu bar icon

    var menuBarIconName: String {
        blinkStatus == .low ? "eye.trianglebadge.exclamationmark" : "eye"
    }

    private var samplingTask: Task<Void, Never>?
    private var breakTimerTask: Task<Void, Never>?
    private var lifecycleObserverTokens: [NSObjectProtocol] = []

    init() {
        UserDefaults.standard.register(defaults: [
            Constants.BlinkTracker.blinkEnabledDefaultsKey: true,
            Constants.BlinkTracker.breakTimerEnabledDefaultsKey: true,
        ])
        registerLifecycleObservers()
        Task { await NotificationService.requestAuthorizationIfNeeded() }

        if UserDefaults.standard.bool(forKey: Constants.BlinkTracker.blinkEnabledDefaultsKey) {
            startMonitoring()
        }
        if UserDefaults.standard.bool(forKey: Constants.BlinkTracker.breakTimerEnabledDefaultsKey) {
            startBreakTimer()
        }
    }

    deinit {
        lifecycleObserverTokens.forEach { NSWorkspace.shared.notificationCenter.removeObserver($0) }
        samplingTask?.cancel()
        breakTimerTask?.cancel()
    }

    // MARK: Settings toggles — called from BlinkTrackerMenuBarScreen's
    // .onChange(of:) on its @AppStorage-backed Toggles.

    func setBlinkTrackerEnabled(_ enabled: Bool) {
        enabled ? startMonitoring() : stopMonitoring()
    }

    func setBreakTimerEnabled(_ enabled: Bool) {
        enabled ? startBreakTimer() : stopBreakTimer()
    }

    // MARK: Blink-rate monitoring

    private func startMonitoring() {
        guard samplingTask == nil else { return }
        cameraStatus = .monitoring
        samplingTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await result in BlinkSamplingSession.run() {
                    self.handle(result)
                }
            } catch let error as BlinkSamplingSession.SessionError {
                switch error {
                case .cameraAccessDenied:
                    self.cameraStatus = .permissionDenied
                case .noCameraAvailable:
                    self.cameraStatus = .unavailable(error.errorDescription ?? "Camera unavailable.")
                }
            } catch {
                self.cameraStatus = .unavailable(error.localizedDescription)
            }
            self.samplingTask = nil
        }
    }

    private func stopMonitoring() {
        samplingTask?.cancel()
        samplingTask = nil
        cameraStatus = .notStarted
        blinkStatus = .unknown
    }

    private func handle(_ result: BlinkSamplingSession.WindowResult) {
        cameraStatus = .monitoring
        // No reliable face in this burst (stepped away, bad lighting) — skip it
        // entirely rather than reading "zero blinks seen" as a real low rate.
        guard result.framesWithFace > 0 else { return }

        let blinksPerMinute = Double(result.blinkCount) / (result.windowDuration / 60)
        lastBlinkRate = blinksPerMinute
        lastCheckedAt = .now

        guard blinksPerMinute < Constants.BlinkTracker.lowBlinkRateThreshold else {
            consecutiveLowWindows = 0
            blinkStatus = .normal
            return
        }

        consecutiveLowWindows += 1
        if consecutiveLowWindows >= Constants.BlinkTracker.consecutiveLowWindowsToWarn {
            blinkStatus = .low
            NotificationService.postBlinkWarning()
            // Reset the streak (not blinkStatus) so the warning fires once per
            // low episode rather than on every subsequent burst while it lasts.
            // blinkStatus stays .low — and visible in the menu bar — until a
            // normal-rate window clears it above.
            consecutiveLowWindows = 0
        }
    }

    // MARK: 20-20-20 break timer — no camera involvement at all

    private func startBreakTimer() {
        guard breakTimerTask == nil else { return }
        nextBreakAt = .now.addingTimeInterval(Constants.BlinkTracker.breakIntervalMinutes)
        breakTimerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                try? await Task.sleep(for: .seconds(Constants.BlinkTracker.breakIntervalMinutes))
                guard !Task.isCancelled else { return }
                self.nextBreakAt = .now.addingTimeInterval(Constants.BlinkTracker.breakIntervalMinutes)
                NotificationService.postBreakReminder()
            }
        }
    }

    private func stopBreakTimer() {
        breakTimerTask?.cancel()
        breakTimerTask = nil
        nextBreakAt = nil
    }

    // MARK: Sleep/wake — pause both loops rather than burn camera/battery on a
    // sleeping or locked Mac with no one to warn.

    private func registerLifecycleObservers() {
        // NSNotificationCenter's closure parameter predates Swift concurrency —
        // `queue: .main` is only a runtime guarantee, not something the compiler
        // treats as main-actor isolation, so the hop to MainActor is spelled out
        // explicitly rather than calling these methods directly from the closure.
        let center = NSWorkspace.shared.notificationCenter
        lifecycleObserverTokens = [
            center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.pauseForSleep() }
            },
            center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.resumeAfterWake() }
            },
        ]
    }

    private func pauseForSleep() {
        samplingTask?.cancel()
        samplingTask = nil
        breakTimerTask?.cancel()
        breakTimerTask = nil
    }

    private func resumeAfterWake() {
        if UserDefaults.standard.bool(forKey: Constants.BlinkTracker.blinkEnabledDefaultsKey) {
            startMonitoring()
        }
        if UserDefaults.standard.bool(forKey: Constants.BlinkTracker.breakTimerEnabledDefaultsKey) {
            startBreakTimer()
        }
    }
}
