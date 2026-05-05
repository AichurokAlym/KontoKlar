import Foundation
import Combine

@MainActor
final class PickerCategoryViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var persistenceFeedback: PersistenceUserFeedback?
    @Published var selectedType: CategoryType

    private let repository: CategoryRepository

    init(repository: CategoryRepository, selectedType: CategoryType) {
        self.repository = repository
        self.selectedType = selectedType
        reload()
    }

    func clearPersistenceError() {
        persistenceFeedback = nil
    }

    func reload() {
        do {
            categories = try repository.fetchAllSortedByName()
            persistenceFeedback = nil
        } catch {
            PersistenceLogger.log(error, operation: "fetchAllCategoriesSortedByName")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.loadCategories, error: error)
        }
    }

    func categoriesForSelectedType() -> [Category] {
        categories.filter { $0.type == selectedType }
    }
}
