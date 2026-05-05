import Foundation
import SwiftData

@Model
final class TransactionItem {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var note: String
    var date: Date
    var type: CategoryType
    var category: Category?
    
    init(
        id: UUID = UUID(),
        amount: Double = 0,
        note: String = "",
        date: Date = Date(),
        type: CategoryType = .expense,
        category: Category? = nil
    ) {
        self.id = id
        self.amount = amount
        self.note = note
        self.date = date
        self.type = type
        self.category = category
    }
}
