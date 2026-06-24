import SwiftUI

@main
struct WordLinkApp: App {
    @StateObject private var gameViewModel = GameViewModel()

    init() {
        // Warm the keyboard during launch so it's instantly present when the
        // first-launch tutorial opens onto the typing screen.
        DispatchQueue.main.async { KeyboardWarmer.prewarm() }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameViewModel)
                .preferredColorScheme(.light)
        }
    }
}
