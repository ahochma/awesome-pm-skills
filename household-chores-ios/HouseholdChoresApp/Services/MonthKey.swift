import Foundation

enum MonthKey {
    private static let utcCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return cal
    }()

    static func from(date: Date) -> String {
        let components = utcCalendar.dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else {
            return "1970-01"
        }
        return String(format: "%04d-%02d", year, month)
    }

    static func monthRange(for key: String) -> DateInterval? {
        let pieces = key.split(separator: "-")
        guard pieces.count == 2,
              let year = Int(pieces[0]),
              let month = Int(pieces[1]),
              let start = utcCalendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let end = utcCalendar.date(byAdding: DateComponents(month: 1), to: start) else {
            return nil
        }
        return DateInterval(start: start, end: end)
    }

    static func lastMonthKeys(count: Int, from date: Date = Date()) -> [String] {
        guard count > 0 else { return [] }
        let currentStart = monthRange(for: from(date: date))?.start ?? date
        return (0..<count).compactMap { offset in
            guard let monthDate = utcCalendar.date(byAdding: .month, value: -offset, to: currentStart) else {
                return nil
            }
            return from(date: monthDate)
        }
    }
}
