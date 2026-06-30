import SwiftUI

struct PhraseFlashcardView: View {
    let info: PhraseInfo
    var isLatest: Bool = false

    @State private var isFlipped = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Front
            frontSide
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? -90 : 0), axis: (x: 0, y: 1, z: 0))

            // Back
            backSide
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : 90), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
        .scaleEffect(appeared ? 1 : 0.85)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            if isLatest {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    appeared = true
                }
            } else {
                appeared = true
            }
        }
    }

    private var frontSide: some View {
        phraseText
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .overlay(alignment: .bottomTrailing) {
            Text("Tap to flip")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(.systemGray3))
                .tracking(1)
                .padding(.bottom, 8)
                .padding(.trailing, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.indigo.opacity(0.15), lineWidth: 1.5)
        )
        .shadow(color: Color(.systemGray4).opacity(0.2), radius: 4, y: 2)
    }

    private var backSide: some View {
        VStack(spacing: 2) {
            backPhraseText
            Text("\"\(displayedExplanation)\"")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .italic()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .background(Color.indigo)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.indigo.opacity(0.8), lineWidth: 1.5)
        )
    }

    private var presentation: LinkPresentation {
        LinkPresentation(firstWord: info.word1, targetWord: info.word2, explanation: info.explanation)
    }

    private var phraseText: some View {
        HStack(spacing: presentation.separator == .joined ? 0 : 4) {
            Text(presentation.firstWord)
                .foregroundColor(Color(.systemGray))

            phraseSeparator(width: 8, color: Color(.systemGray3))

            Text(presentation.targetWord)
                .foregroundColor(.indigo)
        }
        .font(.system(size: 21, weight: .black, design: .rounded))
        .lineLimit(1)
        .minimumScaleFactor(0.55)
        .accessibilityLabel(Text(presentation.resolvedPhraseText))
    }

    private var backPhraseText: some View {
        HStack(spacing: presentation.separator == .joined ? 0 : 3) {
            Text(presentation.firstWord)

            phraseSeparator(width: 6, color: .white.opacity(0.7))

            Text(presentation.targetWord)
        }
        .font(.system(size: 11, weight: .black))
        .foregroundColor(.white.opacity(0.7))
        .tracking(1)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .accessibilityLabel(Text(presentation.resolvedPhraseText))
    }

    @ViewBuilder
    private func phraseSeparator(width: CGFloat, color: Color) -> some View {
        switch presentation.separator {
        case .joined:
            EmptyView()
        case .hyphen:
            Text("-")
                .foregroundColor(color)
        case .space:
            Color.clear
                .frame(width: width, height: 1)
        }
    }

    private var displayedExplanation: String {
        guard let colonIndex = info.explanation.firstIndex(of: ":") else {
            return info.explanation
        }
        let bodyStart = info.explanation.index(after: colonIndex)
        return info.explanation[bodyStart...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
