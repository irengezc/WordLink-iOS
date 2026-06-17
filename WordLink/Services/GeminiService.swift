import Foundation

// MARK: - AI Service (via Supabase Edge Function)
final class GeminiService {

    private static let fallbackData = ChainData(
        chain: ["HIGH", "SCHOOL", "BUS", "STOP", "SIGN", "LANGUAGE", "BARRIER", "REEF", "KNOT"],
        explanations: [
            "HIGH SCHOOL: A secondary school for students aged roughly 14–18.",
            "SCHOOL BUS: A vehicle that transports students to and from school.",
            "BUS STOP: A designated place where passengers board or exit a bus.",
            "STOP SIGN: A red octagonal road sign requiring vehicles to halt.",
            "SIGN LANGUAGE: A visual language using hand shapes and movements.",
            "LANGUAGE BARRIER: Difficulty communicating due to different languages.",
            "BARRIER REEF: A coral reef running parallel to a coastline.",
            "REEF KNOT: A simple, symmetrical knot used to bind two ropes together."
        ]
    )

    static func generateWordChain(difficulty: Difficulty) async -> ChainData {
        let url = AppConfig.Supabase.edgeFunctionURL("generate-chain")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AppConfig.Supabase.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(AppConfig.Supabase.anonKey, forHTTPHeaderField: "apikey")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["difficulty": difficulty.rawValue])

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return fallbackData
            }

            let json = try JSONDecoder().decode(EdgeFunctionResponse.self, from: data)
            guard json.chain.count >= 9, json.explanations.count >= 8 else {
                return fallbackData
            }
            return ChainData(chain: json.chain, explanations: json.explanations)
        } catch {
            print("generate-chain error: \(error)")
            return fallbackData
        }
    }

    private struct EdgeFunctionResponse: Decodable {
        let chain: [String]
        let explanations: [String]
    }
}
