import SwiftUI

// MARK: - InsightsView
struct InsightsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var roomBreakdown: [(room: Room, done: Int, total: Int)] {
        Room.defaults.compactMap { room in
            let roomChores = appState.chores.filter { $0.roomId == room.id }
            guard !roomChores.isEmpty else { return nil }
            return (room, roomChores.filter(\.isDone).count, roomChores.count)
        }.sorted { $0.total > $1.total }
    }

    private var weekdayBreakdown: [(day: String, count: Int)] {
        let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        let fullDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        return zip(days, fullDays).map { short, full in
            let count = appState.chores.filter { $0.dayOfWeek == full && $0.isDone }.count
            return (short, count)
        }
    }

    private var maxWeekday: Int { weekdayBreakdown.map(\.count).max() ?? 1 }
    private var maxRoom: Int { roomBreakdown.map(\.total).max() ?? 1 }
    private var completionRate: Double {
        let t = appState.chores.count
        guard t > 0 else { return 0 }
        return Double(appState.chores.filter(\.isDone).count) / Double(t)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FAF7F2").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        topStatsRow
                        completionRingCard
                        weekdayBarCard
                        roomBreakdownCard
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(CozyTheme.mutedText)
                }
            }
        }
    }

    // MARK: - Top Stats
    private var topStatsRow: some View {
        HStack(spacing: 10) {
            InsightStatCard(value: "\(appState.totalDone)", label: "All time done", icon: "checkmark.seal.fill", color: Color(hex: "4CAF82"))
            InsightStatCard(value: "\(appState.currentStreak)", label: "Current streak", icon: "flame.fill", color: CozyTheme.accent)
            InsightStatCard(value: "\(Int(completionRate * 100))%", label: "Completion rate", icon: "chart.pie.fill", color: Color(hex: "7B6EF6"))
        }
    }

    // MARK: - Completion Ring
    private var completionRingCard: some View {
        InsightCard(title: "Overall Completion", icon: "chart.pie.fill") {
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(CozyTheme.border, lineWidth: 14)
                        .frame(width: 110, height: 110)
                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(
                            AngularGradient(colors: [CozyTheme.accent, Color(hex: "E09A5A")],
                                            center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 110, height: 110)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: completionRate)
                    VStack(spacing: 2) {
                        Text("\(Int(completionRate * 100))%")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(CozyTheme.primary)
                        Text("done")
                            .font(.system(size: 11))
                            .foregroundColor(CozyTheme.mutedText)
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    legendDot(color: CozyTheme.accent, label: "Completed", value: appState.chores.filter(\.isDone).count)
                    legendDot(color: CozyTheme.border, label: "Remaining", value: appState.chores.filter { !$0.isDone }.count)
                    legendDot(color: Color(hex: "4CAF82"), label: "Total chores", value: appState.chores.count)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }

    private func legendDot(color: Color, label: String, value: Int) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(CozyTheme.mutedText)
            Spacer()
            Text("\(value)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
        }
    }

    // MARK: - Weekday Bar Chart
    private var weekdayBarCard: some View {
        InsightCard(title: "Busiest Days", icon: "calendar.badge.checkmark") {
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(weekdayBreakdown, id: \.day) { item in
                    let barH = maxWeekday > 0 ? CGFloat(item.count) / CGFloat(maxWeekday) * 80 : 0
                    VStack(spacing: 4) {
                        if item.count > 0 {
                            Text("\(item.count)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(CozyTheme.accent)
                        }
                        RoundedRectangle(cornerRadius: 5)
                            .fill(item.count > 0
                                  ? LinearGradient(colors: [CozyTheme.accent, Color(hex: "E09A5A")], startPoint: .top, endPoint: .bottom)
                                  : LinearGradient(colors: [CozyTheme.border], startPoint: .top, endPoint: .bottom))
                            .frame(height: max(8, barH))
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: barH)
                        Text(item.day)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(CozyTheme.mutedText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Room Breakdown
    private var roomBreakdownCard: some View {
        InsightCard(title: "By Room", icon: "house.fill") {
            VStack(spacing: 10) {
                if roomBreakdown.isEmpty {
                    Text("No chores added yet.")
                        .font(.system(size: 14))
                        .foregroundColor(CozyTheme.mutedText)
                        .padding(.vertical, 12)
                } else {
                    ForEach(roomBreakdown, id: \.room.id) { item in
                        roomRow(item)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func roomRow(_ item: (room: Room, done: Int, total: Int)) -> some View {
        let progress = item.total > 0 ? Double(item.done) / Double(item.total) : 0
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: item.room.color).opacity(0.5))
                    .frame(width: 32, height: 32)
                Image(systemName: item.room.icon)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(CozyTheme.accent)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.room.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CozyTheme.primary)
                    Spacer()
                    Text("\(item.done)/\(item.total)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(CozyTheme.mutedText)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(CozyTheme.border).frame(height: 5)
                        Capsule()
                            .fill(progress == 1 ? Color(hex: "4CAF82") : CozyTheme.accent)
                            .frame(width: max(0, geo.size.width * progress), height: 5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 5)
            }
        }
    }
}

// MARK: - Supporting Views

private struct InsightStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cornerRadius).stroke(CozyTheme.border, lineWidth: 1))
    }
}

struct InsightCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CozyTheme.accent)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            Divider().opacity(0.25)
            content()
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
        }
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius).stroke(CozyTheme.border, lineWidth: 1))
        .shadow(color: CozyTheme.primary.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
