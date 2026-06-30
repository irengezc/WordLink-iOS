import Foundation

struct LinkPresentationEvalCase {
    let name: String
    let firstWord: String
    let targetWord: String
    let explanation: String
    let expectedSeparator: String
    let expectedText: String
}

@main
struct LinkPresentationEval {
    static func main() {
        let cases = [
            LinkPresentationEvalCase(
                name: "closed compound uses no separator",
                firstWord: "CLASS",
                targetWord: "ROOM",
                explanation: "CLASSROOM: A room where a teacher and students have lessons.",
                expectedSeparator: "",
                expectedText: "CLASSROOM"
            ),
            LinkPresentationEvalCase(
                name: "known closed compound corrects spaced reservoir prefix",
                firstWord: "CLASS",
                targetWord: "ROOM",
                explanation: "CLASS ROOM: A room where a teacher and students have lessons.",
                expectedSeparator: "",
                expectedText: "CLASSROOM"
            ),
            LinkPresentationEvalCase(
                name: "hyphenated compound uses hyphen",
                firstWord: "CHECK",
                targetWord: "IN",
                explanation: "CHECK-IN: The process of registering when you arrive.",
                expectedSeparator: "-",
                expectedText: "CHECK-IN"
            ),
            LinkPresentationEvalCase(
                name: "open phrase uses a gap",
                firstWord: "HIGH",
                targetWord: "SCHOOL",
                explanation: "HIGH SCHOOL: A school for older children and teenagers.",
                expectedSeparator: " ",
                expectedText: "HIGH SCHOOL"
            ),
            LinkPresentationEvalCase(
                name: "missing phrase prefix falls back to open phrase",
                firstWord: "GO",
                targetWord: "UP",
                explanation: "To move higher or increase.",
                expectedSeparator: " ",
                expectedText: "GO UP"
            )
        ]

        for testCase in cases {
            let presentation = LinkPresentation(
                firstWord: testCase.firstWord,
                targetWord: testCase.targetWord,
                explanation: testCase.explanation
            )

            guard presentation.separator.symbol == testCase.expectedSeparator else {
                fatalError("\(testCase.name): expected separator \(String(reflecting: testCase.expectedSeparator)), got \(String(reflecting: presentation.separator.symbol))")
            }

            guard presentation.resolvedPhraseText == testCase.expectedText else {
                fatalError("\(testCase.name): expected text \(testCase.expectedText), got \(presentation.resolvedPhraseText)")
            }
        }

        let wordDisplaySource = try! String(
            contentsOfFile: "WordLink/Views/Components/WordDisplayView.swift",
            encoding: .utf8
        )
        guard wordDisplaySource.contains("if char == \"?\"") else {
            fatalError("WordDisplayView should render hidden preview letters as underline slots instead of visible question marks")
        }
        guard wordDisplaySource.contains(".frame(width: 14, height: 3)") else {
            fatalError("WordDisplayView should use underline strokes for hidden preview letters")
        }
        guard wordDisplaySource.contains(".frame(width: 8)") else {
            fatalError("WordDisplayView should use a wider visual gap for open phrases")
        }

        let flashcardSource = try! String(
            contentsOfFile: "WordLink/Views/Components/PhraseFlashcardView.swift",
            encoding: .utf8
        )
        guard flashcardSource.contains("displayedExplanation") else {
            fatalError("PhraseFlashcardView should strip repeated phrase prefixes from the explanation body")
        }
        guard !flashcardSource.contains("Text(\"\\\"\\(info.explanation)\\\"\")") else {
            fatalError("PhraseFlashcardView should not render raw explanations with repeated phrase prefixes")
        }
        guard flashcardSource.contains("VStack(spacing: 2)") &&
                flashcardSource.contains(".frame(width: width, height: 1)") else {
            fatalError("PhraseFlashcardView should keep the phrase heading close to the explanation")
        }
        guard flashcardSource.contains("phraseSeparator(width: 8, color: Color(.systemGray3))") else {
            fatalError("PhraseFlashcardView should use a compact front-side gap for open phrases")
        }
        guard flashcardSource.contains("phraseSeparator(width: 6, color: .white.opacity(0.7))") else {
            fatalError("PhraseFlashcardView should use a compact flip-side gap for open phrases")
        }

        let gameViewSource = try! String(
            contentsOfFile: "WordLink/Views/GameView.swift",
            encoding: .utf8
        )
        guard gameViewSource.contains(".frame(width: 112, height: 42)") else {
            fatalError("GameView should reserve enough space for the floating score badge")
        }
        guard gameViewSource.contains(".frame(minWidth: 44)") else {
            fatalError("FloatingScoreView should keep positive score labels readable")
        }

        print("Link presentation eval passed (\(cases.count) cases)")
    }
}
