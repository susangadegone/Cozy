import SwiftUI
import UIKit

// MARK: - Day Column Frame Preference
struct DayFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Drag Drop Manager
@MainActor
final class DragDropManager: ObservableObject {
    @Published var draggingChore: Chore?
    @Published var dragLocation: CGPoint = .zero
    @Published var isOverTrash: Bool = false
    @Published var targetDayIndex: Int? = nil
    @Published var isDragging: Bool = false

    var dayFrames: [Int: CGRect] = [:]
    var trashZoneRect: CGRect = .zero
    var weekDates: [Date] = []

    func startDrag(chore: Chore, at location: CGPoint) {
        draggingChore = chore
        dragLocation = location
        isDragging = true
        isOverTrash = false
        targetDayIndex = nil
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func updateLocation(_ location: CGPoint) {
        dragLocation = location
        isOverTrash = trashZoneRect.contains(location)
        targetDayIndex = nil
        for (idx, frame) in dayFrames {
            if frame.contains(location) {
                targetDayIndex = idx
                break
            }
        }
    }

    func commitDrop(appState: AppState) -> DropResult {
        defer { reset() }
        guard let chore = draggingChore else { return .cancelled }
        if isOverTrash { return .trash(chore) }
        if let idx = targetDayIndex, idx < weekDates.count {
            let targetDate = weekDates[idx]
            let cal = Calendar.current
            if !cal.isDate(targetDate, inSameDayAs: chore.scheduledDate.toDate() ?? Date()) {
                return .rescheduled(chore, targetDate)
            }
        }
        return .cancelled
    }

    func cancelDrag() { reset() }

    private func reset() {
        withAnimation(.spring(response: 0.3)) {
            draggingChore = nil
            isDragging = false
            isOverTrash = false
            targetDayIndex = nil
        }
    }
}

enum DropResult {
    case rescheduled(Chore, Date)
    case trash(Chore)
    case cancelled
}

extension String {
    func toDate() -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.date(from: self)
    }
}
