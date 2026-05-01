import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var step: Int = 0

    // Step 1
    @State private var name: String = ""
    // Step 2
    @State private var householdType: String = "solo"
    // Step 3
    @State private var members: [HouseholdMember] = []
    // Step 4
    @State private var selectedRooms: Set<String> = ["kitchen", "bedroom", "bathroom", "living_room"]
    // Step 5
    @State private var notificationPref: String = "in_app"

    @State private var isSaving = false

    private var isSolo: Bool { householdType == "solo" }
    private var totalSteps: Int { isSolo ? 4 : 5 }

    // Logical steps: 0=name,1=household,2=members(skip if solo),3=rooms,4=notifications,5=finale
    private var visibleStep: Int {
        if isSolo && step >= 2 { return step + 1 }
        return step
    }

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            if step < 5 {
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
                VStack(spacing: 0) {
                    stepContent
                }
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
        case 1: OnboardingStep2(selected: $householdType)
        case 2: OnboardingStep3(members: $members)
        case 3: OnboardingStep4(selectedRooms: $selectedRooms)
        case 4: OnboardingStep5(selected: $notificationPref)
        default: EmptyView()
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
                Text("Step \(min(visibleStep + 1, totalSteps)) of \(totalSteps)")
                    .font(.custom("DMSans-Regular", size: 13))
                    .foregroundColor(CozyTheme.mutedText)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CozyTheme.border)
                        .frame(height: 6)
                    let pct = totalSteps > 0 ? CGFloat(visibleStep + 1) / CGFloat(totalSteps) : 0
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
                if canSkip {
                    Button("Skip") {
                        advance()
                    }
                    .font(.custom("DMSans-Regular", size: 16))
                    .foregroundColor(CozyTheme.mutedText)
                }
                Spacer()
                Button(action: handleNext) {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.85)
                        }
                        Text(nextLabel)
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
    private var canSkip: Bool { step == 2 }

    private var isNextEnabled: Bool {
        switch step {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return !householdType.isEmpty
        case 3: return !selectedRooms.isEmpty
        default: return true
        }
    }

    private var nextLabel: String {
        let isLast = (step == 4) || (isSolo && step == 3)
        return isLast ? "Let's go! 🏡" : "Continue"
    }

    private func goBack() {
        if isSolo && step == 3 {
            step = 1
        } else {
            step = max(0, step - 1)
        }
    }

    private func advance() {
        let lastStep = isSolo ? 3 : 4
        if step < lastStep {
            if isSolo && step == 1 {
                step = 3
            } else {
                step += 1
            }
        } else {
            step = 5 // finale
        }
    }

    private func handleNext() {
        let lastStep = isSolo ? 3 : 4
        if step >= lastStep {
            saveAndFinish()
        } else {
            advance()
        }
    }

    private func saveAndFinish() {
        isSaving = true
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let finalMembers = isSolo ? [] : members
        appState.completeOnboarding(
            name: trimmedName.isEmpty ? "You" : trimmedName,
            householdType: householdType,
            members: finalMembers,
            rooms: Array(selectedRooms),
            notificationPref: notificationPref
        )
        isSaving = false
        step = 5
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
                Text("Open My Home 🏡")
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
