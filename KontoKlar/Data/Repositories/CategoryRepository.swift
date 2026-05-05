import Foundation

protocol CategoryRepository {
    func fetchAllSortedByName() throws -> [Category]
    func insert(_ category: Category) throws
    func delete(_ category: Category) throws
}
