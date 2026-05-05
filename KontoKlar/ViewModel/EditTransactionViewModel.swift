import Foundation
import Combine

@MainActor
final class EditTransactionViewModel: ObservableObject {
    @Published var alertAmount: Bool = false
    @Published private(set) var persistenceFeedback: PersistenceUserFeedback?

    private let transactionRepository: TransactionRepository

    init(transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }

    func clearPersistenceError() {
        persistenceFeedback = nil
    }

    func save(transaction: TransactionItem) -> Bool {
        alertAmount = false

        guard transaction.amount != 0 else {
            alertAmount = true
            return false
        }

        do {
            try transactionRepository.saveChanges()
            persistenceFeedback = nil
            return true
        } catch {
            PersistenceLogger.log(error, operation: "saveTransactionChanges")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.saveTransaction, error: error)
            return false
        }
    }

    func recentNotes(for category: Category?, limit: Int = 50) -> [String] {
        guard let category else { return [] }
        do {
            return try transactionRepository.fetchRecentNotes(categoryId: category.id, limit: limit)
        } catch {
            PersistenceLogger.log(error, operation: "fetchRecentNotes")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.loadRecentNotes, error: error)
            return []
        }
    }
}

