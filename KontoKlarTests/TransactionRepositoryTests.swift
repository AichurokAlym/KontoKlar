import XCTest
import SwiftData
@testable import KontoKlar

final class TransactionRepositoryTests: XCTestCase {
    @MainActor
    func test_swiftDataTransactionRepository_fetchAllSortedByDateDesc() throws {
        let container = try AppModelContainerFactory.makeInMemoryContainer()
        let context = ModelContext(container)
        let repo = SwiftDataTransactionRepository(context: context)

        let cal = Calendar(identifier: .gregorian)
        let older = cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let newer = cal.date(from: DateComponents(year: 2026, month: 1, day: 2))!

        try repo.insert(TransactionItem(amount: 1, note: "old", date: older, type: .expense))
        try repo.insert(TransactionItem(amount: 2, note: "new", date: newer, type: .expense))

        let result = try repo.fetchAllSortedByDateDesc()
        XCTAssertEqual(result.map { $0.note }, ["new", "old"])
    }

    @MainActor
    func test_swiftDataTransactionRepository_deleteManyRemovesTransactions() throws {
        let container = try AppModelContainerFactory.makeInMemoryContainer()
        let context = ModelContext(container)
        let repo = SwiftDataTransactionRepository(context: context)

        let t1 = TransactionItem(amount: 1, note: "a")
        let t2 = TransactionItem(amount: 2, note: "b")
        let t3 = TransactionItem(amount: 3, note: "c")
        try repo.insert(t1)
        try repo.insert(t2)
        try repo.insert(t3)

        var all = try repo.fetchAllSortedByDateDesc()
        XCTAssertEqual(all.count, 3)

        try repo.delete([t1, t3])
        all = try repo.fetchAllSortedByDateDesc()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.note, "b")
    }

    @MainActor
    func test_swiftDataTransactionRepository_fetchRecentNotes_returnsDistinctNotes_limited_andCategoryFiltered() throws {
        let container = try AppModelContainerFactory.makeInMemoryContainer()
        let context = ModelContext(container)
        let repo = SwiftDataTransactionRepository(context: context)

        let c1 = Category(name: "C1", type: .expense)
        let c2 = Category(name: "C2", type: .expense)
        context.insert(c1)
        context.insert(c2)

        let base = Date(timeIntervalSince1970: 10_000)
        try repo.insert(TransactionItem(amount: 1, note: "A", date: base.addingTimeInterval(3), type: .expense, category: c1))
        try repo.insert(TransactionItem(amount: 1, note: "A", date: base.addingTimeInterval(2), type: .expense, category: c1))
        try repo.insert(TransactionItem(amount: 1, note: "", date: base.addingTimeInterval(1), type: .expense, category: c1)) // ignored
        try repo.insert(TransactionItem(amount: 1, note: "B", date: base.addingTimeInterval(0), type: .expense, category: c1))
        try repo.insert(TransactionItem(amount: 1, note: "X", date: base.addingTimeInterval(4), type: .expense, category: c2)) // other category

        let notes = try repo.fetchRecentNotes(categoryId: c1.id, limit: 1)
        XCTAssertEqual(notes, ["A"])

        let notes2 = try repo.fetchRecentNotes(categoryId: c1.id, limit: 10)
        XCTAssertEqual(notes2, ["A", "B"])
    }

    @MainActor
    func test_swiftDataTransactionRepository_saveChanges_persistsEdits() throws {
        let container = try AppModelContainerFactory.makeInMemoryContainer()
        let context = ModelContext(container)
        let repo = SwiftDataTransactionRepository(context: context)

        let t = TransactionItem(amount: 1, note: "before")
        try repo.insert(t)

        let fetched = try repo.fetchAllSortedByDateDesc()
        XCTAssertEqual(fetched.count, 1)

        fetched[0].note = "after"
        try repo.saveChanges()

        let fetchedAgain = try repo.fetchAllSortedByDateDesc()
        XCTAssertEqual(fetchedAgain.first?.note, "after")
    }
}

