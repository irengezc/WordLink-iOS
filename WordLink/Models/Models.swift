import Foundation

// MARK: - Difficulty
enum Difficulty: String, Codable, CaseIterable {
    case easy = "EASY"
    case medium = "MEDIUM"
    case hard = "HARD"

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var startingScore: Int {
        switch self {
        case .easy: return 100
        case .medium: return 80
        case .hard: return 50
        }
    }

    var hintCost: Int {
        switch self {
        case .easy: return 15
        case .medium: return 25
        case .hard: return 40
        }
    }

    var emoji: String {
        switch self {
        case .easy: return "🌱"
        case .medium: return "🔥"
        case .hard: return "💀"
        }
    }

    var description: String {
        switch self {
        case .easy: return "Common phrases & simple connections"
        case .medium: return "Idioms and everyday collocations"
        case .hard: return "Complex idioms & abstract links"
        }
    }

    var color: String {
        switch self {
        case .easy: return "emerald"
        case .medium: return "amber"
        case .hard: return "rose"
        }
    }
}

// MARK: - Phrase Info
struct PhraseInfo: Codable, Identifiable {
    var id = UUID()
    let word1: String
    let word2: String
    let explanation: String

    enum CodingKeys: String, CodingKey {
        case word1, word2, explanation
    }
}

// MARK: - Link Presentation
enum LinkSeparator: Equatable {
    case joined
    case hyphen
    case space

    var symbol: String {
        switch self {
        case .joined: return ""
        case .hyphen: return "-"
        case .space: return " "
        }
    }
}

struct LinkPresentation: Equatable {
    let firstWord: String
    let targetWord: String
    let separator: LinkSeparator
    let resolvedPhraseText: String

    init(firstWord: String, targetWord: String, explanation: String = "") {
        let normalizedFirst = Self.normalized(firstWord)
        let normalizedTarget = Self.normalized(targetWord)
        self.firstWord = normalizedFirst
        self.targetWord = normalizedTarget

        let joinedText = normalizedFirst + normalizedTarget
        let hyphenText = normalizedFirst + "-" + normalizedTarget
        let openText = normalizedFirst + " " + normalizedTarget
        let explanationPrefix = Self.explanationPrefix(from: explanation)

        if explanationPrefix == joinedText || Self.knownJoinedPhrases.contains(joinedText) {
            separator = .joined
            resolvedPhraseText = joinedText
        } else if explanationPrefix == hyphenText || Self.knownHyphenatedPhrases.contains(hyphenText) {
            separator = .hyphen
            resolvedPhraseText = hyphenText
        } else if explanationPrefix == openText {
            separator = .space
            resolvedPhraseText = openText
        } else {
            separator = .space
            resolvedPhraseText = openText
        }
    }

    func previewText(targetDisplay: String) -> String {
        firstWord + separator.symbol + targetDisplay
    }

    private static func normalized(_ word: String) -> String {
        word.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    private static func explanationPrefix(from explanation: String) -> String? {
        guard let colonIndex = explanation.firstIndex(of: ":") else { return nil }
        let prefix = explanation[..<colonIndex]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        return prefix.isEmpty ? nil : prefix
    }

    private static let knownJoinedPhrases: Set<String> = [
        "AIRPORT",
        "BASEBALL",
        "BASKETBALL",
        "BATHROOM",
        "BEDROOM",
        "BIRTHDAY",
        "BOYFRIEND",
        "CLASSROOM",
        "COPYRIGHT",
        "DOORSTEP",
        "FEEDBACK",
        "FIREFIGHTER",
        "HOMEWORK",
        "LIGHTHOUSE",
        "MARKETPLACE",
        "NOTEBOOK",
        "OUTDOOR",
        "PLAYGROUND",
        "RAINCOAT",
        "SIDEWALK",
        "SUNGLASSES",
        "TABLECLOTH",
        "UPSIDE",
        "WALKWAY",
        "WORKSHEET"
    ]

    private static let knownHyphenatedPhrases: Set<String> = []
}

// MARK: - History Item
struct HistoryItem: Codable, Identifiable {
    let id: String
    let date: String
    let score: Int
    let difficulty: Difficulty
    let chainLength: Int
    let phrases: [PhraseInfo]
}

// MARK: - Chain Data (from API)
struct ChainData {
    let chain: [String]
    let explanations: [String]
}

// MARK: - Game Status
enum GameStatus: Equatable {
    case start
    case difficultySelect
    case loading
    case playing
    case results
    case history
}

// MARK: - Feedback State
enum FeedbackState: Equatable {
    case none
    case correct
    case wrong
}

// MARK: - Constants
enum GameConstants {
    static let maxWords = 8
    static let poolSize = 3
}
