import SwiftUI

struct ScheduleReadyView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var appState: AppState

    @State private var heroVisible   = false
    @State private var titleVisible  = false
    @State private var statsVisible  = false
    @State private var weekVisible   = false
    @State private var buttonVisible = false
    @State private var showConfetti  = false

    private var userName: String {
        onboardingVM.userName.isEmpty ? "friend" : onboardingVM.userName
    }
    private var choreCount: Int { onboardingVM.generatedSchedule.count }
    private var roomCount: Int  { onboardingVM.selectedRooms.count }

    private var daysWithChores: Set<Int> {
        Set(onboardingVM.generatedSchedule.map(\.dayIndex))
    }
    private let dayLabels = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    // Vibrant dot colors cycling across the week
    private let dotColors: [Color] = [
        Color(hex: "4ECDC4"), Color(hex: "FF6B6B"),
        Color(hex: "FFE66D"), Color(hex: "A8E6CF"),
        Color(hex: "C3A6FF"), Color(hex: "FF8FA3"),
        Color(hex: "4ECDC4")
    ]

    var body: some View {
        ZStack {
            background
            if showConfetti {
                ConfettiOverlay(event: .badgeUnlock)
                    .ignoresSafeArea()
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    contentCard
                }
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .onAppear { animateIn() }
    }

    // MARK: - Background gradient
    private var background: some View {
        LinearGradient(
            colors: [Color(hex: "4ECDC4"), Color(hex: "FF6B6B")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 16) {
            Text("🏠")
                .font(.system(size: 80))
                .scaleEffect(heroVisible ? 1.0 : 0.4)
                .opacity(heroVisible ? 1 : 0)
                .padding(.top, 72)

            VStack(spacing: 6) {
                Text("You're all set,")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                Text(userName + "! ✨")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .opacity(titleVisible ? 1 : 0)
            .offset(y: titleVisible ? 0 : 20)

            statsRow
                .opacity(statsVisible ? 1 : 0)
                .offset(y: statsVisible ? 0 : 14)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statChip(icon: "checkmark.circle.fill", value: "\(choreCount)", label: "chores")
            statChip(icon: "house.fill", value: "\(roomCount)", label: "rooms")
            statChip(icon: "calendar", value: "7", label: "days")
        }
    }

    private func statChip(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Content Card
    private var contentCard: some View {
        VStack(spacing: 24) {
            weekDotsSection
            letsGoButton
        }
        .padding(24)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -4)
        .padding(.horizontal, 0)
        .opacity(weekVisible ? 1 : 0)
        .offset(y: weekVisible ? 0 : 24)
    }

    private var weekDotsSection: some View {
        VStack(spacing: 14) {
            Text("Your week at a glance")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "666666"))
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { idx in
                    let hasChore = daysWithChores.contains(idx)
                    VStack(spacing: 8) {
                        Text(dayLabels[idx])
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "999999"))
                        Circle()
                            .fill(hasChore ? dotColors[idx] : Color(hex: "E8E8E8"))
                            .frame(width: hasChore ? 28 : 14, height: hasChore ? 28 : 14)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: hasChore)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(16)
        .background(Color(hex: "F8F8F8"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var letsGoButton: some View {
        Button {
            if var p = appState.profile {
                p.onboardingCompleted = true
                appState.profile = p
                LocalStore.shared.saveProfile(p)
            }
        } label: {
            HStack(spacing: 10) {
                Text("Let's go!")
                    .font(.system(size: 18, weight: .bold))
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                LinearGradient(
                    colors: [Color(hex: "4ECDC4"), Color(hex: "FF6B6B")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: "FF6B6B").opacity(0.35), radius: 12, x: 0, y: 6)
        }
        .opacity(buttonVisible ? 1 : 0)
        .scaleEffect(buttonVisible ? 1 : 0.92)
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1)) { heroVisible   = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.35))                      { titleVisible  = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.55))                      { statsVisible  = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.75)) { weekVisible   = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.0))  { buttonVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { showConfetti = true }
    }
}
