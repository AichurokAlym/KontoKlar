import XCTest
import SwiftUI
@testable import KontoKlar

final class HomeViewModelTests: XCTestCase {
    @MainActor
    func test_stats_areComputedFromTransactionStore() {
        let repo = TestTransactionRepository(transactions: [
            TransactionItem(amount: 100, type: .income),
            TransactionItem(amount: 40, type: .expense),
        ])
        let transactionStore = TransactionStore(repository: repo, autoLoad: false)
        transactionStore.reload()

        let categoryStore = CategoryStore(repository: TestCategoryRepository(), autoLoad: false)
        categoryStore.reload()

        let appVM = AppViewModel()
        appVM.selectedFeedbackHaptic = false

        let sut = HomeViewModel(appVM: appVM, categoryStore: categoryStore, transactionStore: transactionStore)

        XCTAssertEqual(sut.totalIncomes, 100, accuracy: 0.000_001)
        XCTAssertEqual(sut.totalExpenses, 40, accuracy: 0.000_001)
        XCTAssertEqual(sut.balance, 60, accuracy: 0.000_001)
    }

    @MainActor
    func test_openSettings_appendsSettingsDestination() {
        let appVM = AppViewModel()
        appVM.selectedFeedbackHaptic = false

        let categoryStore = CategoryStore(repository: TestCategoryRepository(), autoLoad: false)
        let transactionStore = TransactionStore(repository: TestTransactionRepository(), autoLoad: false)

        let sut = HomeViewModel(appVM: appVM, categoryStore: categoryStore, transactionStore: transactionStore)

        sut.openSettings()

        // NavigationPath is opaque, but we can validate "not empty" and type by decoding hashables.
        XCTAssertFalse(sut.path.isEmpty)
    }

    @MainActor
    func test_openAddTransaction_setsShowAddTransactionTrue() {
        let appVM = AppViewModel()
        appVM.selectedFeedbackHaptic = false

        let sut = HomeViewModel(
            appVM: appVM,
            categoryStore: CategoryStore(repository: TestCategoryRepository(), autoLoad: false),
            transactionStore: TransactionStore(repository: TestTransactionRepository(), autoLoad: false)
        )

        sut.openAddTransaction()

        XCTAssertTrue(sut.showAddTransaction)
    }

    @MainActor
    func test_categoriesForSelectedTypeSortedByAmount_sortsDescendingAndFiltersZeroes() {
        let expense1 = Category(name: "Food", type: .expense)
        let expense2 = Category(name: "Transport", type: .expense)
        let income = Category(name: "Salary", type: .income)

        let categoryRepo = TestCategoryRepository(categories: [expense1, expense2, income])
        let categoryStore = CategoryStore(repository: categoryRepo, autoLoad: false)
        categoryStore.reload()

        let txRepo = TestTransactionRepository(transactions: [
            TransactionItem(amount: 10, type: .expense, category: expense1),
            TransactionItem(amount: 30, type: .expense, category: expense2),
            TransactionItem(amount: 5, type: .expense, category: expense1),
            TransactionItem(amount: 999, type: .income, category: income),
        ])
        let transactionStore = TransactionStore(repository: txRepo, autoLoad: false)
        transactionStore.reload()

        let appVM = AppViewModel()
        appVM.selectedFeedbackHaptic = false

        let sut = HomeViewModel(appVM: appVM, categoryStore: categoryStore, transactionStore: transactionStore)
        sut.selectedCategoryType = .expense

        let sorted = sut.categoriesForSelectedTypeSortedByAmount()

        XCTAssertEqual(sorted.map { $0.id }, [expense2.id, expense1.id])
    }

    @MainActor
    func test_amountForCategory_sumsOnlyMatchingTypeAndCategory() {
        let c = Category(name: "Food", type: .expense)
        let other = Category(name: "Other", type: .expense)

        let categoryStore = CategoryStore(repository: TestCategoryRepository(categories: [c, other]), autoLoad: false)
        categoryStore.reload()

        let txRepo = TestTransactionRepository(transactions: [
            TransactionItem(amount: 10, type: .expense, category: c),
            TransactionItem(amount: 5, type: .expense, category: c),
            TransactionItem(amount: 3, type: .expense, category: other),
            TransactionItem(amount: 100, type: .income, category: c),
        ])
        let transactionStore = TransactionStore(repository: txRepo, autoLoad: false)
        transactionStore.reload()

        let appVM = AppViewModel()
        appVM.selectedFeedbackHaptic = false
        let sut = HomeViewModel(appVM: appVM, categoryStore: categoryStore, transactionStore: transactionStore)

        XCTAssertEqual(sut.amountForCategory(c, type: .expense), 15, accuracy: 0.000_001)
    }

    @MainActor
    func test_categoryForRoute_returnsCategoryFromStore() {
        let c = Category(name: "Food", type: .expense)
        let repo = TestCategoryRepository(categories: [c])
        let store = CategoryStore(repository: repo, autoLoad: false)
        store.reload()

        let sut = HomeViewModel(
            appVM: AppViewModel(),
            categoryStore: store,
            transactionStore: TransactionStore(repository: TestTransactionRepository(), autoLoad: false)
        )

        XCTAssertEqual(sut.categoryForRoute(id: c.id)?.id, c.id)
    }
}