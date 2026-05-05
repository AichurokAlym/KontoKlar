import XCTest
@testable import KontoKlar

final class TransactionListViewModelTests: XCTestCase {
    @MainActor
    func test_isFilteredEmpty_trueWhenNoTransactionsInRange() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = cal.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12))!
        let repo = TestTransactionRepository(transactions: [
            TransactionItem(amount: 1, date: day1, type: .expense),
        ])
        let store = TransactionStore(repository: repo, autoLoad: false)
        store.reload()

        let sut = TransactionListViewModel(store: store)
        sut.dateRangeSelection = DateRangeSelection(
            range: .custom,
            customStartDate: cal.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
            customEndDate: cal.date(from: DateComponents(year: 2026, month: 2, day: 1))!
        )

        XCTAssertTrue(sut.isFilteredEmpty)
    }

    @MainActor
    func test_groupedByDate_groupsOnlyFilteredTransactions() {
        let cal = Calendar(identifier: .gregorian)
        let jan1 = cal.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12))!
        let jan2 = cal.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 12))!

        let repo = TestTransactionRepository(transactions: [
            TransactionItem(amount: 1, date: jan1, type: .expense),
            TransactionItem(amount: 2, date: jan2, type: .expense),
        ])
        let store = TransactionStore(repository: repo, autoLoad: false)
        store.reload()

        let sut = TransactionListViewModel(store: store)
        sut.dateRangeSelection = DateRangeSelection(range: .custom, customStartDate: jan2, customEndDate: jan2)

        let grouped = sut.groupedByDate()

        XCTAssertEqual(grouped.keys.count, 1)
        XCTAssertEqual(grouped[Calendar.current.startOfDay(for: jan2)]?.count, 1)
    }

    @MainActor
    func test_delete_deletesCorrectItemsFromSectionTransactions() {
        let a = TransactionItem(amount: 1, note: "A")
        let b = TransactionItem(amount: 2, note: "B")
        let repo = TestTransactionRepository(transactions: [a, b])
        let store = TransactionStore(repository: repo, autoLoad: false)
        store.reload()

        let sut = TransactionListViewModel(store: store)
        sut.delete(at: IndexSet(integer: 0), from: [a, b])

        XCTAssertEqual(repo.deleteManyCallCount, 1)
        XCTAssertFalse(store.transactions.contains(where: { $0.id == a.id }))
        XCTAssertTrue(store.transactions.contains(where: { $0.id == b.id }))
    }

    @MainActor
    func test_clearPersistenceError_clearsStoreFeedback() {
        let repo = TestTransactionRepository(transactions: [])
        repo.fetchError = TestError.any
        let store = TransactionStore(repository: repo, autoLoad: false)
        store.reload()

        let sut = TransactionListViewModel(store: store)
        sut.clearPersistenceError()

        XCTAssertNil(store.persistenceFeedback)
        XCTAssertNil(sut.persistenceFeedback)
    }
}
