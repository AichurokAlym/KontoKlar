import Foundation

struct DateRangeSelection: Equatable {
    var range: DashboardDateRange = .month
    var customStartDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    var customEndDate: Date = Date()

    func interval(now: Date = Date(), calendar: Calendar = .current) -> DateInterval? {
        switch range {
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: now)
        case .month:
            return calendar.dateInterval(of: .month, for: now)
        case .year:
            return calendar.dateInterval(of: .year, for: now)
        case .custom:
            let start = min(customStartDate, customEndDate)
            let end = max(customStartDate, customEndDate)
            let startDay = calendar.startOfDay(for: start)
            let endDay = calendar.startOfDay(for: end)
            let inclusiveEnd = calendar.date(byAdding: .day, value: 1, to: endDay) ?? end
            return DateInterval(start: startDay, end: inclusiveEnd)
        }
    }
}

