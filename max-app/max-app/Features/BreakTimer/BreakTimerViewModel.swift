//
//  BreakTimerViewModel.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: @Observable, Task, NSWorkspace notifications — no third-party code.
//
//  Was BlinkTrackerViewModel: also drove a camera-based blink-rate monitor
//  alongside this timer. Cut — the camera indicator light turning on made you
//  self-conscious about blinking, which defeats the point. This is now just
//  the 20-20-20 break reminder, no camera/Vision involved at all.
//

import AppKit
import Foundation

@Observable
final class BreakTimerViewModel {
    private(set) var nextBreakAt: Date?

    private var breakTimerTask: Task<Void, Never>?
    private var lifecycleObserverTokens: [NSObjectProtocol] = []

    init() {
        UserDefaults.standard.register(defaults: [
            Constants.BreakTimer.enabledDefaultsKey: true,
        ])
        registerLifecycleObservers()
        Task { await NotificationService.requestAuthorizationIfNeeded() }

        if UserDefaults.standard.bool(forKey: Constants.BreakTimer.enabledDefaultsKey) {
            startBreakTimer()
        }
    }

    deinit {
        lifecycleObserverTokens.forEach { NSWorkspace.shared.notificationCenter.removeObserver($0) }
        breakTimerTask?.cancel()
    }

    /// Called from BreakTimerMenuBarScreen's .onChange(of:) on its
    /// @AppStorage-backed Toggle.
    func setBreakTimerEnabled(_ enabled: Bool) {
        enabled ? startBreakTimer() : stopBreakTimer()
    }

    private func startBreakTimer() {
        guard breakTimerTask == nil else { return }
        nextBreakAt = .now.addingTimeInterval(Constants.BreakTimer.breakInterval)
        breakTimerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                try? await Task.sleep(for: .seconds(Constants.BreakTimer.breakInterval))
                guard !Task.isCancelled else { return }
                self.nextBreakAt = .now.addingTimeInterval(Constants.BreakTimer.breakInterval)
                NotificationService.postBreakReminder()
            }
        }
    }

    private func stopBreakTimer() {
        breakTimerTask?.cancel()
        breakTimerTask = nil
        nextBreakAt = nil
    }

    // MARK: Sleep/wake — pause rather than keep reminding on a sleeping/locked Mac.

    private func registerLifecycleObservers() {
        let center = NSWorkspace.shared.notificationCenter
        lifecycleObserverTokens = [
            center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.stopBreakTimer() }
            },
            center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.resumeAfterWake() }
            },
        ]
    }

    private func resumeAfterWake() {
        if UserDefaults.standard.bool(forKey: Constants.BreakTimer.enabledDefaultsKey) {
            startBreakTimer()
        }
    }
}
