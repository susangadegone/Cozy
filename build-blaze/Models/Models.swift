import Foundation

// MARK: - UserPreferences
struct UserPreferences: Codable {
    var dailyReminders: Bool = true
    var overdueAlerts: Bool = true
    var partnerActivity: Bool = false
    var streakReminders: Bool = true
    var weekStartsOnSunday: Bool = true

    enum CodingKeys: String, CodingKey {
        case dailyReminders = "daily_reminders"
        case overdueAlerts = "overdue_alerts"
        case partnerActivity = "partner_activity"
        case streakReminders = "streak_reminders"
        case weekStartsOnSunday = "week_starts_sunday"
    }
}

// MARK: - Profile
struct Profile: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var householdType: String
    var members: [HouseholdMember]
    var rooms: [String]
    var notificationPreference: String
    var onboardingCompleted: Bool
    var role: String?
    var joinedAt: String?
    var earnedBadgeIds: [String]?
    var preferences: UserPreferences?
    var inviteCode: String?
    var avatarEmoji: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case householdType = "household_type"
        case members, rooms
        case notificationPreference = "notification_preference"
        case onboardingCompleted = "onboarding_completed"
        case role
        case joinedAt = "joined_at"
        case earnedBadgeIds = "earned_badge_ids"
        case preferences
        case inviteCode = "invite_code"
        case avatarEmoji = "avatar_emoji"
    }

    var isAdmin: Bool { role == "admin" || role == nil }

    var initials: String {
        let parts = displayName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }
}

// MARK: - HouseholdMember
struct HouseholdMember: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let emoji: String
    var role: String?
}

// MARK: - Chore
struct Chore: Codable, Identifiable {
    var id: UUID
    var userId: UUID
    var roomId: String
    var choreName: String
    var dayOfWeek: String
    var assignedTo: String
    var isDone: Bool
    var scheduledDate: String
    var completedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case roomId = "room_id"
        case choreName = "chore_name"
        case dayOfWeek = "day_of_week"
        case assignedTo = "assigned_to"
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
        Room(id: "kitchen", name: "Kitchen", icon: "🍳", color: "FFF0D6"),
        Room(id: "bedroom", name: "Bedroom", icon: "🛏️", color: "F5EDE6"),
        Room(id: "bathroom", name: "Bathroom", icon: "🚿", color: "FDEEF4"),
        Room(id: "living_room", name: "Living Room", icon: "🛋️", color: "FFF5E6"),
        Room(id: "outdoor", name: "Outdoor", icon: "🌿", color: "E8F5E9"),
        Room(id: "other", name: "Other", icon: "📦", color: "F0EBF5"),
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
