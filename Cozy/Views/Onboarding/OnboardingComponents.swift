import SwiftUI

// MARK: - Progress Bar
struct OnboardingProgressBar: View {
    let step: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(step) of \(total)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CozyTheme.border)
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CozyTheme.accent)
                        .frame(width: geo.size.width * (Double(step) / Double(total)), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Choice Card
struct OnboardingChoiceCard: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? CozyTheme.primary : CozyTheme.primary.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CozyTheme.accent)
                        .font(.system(size: 20))
                }
            }
            .padding(16)
            .background(isSelected ? Color(hex: "F5EDE4") : CozyTheme.card)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
