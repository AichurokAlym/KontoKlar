import Foundation
import SwiftData

enum AppModelContainerFactory {
    static func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: Category.self, TransactionItem.self)
    }

    static func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([Category.self, TransactionItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

