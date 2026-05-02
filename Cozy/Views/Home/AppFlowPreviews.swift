import SwiftUI

// MARK: - App Flow Previews for Testing
// Use Xcode's preview canvas to test individual screens

#if DEBUG

// MARK: - Onboarding Flow Preview
struct OnboardingFlowPreview: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        OnboardingView()
            .environmentObject(appState)
    }
}

#Preview("Onboarding") {
    OnboardingFlowPreview()
}

// MARK: - Home/Dashboard Preview
struct DashboardPreview: View {
    @StateObject private var appState = AppState()
    @StateObject private var dragManager = DragDropManager()
    
    var body: some View {
        HomeView()
            .environmentObject(appState)
            .onAppear {
                // Simulate completed onboarding
                var profile = appState.profile ?? LocalStore.shared.defaultProfile()
                profile.onboardingCompleted = true
                profile.displayName = "Sarah"
                profile.homeName = "Sarah's Place"
                profile.rooms = ["kitchen", "bedroom", "bathroom", "living_room"]
                appState.profile = profile
                
                // Add sample chores
                let sampleChores = createSampleChores(userId: profile.id)
                appState.chores = sampleChores
            }
    }
    
    private func createSampleChores(userId: UUID) -> [Chore] {
        let today = Calendar.current.startOfDay(for: Date())
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let dowFmt = DateFormatter()
        dowFmt.dateFormat = "EEEE"
        
        return [
            Chore(
                id: UUID(),
                userId: userId,
                roomId: "kitchen",
                choreName: "Wipe counters",
                dayOfWeek: dowFmt.string(from: today),
                isDone: false,
                scheduledDate: fmt.string(from: today),
                completedAt: nil
            ),
            Chore(
                id: UUID(),
                userId: userId,
                roomId: "bedroom",
                choreName: "Make bed",
                dayOfWeek: dowFmt.string(from: today),
                isDone: true,
                scheduledDate: fmt.string(from: today),
                completedAt: ISO8601DateFormatter().string(from: Date())
            ),
            Chore(
                id: UUID(),
                userId: userId,
                roomId: "bathroom",
                choreName: "Clean mirror",
                dayOfWeek: dowFmt.string(from: today),
                isDone: false,
                scheduledDate: fmt.string(from: today),
                completedAt: nil
            )
        ]
    }
}

#Preview("Dashboard with Data") {
    DashboardPreview()
}

// MARK: - Chores View Preview
struct ChoresViewPreview: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        ChoresView()
            .environmentObject(appState)
            .onAppear {
                // Set up profile
                var profile = appState.profile ?? LocalStore.shared.defaultProfile()
                profile.onboardingCompleted = true
                profile.rooms = ["kitchen", "bedroom", "bathroom", "living_room"]
                appState.profile = profile
            }
    }
}

#Preview("Chores Screen") {
    ChoresViewPreview()
}

// MARK: - Chore Library Preview
struct ChoreLibraryPreview: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        ChoreLibraryView()
            .environmentObject(appState)
            .onAppear {
                // Set up profile with rooms
                var profile = appState.profile ?? LocalStore.shared.defaultProfile()
                profile.onboardingCompleted = true
                profile.displayName = "Alex"
                profile.rooms = ["kitchen", "bedroom", "bathroom", "living_room"]
                appState.profile = profile
                
                // Add one sample chore so we can see Add/Added states
                let userId = profile.id
                let today = Date()
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
                let dowFmt = DateFormatter()
                dowFmt.dateFormat = "EEEE"
                
                appState.chores = [
                    Chore(
                        id: UUID(),
                        userId: userId,
                        roomId: "kitchen",
                        choreName: "Clear the sink",
                        dayOfWeek: dowFmt.string(from: today),
                        isDone: false,
                        scheduledDate: fmt.string(from: today),
                        completedAt: nil
                    )
                ]
            }
    }
}

#Preview("Chore Library") {
    ChoreLibraryPreview()
}

// MARK: - Profile View Preview
struct ProfileViewPreview: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        ProfileView()
            .environmentObject(appState)
            .onAppear {
                var profile = appState.profile ?? LocalStore.shared.defaultProfile()
                profile.onboardingCompleted = true
                profile.displayName = "Taylor"
                profile.earnedBadgeIds = ["first_week", "week_warrior"]
                appState.profile = profile
            }
    }
}

#Preview("Profile") {
    ProfileViewPreview()
}

#endif
