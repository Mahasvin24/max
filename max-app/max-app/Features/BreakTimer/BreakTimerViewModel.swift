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
import CoreGraphics
import Foundation

@Observable
final class BreakTimerViewModel {
    private(set) var nextBreakAt: Date?
    private(set) var isPausedForInactivity = false

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

    /// Shortens the current interval without bypassing the normal timer and
    /// notification path, making the complete reminder flow easy to verify.
    func setRemainingTimeForTesting() {
        guard breakTimerTask != nil else { return }
        isPausedForInactivity = false
        nextBreakAt = Date.now.addingTimeInterval(20)
    }

    private func startBreakTimer() {
        guard breakTimerTask == nil else { return }
        resumeTimer(at: .now)
        breakTimerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Constants.BreakTimer.activityCheckInterval))
                guard !Task.isCancelled else { return }
                guard let self else { return }
                self.updateTimer(at: .now)
            }
        }
    }

    private func stopBreakTimer() {
        breakTimerTask?.cancel()
        breakTimerTask = nil
        nextBreakAt = nil
        isPausedForInactivity = false
    }

    private func updateTimer(at now: Date) {
        let idleDuration = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState,
            // kCGAnyInputEventType is a C macro and isn't imported into Swift.
            // Core Graphics defines it as all bits set in CGEventType's UInt32.
            eventType: CGEventType(rawValue: UInt32.max)!
        )

        if idleDuration >= Constants.BreakTimer.idleThreshold {
            pauseForInactivity(at: now)
            return
        }

        if isPausedForInactivity {
            resumeTimer(at: now)
            return
        }

        guard let nextBreakAt, now >= nextBreakAt else { return }
        NotificationService.postBreakReminder()
        resumeTimer(at: now)
    }

    private func pauseForInactivity(at now: Date) {
        isPausedForInactivity = true
        // Keep the UI at 20:00 instead of letting wall-clock time elapse while
        // the person is away. A fresh interval starts after their next input.
        nextBreakAt = now.addingTimeInterval(Constants.BreakTimer.breakInterval)
    }

    private func resumeTimer(at now: Date) {
        isPausedForInactivity = false
        nextBreakAt = now.addingTimeInterval(Constants.BreakTimer.breakInterval)
    }

    // MARK: Sleep, screen, and login-session lifecycle

    private func registerLifecycleObservers() {
        let center = NSWorkspace.shared.notificationCenter
        lifecycleObserverTokens = [
            center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.pauseIfEnabled() }
            },
            center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.pauseIfEnabled() }
            },
            center.addObserver(forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.pauseIfEnabled() }
            },
            center.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.pauseIfEnabled() }
            },
            center.addObserver(forName: NSWorkspace.sessionDidResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.pauseIfEnabled() }
            },
            center.addObserver(forName: NSWorkspace.sessionDidBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.pauseIfEnabled() }
            },
        ]
    }

    private func pauseIfEnabled() {
        guard UserDefaults.standard.bool(forKey: Constants.BreakTimer.enabledDefaultsKey) else { return }
        pauseForInactivity(at: .now)
    }
}
