import UIKit

/// Pre-warms the system keyboard so it appears instantly the first time the
/// player reaches the typing screen.
///
/// The very first keyboard instantiation in a process is expensive (hundreds of
/// ms). On first launch the app drops straight into the guided tutorial, which
/// opens directly onto the typing screen — so that cost would otherwise land
/// right as the player sees the opening word. Warming during launch hides it.
enum KeyboardWarmer {
    private static var warmed = false
    private static var attempts = 0

    static func prewarm() {
        guard !warmed else { return }

        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            // The key window may not exist yet during launch; retry briefly.
            attempts += 1
            guard attempts < 20 else { return }
            DispatchQueue.main.async { prewarm() }
            return
        }

        warmed = true

        // A throwaway, invisible field. Becoming and immediately resigning first
        // responder in the same runloop spins up the keyboard subsystem without
        // visibly showing the keyboard.
        let field = UITextField(frame: .zero)
        field.keyboardType = .asciiCapable
        field.autocorrectionType = .no
        field.alpha = 0
        window.addSubview(field)
        field.becomeFirstResponder()
        field.resignFirstResponder()
        field.removeFromSuperview()
    }
}
