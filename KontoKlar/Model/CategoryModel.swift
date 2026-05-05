import Foundation
import SwiftData


@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var color: String
    var type: CategoryType
    @Relationship(deleteRule: .cascade, inverse: \TransactionItem.category) var transactions: [TransactionItem]

    var localizedName: String {
        NSLocalizedString(name, comment: name)
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        icon: String = "",
        color: String = "",
        type: CategoryType = .expense,
        transactions: [TransactionItem] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
        self.transactions = transactions
    }
}
