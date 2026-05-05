import Foundation
import Combine

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published private(set) var transactions: [TransactionItem] = []
    @Published private(set) var persistenceFeedback: PersistenceUserFeedback?

    private let repository: TransactionRepository
    private let dashboardStatsUseCase: DashboardStatsUseCase

    init(
        repository: TransactionRepository,
        dashboardStatsUseCase: DashboardStatsUseCase = DashboardStatsUseCase()
    ) {
        self.repository = repository
        self.dashboardStatsUseCase = dashboardStatsUseCase
        reload()
    }

    func clearPersistenceError() {
        persistenceFeedback = nil
    }

    func reload() {
        do {
            transactions = try repository.fetchAllSortedByDateDesc()
            persistenceFeedback = nil
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
}
