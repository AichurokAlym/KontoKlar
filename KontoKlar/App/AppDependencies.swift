import Foundation
import Combine

@MainActor
final class AppDependencies: ObservableObject {
    let categoryRepository: CategoryRepository
    let transactionRepository: TransactionRepository

    let categoryStore: CategoryStore
    let transactionStore: TransactionStore

    init(categoryRepository: CategoryRepository, transactionRepository: TransactionRepository) {
        self.categoryRepository = categoryRepository
        self.transactionRepository = transactionRepository

        self.categoryStore = CategoryStore(repository: categoryRepository)
        self.transactionStore = TransactionStore(repository: transactionRepository)
    }

    func makeCategoryListViewModel() -> CategoryListViewModel {
        CategoryListViewModel(store: categoryStore)
    }

    func makeAddCategoryViewModel(initialType: CategoryType) -> AddCategoryViewModel {
        AddCategoryViewModel(repository: categoryRepository, selectedType: initialType)
    }

    func makePickerCategoryViewModel(initialType: CategoryType) -> PickerCategoryViewModel {
        PickerCategoryViewModel(repository: categoryRepository, selectedType: initialType)
    }

    func makeTransactionListViewModel() -> TransactionListViewModel {
        TransactionListViewModel(store: transactionStore)
    }

    func makeAddTransactionViewModel(initialType: CategoryType) -> AddTransactionViewModel {
        AddTransactionViewModel(transactionRepository: transactionRepository, selectedType: initialType)
    }

    func makeEditTransactionViewModel() -> EditTransactionViewModel {
        EditTransactionViewModel(transactionRepository: transactionRepository)
    }

    func makeTransactionCategoryViewModel(category: Category) -> TransactionCategoryViewModel {
        TransactionCategoryViewModel(category: category, repository: transactionRepository)
    }
}
