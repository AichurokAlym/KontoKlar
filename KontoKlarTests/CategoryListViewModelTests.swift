import XCTest
@testable import KontoKlar

final class CategoryListViewModelTests: XCTestCase {
    @MainActor
    func test_categoriesForSelectedType_filtersByType() {
        let expense = Category(name: "E", type: .expense)
        let income = Category(name: "I", type: .income)
        let repo = TestCategoryRepository(categories: [expense, income])
        let store = CategoryStore(repository: repo, autoLoad: false)
        store.reload()

        let sut = CategoryListViewModel(store: store)
        sut.selectedType = .income

        let result = sut.categoriesForSelectedType()

        XCTAssertEqual(result.map { $0.id }, [income.id])
    }

    @MainActor
    func test_delete_deletesItemsAtOffsetsFromFilteredList() {
        let e1 = Category(name: "E1", type: .expense)
        let e2 = Category(name: "E2", type: .expense)
        let i1 = Category(name: "I1", type: .income)
        let repo = TestCategoryRepository(categories: [e1, e2, i1])
        let store = CategoryStore(repository: repo, autoLoad: false)
        store.reload()

        let sut = CategoryListViewModel(store: store)
        sut.selectedType = .expense

        sut.delete(at: IndexSet(integer: 0)) // E1 after sorting by name

        XCTAssertEqual(repo.deleteCallCount, 1)
        XCTAssertFalse(store.categories.contains(where: { $0.id == e1.id }))
        XCTAssertTrue(store.categories.contains(where: { $0.id == e2.id }))
        XCTAssertTrue(store.categories.contains(where: { $0.id == i1.id }))
    }

    @MainActor
    func test_persistenceFeedback_isForwardedFromStore() {
        let repo = TestCategoryRepository(categories: [])
        repo.fetchError = TestError.any
        let store = CategoryStore(repository: repo, autoLoad: false)
        store.reload()
        let sut = CategoryListViewModel(store: store)

        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.loadCategories)
    }

    @MainActor
    func test_clearPersistenceError_clearsStoreFeedback() {
        let repo = TestCategoryRepository(categories: [])
        repo.fetchError = TestError.any
        let store = CategoryStore(repository: repo, autoLoad: false)
        store.reload()
        let sut = CategoryListViewModel(store: store)

        sut.clearPersistenceError()

        XCTAssertNil(store.persistenceFeedback)
        XCTAssertNil(sut.persistenceFeedback)
    }
}

