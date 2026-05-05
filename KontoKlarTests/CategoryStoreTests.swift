import XCTest
@testable import KontoKlar

final class CategoryStoreTests: XCTestCase {
    @MainActor
    func test_init_autoLoadFalse_doesNotFetch() {
        let repo = TestCategoryRepository(categories: [Category(name: "A")])
        _ = CategoryStore(repository: repo, autoLoad: false)

        XCTAssertEqual(repo.fetchCallCount, 0)
    }

    @MainActor
    func test_reload_success_updatesCategoriesAndClearsFeedback() {
        let a = Category(name: "A")
        let b = Category(name: "B")
        let repo = TestCategoryRepository(categories: [b, a])
        let sut = CategoryStore(repository: repo, autoLoad: false)

        sut.reload()

        XCTAssertEqual(repo.fetchCallCount, 1)
        XCTAssertEqual(sut.categories.map { $0.name }, ["A", "B"])
        XCTAssertNil(sut.persistenceFeedback)
    }

    @MainActor
    func test_reload_failure_setsFeedback() {
        let repo = TestCategoryRepository(categories: [])
        repo.fetchError = TestError.any
        let sut = CategoryStore(repository: repo, autoLoad: false)

        sut.reload()

        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.loadCategories)
    }

    @MainActor
    func test_delete_success_deletesAndReloads() {
        let a = Category(name: "A")
        let repo = TestCategoryRepository(categories: [a])
        let sut = CategoryStore(repository: repo, autoLoad: false)
        sut.reload()

        sut.delete(a)

        XCTAssertEqual(repo.deleteCallCount, 1)
        XCTAssertTrue(repo.fetchCallCount >= 2) // initial reload + reload after delete
        XCTAssertTrue(sut.categories.isEmpty)
        XCTAssertNil(sut.persistenceFeedback)
    }

    @MainActor
    func test_createDefaultCategoriesIfNeeded_whenEmpty_insertsDefaults() {
        let repo = TestCategoryRepository(categories: [])
        let sut = CategoryStore(repository: repo, autoLoad: false)
        sut.reload()

        sut.createDefaultCategoriesIfNeeded()

        XCTAssertEqual(repo.insertCallCount, makeDefaultCategories().count)
        XCTAssertFalse(sut.categories.isEmpty)
        XCTAssertNil(sut.persistenceFeedback)
    }

    @MainActor
    func test_createDefaultCategoriesIfNeeded_whenInsertFails_setsFeedbackAndStops() {
        let repo = TestCategoryRepository(categories: [])
        repo.insertError = TestError.any
        let sut = CategoryStore(repository: repo, autoLoad: false)
        sut.reload()

        sut.createDefaultCategoriesIfNeeded()

        XCTAssertEqual(repo.insertCallCount, 1)
        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.createDefaultCategories)
    }
}

