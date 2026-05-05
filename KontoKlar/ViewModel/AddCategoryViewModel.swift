import Foundation
import Combine

@MainActor
final class AddCategoryViewModel: ObservableObject {
    @Published var selectedType: CategoryType
    @Published var name: String = ""
    @Published var selectedImage: String = "folder.circle"
    @Published var selectedColor: String = "colorBlue"
    @Published var showAlert: Bool = false
    @Published private(set) var persistenceFeedback: PersistenceUserFeedback?

    private let repository: CategoryRepository

    init(repository: CategoryRepository, selectedType: CategoryType) {
        self.repository = repository
        self.selectedType = selectedType
    }

    func clearPersistenceError() {
        persistenceFeedback = nil
    }

    func addCategory() -> Bool {
        guard !name.isEmpty else {
            showAlert = true
            return false
        }

        let category = Category(name: name, icon: selectedImage, color: selectedColor, type: selectedType)
        do {
            try repository.insert(category)
            persistenceFeedback = nil
            return true
        } catch {
            PersistenceLogger.log(error, operation: "insertCategory")
            persistenceFeedback = PersistenceUserFeedback(titleKey: PersistenceFeedbackTitle.addCategory, error: error)
            return false
        }
    }
}

