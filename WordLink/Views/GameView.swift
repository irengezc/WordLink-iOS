import SwiftUI

struct GameView: View {
    @EnvironmentObject var vm: GameViewModel
    @FocusState private var isKeyboardFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var showIdleNudge = false
    @State private var idleTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
                .shadow(color: Color(.systemGray5), radius: 1, y: 1)
                .zIndex(1)

            // Progress Bar
            progressBar
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))

            // Tutorial coach banner (guided mode only)
            if let coach = vm.tutorialCoach {
                coachBanner(coach, isNudge: showIdleNudge)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .transition(.opacity)
            }

            // Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        // Completed phrases
                        ForEach(Array(vm.completedPhrases.enumerated()), id: \.element.id) { index, phrase in
                            PhraseFlashcardView(
                                info: phrase,
                                isLatest: index == vm.completedPhrases.count - 1
                            )
                            .id("phrase_\(index)")
                        }

                        // Active guess area
                        if !vm.isGameOver {
                            WordDisplayView(
                                firstWord: vm.currentWord,
                                targetWord: vm.targetWord,
                                revealedCount: vm.revealedLetters,
                                userInput: vm.userInput,
                                feedback: vm.feedback,
                                separator: vm.currentLinkSeparator,
                                highlightCursor: tilePulse
                            )
                            .id("active")
                            .padding(.top, vm.completedPhrases.isEmpty ? 0 : 8)
                        }

                        // Bottom padding for keyboard
                        Color.clear.frame(height: max(keyboardHeight + 100, 120))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .onChange(of: vm.currentIndex) { _ in
                    withAnimation {
                        proxy.scrollTo("active", anchor: .center)
                    }
                }
                .onChange(of: vm.completedPhrases.count) { count in
                    withAnimation {
                        if count > 0 {
                            proxy.scrollTo("phrase_\(count - 1)", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        // Hidden text field to capture keyboard input
        .overlay(
            TextField("", text: hiddenBinding)
                .focused($isKeyboardFocused)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .opacity(0)
                .frame(width: 1, height: 1)
                .allowsHitTesting(false)
        )
        .onAppear {
            setupKeyboardObserver()
            // Assert focus now and again on the next runloop. The first attempt
            // can be dropped while the page is still animating in; the re-assert
            // guarantees the keyboard is up by the time the screen settles.
            isKeyboardFocused = true
            DispatchQueue.main.async { isKeyboardFocused = true }
            scheduleIdleNudge()
        }
        .animation(.easeInOut(duration: 0.25), value: vm.tutorialCoach)
        .onChange(of: vm.currentIndex) { _ in scheduleIdleNudge() }
        .onChange(of: vm.userInput) { _ in scheduleIdleNudge() }
        .onChange(of: vm.revealedLetters) { _ in scheduleIdleNudge() }
        .onDisappear {
            idleTask?.cancel()
            NotificationCenter.default.removeObserver(self)
        }
    }

    // MARK: - Hidden input binding
    private var hiddenBinding: Binding<String> {
        Binding(
            get: { vm.userInput },
            set: { newVal in
                // Only process new characters
                let old = vm.userInput
                if newVal.count > old.count {
                    let newChar = newVal[newVal.index(newVal.startIndex, offsetBy: old.count)]
                    vm.appendCharacter(newChar)
                } else if newVal.count < old.count {
                    vm.deleteCharacter()
                }
            }
        )
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            HStack {
                Button {
                    HapticsService.shared.light()
                    vm.goHome()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(.systemGray))
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                Spacer(minLength: 0)
            }
            .frame(width: 94)

            Spacer()

            ZStack(alignment: .top) {
                Text("\(vm.score)")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(Color(.label))
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: vm.score)
                    .frame(minWidth: 76)

                if let change = vm.scoreChange {
                    FloatingScoreView(amount: change.amount)
                        .id(change.id)
                        .offset(y: -18)
                }
            }
            .frame(width: 112, height: 42)

            Spacer()

            let hintAvailable = vm.score >= vm.difficulty.hintCost
            Button {
                HapticsService.shared.light()
                vm.useHint()
                scheduleIdleNudge()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 13, weight: .black))
                    Text("Hint")
                        .font(.system(size: 13, weight: .black))
                }
                .foregroundColor(hintAvailable ? .white : Color(.systemGray3))
                .frame(width: 76, height: 36)
                .background(hintAvailable ? Color.amber : Color(.systemGray6))
                .cornerRadius(11)
                .shadow(color: hintAvailable ? Color.amber.opacity(0.25) : .clear, radius: 5, y: 2)
                .rippleHighlight(hintSpotlight, cornerRadius: 11)
                .overlay(alignment: .bottom) {
                    if hintSpotlight {
                        GuideArrow()
                            .offset(y: 36)
                    }
                }
            }
            .disabled(!hintAvailable)
        }
    }

    private var topBarHeight: CGFloat { 60 }

    /// Whether the hint button should be spotlighted to teach hints during the
    /// guided tutorial.
    private var hintSpotlight: Bool {
        // Never on the opening word — step 0 only highlights the word tile.
        // Hints are taught starting at step 1.
        vm.isTutorial && !vm.isGameOver && vm.hintsUsed == 0
            && vm.currentIndex >= 1 && (vm.currentIndex == 1 || showIdleNudge)
    }

    /// Whether the next tile to fill should pulse to show first-time players
    /// where to type. Only on the tutorial's opening word, before they answer.
    private var tilePulse: Bool {
        vm.isTutorial && !vm.isGameOver && vm.currentIndex == 0 && vm.feedback == .none
    }

    // MARK: - Tutorial coach banner
    private func coachBanner(_ text: String, isNudge: Bool) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.amber)
                .frame(width: 32, height: 32)
                .background(Color.amber.opacity(0.18))
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.amber.opacity(0.12))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.amber, lineWidth: isNudge ? 2 : 1)
        )
        .shadow(color: Color.amber.opacity(0.15), radius: 3, y: 1)
        .animation(.easeInOut(duration: 0.2), value: text)
        .animation(.easeInOut(duration: 0.2), value: isNudge)
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 5) {
            ForEach(0..<vm.totalWords, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(i < vm.currentIndex ? Color.indigo : (i == vm.currentIndex ? Color.indigo.opacity(0.3) : Color(.systemGray5)))
                    .frame(height: 6)
                    .animation(.spring(response: 0.3), value: vm.currentIndex)
            }
        }
    }

    // MARK: - Tutorial idle nudge
    private func scheduleIdleNudge() {
        idleTask?.cancel()
        showIdleNudge = false

        guard vm.isTutorial, !vm.isGameOver, vm.feedback == .none else { return }

        idleTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled, vm.isTutorial, !vm.isGameOver, vm.feedback == .none else { return }
            if vm.userInput.isEmpty || vm.currentIndex == 1 {
                showIdleNudge = true
            }
        }
    }

    // MARK: - Keyboard observer
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation { keyboardHeight = frame.height }
            }
        }
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation { keyboardHeight = 0 }
        }
    }
}

