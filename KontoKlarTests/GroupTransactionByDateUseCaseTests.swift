import XCTest
@testable import KontoKlar

final class GroupTransactionByDateUseCaseTests: XCTestCase {
    private let sut = GroupTransactionsByDateUseCase()

    func test_group_whenEmpty_returnsEmptyDictionary() {
        XCTAssertTrue(sut.group([]).isEmpty)
    }

    func test_group_groupsTransactionsByStartOfDay_ignoringTime() {
        let cal = Calendar(identifier: .gregorian)
        let day = cal.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 0, minute: 0))!
        let dayLater = cal.date(byAdding: .hour, value: 15, to: day)!

        let t1 = makeTransaction(date: day)
        let t2 = makeTransaction(date: dayLater)

        let grouped = sut.group([t1, t2])

        XCTAssertEqual(grouped.keys.count, 1)
        let key = grouped.keys.first!
        XCTAssertEqual(key, Calendar.current.startOfDay(for: day))
        XCTAssertEqual(grouped[key]?.count, 2)
    }

    func test_group_separatesDifferentDays() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = cal.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 8))!
        let day2 = cal.date(from: DateComponents(year: 2026, month: 3, day: 11, hour: 9))!

        let grouped = sut.group([makeTransaction(date: day1), makeTransaction(date: day2)])

        XCTAssertEqual(grouped.keys.count, 2)
        XCTAssertEqual(grouped[Calendar.current.startOfDay(for: day1)]?.count, 1)
        XCTAssertEqual(grouped[Calendar.current.startOfDay(for: day2)]?.count, 1)
    }

    func test_group_preservesAllTransactions() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = cal.date(from: DateComponents(year: 2026, month: 4, day: 1, hour: 8))!
        let day1Later = cal.date(byAdding: .hour, value: 2, to: day1)!
        let day2 = cal.date(from: DateComponents(year: 2026, month: 4, day: 2, hour: 8))!

        let tx = [
            makeTransaction(date: day1),
            makeTransaction(date: day1Later),
            makeTransaction(date: day2),
        ]

        let grouped = sut.group(tx)
        let total = grouped.values.reduce(0) { $0 + $1.count }

        XCTAssertEqual(total, tx.count)
    }

    private func makeTransaction(date: Date) -> TransactionItem {
        TransactionItem(amount: 1, note: "n", date: date, type: .expense, category: nil)
    }

}
