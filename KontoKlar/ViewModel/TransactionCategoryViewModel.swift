import Foundation
import Combine

@MainActor
final class TransactionCategoryViewModel: ObservableObject {
    let category: Category
    @Published private(set) var transactions: [TransactionItem] = []
    @Published private(set) var persistenceFeedback: PersistenceUserFeedback?

    private let repository: TransactionRepository
    private let groupByDateUseCase: GroupTransactionsByDateUseCase

    init(
        category: Category,
        repository: TransactionRepository,
        groupByDateUseCase: GroupTransactionsByDateUseCase = GroupTransactionsByDateUseCase()
    ) {
        self.category = category
        self.repository = repository
        self.groupByDateUseCase = groupByDateUseCase
        reload()
    }

    func clearPersistenceError() {
        persistenceFeedback = nil
    }

    func reload(clearPersistenceFeedback: Bool = true) {
        do {
            let all = try repository.fetchAllSortedByDateDesc()
            transactions = all.filter { $0.category?.id == category.id }
            if clearPersistenceFeedback {
                persistenceFeedback = nil
            }
        } catch {
            PersistenceLogger.log(error, operation: "fetchAllTransactionsSortedByDateDesc")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.loadTransactions, error: error)
        }
    }

    func groupedByDate() -> [Date: [TransactionItem]] {
        groupByDateUseCase.group(transactions)
    }

    func delete(at offsets: IndexSet, from sectionTransactions: [TransactionItem]) {
        let items = offsets.map { sectionTransactions[$0] }
        do {
            try repository.delete(items)
            persistenceFeedback = nil
        } catch {
            PersistenceLogger.log(error, operation: "deleteTransactions")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.deleteTransactions, error: error)
            reload(clearPersistenceFeedback: false)
            return
        }
        reload()
    }
}
