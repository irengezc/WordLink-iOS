import UIKit

/// Haptic feedback for the game's "juice" layer.
///
/// Generators are kept alive as statics so `prepare()` can warm them up when a
/// level appears, removing the latency of the first tap. On the simulator these
/// calls simply no-op — they never crash — so feel must be tested on a device.
enum Haptics {
    private static let selectionGen = UISelectionFeedbackGenerator()
    private static let impactMed = UIImpactFeedbackGenerator(style: .medium)

    /// Light tick when a word/letter is selected.
    static func selection() { selectionGen.selectionChanged() }

    /// Firm tap when two halves snap into a link.
    static func snap() { impactMed.impactOccurred(intensity: 0.9) }

    /// Rewarding buzz when a full chain completes.
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }

    /// Short error buzz on a wrong answer.
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }

    /// Call when the level appears to remove first-tap latency.
    static func prepare() {
        selectionGen.prepare()
        impactMed.prepare()
    }
}
