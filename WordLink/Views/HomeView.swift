import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: GameViewModel
    @ObservedObject private var sound = SoundManager.shared

    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.25, green: 0.15, blue: 0.55), Color(red: 0.15, green: 0.08, blue: 0.38)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative circles
            decorativeBackground

            VStack(spacing: 0) {
                Spacer()

                // Logo + Title
                titleSection
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)

                Spacer()

                // Buttons
                buttonSection
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
            }

            // Sound mute toggle (persists across launches via SoundManager).
            VStack {
                HStack {
                    Spacer()
                    muteButton
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
        }
    }

    private var muteButton: some View {
        Button {
            HapticsService.shared.light()
            sound.isMuted.toggle()
            // Play a tick so unmuting gives immediate, audible confirmation.
            if !sound.isMuted { sound.play("tap") }
        } label: {
            Image(systemName: sound.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
        .accessibilityLabel(sound.isMuted ? "Unmute sound" : "Mute sound")
    }

    private var decorativeBackground: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -200)
            Circle()
                .fill(Color.white.opacity(0.03))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 250)
        }
    }

    private var titleSection: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "link.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, Color(white: 0.8)], startPoint: .top, endPoint: .bottom)
                    )
            }
            .shadow(color: Color.black.opacity(0.3), radius: 20, y: 8)

            VStack(spacing: 8) {
                Text("WordLink")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.white)
                    .tracking(-1)

                Text("Chain words. Build phrases.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
                    .tracking(0.5)
            }
        }
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            // Play Button
            Button {
                HapticsService.shared.medium()
                vm.goToDifficultySelect()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Play")
                        .font(.system(size: 18, weight: .black))
                }
                .foregroundColor(.indigo)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.25), radius: 12, y: 4)
            }

            // Secondary buttons row
            HStack(spacing: 14) {
                secondaryButton(icon: "clock.arrow.circlepath", title: "History") {
                    HapticsService.shared.light()
                    vm.goToHistory()
                }
                secondaryButton(icon: "questionmark.circle", title: "How to Play") {
                    HapticsService.shared.light()
                    vm.goToTutorial()
                }
            }
        }
    }

    private func secondaryButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white.opacity(0.9))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white.opacity(0.15))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
