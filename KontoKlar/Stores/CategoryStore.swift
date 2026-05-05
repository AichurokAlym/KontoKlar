import Combine
import Foundation

@MainActor
final class CategoryStore: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var persistenceFeedback: PersistenceUserFeedback?

    private let repository: CategoryRepository

    init(repository: CategoryRepository, autoLoad: Bool = true) {
        self.repository = repository
        if autoLoad {
            reload()
        }
    }

    func clearPersistenceError() {
        persistenceFeedback = nil
    }

    func reload(clearPersistenceFeedback: Bool = true) {
        do {
            categories = try repository.fetchAllSortedByName()
            if clearPersistenceFeedback {
                persistenceFeedback = nil
            }
        } catch {
            PersistenceLogger.log(error, operation: "fetchAllCategoriesSortedByName")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.loadCategories, error: error)
        }
    }

    func createDefaultCategoriesIfNeeded() {
        guard categories.isEmpty else { return }

        for category in makeDefaultCategories() {
            do {
                try repository.insert(category)
            } catch {
                PersistenceLogger.log(error, operation: "insertDefaultCategory")
                persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.createDefaultCategories, error: error)
                reload(clearPersistenceFeedback: false)
                return
            }
        }

        reload()
    }

    func categories(for type: CategoryType) -> [Category] {
        categories.filter { $0.type == type }
    }

    func category(withId id: UUID) -> Category? {
        categories.first(where: { $0.id == id })
    }

    func delete(_ category: Category) {
        do {
            try repository.delete(category)
            persistenceFeedback = nil
        } catch {
            PersistenceLogger.log(error, operation: "deleteCategory")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.deleteCategory, error: error)
        }
        reload(clearPersistenceFeedback: false)
    }
}

