import Foundation

protocol TransactionRepository {
    func fetchAllSortedByDateDesc() throws -> [TransactionItem]
    func fetchRecentNotes(categoryId: UUID, limit: Int) throws -> [String]
    func insert(_ transaction: TransactionItem) throws
    func delete(_ transaction: TransactionItem) throws
    func delete(_ transactions: [TransactionItem]) throws
    func saveChanges() throws
}
