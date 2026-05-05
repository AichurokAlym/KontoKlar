import Foundation
import SwiftData

final class SwiftDataTransactionRepository: TransactionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAllSortedByDateDesc() throws -> [TransactionItem] {
        let descriptor = FetchDescriptor<TransactionItem>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func fetchRecentNotes(categoryId: UUID, limit: Int) throws -> [String] {
        var notes: [String] = []
        var seen: Set<String> = []

        let descriptor = FetchDescriptor<TransactionItem>(
            predicate: #Predicate { item in
                item.category?.id == categoryId && item.note != ""
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        // SwiftData doesn't support "distinct" fetches, so we de-duplicate in-memory,
        // but over a much smaller candidate set than "fetch all".
        let items = try context.fetch(descriptor)
        for item in items {
            let note = item.note
            guard !note.isEmpty else { continue }
            guard !seen.contains(note) else { continue }
            seen.insert(note)
            notes.append(note)
            if notes.count >= limit { break }
        }

        return notes
    }

    func insert(_ transaction: TransactionItem) throws {
        context.insert(transaction)
        try context.save()
    }

    func delete(_ transaction: TransactionItem) throws {
        context.delete(transaction)
        try context.save()
    }

    func delete(_ transactions: [TransactionItem]) throws {
        for t in transactions {
            context.delete(t)
        }
        try context.save()
    }

    func saveChanges() throws {
        try context.save()
    }
}
