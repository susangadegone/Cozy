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
            name: "First Chore!",
            icon: "⭐",
            description: "Complete your very first chore",
            check: { _, chores, _ in chores.filter(\.isDone).count >= 1 }
        ),
        BadgeDefinition(
            id: "streak-3",
            name: "3-Day Streak",
            icon: "🔥",
            description: "Keep a 3-day completion streak",
            check: { _, _, streak in streak >= 3 }
        ),
        BadgeDefinition(
            id: "streak-7",
            name: "Week Warrior",
            icon: "💪",
            description: "Complete all chores 7 days in a row",
            check: { _, _, streak in streak >= 7 }
        ),
        BadgeDefinition(
            id: "kitchen-hero",
            name: "Kitchen Hero",
            icon: "🍳",
            description: "Complete 10 kitchen chores",
            check: { _, chores, _ in chores.filter { $0.roomId == "kitchen" && $0.isDone }.count >= 10 }
        ),
        BadgeDefinition(
            id: "clean-sweep",
            name: "Clean Sweep",
            icon: "🧹",
            description: "Complete 25 chores total",
            check: { _, chores, _ in chores.filter(\.isDone).count >= 25 }
        ),
        BadgeDefinition(
            id: "team-player",
            name: "Team Player",
            icon: "🤝",
            description: "Have 2+ household members",
            check: { profile, _, _ in profile.members.count >= 2 }
        ),
        BadgeDefinition(
            id: "bathroom-boss",
            name: "Bathroom Boss",
            icon: "🚿",
            description: "Complete 5 bathroom chores",
            check: { _, chores, _ in chores.filter { $0.roomId == "bathroom" && $0.isDone }.count >= 5 }
        ),
        BadgeDefinition(
            id: "outdoor-lover",
            name: "Outdoor Lover",
            icon: "🌿",
            description: "Complete 5 outdoor chores",
            check: { _, chores, _ in chores.filter { $0.roomId == "outdoor" && $0.isDone }.count >= 5 }
        ),
    ]

    static func evaluateNewlyEarned(profile: Profile, chores: [Chore], streak: Int) -> [BadgeDefinition] {
        let already = Set(profile.earnedBadgeIds ?? [])
        return all.filter { badge in
            !already.contains(badge.id) && badge.check(profile, chores, streak)
        }
    }
}
