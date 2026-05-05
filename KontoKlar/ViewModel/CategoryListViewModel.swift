import Foundation
import Combine

@MainActor
final class CategoryListViewModel: ObservableObject {
    @Published var selectedType: CategoryType = .expense

    private let store: CategoryStore

    init(store: CategoryStore) {
        self.store = store
    }

    var persistenceFeedback: PersistenceUserFeedback? { store.persistenceFeedback }

    func categoriesForSelectedType() -> [Category] {
        store.categories(for: selectedType)
    }

    func delete(at offsets: IndexSet) {
        let filtered = categoriesForSelectedType()
        for idx in offsets {
            store.delete(filtered[idx])
        }
    }

    func clearPersistenceError() {
        store.clearPersistenceError()
    }
}
