import SwiftUI

/// Wrong-answer feedback: a short horizontal shake.
///
/// Flip `trigger` to `true` to fire one shake. Uses the iOS 16 one-parameter
/// `onChange` (the project's deployment target is iOS 16.0).
struct Shake: ViewModifier {
    let trigger: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { newValue in
                guard newValue else { return }
                withAnimation(.default) { offset = -10 }
                for (i, x) in [10.0, -8, 8, -4, 0].enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(i + 1)) {
                        withAnimation(.default) { offset = x }
                    }
                }
            }
    }
}

extension View {
    func shake(trigger: Bool) -> some View { modifier(Shake(trigger: trigger)) }
}
