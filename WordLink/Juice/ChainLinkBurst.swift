import SwiftUI

/// The signature "link-snap" effect: a glow ring plus a burst of particles that
/// plays once. Overlay it on the connecting tile when a chain link completes.
///
/// Drive it with an `id`-keyed `@State` so SwiftUI builds a fresh instance —
/// and thus replays the `.onAppear` animation — on every completion. See the
/// usage in `GameView`.
struct ChainLinkBurst: View {
    var color: Color = .yellow
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.5))
                .frame(width: 60, height: 60)
                .scaleEffect(animate ? 2.2 : 0.3)
                .opacity(animate ? 0 : 0.8)

            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .offset(y: animate ? -42 : 0)
                    .rotationEffect(.degrees(Double(i) / 8 * 360))
                    .opacity(animate ? 0 : 1)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { animate = true }
        }
    }
}
