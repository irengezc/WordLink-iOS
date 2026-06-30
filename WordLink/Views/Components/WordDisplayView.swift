import SwiftUI

struct WordDisplayView: View {
    let firstWord: String
    let targetWord: String
    let revealedCount: Int
    let userInput: String
    let feedback: FeedbackState
    /// When true, a pulsing ring draws the eye to the next tile to fill
    /// (used to guide first-time players during the tutorial).
    var highlightCursor: Bool = false

    var body: some View {
        targetWordCard
            // Juice layer: the card pops on a correct link and shakes on a wrong one.
            .snapBounce(trigger: feedback == .correct)
            .shake(trigger: feedback == .wrong)
            .padding(.horizontal)
    }

    // MARK: - Word Card
    private var targetWordCard: some View {
        VStack(spacing: 16) {
            phraseTiles
            feedbackLabel
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(borderColor, lineWidth: 2)
        )
        .shadow(color: shadowColor, radius: 12, y: 4)
    }

    /// Tile scales tried (largest first) when shrinking the target to fit one
    /// line. `ViewThatFits` picks the first that fits the available width.
    private let tileScales: [CGFloat] = [1.0, 0.88, 0.76, 0.64, 0.54, 0.46]

    /// The front word + plus, followed by the target spelled out as tiles.
    ///
    /// Layout keeps each word whole on a single line:
    /// - Preferred: everything on one line, full-size tiles.
    /// - If the front word makes it too wide, it moves onto its own line above
    ///   the target (the target stays full size).
    /// - If the target itself is too long, the tiles shrink to fit one line.
    private var phraseTiles: some View {
        ViewThatFits(in: .horizontal) {
            // 1. Front word + full-size target, all on one line.
            HStack(spacing: 10) {
                frontWordLabel
                plusIcon
                tileRow(scale: 1)
            }
            // 2. Front word stacked above the target; target shrinks to fit.
            VStack(spacing: 10) {
                // Only here — on its own full-width line — do we allow the front
                // word to scale down, as a last resort for very long words.
                frontWordLabel
                    .minimumScaleFactor(0.7)
                fittedTileRow
            }
        }
    }

    // Rigid in the inline layout: it reports its true width so a long front word
    // forces the stacked fallback instead of silently shrinking on one line.
    private var frontWordLabel: some View {
        Text(firstWord)
            .font(.system(size: 18, weight: .black))
            .foregroundColor(Color(.systemGray))
            .lineLimit(1)
    }

    private var plusIcon: some View {
        Image(systemName: "plus")
            .font(.system(size: 11, weight: .black))
            .foregroundColor(Color(.systemGray3))
    }

    /// The target on a single line, shrunk just enough to fit the width.
    private var fittedTileRow: some View {
        ViewThatFits(in: .horizontal) {
            ForEach(tileScales, id: \.self) { scale in
                tileRow(scale: scale)
            }
        }
    }

    private func tileRow(scale: CGFloat) -> some View {
        HStack(spacing: 6 * scale) {
            ForEach(0..<targetWord.count, id: \.self) { index in
                let char = targetWord[targetWord.index(targetWord.startIndex, offsetBy: index)]
                LetterTile(
                    character: tileCharacter(index: index, char: char),
                    isRevealed: index < revealedCount,
                    hasUserInput: !tileCharacter(index: index, char: char).isEmpty && index >= revealedCount,
                    isCursor: isCursorPosition(index: index),
                    showPulse: highlightCursor && isCursorPosition(index: index),
                    scale: scale
                )
            }
        }
    }

    private func tileCharacter(index: Int, char: Character) -> String {
        if index < revealedCount {
            return String(char)
        }
        let inputIndex = index - revealedCount
        if inputIndex < userInput.count {
            return String(userInput[userInput.index(userInput.startIndex, offsetBy: inputIndex)])
        }
        return ""
    }

    private func isCursorPosition(index: Int) -> Bool {
        guard index >= revealedCount else { return false }
        return index == revealedCount + userInput.count
    }

