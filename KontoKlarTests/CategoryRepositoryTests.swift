import XCTest
import SwiftData
@testable import KontoKlar

final class CategoryRepositoryTests: XCTestCase {
    @MainActor
    func test_swiftDataCategoryRepository_insertAndFetchAllSortedByName() throws {
        let container = try AppModelContainerFactory.makeInMemoryContainer()
        let context = ModelContext(container)
        let repo = SwiftDataCategoryRepository(context: context)

        let b = Category(name: "B")
        let a = Category(name: "A")

        try repo.insert(b)
        try repo.insert(a)

        let result = try repo.fetchAllSortedByName()
        XCTAssertEqual(result.map { $0.name }, ["A", "B"])
    }

    @MainActor
    func test_swiftDataCategoryRepository_deleteRemovesCategory() throws {
        let container = try AppModelContainerFactory.makeInMemoryContainer()
        let context = ModelContext(container)
        let repo = SwiftDataCategoryRepository(context: context)

        let c = Category(name: "ToDelete")
        try repo.insert(c)

        XCTAssertEqual(try repo.fetchAllSortedByName().count, 1)

        try repo.delete(c)
        XCTAssertEqual(try repo.fetchAllSortedByName().count, 0)
    }
}

