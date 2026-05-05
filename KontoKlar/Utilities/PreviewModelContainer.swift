import Foundation
import SwiftData

/// In-memory SwiftData stack for SwiftUI previews (same schema as the app).
enum PreviewModelContainer {
    static func makeInMemoryEmpty() throws -> ModelContainer {
        try AppModelContainerFactory.makeInMemoryContainer()
    }

    /// One expense category and one linked transaction (lists, editors).
    static func makeInMemoryWithSampleTransaction() throws -> (ModelContainer, Category, TransactionItem) {
        let container = try makeInMemoryEmpty()
        let context = ModelContext(container)
        let category = Category(name: "Food", icon: "cart", color: "colorPurple", type: .expense)
        let transaction = TransactionItem(
            amount: 24.90,
            note: "Preview",
            date: Date(),
            type: .expense,
            category: category
        )
        context.insert(category)
        context.insert(transaction)
        try context.save()
        return (container, category, transaction)
    }

    /// Several categories (picker, category settings).
    static func makeInMemoryWithMultipleCategories() throws -> (ModelContainer, [Category]) {
        let container = try makeInMemoryEmpty()
        let context = ModelContext(container)
        let categories: [Category] = [
            Category(name: "Food", icon: "cart", color: "colorPurple", type: .expense),
            Category(name: "Transport", icon: "bus.fill", color: "colorGray1", type: .expense),
            Category(name: "Salary", icon: "dollarsign", color: "colorGreen", type: .income),
        ]
        categories.forEach { context.insert($0) }
        try context.save()
        return (container, categories)
    }
}

