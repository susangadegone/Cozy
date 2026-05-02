import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var step: Int = 0

    // Step 1 — name
    @State private var name: String = ""
    // Step 2 — home name
    @State private var homeName: String = ""
    // Step 3 — rooms
    @State private var selectedRooms: Set<String> = ["kitchen", "bedroom", "bathroom", "living_room"]
    // Step 4 — notifications
    @State private var notificationPref: String = "in_app"

    @State private var isSaving = false

    private let totalSteps = 4

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            if step < totalSteps {
                mainFlow
            } else {
                finaleView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: - Main Flow
    private var mainFlow: some View {
        VStack(spacing: 0) {
            progressBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) { stepContent }
                    .padding(.top, 12)
            }
            Spacer(minLength: 0)
            bottomBar
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: OnboardingStep1(name: $name)
        case 1: homeNameStep
        case 2: OnboardingStep4(selectedRooms: $selectedRooms)
        case 3: OnboardingStep5(selected: $notificationPref)
        default: EmptyView()
        }
    }

    // MARK: - Home Name Step
    private var homeNameStep: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("🏡")
                    .font(.system(size: 64))
                    .padding(.top, 8)
                Text("Name your home")
                    .font(.custom("Fraunces-Regular", size: 28))
                    .foregroundColor(CozyTheme.primary)
                Text("Give your place a name.\nThis appears on your home screen.")
                    .font(.custom("DMSans-Regular", size: 16))
                    .foregroundColor(CozyTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.bottom, 12)

            TextField("e.g. Cozy Home, The Nest…", text: $homeName)
                .font(.custom("DMSans-Regular", size: 18))
                .foregroundColor(CozyTheme.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(CozyTheme.card)
                .cornerRadius(CozyTheme.cornerRadius)
                .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(CozyTheme.border, lineWidth: 1))
                .autocorrectionDisabled()
                .submitLabel(.next)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 12) {
            HStack {
                if step > 0 {
                    Button(action: goBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.custom("DMSans-Regular", size: 15))
                        .foregroundColor(CozyTheme.mutedText)
                    }
                }
                Spacer()
                Text("Step \(step + 1) of \(totalSteps)")
                    .font(.custom("DMSans-Regular", size: 13))
                    .foregroundColor(CozyTheme.mutedText)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(CozyTheme.border).frame(height: 6)
                    let pct = CGFloat(step + 1) / CGFloat(totalSteps)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CozyTheme.accent)
                        .frame(width: geo.size.width * min(pct, 1.0), height: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: step)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(CozyTheme.border)
            HStack {
                Spacer()
                Button(action: handleNext) {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView().tint(.white).scaleEffect(0.85)
                        }
                        Text(step == totalSteps - 1 ? "Let's go" : "Continue")
                            .font(.custom("DMSans-SemiBold", size: 17))
                            .foregroundColor(.white)
                        if !isSaving {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 28)
                    .frame(height: 52)
                    .background(isNextEnabled ? CozyTheme.primary : CozyTheme.border)
                    .cornerRadius(CozyTheme.cornerRadius)
                }
                .disabled(!isNextEnabled || isSaving)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .padding(.bottom, 8)
        }
        .background(CozyTheme.background)
    }

    // MARK: - Logic
    private var isNextEnabled: Bool {
        switch step {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return !selectedRooms.isEmpty
        default: return true
        }
    }

    private func goBack() {
        step = max(0, step - 1)
    }

    private func handleNext() {
        if step < totalSteps - 1 {
            step += 1
        } else {
            saveAndFinish()
        }
    }

    private func saveAndFinish() {
        isSaving = true
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedHome = homeName.trimmingCharacters(in: .whitespaces)
        appState.completeOnboarding(
            name: trimmedName.isEmpty ? "You" : trimmedName,
            homeName: trimmedHome.isEmpty ? "My Home" : trimmedHome,
            rooms: Array(selectedRooms),
            notificationPref: notificationPref
        )
        isSaving = false
        step = totalSteps
    }

    // MARK: - Finale
    private var finaleView: some View {
        VStack(spacing: 0) {
            Spacer()
            OnboardingFinale(name: name)
            Spacer()
            Button(action: {
                NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
            }) {
                Text("Open Cozy")
                    .font(.custom("DMSans-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(CozyTheme.primary)
                    .cornerRadius(CozyTheme.cornerRadius)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}
