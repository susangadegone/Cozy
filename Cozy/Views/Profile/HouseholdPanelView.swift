import SwiftUI

struct HouseholdPanelView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "house.fill")
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.accent)
            Text(appState.profile?.homeName ?? "My Home")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.primary)
            Spacer()
        }
        .padding(.vertical, 12)
    }
}
