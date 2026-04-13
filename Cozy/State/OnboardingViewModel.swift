import Foundation

struct ScheduledChore: Identifiable {
    let id = UUID()
    let name: String
    let room: String
    let dayIndex: Int  // 0 = Sun, 6 = Sat
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var homeType: String = ""
    @Published var householdType: String = ""
    @Published var isSolo: Bool = false
    @Published var cleaningRhythm: String = ""
    @Published var selectedRooms: [String] = []
    @Published var reminderStyle: String = ""
    @Published var generatedSchedule: [ScheduledChore] = []

    // MARK: - Schedule Generation
    func generateSchedule() {
        let choreMap: [String: [String]] = [
            "Kitchen": ["Wash dishes", "Wipe counters", "Take out trash", "Mop floor"],
            "Bedroom": ["Make bed", "Vacuum", "Dust shelves", "Change sheets"],
            "Bathroom": ["Scrub toilet", "Clean mirror", "Wipe sink", "Clean shower"],
            "Living room": ["Vacuum carpet", "Dust TV", "Fluff pillows", "Wipe windows"],
            "Outdoor/yard": ["Water plants", "Sweep porch", "Pick up leaves", "Mow lawn"],
            "Home office": ["Organize desk", "Wipe monitor", "Vacuum floor", "Sort cables"],
            "Other": ["Sort mail", "Clean laundry", "Take out recycling"]
        ]

        var result: [ScheduledChore] = []
        let days = dayIndices(for: cleaningRhythm)

        for room in selectedRooms {
            let chores = choreMap[room] ?? ["Tidy up"]
            for (i, chore) in chores.prefix(2).enumerated() {
                let day = days[i % days.count]
                result.append(ScheduledChore(name: chore, room: room, dayIndex: day))
            }
        }

        generatedSchedule = result
    }

    private func dayIndices(for rhythm: String) -> [Int] {
        switch rhythm {
        case "A little every day":        return [1, 2, 3, 4, 5]
        case "Power session on weekends": return [6, 0]
        case "Mix of both":               return [1, 3, 6]
        default:                          return [1, 4]
        }
    }
}
