import SwiftUI

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let step: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(step) of \(total)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                Spacer()
                Text("\(Int((Double(step) / Double(total)) * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(CozyTheme.accent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CozyTheme.border)
                        .frame(height: 5)
                    Capsule()
                        .fill(CozyTheme.accent)
                        .frame(width: geo.size.width * (Double(step) / Double(total)), height: 5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)
                }
            }
            .frame(height: 5)
        }
    }
}

// MARK: - Choice Card (list style)

struct OnboardingChoiceCard: View {
    let label: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? CozyTheme.accent : CozyTheme.mutedText)
                        .frame(width: 26)
                }
                Text(label)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(CozyTheme.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                ZStack {
                    Circle()
                        .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(CozyTheme.accent)
                            .frame(width: 13, height: 13)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(isSelected ? CozyTheme.accent.opacity(0.07) : CozyTheme.card)
            .cornerRadius(CozyTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                    .stroke(isSelected ? CozyTheme.accent : CozyTheme.border,
                            lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Onboarding Next Button

struct OnboardingNextButton: View {
    let label: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    init(label: String = "Next", isEnabled: Bool, isLoading: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: CozyTheme.pillRadius)
                    .fill(isEnabled ? CozyTheme.accent : CozyTheme.border)
                    .frame(height: 54)
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(label)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isEnabled ? .white : CozyTheme.mutedText)
                }
            }
        }
        .disabled(!isEnabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Onboarding Shell (shared layout)

struct OnboardingShell<Content: View>: View {
    let step: Int
    let total: Int
    let onBack: (() -> Void)?
    @ViewBuilder let content: Content

    init(step: Int, total: Int, onBack: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.step = step
        self.total = total
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                if let onBack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(CozyTheme.accent)
                    }
                    .padding(.bottom, 20)
                }
                OnboardingProgressBar(step: step, total: total)
                    .padding(.bottom, 28)
                content
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 44)
        }
        .navigationBarHidden(true)
    }
}
