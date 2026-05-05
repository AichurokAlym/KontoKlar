import Foundation
import Combine

@MainActor
final class AddTransactionViewModel: ObservableObject {
    @Published var selectedCategory: Category?
    @Published var amount: Double = 0
    @Published var date: Date = Date()
    @Published var note: String = ""
    @Published var selectedType: CategoryType

    @Published var alertAmount: Bool = false
    @Published var alertCategory: Bool = false
    @Published private(set) var persistenceFeedback: PersistenceUserFeedback?

    private let transactionRepository: TransactionRepository

    init(transactionRepository: TransactionRepository, selectedType: CategoryType) {
        self.transactionRepository = transactionRepository
        self.selectedType = selectedType
    }

    func clearPersistenceError() {
        persistenceFeedback = nil
    }

    func onTypeChanged() {
        selectedCategory = nil
    }

    func recentNotes(limit: Int = 50) -> [String] {
        guard let selectedCategory else { return [] }
        do {
            return try transactionRepository.fetchRecentNotes(categoryId: selectedCategory.id, limit: limit)
        } catch {
            PersistenceLogger.log(error, operation: "fetchRecentNotes")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.loadRecentNotes, error: error)
            return []
        }
    }

    func submit() -> Bool {
        alertAmount = false
        alertCategory = false

        guard amount != 0 else {
            alertAmount = true
            return false
        }
        guard let category = selectedCategory else {
            alertCategory = true
            return false
        }
        guard selectedType == category.type else {
            alertCategory = true
            selectedCategory = nil
            return false
        }

        let transaction = TransactionItem(
            amount: amount,
            note: note,
            date: date,
            type: selectedType,
            category: category
        )
        do {
            try transactionRepository.insert(transaction)
            persistenceFeedback = nil
            return true
        } catch {
            PersistenceLogger.log(error, operation: "insertTransaction")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.addTransaction, error: error)
            return false
        }
    }
}
