import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var dragManager = DragDropManager()

    @State private var showAddChore = false
    @State private var showMonthView = false
    @State private var showConfetti = false
    @State private var toastMessage: String?
    @State private var weekOffset: Int = 0
    @State private var fabPressed = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CozyTheme.background.ignoresSafeArea()
            mainLayout
            if dragManager.isDragging { TrashDropZone().environmentObject(dragManager) }
            FloatingDragChip().environmentObject(dragManager)
            if showConfetti { ConfettiOverlay() }
            if let msg = toastMessage { toastBanner(msg) }
            fabButton
        }
        .sheet(isPresented: $showAddChore) {
            AddChoreView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showMonthView) {
            MonthView(isPresented: $showMonthView)
                .environmentObject(appState)
                .presentationDetents([.fraction(0.65)])
                .presentationDragIndicator(.visible)
        }
        .task { await appState.loadData() }
        .gesture(globalDragGesture)
    }

    // MARK: - FAB
    private var fabButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showAddChore = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color(hex: "#5C3D2E"))
                        .clipShape(Circle())
                        .shadow(color: Color(red: 92/255, green: 61/255, blue: 46/255).opacity(0.3),
                                radius: 16, x: 0, y: 4)
                        .scaleEffect(fabPressed ? 0.92 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: fabPressed)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in fabPressed = true }
                        .onEnded { _ in fabPressed = false }
                )
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .safeAreaPadding(.bottom)
            }
        }
    }

    // MARK: - Main Layout
    private var mainLayout: some View {
        VStack(spacing: 0) {
            headerBar
            weekStripSection
            Divider().opacity(0.2)
            ScrollView(showsIndicators: false) {
                DashboardView(
                    onChoreComplete: fireConfetti,
                    onAddChore: { showAddChore = true },
                    onCalendarTap: { showMonthView = true }
                )
                .environmentObject(appState)
                .environmentObject(dragManager)
            }
        }
    }

    private var weekStripSection: some View {
        WeekStripView(weekOffset: $weekOffset)
            .environmentObject(appState)
            .environmentObject(dragManager)
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cozy Home")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(CozyTheme.primary)
                Text(greetingLine)
                    .font(.system(size: 13))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
            Button { showMonthView.toggle() } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CozyTheme.primary)
                    .frame(width: 36, height: 36)
                    .background(CozyTheme.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(CozyTheme.border, lineWidth: 1))
            }
            Menu {
                Button("Sign Out", role: .destructive) {
                    Task { try? await authManager.signOut() }
                }
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(CozyTheme.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    // MARK: - Global Drag Gesture (tracks position + handles drop)
    private var globalDragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                if dragManager.isDragging {
                    dragManager.updateLocation(value.location)
                }
            }
            .onEnded { _ in
                guard dragManager.isDragging else { return }
                let result = dragManager.commitDrop(appState: appState)
                handleDropResult(result)
            }
    }

    private func handleDropResult(_ result: DropResult) {
        switch result {
        case .rescheduled(let chore, let date):
            Task {
                await appState.rescheduleChore(chore, to: date)
                showToast("Moved to \(shortDate(date)) 📅")
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)
            }
        case .trash(let chore):
            Task {
                await appState.deleteChore(chore)
                showToast("Chore removed 🗑️")
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.warning)
            }
        case .cancelled:
            break
        }
    }

    // MARK: - Toast & Confetti
    private func fireConfetti() {
        showConfetti = true
        showToast("Nice work! 🎉")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showConfetti = false }
        }
    }

    private func showToast(_ message: String) {
        withAnimation(.spring()) { toastMessage = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { toastMessage = nil }
        }
    }

    private func toastBanner(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(CozyTheme.primary.opacity(0.92))
                .cornerRadius(25)
                .shadow(color: CozyTheme.primary.opacity(0.2), radius: 8, y: 4)
                .padding(.bottom, dragManager.isDragging ? 90 : 30)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Helpers
    private var greetingLine: String {
        let name = appState.profile?.displayName ?? "Friend"
        return "Hey \(name)! 👋"
    }

    private func shortDate(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "EEE, MMM d"
        return fmt.string(from: date)
    }
}