// MARK: - Floating "+N" / "-N" score badge
/// A playful badge that pops out near the score, drifts upward and fades.
/// Green "+N" when points are earned, coral "-N" when spent on a hint.
/// Drives its own animation on appear; the view model removes it after.
private struct FloatingScoreView: View {
    let amount: Int  // signed
    @State private var appeared = false
    @State private var leaving = false

    private var isGain: Bool { amount >= 0 }
    private var label: String { isGain ? "+\(amount)" : "\(amount)" }
    private var tint: Color {
        isGain
            ? Color(red: 0.18, green: 0.78, blue: 0.44)   // fresh green
            : Color(red: 1.0, green: 0.35, blue: 0.42)    // coral
    }

    var body: some View {
        Text(label)
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .frame(minWidth: 44)
            .background(Capsule().fill(tint))
            .shadow(color: tint.opacity(0.4), radius: 4, y: 2)
            .scaleEffect(appeared ? 1.0 : 0.3)
            .offset(y: leaving ? -28 : 0)
            .opacity(leaving ? 0 : (appeared ? 1 : 0))
            .onAppear {
                // Phase 1: springy pop-in. Phase 2: float up and fade out.
                withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                    appeared = true
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.35)) {
                    leaving = true
                }
            }
            .allowsHitTesting(false)
    }
}

// MARK: - Color extension for amber
extension Color {
    static let amber = Color(red: 0.9, green: 0.65, blue: 0.1)
}
