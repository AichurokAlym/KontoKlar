import Foundation

// User-facing persistence failure: localized title + system detail (for alerts).
struct PersistenceUserFeedback: Equatable {
    let titleKey: String
    let detailMessage: String

    init(titleKey: String, error: Error) {
        self.titleKey = titleKey
        self.detailMessage = error.localizedDescription
    }

    var localizedTitle: String {
        NSLocalizedString(titleKey, comment: "Persistence error title")
    }

    // Body text for alerts: short label + system/store detail.
    var localizedMessage: String {
        let label = NSLocalizedString("Persistence details label", comment: "Prefix before technical error text")
        return "\(label): \(detailMessage)"
    }
}

enum PersistenceFeedbackTitle {
    static let loadCategories = "Could not load categories"
    static let loadTransactions = "Could not load transactions"
    static let saveTransaction = "Could not save transaction"
    static let addCategory = "Could not add category"
    static let addTransaction = "Could not add transaction"
    static let deleteCategory = "Could not delete category"
    static let deleteTransactions = "Could not delete transactions"
    static let createDefaultCategories = "Could not create starter categories"
    static let loadRecentNotes = "Could not load suggested notes"
}
