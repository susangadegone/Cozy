import SwiftUI

struct PartnerInviteView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 56))
                    .foregroundColor(CozyTheme.accent.opacity(0.7))
                VStack(spacing: 8) {
                    Text("Partner Invite")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(CozyTheme.primary)
                    Text("Shared households are coming soon.\nYou'll be able to invite a partner and split chores together.")
                        .font(.system(size: 15))
                        .foregroundColor(CozyTheme.mutedText)
                        .multilineTextAlignment(.center)
                }
                Button("Got it") { dismiss() }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(CozyTheme.accent)
                    .cornerRadius(CozyTheme.pillRadius)
                    .padding(.horizontal, 40)
            }
            .padding(32)
        }
    }
}
