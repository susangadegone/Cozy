import SwiftUI

enum CleanlinessType: String, CaseIterable, Codable {
    case chaosDweller   = "Chaos Dweller"
    case functionalMess = "Functional Mess"
    case mostlyTidy     = "Mostly Tidy"
    case calmKeeper     = "Calm Keeper"

    var icon: String {
        switch self {
        case .chaosDweller:   return "🌪️"
        case .functionalMess: return "😅"
        case .mostlyTidy:     return "🙂"
        case .calmKeeper:     return "✨"
        }
    }

    var description: String {
        switch self {
        case .chaosDweller:   return "Things pile up and it feels overwhelming"
        case .functionalMess: return "Mostly okay, certain spots get bad"
        case .mostlyTidy:     return "Generally clean, just inconsistent"
        case .calmKeeper:     return "A place for everything, low stress"
        }
    }

    var dailyChoreCap: Int {
        switch self {
        case .chaosDweller:   return 2
        case .functionalMess: return 3
        case .mostlyTidy:     return 4
        case .calmKeeper:     return 6
        }
    }

    var accentColor: Color {
        switch self {
        case .chaosDweller:   return Color(hex: "D97B6C")
        case .functionalMess: return Color(hex: "E0A850")
        case .mostlyTidy:     return Color(hex: "7BA89E")
        case .calmKeeper:     return Color(hex: "5B8C5A")
        }
    }
}
