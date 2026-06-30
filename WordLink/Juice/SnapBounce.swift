import SwiftUI

/// A scale-bounce so completed words visibly "pop" into a link.
///
/// Flip `trigger` to `true` to fire one bounce. Uses the iOS 16 one-parameter
/// `onChange` (the project's deployment target is iOS 16.0).
struct SnapBounce: ViewModifier {
    let trigger: Bool
    @State private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { newValue in
                guard newValue else { return }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { scale = 1.25 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { scale = 1 }
                }
            }
    }
}

extension View {
    func snapBounce(trigger: Bool) -> some View { modifier(SnapBounce(trigger: trigger)) }
}
