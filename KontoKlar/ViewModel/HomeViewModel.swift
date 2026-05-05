import Combine
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedCategoryType: CategoryType = .expense
    @Published var showAddTransaction: Bool = false
    @Published var path = NavigationPath()
    @Published var dateRangeSelection: DateRangeSelection = DateRangeSelection()
    @Published var showCustomDateRange: Bool = false

    private let appVM: AppViewModel
    private let categoryStore: CategoryStore
    private let transactionStore: TransactionStore
    private var cancellables: Set<AnyCancellable> = []

    init(appVM: AppViewModel, categoryStore: CategoryStore, transactionStore: TransactionStore) {
        self.appVM = appVM
        self.categoryStore = categoryStore
        self.transactionStore = transactionStore

        transactionStore.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        categoryStore.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var currencySymbol: String { appVM.currencySymbol }

    private var activeInterval: DateInterval? {
        dateRangeSelection.interval()
    }
    
    private var filteredStats: DashboardStats {
        transactionStore.stats(in: activeInterval)
    }

    var balance: Double { filteredStats.balance }
    var averageDailyExpense: Double { filteredStats.averageDailyExpense }
    var totalIncomes: Double { filteredStats.totalIncomes }
    var totalExpenses: Double { filteredStats.totalExpenses }
    
    var monthlyBudget: Double { appVM.monthlyBudget }
    var savingsGoal: Double { appVM.savingsGoal }
    
    var currentMonthExpenses: Double {
        let month = Calendar.current.dateInterval(of: .month, for: Date())
        return transactionStore.stats(in: month).totalExpenses
    }
    
    var budgetProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(currentMonthExpenses / monthlyBudget, 1)
    }
    
    var savingsProgress: Double {
        guard savingsGoal > 0 else { return 0 }
        return min(max(balance, 0) / savingsGoal, 1)
    }

    func refresh() {
        transactionStore.reload()
        categoryStore.reload()
    }

    func categoriesForSelectedTypeSortedByAmount() -> [Category] {
        let categories = categoryStore.categories(for: selectedCategoryType)
        let itemsWithAmount = categories
            .map { ($0, amountForCategory($0, type: selectedCategoryType)) }
            .filter { $0.1 > 0 }
            .sorted(by: { $0.1 > $1.1 })
            .map { $0.0 }
        return itemsWithAmount
    }
    
    func amountForCategory(_ category: Category, type: CategoryType) -> Double {
        let interval = activeInterval
        return transactionStore
            .transactions(in: interval)
            .filter { $0.type == type && $0.category?.id == category.id }
            .reduce(0.0) { $0 + $1.amount }
    }

    func openAddTransaction() {
        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
        showAddTransaction = true
    }
    
    func openSettings() {
        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
        path.append(HomeDestination.settings)
    }
    
    func openCategoryTransactions(category: Category) {
        path.append(HomeDestination.categoryTransactions(category.id))
    }
    
    func categoryForRoute(id: UUID) -> Category? {
        categoryStore.category(withId: id)
    }
}

enum HomeDestination: Hashable {
    case settings
    case settingsTransactions
    case settingsCategories
    case categoryTransactions(UUID)
}

