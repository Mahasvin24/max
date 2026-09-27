//
//  BreakWarningPresenter.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: NSPanel, NSHostingView, and SwiftUI — no third-party code.
//
//  Presents the eye-break warning beneath Max's menu-bar item without
//  activating the app or replacing the SwiftUI-owned MenuBarExtra.
//

import AppKit
import SwiftUI

@MainActor
final class BreakWarningPresenter {
    static let shared = BreakWarningPresenter()

    private enum Layout {
        static let size = NSSize(width: 260, height: 82)
        static let horizontalScreenInset: CGFloat = 8
        static let hiddenOffset: CGFloat = 8
        static let animationDuration: TimeInterval = 0.18
    }

    private var panel: NSPanel?
    private var dismissalTask: Task<Void, Never>?
    private var presentationID = UUID()

    private init() {}

    func show() {
        guard let screen = targetScreen else { return }

        dismissalTask?.cancel()
        presentationID = UUID()

        let panel = panel ?? makePanel()
        let visibleOrigin = origin(for: panel, on: screen)
        let hiddenOrigin = NSPoint(x: visibleOrigin.x, y: visibleOrigin.y + Layout.hiddenOffset)

        panel.setFrameOrigin(hiddenOrigin)
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = Layout.animationDuration
            panel.animator().alphaValue = 1
            panel.animator().setFrameOrigin(visibleOrigin)
        }

        let currentPresentationID = presentationID
        dismissalTask = Task { [weak self, weak panel] in
            do {
                try await Task.sleep(for: .seconds(Constants.BreakTimer.warningDuration))
            } catch {
                return
            }

            guard let self, let panel, presentationID == currentPresentationID else { return }
            animateOut(panel, toward: hiddenOrigin)

            do {
                try await Task.sleep(for: .seconds(Layout.animationDuration))
            } catch {
                return
            }

            guard presentationID == currentPresentationID else { return }
            panel.orderOut(nil)
        }
    }

    private func animateOut(_ panel: NSPanel, toward origin: NSPoint) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Layout.animationDuration
            panel.animator().alphaValue = 0
            panel.animator().setFrameOrigin(origin)
        }
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: Layout.size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.isMovable = false
        panel.isOpaque = false
        panel.isReleasedWhenClosed = false
        panel.level = .statusBar
        panel.contentView = NSHostingView(rootView: BreakWarningView())
        self.panel = panel
        return panel
    }

    private var targetScreen: NSScreen? {
        let pointerLocation = NSEvent.mouseLocation
        return NSScreen.screens.first(where: { $0.frame.contains(pointerLocation) })
            ?? NSScreen.main
            ?? NSScreen.screens.first
    }

    private func origin(for panel: NSPanel, on screen: NSScreen) -> NSPoint {
        let savedPosition = UserDefaults.standard.object(
            forKey: Constants.MenuBar.preferredPositionDefaultsKey
        ) as? NSNumber
        let positionFromRight = savedPosition.map(CGFloat.init(truncating:))
            ?? Constants.MenuBar.initialPreferredPosition
        let itemCenterX = screen.frame.maxX - positionFromRight
        let unclampedX = itemCenterX - panel.frame.width / 2
        let x = min(
            max(unclampedX, screen.visibleFrame.minX + Layout.horizontalScreenInset),
            screen.visibleFrame.maxX - panel.frame.width - Layout.horizontalScreenInset
        )

        // visibleFrame.maxY is the lower edge of the menu bar, so the callout's
        // pointer visually connects to the status item without covering it.
        return NSPoint(x: x, y: screen.visibleFrame.maxY - panel.frame.height)
    }
}

private struct BreakWarningView: View {
    var body: some View {
        VStack(spacing: 0) {
            MenuBarCalloutPointer()
                .fill(Color.surfaceElevated)
                .frame(width: 18, height: 9)

            HStack(spacing: AppSpacing.m) {
                LogoMark(size: 24)
                    .foregroundStyle(Color.textPrimary)

                Text("It's been 20 minutes. Take a break?")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.vertical, AppSpacing.m)
            .background(Color.surfaceElevated, in: .rect(cornerRadius: AppRadius.panelCard))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.panelCard)
                    .strokeBorder(Color.borderSubtle, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.28), radius: 12, y: 5)
        }
        .padding(.horizontal, AppSpacing.s)
        .padding(.bottom, AppSpacing.s)
        .frame(width: 260, height: 82, alignment: .top)
        .preferredColorScheme(.dark)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("It's been 20 minutes. Take a break?")
    }
}

private struct MenuBarCalloutPointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
