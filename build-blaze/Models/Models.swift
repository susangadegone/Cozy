import Foundation

// MARK: - Profile
struct Profile: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var householdType: String
    var members: [HouseholdMember]
    var rooms: [String]
    var notificationPreference: String
    var onboardingCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case householdType = "household_type"
        case members, rooms
        case notificationPreference = "notification_preference"
        case onboardingCompleted = "onboarding_completed"
    }
}

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
    var assignedTo: String
    var isDone: Bool
    var scheduledDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case roomId = "room_id"
        case choreName = "chore_name"
        case dayOfWeek = "day_of_week"
        case assignedTo = "assigned_to"
        case isDone = "is_done"
        case scheduledDate = "scheduled_date"
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
