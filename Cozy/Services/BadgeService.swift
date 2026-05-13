import Foundation

struct BadgeDefinition: Identifiable, Equatable {
    static func == (lhs: BadgeDefinition, rhs: BadgeDefinition) -> Bool { lhs.id == rhs.id }

    let id: String
    let name: String
    let icon: String
    let description: String
    let check: (Profile, [Chore], Int) -> Bool
}

enum BadgeService {
    static let all: [BadgeDefinition] = [
        BadgeDefinition(
            id: "first-chore",
            name: "First chore!",
            icon: "⭐",
            description: "Complete your very first chore",
            check: { _, chores, _ in chores.filter(\.isDone).count >= 1 }
        ),
        BadgeDefinition(
            id: "streak-5",
            name: "5-day streak",
            icon: "🔥",
            description: "Keep a 5-day completion streak",
            check: { _, _, streak in streak >= 5 }
        ),
        BadgeDefinition(
            id: "streak-30",
            name: "30-day streak",
            icon: "🏆",
            description: "Complete chores 30 days in a row",
            check: { _, _, streak in streak >= 30 }
        ),
        BadgeDefinition(
            id: "kitchen-hero",
            name: "Kitchen hero",
            icon: "🍳",
            description: "Complete 10 kitchen chores",
            check: { _, chores, _ in chores.filter { $0.roomId == "kitchen" && $0.isDone }.count >= 10 }
        ),
        BadgeDefinition(
            id: "perfect-week",
            name: "Perfect week",
            icon: "🎯",
            description: "Complete every scheduled chore in a week",
            check: { _, chores, _ in
                let cal = Calendar.current
                guard let interval = cal.dateInterval(of: .weekOfYear, for: Date()) else { return false }
                let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
                let dates = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: interval.start) }
                let strings = Set(dates.map { fmt.string(from: $0) })
                let weekChores = chores.filter { strings.contains($0.scheduledDate) }
                return !weekChores.isEmpty && weekChores.allSatisfy(\.isDone)
            }
        ),
        BadgeDefinition(
            id: "all-rooms",
            name: "All rooms",
            icon: "🏠",
            description: "Complete a chore in every room",
            check: { _, chores, _ in
                let rooms = Set(["kitchen", "bedroom", "bathroom", "living", "outdoor"])
                let doneRooms = Set(chores.filter(\.isDone).map(\.roomId))
                return rooms.isSubset(of: doneRooms)
            }
        ),
        BadgeDefinition(
            id: "100-chores",
            name: "100 chores",
            icon: "🌟",
            description: "Complete 100 chores total",
            check: { _, chores, _ in chores.filter(\.isDone).count >= 100 }
        ),
    ]

    static func evaluateNewlyEarned(profile: Profile, chores: [Chore], streak: Int) -> [BadgeDefinition] {
        let already = Set(profile.earnedBadgeIds ?? [])
        return all.filter { badge in
            !already.contains(badge.id) && badge.check(profile, chores, streak)
        }
    }
}
