import Foundation

enum SpellingVariants {
    private static let explicitPairs: [String: [String]] = [
        "CATALOG": ["CATALOGUE"],
        "CENTER": ["CENTRE"],
        "CHECK": ["CHEQUE"],
        "COLOR": ["COLOUR"],
        "DEFENSE": ["DEFENCE"],
        "DIALOG": ["DIALOGUE"],
        "DONUT": ["DOUGHNUT"],
        "FAVOR": ["FAVOUR"],
        "GRAY": ["GREY"],
        "HONOR": ["HONOUR"],
        "JUDGMENT": ["JUDGEMENT"],
        "LABOR": ["LABOUR"],
        "LICENSE": ["LICENCE"],
        "METER": ["METRE"],
        "NEIGHBOR": ["NEIGHBOUR"],
        "PLOW": ["PLOUGH"],
        "THEATER": ["THEATRE"],
        "TIRE": ["TYRE"]
    ]

    private static let reversiblePairs: [(String, String)] = [
        ("IZATION", "ISATION"),
        ("IZE", "ISE")
    ]

    static func acceptedForms(for word: String) -> Set<String> {
        let canonical = word.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !canonical.isEmpty else { return [] }

        var forms: Set<String> = [canonical]

        for variant in explicitPairs[canonical] ?? [] {
            forms.insert(variant)
        }

        for (usSuffix, ukSuffix) in reversiblePairs {
            if canonical.hasSuffix(usSuffix) {
                forms.insert(String(canonical.dropLast(usSuffix.count)) + ukSuffix)
            }
            if canonical.hasSuffix(ukSuffix) {
                forms.insert(String(canonical.dropLast(ukSuffix.count)) + usSuffix)
            }
        }

        let seedForms = forms
        for form in seedForms {
            for variant in explicitPairs[form] ?? [] {
                forms.insert(variant)
            }
            for (base, variants) in explicitPairs where variants.contains(form) {
                forms.insert(base)
            }
        }

        return forms
    }
}
