import Foundation
import SwiftData

final class SwiftDataCategoryRepository: CategoryRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAllSortedByName() throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }

    func insert(_ category: Category) throws {
        context.insert(category)
        try context.save()
    }

    func delete(_ category: Category) throws {
        context.delete(category)
        try context.save()
    }
}
