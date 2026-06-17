import Foundation

enum AppConfig {
    enum Supabase {
        static let projectURL = URL(string: "https://azsrjwfieyldeertdlws.supabase.co")!
        static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF6c3Jqd2ZpZXlsZGVlcnRkbHdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNzM5NTgsImV4cCI6MjA5MTY0OTk1OH0.biWZJ8VnVj4PYB6EoQRVJtd0OMrFmzaxtJy3DfDvW54"

        static var functionsBaseURL: URL {
            projectURL
                .appendingPathComponent("functions")
                .appendingPathComponent("v1")
        }

        static func edgeFunctionURL(_ name: String) -> URL {
            functionsBaseURL.appendingPathComponent(name)
        }

        static func restURL(path: String) -> URL {
            projectURL
                .appendingPathComponent("rest")
                .appendingPathComponent("v1")
                .appendingPathComponent(path)
        }

        static func rpcURL(_ name: String) -> URL {
            projectURL
                .appendingPathComponent("rest")
                .appendingPathComponent("v1")
                .appendingPathComponent("rpc")
                .appendingPathComponent(name)
        }

        static func authURL(path: String) -> URL {
            projectURL
                .appendingPathComponent("auth")
                .appendingPathComponent("v1")
                .appendingPathComponent(path)
        }
    }
}
