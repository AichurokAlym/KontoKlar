import XCTest
@testable import KontoKlar

final class TransactionStoreTests: XCTestCase {
    @MainActor
    func test_init_autoLoadFalse_doesNotFetch() {
        let repo = TestTransactionRepository(transactions: [TransactionItem(amount: 1)])
        _ = TransactionStore(repository: repo, autoLoad: false)

        XCTAssertEqual(repo.fetchCallCount, 0)
    }

    @MainActor
    func test_reload_success_updatesTransactionsAndClearsFeedback() {
        let cal = Calendar(identifier: .gregorian)
        let t1 = TransactionItem(amount: 1, date: cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!)
        let t2 = TransactionItem(amount: 2, date: cal.date(from: DateComponents(year: 2026, month: 1, day: 2))!)
        let repo = TestTransactionRepository(transactions: [t1, t2])
        let sut = TransactionStore(repository: repo, autoLoad: false)

        sut.reload()

        XCTAssertEqual(repo.fetchCallCount, 1)
        XCTAssertEqual(sut.transactions.first?.amount, 2) // date desc
        XCTAssertNil(sut.persistenceFeedback)
    }

    @MainActor
    func test_reload_failure_setsFeedback() {
        let repo = TestTransactionRepository(transactions: [])
        repo.fetchError = TestError.any
        let sut = TransactionStore(repository: repo, autoLoad: false)

        sut.reload()

        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.loadTransactions)
    }

    @MainActor
    func test_insert_success_returnsTrue_andReloads() {
        let repo = TestTransactionRepository(transactions: [])
        let sut = TransactionStore(repository: repo, autoLoad: false)
        sut.reload()

        let ok = sut.insert(TransactionItem(amount: 10))

        XCTAssertTrue(ok)
        XCTAssertEqual(repo.insertCallCount, 1)
        XCTAssertTrue(repo.fetchCallCount >= 2) // manual reload + reload after insert
        XCTAssertNil(sut.persistenceFeedback)
    }

    @MainActor
    func test_insert_failure_returnsFalse_setsFeedback() {
        let repo = TestTransactionRepository(transactions: [])
        repo.insertError = TestError.any
        let sut = TransactionStore(repository: repo, autoLoad: false)

        let ok = sut.insert(TransactionItem(amount: 10))

        XCTAssertFalse(ok)
        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.addTransaction)
    }

    @MainActor
    func test_delete_success_deletesAndReloads() {
        let a = TransactionItem(amount: 1)
        let b = TransactionItem(amount: 2)
        let repo = TestTransactionRepository(transactions: [a, b])
        let sut = TransactionStore(repository: repo, autoLoad: false)
        sut.reload()

        sut.delete([a])

        XCTAssertEqual(repo.deleteManyCallCount, 1)
        XCTAssertTrue(repo.fetchCallCount >= 2)
        XCTAssertEqual(sut.transactions.count, 1)
        XCTAssertEqual(sut.transactions.first?.id, b.id)
    }

    @MainActor
    func test_transactions_inInterval_filtersByDate() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = cal.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12))!
        let day2 = cal.date(from: DateComponents(year: 2026, month: 1, day: 2, hour: 12))!
        let t1 = TransactionItem(amount: 1, date: day1)
        let t2 = TransactionItem(amount: 2, date: day2)
        let repo = TestTransactionRepository(transactions: [t1, t2])
        let sut = TransactionStore(repository: repo, autoLoad: false)
        sut.reload()

        let interval = DateInterval(start: cal.startOfDay(for: day2), end: cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: day2))!)
        let filtered = sut.transactions(in: interval)

        XCTAssertEqual(filtered.map(\.id), [t2.id])
    }

    @MainActor
    func test_stats_usesDashboardStatsUseCase() {
        let repo = TestTransactionRepository(transactions: [
            TransactionItem(amount: 100, type: .income),
            TransactionItem(amount: 40, type: .expense),
        ])
        let sut = TransactionStore(repository: repo, autoLoad: false)
        sut.reload()

        let stats = sut.stats(in: nil)

        XCTAssertEqual(stats.totalIncomes, 100, accuracy: 0.000_001)
        XCTAssertEqual(stats.totalExpenses, 40, accuracy: 0.000_001)
        XCTAssertEqual(stats.balance, 60, accuracy: 0.000_001)
    }
}

