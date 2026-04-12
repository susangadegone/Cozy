import SwiftUI

struct HouseholdOption: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let subtitle: String
}

struct OnboardingStep2: View {
    @Binding var selected: String

    let options: [HouseholdOption] = [
        HouseholdOption(id: "solo", emoji: "🧍", title: "Just me", subtitle: "Flying solo, keeping it tidy"),
        HouseholdOption(id: "partner", emoji: "👫", title: "Partner", subtitle: "Two hearts, one cozy home"),
        HouseholdOption(id: "family", emoji: "👨‍👩‍👧‍👦", title: "Family", subtitle: "A full house of helpers"),
        HouseholdOption(id: "roommates", emoji: "🏘️", title: "Roommates", subtitle: "Sharing space & chores"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            optionsGrid
            Spacer()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🏠")
                .font(.system(size: 64))
                .padding(.top, 8)
            Text("Your Household")
                .font(.custom("Fraunces-Regular", size: 28))
                .foregroundColor(CozyTheme.primary)
            Text("How would you describe your home?")
                .font(.custom("DMSans-Regular", size: 16))
                .foregroundColor(CozyTheme.mutedText)
        }
        .padding(.bottom, 32)
    }

    private var optionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(options) { option in
                HouseholdOptionCard(option: option, isSelected: selected == option.id) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = option.id
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

struct HouseholdOptionCard: View {
    let option: HouseholdOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Text(option.emoji)
                    .font(.system(size: 36))
                Text(option.title)
                    .font(.custom("Fraunces-Regular", size: 16))
                    .foregroundColor(CozyTheme.primary)
                Text(option.subtitle)
                    .font(.custom("DMSans-Regular", size: 12))
                    .foregroundColor(CozyTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? CozyTheme.accent.opacity(0.12) : CozyTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                    .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(CozyTheme.cornerRadius)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
