import Foundation

// MARK: - UserPreferences
struct UserPreferences: Codable {
    var dailyReminders: Bool = true
    var overdueAlerts: Bool = true
    var streakReminders: Bool = true
    var weekStartsOnSunday: Bool = true

    enum CodingKeys: String, CodingKey {
        case dailyReminders = "daily_reminders"
        case overdueAlerts = "overdue_alerts"
        case streakReminders = "streak_reminders"
        case weekStartsOnSunday = "week_starts_sunday"
    }
}

// MARK: - Profile
struct Profile: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var homeName: String
    var rooms: [String]
    var notificationPreference: String
    var onboardingCompleted: Bool
    var joinedAt: String?
    var earnedBadgeIds: [String]?
    var preferences: UserPreferences?
    var avatarEmoji: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case homeName = "home_name"
        case rooms
        case notificationPreference = "notification_preference"
        case onboardingCompleted = "onboarding_completed"
        case joinedAt = "joined_at"
        case earnedBadgeIds = "earned_badge_ids"
        case preferences
        case avatarEmoji = "avatar_emoji"
    }

    var initials: String {
        let parts = displayName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }
}

// MARK: - HouseholdMember (legacy stub — kept for compile compatibility)
struct HouseholdMember: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let emoji: String
}

// MARK: - Chore
struct Chore: Codable, Identifiable {
    var id: UUID
    var userId: UUID
    var roomId: String
    var choreName: String
    var dayOfWeek: String
    var isDone: Bool
    var scheduledDate: String
    var completedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case roomId = "room_id"
        case choreName = "chore_name"
        case dayOfWeek = "day_of_week"
        case isDone = "is_done"
        case scheduledDate = "scheduled_date"
        case completedAt = "completed_at"
    }
}

// MARK: - ActivityLog
struct ActivityLog: Identifiable {
    let id: UUID
    let type: ActivityType
    let text: String
    let timestamp: Date
    let userId: String

    enum ActivityType {
        case choreAdded, choreDone, streakMilestone, badgeEarned
    }
}

// MARK: - Room
struct Room: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let color: String

    static let defaults: [Room] = [
        Room(id: "kitchen", name: "Kitchen", icon: "fork.knife", color: "FFF3E0"),
        Room(id: "bedroom", name: "Bedroom", icon: "bed.double", color: "F3E5F5"),
        Room(id: "bathroom", name: "Bathroom", icon: "shower", color: "E0F2F1"),
        Room(id: "living_room", name: "Living Room", icon: "sofa", color: "FFFDE7"),
        Room(id: "outdoor", name: "Outdoor", icon: "leaf", color: "E8F5E9"),
        Room(id: "office", name: "Home Office", icon: "desktopcomputer", color: "E3F2FD"),
        Room(id: "other", name: "Other", icon: "archivebox", color: "F1F8E9"),
    ]

    static let defaultChores: [String: [String]] = [
        "kitchen": ["Wash dishes", "Wipe counters", "Take out trash", "Mop floor", "Clean fridge"],
        "bedroom": ["Make bed", "Vacuum", "Dust shelves", "Organize closet", "Change sheets"],
        "bathroom": ["Scrub toilet", "Clean mirror", "Wipe sink", "Mop floor", "Clean shower"],
        "living_room": ["Vacuum carpet", "Dust TV", "Fluff pillows", "Organize books", "Wipe windows"],
        "outdoor": ["Water plants", "Mow lawn", "Sweep porch", "Clean grill", "Pick up leaves"],
        "other": ["Sort mail", "Organize garage", "Clean laundry", "Take out recycling"],
    ]
}
