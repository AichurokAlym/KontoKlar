import XCTest
@testable import KontoKlar

final class DashboardDateRangeTests: XCTestCase {
    func test_allCases_containsExpectedCases() {
        XCTAssertEqual(DashboardDateRange.allCases, [.week, .month, .year, .custom])
    }

    func test_id_isRawValue() {
        XCTAssertEqual(DashboardDateRange.week.id, "week")
        XCTAssertEqual(DashboardDateRange.month.id, "month")
        XCTAssertEqual(DashboardDateRange.year.id, "year")
        XCTAssertEqual(DashboardDateRange.custom.id, "custom")
    }

    func test_title_matchesLocalizationKeys() {
        // Keys are currently also the default fallback values (no explicit strings in Localizable).
        XCTAssertEqual(DashboardDateRange.week.title, "This week")
        XCTAssertEqual(DashboardDateRange.month.title, "This month")
        XCTAssertEqual(DashboardDateRange.year.title, "This year")
        XCTAssertEqual(DashboardDateRange.custom.title, "Custom")
    }

}
