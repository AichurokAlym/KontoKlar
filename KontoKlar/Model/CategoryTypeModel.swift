import Foundation

enum CategoryType: String, Codable, CaseIterable {
    case expense = "Expense"
    case income = "Income"
    
    func localizedName() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
