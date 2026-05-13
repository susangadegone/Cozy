import Foundation

// MARK: - Profile
struct Profile: Codable, Identifiable {
    var id: UUID
    var displayName: String
    var avatarEmoji: String
    var homeName: String
    var rooms: [String]
    var notificationPreference: String
    var onboardingCompleted: Bool
    var createdAt: String
    var joinedAt: String?
    var preferences: UserPreferences?
    var earnedBadgeIds: [String]?
    
    init(id: UUID = UUID(),
         displayName: String = "",
         avatarEmoji: String = "👤",
         homeName: String = "",
         rooms: [String] = [],
         notificationPreference: String = "Off",
         onboardingCompleted: Bool = false,
         createdAt: String = ISO8601DateFormatter().string(from: Date()),
         joinedAt: String? = nil,
         preferences: UserPreferences? = nil,
         earnedBadgeIds: [String]? = nil) {
        self.id = id
        self.displayName = displayName
        self.avatarEmoji = avatarEmoji
        self.homeName = homeName
        self.rooms = rooms
        self.notificationPreference = notificationPreference
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
        self.joinedAt = joinedAt ?? createdAt
        self.preferences = preferences
        self.earnedBadgeIds = earnedBadgeIds
    }
}

// MARK: - Chore
struct Chore: Identifiable, Codable, Equatable {
    var id: UUID
    var userId: UUID
    var roomId: String
    var choreName: String
    var dayOfWeek: String
    var isDone: Bool
    var scheduledDate: String
    var completedAt: String?
    
    init(id: UUID = UUID(),
         userId: UUID,
         roomId: String,
         choreName: String,
         dayOfWeek: String,
         isDone: Bool = false,
         scheduledDate: String,
         completedAt: String? = nil) {
        self.id = id
        self.userId = userId
        self.roomId = roomId
        self.choreName = choreName
        self.dayOfWeek = dayOfWeek
        self.isDone = isDone
        self.scheduledDate = scheduledDate
        self.completedAt = completedAt
    }
}

// MARK: - Room
struct Room: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let color: String
    
    static let defaults: [Room] = [
        Room(id: "kitchen", name: "Kitchen", icon: "fork.knife", color: "FFF3DC"),
        Room(id: "bedroom", name: "Bedroom", icon: "bed.double", color: "F0E8E0"),
        Room(id: "bathroom", name: "Bathroom", icon: "shower", color: "E4EEF2"),
        Room(id: "living", name: "Living Room", icon: "sofa", color: "FDF3E3"),
        Room(id: "outdoor", name: "Outdoor", icon: "leaf", color: "E5EDDF"),
        Room(id: "laundry", name: "Laundry", icon: "washer", color: "F5F5DC")
    ]
}

// MARK: - UserPreferences
struct UserPreferences: Codable {
    var theme: String = "light"
    var notificationsEnabled: Bool = false
    var soundEnabled: Bool = true
    var hapticEnabled: Bool = true
    var confettiEnabled: Bool = true
    
    // Settings view preferences
    var dailyReminders: Bool = false
    var overdueAlerts: Bool = false
    var streakReminders: Bool = false
    var weekStartsOnSunday: Bool = true
}

// MARK: - HouseholdMember
struct HouseholdMember: Identifiable, Codable {
    var id: UUID
    var name: String
    var avatarEmoji: String
    var role: String
    
    init(id: UUID = UUID(),
         name: String,
         avatarEmoji: String = "👤",
         role: String = "Member") {
        self.id = id
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.role = role
    }
}

// MARK: - ActivityLog
struct ActivityLog: Identifiable, Codable {
    enum ActivityType: String, Codable {
        case choreDone
        case choreAdded
        case streakMilestone
        case badgeEarned
    }
    
    var id: UUID
    var type: ActivityType
    var text: String
    var timestamp: Date
    var userId: String
}


