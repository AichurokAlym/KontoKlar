import Foundation

enum DashboardDateRange: String, CaseIterable, Identifiable {
    case week
    case month
    case year
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week: return NSLocalizedString("This week", comment: "This week")
        case .month: return NSLocalizedString("This month", comment: "This month")
        case .year: return NSLocalizedString("This year", comment: "This year")
        case .custom: return NSLocalizedString("Custom", comment: "Custom")
        }
    }
}

