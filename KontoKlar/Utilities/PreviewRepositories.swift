import Foundation

// Stub repositories for SwiftUI previews and lightweight setup.
final class PreviewCategoryRepository: CategoryRepository {
    func fetchAllSortedByName() throws -> [Category] { [] }
    func insert(_ category: Category) throws {}
    func delete(_ category: Category) throws {}
}

final class PreviewTransactionRepository: TransactionRepository {
    func fetchAllSortedByDateDesc() throws -> [TransactionItem] { [] }
    func fetchRecentNotes(categoryId: UUID, limit: Int) throws -> [String] { [] }
    func insert(_ transaction: TransactionItem) throws {}
    func delete(_ transaction: TransactionItem) throws {}
    func delete(_ transactions: [TransactionItem]) throws {}
    func saveChanges() throws {}
}
