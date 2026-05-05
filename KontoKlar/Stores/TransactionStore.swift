import Combine
import Foundation

@MainActor
final class TransactionStore: ObservableObject {
    @Published private(set) var transactions: [TransactionItem] = []
    @Published private(set) var persistenceFeedback: PersistenceUserFeedback?

    private let repository: TransactionRepository
    private let dashboardStatsUseCase: DashboardStatsUseCase

    init(
        repository: TransactionRepository,
        dashboardStatsUseCase: DashboardStatsUseCase = DashboardStatsUseCase(),
        autoLoad: Bool = true
    ) {
        self.repository = repository
        self.dashboardStatsUseCase = dashboardStatsUseCase
        if autoLoad {
            reload()
        }
    }

    func clearPersistenceError() {
        persistenceFeedback = nil
    }

    func reload(clearPersistenceFeedback: Bool = true) {
        do {
            transactions = try repository.fetchAllSortedByDateDesc()
            if clearPersistenceFeedback {
                persistenceFeedback = nil
            }
        } catch {
            PersistenceLogger.log(error, operation: "fetchAllTransactionsSortedByDateDesc")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.loadTransactions, error: error)
        }
    }

    func transactions(in interval: DateInterval?) -> [TransactionItem] {
        guard let interval else { return transactions }
        return transactions.filter { interval.contains($0.date) }
    }

    func stats(in interval: DateInterval?) -> DashboardStats {
        dashboardStatsUseCase.compute(transactions: transactions(in: interval))
    }

    func insert(_ transaction: TransactionItem) -> Bool {
        do {
            try repository.insert(transaction)
            persistenceFeedback = nil
            reload(clearPersistenceFeedback: false)
            return true
        } catch {
            PersistenceLogger.log(error, operation: "insertTransaction")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.addTransaction, error: error)
            return false
        }
    }

    func delete(_ transactions: [TransactionItem]) {
        do {
            try repository.delete(transactions)
            persistenceFeedback = nil
        } catch {
            PersistenceLogger.log(error, operation: "deleteTransactions")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.deleteTransactions, error: error)
        }
        reload(clearPersistenceFeedback: false)
    }

    func saveChanges() {
        do {
            try repository.saveChanges()
            persistenceFeedback = nil
        } catch {
            PersistenceLogger.log(error, operation: "saveChanges")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.saveTransaction, error: error)
        }
        reload(clearPersistenceFeedback: false)
    }
}

