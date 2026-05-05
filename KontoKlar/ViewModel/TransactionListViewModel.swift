import Foundation
import Combine

@MainActor
final class TransactionListViewModel: ObservableObject {
    @Published var dateRangeSelection: DateRangeSelection = DateRangeSelection()
    @Published var showCustomDateRange: Bool = false

    private let store: TransactionStore
    private let groupByDateUseCase: GroupTransactionsByDateUseCase

    init(
        store: TransactionStore,
        groupByDateUseCase: GroupTransactionsByDateUseCase = GroupTransactionsByDateUseCase()
    ) {
        self.store = store
        self.groupByDateUseCase = groupByDateUseCase
    }

    var persistenceFeedback: PersistenceUserFeedback? { store.persistenceFeedback }

    var selectedDateRange: DashboardDateRange {
        get { dateRangeSelection.range }
        set { dateRangeSelection.range = newValue }
    }

    var customStartDate: Date {
        get { dateRangeSelection.customStartDate }
        set { dateRangeSelection.customStartDate = newValue }
    }

    var customEndDate: Date {
        get { dateRangeSelection.customEndDate }
        set { dateRangeSelection.customEndDate = newValue }
    }

    private var filteredTransactions: [TransactionItem] {
        store.transactions(in: dateRangeSelection.interval())
    }
    
    var isFilteredEmpty: Bool {
        filteredTransactions.isEmpty
    }

    func groupedByDate() -> [Date: [TransactionItem]] {
        groupByDateUseCase.group(filteredTransactions)
    }

    func delete(at offsets: IndexSet, from sectionTransactions: [TransactionItem]) {
        let items = offsets.map { sectionTransactions[$0] }
        store.delete(items)
    }

    func clearPersistenceError() {
        store.clearPersistenceError()
    }
}
