import Foundation
@testable import KontoKlar

typealias AppCategory = KontoKlar.Category
typealias AppTransactionItem = KontoKlar.TransactionItem

enum TestError: Error, Equatable {
    case any
}

final class TestCategoryRepository: CategoryRepository {
    var categories: [AppCategory]

    var fetchError: Error?
    var insertError: Error?
    var deleteError: Error?

    private(set) var fetchCallCount = 0
    private(set) var insertCallCount = 0
    private(set) var deleteCallCount = 0

    init(categories: [AppCategory] = []) {
        self.categories = categories
    }

    func fetchAllSortedByName() throws -> [AppCategory] {
        fetchCallCount += 1
        if let fetchError { throw fetchError }
        return categories.sorted(by: { $0.name < $1.name })
    }

    func insert(_ category: AppCategory) throws {
        insertCallCount += 1
        if let insertError { throw insertError }
        categories.append(category)
    }

    func delete(_ category: AppCategory) throws {
        deleteCallCount += 1
        if let deleteError { throw deleteError }
        categories.removeAll(where: { $0.id == category.id })
    }
}

final class TestTransactionRepository: TransactionRepository {
    var transactions: [AppTransactionItem]

    var fetchError: Error?
    var recentNotesError: Error?
    var insertError: Error?
    var deleteError: Error?
    var saveChangesError: Error?

    private(set) var fetchCallCount = 0
    private(set) var fetchRecentNotesCallCount = 0
    private(set) var insertCallCount = 0
    private(set) var deleteManyCallCount = 0
    private(set) var saveChangesCallCount = 0

    init(transactions: [AppTransactionItem] = []) {
        self.transactions = transactions
    }

    func fetchAllSortedByDateDesc() throws -> [AppTransactionItem] {
        fetchCallCount += 1
        if let fetchError { throw fetchError }
        return transactions.sorted(by: { $0.date > $1.date })
    }

    func fetchRecentNotes(categoryId: UUID, limit: Int) throws -> [String] {
        fetchRecentNotesCallCount += 1
        if let recentNotesError { throw recentNotesError }
        var seen = Set<String>()
        var notes: [String] = []
        for t in transactions.sorted(by: { $0.date > $1.date }) {
            guard t.category?.id == categoryId else { continue }
            guard !t.note.isEmpty else { continue }
            guard !seen.contains(t.note) else { continue }
            seen.insert(t.note)
            notes.append(t.note)
            if notes.count >= limit { break }
        }
        return notes
    }

    func insert(_ transaction: AppTransactionItem) throws {
        insertCallCount += 1
        if let insertError { throw insertError }
        transactions.append(transaction)
    }

    func delete(_ transaction: AppTransactionItem) throws {
        // Not used by stores; keep for protocol conformance.
        if let deleteError { throw deleteError }
        transactions.removeAll(where: { $0.id == transaction.id })
    }

    func delete(_ transactions: [AppTransactionItem]) throws {
        deleteManyCallCount += 1
        if let deleteError { throw deleteError }
        let ids = Set(transactions.map(\.id))
        self.transactions.removeAll(where: { ids.contains($0.id) })
    }

    func saveChanges() throws {
        saveChangesCallCount += 1
        if let saveChangesError { throw saveChangesError }
    }
}

