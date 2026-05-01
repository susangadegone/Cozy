import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            mainTabs
        }
    }

    private var mainTabs: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            ChoresView()
                .tabItem { Label("Chores", systemImage: "checkmark.circle.fill") }
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(CozyTheme.accent)
    }
}