    private var feedbackLabel: some View {
        Group {
            switch feedback {
            case .wrong:
                Text("Incorrect!")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.red)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(20)
            case .correct:
                Text("Correct!")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.green)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.12))
                    .cornerRadius(20)
            case .none:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: feedback)
    }

    // MARK: - Colors
    private var cardBackground: Color {
        switch feedback {
        case .correct: return Color.green.opacity(0.05)
        case .wrong:   return Color.red.opacity(0.05)
        case .none:    return Color(.systemBackground)
        }
    }

    private var borderColor: Color {
        switch feedback {
        case .correct: return .green.opacity(0.5)
        case .wrong:   return .red.opacity(0.5)
        case .none:    return Color(.systemGray5)
        }
    }

    private var shadowColor: Color {
        switch feedback {
        case .correct: return Color.green.opacity(0.15)
        case .wrong:   return Color.red.opacity(0.15)
        case .none:    return Color(.systemGray4).opacity(0.3)
        }
    }

}

// MARK: - Letter Tile
struct LetterTile: View {
    let character: String
    let isRevealed: Bool
    let hasUserInput: Bool
    let isCursor: Bool
    var showPulse: Bool = false
    /// Uniform scale (1 = default 36×44 tile) used to shrink long words to fit.
    var scale: CGFloat = 1

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10 * scale)
                .fill(tileBackground)
            RoundedRectangle(cornerRadius: 10 * scale)
                .frame(height: 4 * scale)
                .foregroundColor(bottomColor)
                .offset(y: 18 * scale)

            if !character.isEmpty {
                Text(character)
                    .font(.system(size: 22 * scale, weight: .black))
                    .foregroundColor(textColor)
            }

            if isCursor {
                RoundedRectangle(cornerRadius: 2 * scale)
                    .fill(Color.indigo.opacity(0.6))
                    .frame(width: 18 * scale, height: 3 * scale)
                    .offset(y: 12 * scale)
            }

        }
        .frame(width: 36 * scale, height: 44 * scale)
        .rippleHighlight(showPulse, cornerRadius: 12 * scale)
        .animation(.spring(response: 0.2), value: character)
    }

    private var tileBackground: Color {
        if isRevealed { return Color.indigo.opacity(0.08) }
        if hasUserInput { return Color(.systemBackground) }
        return Color(.systemGray6)
    }

    private var bottomColor: Color {
        if isRevealed { return .indigo }
        if hasUserInput { return Color.indigo.opacity(0.4) }
        return Color(.systemGray4)
    }

    private var textColor: Color {
        if isRevealed { return .indigo }
        return Color(.label)
    }
}

// MARK: - Ripple Highlight
/// An expanding amber ring that emanates from a view to draw the eye. Used on
/// the tutorial tile cursor to show where typing lands.
struct RippleHighlight: ViewModifier {
    let active: Bool
    var cornerRadius: CGFloat = 12

    @State private var pulse = false

    func body(content: Content) -> some View {
        content.overlay {
            if active {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.amber, lineWidth: 3)
                    .scaleEffect(pulse ? 1.18 : 1.0)
                    .opacity(pulse ? 0 : 0.9)
                    .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: pulse)
                    .onAppear { pulse = true }
                    .onDisappear { pulse = false }
            }
        }
    }
}

extension View {
    func rippleHighlight(_ active: Bool, cornerRadius: CGFloat = 12) -> some View {
        modifier(RippleHighlight(active: active, cornerRadius: cornerRadius))
    }
}

// MARK: - Guide Arrow
/// A bouncing amber arrow that points up at the Hint button to show first-time
/// players where to tap during the tutorial's hint step.
struct GuideArrow: View {
    @State private var bounce = false

    var body: some View {
        Image(systemName: "arrowshape.up.fill")
            .font(.system(size: 24, weight: .black))
            .foregroundColor(.amber)
            .shadow(color: Color.amber.opacity(0.4), radius: 4, y: 2)
            // Bob only downward so the highest point never reaches the button.
            .offset(y: bounce ? 0 : 7)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: bounce)
            .onAppear { bounce = true }
            .transition(.scale(scale: 0.5).combined(with: .opacity))
    }
}
