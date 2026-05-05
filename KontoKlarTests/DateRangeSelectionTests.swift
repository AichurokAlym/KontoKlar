import XCTest
@testable import KontoKlar

final class DateRangeSelectionTests: XCTestCase {
    private var calendarUTC: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }

    func test_interval_week_matchesCalendarWeekInterval() {
        let now = calendarUTC.date(from: DateComponents(year: 2026, month: 5, day: 6, hour: 12))!
        let sut = DateRangeSelection(range: .week, customStartDate: now, customEndDate: now)

        let interval = sut.interval(now: now, calendar: calendarUTC)
        let expected = calendarUTC.dateInterval(of: .weekOfYear, for: now)

        XCTAssertEqual(interval?.start, expected?.start)
        XCTAssertEqual(interval?.end, expected?.end)
    }

    func test_interval_month_matchesCalendarMonthInterval() {
        let now = calendarUTC.date(from: DateComponents(year: 2026, month: 5, day: 6, hour: 12))!
        let sut = DateRangeSelection(range: .month, customStartDate: now, customEndDate: now)

        let interval = sut.interval(now: now, calendar: calendarUTC)
        let expected = calendarUTC.dateInterval(of: .month, for: now)

        XCTAssertEqual(interval?.start, expected?.start)
        XCTAssertEqual(interval?.end, expected?.end)
    }

    func test_interval_year_matchesCalendarYearInterval() {
        let now = calendarUTC.date(from: DateComponents(year: 2026, month: 5, day: 6, hour: 12))!
        let sut = DateRangeSelection(range: .year, customStartDate: now, customEndDate: now)

        let interval = sut.interval(now: now, calendar: calendarUTC)
        let expected = calendarUTC.dateInterval(of: .year, for: now)

        XCTAssertEqual(interval?.start, expected?.start)
        XCTAssertEqual(interval?.end, expected?.end)
    }

    func test_interval_custom_usesMinMaxAndIncludesWholeEndDay() {
        // start > end on purpose (should be normalized)
        let start = calendarUTC.date(from: DateComponents(year: 2026, month: 5, day: 10, hour: 18))!
        let end = calendarUTC.date(from: DateComponents(year: 2026, month: 5, day: 8, hour: 9))!

        let sut = DateRangeSelection(range: .custom, customStartDate: start, customEndDate: end)
        let interval = sut.interval(now: start, calendar: calendarUTC)

        let expectedStartDay = calendarUTC.startOfDay(for: end) // min(start,end)
        let expectedEndDay = calendarUTC.startOfDay(for: start) // max(start,end)
        let expectedInclusiveEnd = calendarUTC.date(byAdding: .day, value: 1, to: expectedEndDay)!

        XCTAssertEqual(interval?.start, expectedStartDay)
        XCTAssertEqual(interval?.end, expectedInclusiveEnd)
    }

}
