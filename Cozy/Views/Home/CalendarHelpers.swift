import SwiftUI

// MARK: - Calendar Helpers
enum CalendarHelpers {
    static let dayAbbreviations = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

    static func weekDays(offset: Int) -> [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let sundayOffset = -(weekday - 1)
        guard let sunday = cal.date(byAdding: .day, value: sundayOffset + (offset * 7), to: today) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: sunday) }
    }

    static func dateString(_ date: Date) -> String {
        DateFormatters.yearMonthDay.string(from: date)
    }

    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    static func roomColor(for roomId: String) -> Color {
        switch roomId {
        case "kitchen":     return Color(hex: "FFF0D6")
        case "bedroom":     return Color(hex: "F5EDE6")
        case "bathroom":    return Color(hex: "E8F0F5")
        case "living_room": return Color(hex: "FFF5E6")
        case "outdoor":     return Color(hex: "E6F0E8")
        case "other":       return Color(hex: "EDE8F5")
        default:            return Color(hex: "F2EDE8")
        }
    }

    static func roomBorderColor(for roomId: String) -> Color {
        switch roomId {
        case "kitchen":     return Color(hex: "D4A574")
        case "bedroom":     return Color(hex: "B89A8A")
        case "bathroom":    return Color(hex: "7AADC0")
        case "living_room": return Color(hex: "C8A86B")
        case "outdoor":     return Color(hex: "7AAD8C")
        case "other":       return Color(hex: "9B8AB5")
        default:            return Color(hex: "C0B8AF")
        }
    }

    static func monthGrid(for date: Date) -> [Date?] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: date),
              let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: date))
        else { return [] }
        let firstWeekday = cal.component(.weekday, from: firstDay) - 1
        var grid: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            grid.append(cal.date(byAdding: .day, value: day - 1, to: firstDay))
        }
        while grid.count % 7 != 0 { grid.append(nil) }
        return grid
    }
}
