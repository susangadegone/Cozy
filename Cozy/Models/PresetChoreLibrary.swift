import Foundation

// MARK: - PresetChore
struct PresetChore: Identifiable {
    let id: UUID = UUID()
    let name: String
    let roomId: String           // matches Room.id: "kitchen", "bedroom", "bathroom", "living_room"
    let isDefaultAdded: Bool     // true = auto-add on onboarding; false = browse-only
    let defaultSchedule: String = "weekly"
}

// MARK: - PresetChoreLibrary
enum PresetChoreLibrary {
    static let allChores: [PresetChore] = [
        // KITCHEN — 2 auto-add + 6 library
        PresetChore(name: "Clear the sink",              roomId: "kitchen",     isDefaultAdded: true),
        PresetChore(name: "Wipe counters",               roomId: "kitchen",     isDefaultAdded: true),
        PresetChore(name: "Take out trash",              roomId: "kitchen",     isDefaultAdded: false),
        PresetChore(name: "Wipe stovetop",               roomId: "kitchen",     isDefaultAdded: false),
        PresetChore(name: "Empty the dish rack",         roomId: "kitchen",     isDefaultAdded: false),
        PresetChore(name: "Wipe down the fridge handle", roomId: "kitchen",     isDefaultAdded: false),
        PresetChore(name: "Sweep the floor",             roomId: "kitchen",     isDefaultAdded: false),
        PresetChore(name: "Clear the table",             roomId: "kitchen",     isDefaultAdded: false),
        // BEDROOM — 2 auto-add + 5 library
        PresetChore(name: "Make bed",                    roomId: "bedroom",     isDefaultAdded: true),
        PresetChore(name: "Clear nightstand",            roomId: "bedroom",     isDefaultAdded: true),
        PresetChore(name: "Tidy the floor",              roomId: "bedroom",     isDefaultAdded: false),
        PresetChore(name: "Put clothes away",            roomId: "bedroom",     isDefaultAdded: false),
        PresetChore(name: "Wipe dresser top",            roomId: "bedroom",     isDefaultAdded: false),
        PresetChore(name: "Empty laundry basket",        roomId: "bedroom",     isDefaultAdded: false),
        PresetChore(name: "Open the windows",            roomId: "bedroom",     isDefaultAdded: false),
        // BATHROOM — 2 auto-add + 5 library
        PresetChore(name: "Wipe sink",                   roomId: "bathroom",    isDefaultAdded: true),
        PresetChore(name: "Clean mirror",                roomId: "bathroom",    isDefaultAdded: true),
        PresetChore(name: "Scrub toilet",                roomId: "bathroom",    isDefaultAdded: false),
        PresetChore(name: "Hang fresh towel",            roomId: "bathroom",    isDefaultAdded: false),
        PresetChore(name: "Empty trash",                 roomId: "bathroom",    isDefaultAdded: false),
        PresetChore(name: "Wipe shower glass",           roomId: "bathroom",    isDefaultAdded: false),
        PresetChore(name: "Sweep the floor",             roomId: "bathroom",    isDefaultAdded: false),
        // LIVING ROOM — 2 auto-add + 6 library
        PresetChore(name: "Quick floor pickup",          roomId: "living", isDefaultAdded: true),
        PresetChore(name: "Reset the couch",             roomId: "living", isDefaultAdded: true),
        PresetChore(name: "Wipe surfaces",               roomId: "living", isDefaultAdded: false),
        PresetChore(name: "Fold throw blankets",         roomId: "living", isDefaultAdded: false),
        PresetChore(name: "Clear coffee table",          roomId: "living", isDefaultAdded: false),
        PresetChore(name: "Wipe the TV",                 roomId: "living", isDefaultAdded: false),
        PresetChore(name: "Tidy entryway",               roomId: "living", isDefaultAdded: false),
        PresetChore(name: "Vacuum",                      roomId: "living", isDefaultAdded: false),
        // OUTDOOR — 2 auto-add + 4 library
        PresetChore(name: "Water plants",                roomId: "outdoor",     isDefaultAdded: true),
        PresetChore(name: "Sweep porch",                 roomId: "outdoor",     isDefaultAdded: true),
        PresetChore(name: "Check mailbox",               roomId: "outdoor",     isDefaultAdded: false),
        PresetChore(name: "Wipe outdoor furniture",      roomId: "outdoor",     isDefaultAdded: false),
        PresetChore(name: "Clear walkway",               roomId: "outdoor",     isDefaultAdded: false),
        PresetChore(name: "Take out recycling",          roomId: "outdoor",     isDefaultAdded: false),
        // LAUNDRY — 2 auto-add + 4 library
        PresetChore(name: "Sort laundry",                roomId: "laundry",     isDefaultAdded: true),
        PresetChore(name: "Fold clothes",                roomId: "laundry",     isDefaultAdded: true),
        PresetChore(name: "Clean lint trap",             roomId: "laundry",     isDefaultAdded: false),
        PresetChore(name: "Wipe machines",               roomId: "laundry",     isDefaultAdded: false),
        PresetChore(name: "Empty hamper",                roomId: "laundry",     isDefaultAdded: false),
        PresetChore(name: "Organize supplies",           roomId: "laundry",     isDefaultAdded: false),
    ]

    /// Auto-add presets for a specific room
    static func defaults(for roomId: String) -> [PresetChore] {
        allChores.filter { $0.roomId == roomId && $0.isDefaultAdded }
    }

    /// All presets for a specific room (for browse library)
    static func all(for roomId: String) -> [PresetChore] {
        allChores.filter { $0.roomId == roomId }
    }
}
