//
//  LogoMark.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: MaxVortex Shape, KeyframeAnimator — no third-party code.
//  The in-app shape and menu bar template SVG are generated from the same
//  approved geometry in logo/vortex.js by logo/build.cjs.
//

import SwiftUI

/// The brandmark at a given size. Tint it with `.foregroundStyle`.
struct LogoMark: View {
    var size: CGFloat = 16
    var collapse: CGFloat = 0

    var body: some View {
        MaxVortex(collapse: collapse)
            .fill(.foreground)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// The brandmark spinning, for "Max is working on it" states.
///
/// The motion is a wind-up rather than a constant rotation: it drifts
/// counter-clockwise first, then releases into a full clockwise turn, settles,
/// and holds for a beat before going again. That backswing is the classic
/// animation principle of anticipation — the little move against the direction of
/// travel is what makes the spin read as effort rather than as a spinning GIF.
///
/// Built on `KeyframeAnimator` (macOS 14+) rather than a hand-rolled chain of
/// `withAnimation` calls or a third-party effects package. It's Apple's own API
/// for exactly this — one timeline, per-segment timing curves — and the
/// alternative libraries looked at (Pow) offer *change-triggered* spins, which
/// are a different thing from a repeating activity indicator.
///
/// If the timing needs adjusting, the durations below are the only knobs; they
/// sum to the cycle length. Keep the last keyframe at 360 and the initial value
/// at 0 so the loop point is invisible — 360° and 0° are the same picture.
struct LogoSpinner: View {
    var size: CGFloat = 16

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            // Reduce Motion means no spin at all — the accompanying "Thinking…"
            // text already says what's happening, so a still mark loses nothing.
            LogoMark(size: size)
        } else {
            KeyframeAnimator(initialValue: 0.0, repeating: true) { angle in
                LogoMark(size: size)
                    .rotationEffect(.degrees(angle))
            } keyframes: { _ in
                KeyframeTrack {
                    // Wind up: ease back against the spin and settle at the top of
                    // the backswing. `endVelocity: 0` matters — without it the cubic
                    // solver picks a velocity that smooths into the next keyframe
                    // (+180) and overshoots the target badly: -32 here measured as a
                    // -42 actual dip. Pinning the velocity makes the number mean what
                    // it says, and gives a crisper wind-up-pause-release.
                    //
                    // Keep this small. The mark has SIX-FOLD rotational symmetry, so
                    // 60 degrees is a complete visual period — a 40 degree backswing
                    // is most of a full turn to the eye, which reads as a lurch. ~20
                    // is about a third of a period: clearly legible, still subtle.
                    CubicKeyframe(-20, duration: 0.40, endVelocity: 0)
                    // Release: fastest through the middle of the turn.
                    CubicKeyframe(180, duration: 0.30)
                    CubicKeyframe(330, duration: 0.26)
                    // Settle onto the full turn instead of stopping dead.
                    SpringKeyframe(360, duration: 0.30, spring: .snappy)
                    // A beat of stillness, so the next wind-up reads as a fresh
                    // gesture rather than one continuous rotation.
                    LinearKeyframe(360, duration: 0.28)
                }
            }
        }
    }
}

#Preview("Mark") {
    HStack(spacing: 20) {
        LogoMark(size: 16)
        LogoMark(size: 28).foregroundStyle(.secondary)
        LogoMark(size: 44).foregroundStyle(Color.accentColor)
    }
    .padding()
}

#Preview("Spinner") {
    LogoSpinner(size: 32)
        .foregroundStyle(Color.accentColor)
        .padding(40)
}
