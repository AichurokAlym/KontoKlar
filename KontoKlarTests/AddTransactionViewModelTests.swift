import XCTest
@testable import KontoKlar

final class AddTransactionViewModelTests: XCTestCase {
    @MainActor
    func test_submit_whenAmountIsZero_setsAlertAmountAndReturnsFalse() {
        let repo = TestTransactionRepository()
        let sut = AddTransactionViewModel(transactionRepository: repo, selectedType: .expense)
        sut.amount = 0
        sut.selectedCategory = Category(type: .expense)

        let ok = sut.submit()

        XCTAssertFalse(ok)
        XCTAssertTrue(sut.alertAmount)
        XCTAssertFalse(sut.alertCategory)
        XCTAssertEqual(repo.insertCallCount, 0)
    }

    @MainActor
    func test_submit_whenCategoryMissing_setsAlertCategoryAndReturnsFalse() {
        let repo = TestTransactionRepository()
        let sut = AddTransactionViewModel(transactionRepository: repo, selectedType: .expense)
        sut.amount = 10
        sut.selectedCategory = nil

        let ok = sut.submit()

        XCTAssertFalse(ok)
        XCTAssertFalse(sut.alertAmount)
        XCTAssertTrue(sut.alertCategory)
        XCTAssertEqual(repo.insertCallCount, 0)
    }

    @MainActor
    func test_submit_whenTypeMismatch_setsAlertCategory_clearsSelectedCategory_returnsFalse() {
        let repo = TestTransactionRepository()
        let sut = AddTransactionViewModel(transactionRepository: repo, selectedType: .expense)
        sut.amount = 10
        sut.selectedCategory = Category(type: .income)

        let ok = sut.submit()

        XCTAssertFalse(ok)
        XCTAssertTrue(sut.alertCategory)
        XCTAssertNil(sut.selectedCategory)
        XCTAssertEqual(repo.insertCallCount, 0)
    }

    @MainActor
    func test_submit_whenInsertSucceeds_returnsTrue_clearsFeedback_insertsTransaction() {
        let repo = TestTransactionRepository()
        let sut = AddTransactionViewModel(transactionRepository: repo, selectedType: .expense)
        let category = Category(type: .expense)
        sut.amount = 12.34
        sut.note = "Lunch"
        sut.date = Date(timeIntervalSince1970: 1_000)
        sut.selectedCategory = category

        let ok = sut.submit()

        XCTAssertTrue(ok)
        XCTAssertEqual(repo.insertCallCount, 1)
        XCTAssertNil(sut.persistenceFeedback)
        XCTAssertEqual(repo.transactions.count, 1)
        XCTAssertEqual(repo.transactions[0].amount, 12.34, accuracy: 0.000_001)
        XCTAssertEqual(repo.transactions[0].note, "Lunch")
        XCTAssertEqual(repo.transactions[0].type, .expense)
        XCTAssertEqual(repo.transactions[0].category?.id, category.id)
    }

    @MainActor
    func test_submit_whenInsertFails_returnsFalse_setsPersistenceFeedback() {
        let repo = TestTransactionRepository()
        repo.insertError = TestError.any
        let sut = AddTransactionViewModel(transactionRepository: repo, selectedType: .expense)
        sut.amount = 10
        sut.selectedCategory = Category(type: .expense)

        let ok = sut.submit()

        XCTAssertFalse(ok)
        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.addTransaction)
    }

    @MainActor
    func test_recentNotes_whenNoCategory_returnsEmpty() {
        let repo = TestTransactionRepository()
        let sut = AddTransactionViewModel(transactionRepository: repo, selectedType: .expense)
        sut.selectedCategory = nil

        XCTAssertEqual(sut.recentNotes(), [])
        XCTAssertEqual(repo.fetchRecentNotesCallCount, 0)
    }

    @MainActor
    func test_recentNotes_whenRepoReturnsNotes_returnsThoseNotes() {
        let category = Category(type: .expense)
        let repo = TestTransactionRepository(transactions: [
            TransactionItem(note: "A", date: Date(timeIntervalSince1970: 3), category: category),
            TransactionItem(note: "B", date: Date(timeIntervalSince1970: 2), category: category),
            TransactionItem(note: "A", date: Date(timeIntervalSince1970: 1), category: category),
        ])
        let sut = AddTransactionViewModel(transactionRepository: repo, selectedType: .expense)
        sut.selectedCategory = category

        let notes = sut.recentNotes(limit: 10)

        XCTAssertEqual(repo.fetchRecentNotesCallCount, 1)
        XCTAssertEqual(notes, ["A", "B"])
    }

    @MainActor
    func test_recentNotes_whenRepoThrows_setsFeedback_andReturnsEmpty() {
        let category = Category(type: .expense)
        let repo = TestTransactionRepository()
        repo.recentNotesError = TestError.any
        let sut = AddTransactionViewModel(transactionRepository: repo, selectedType: .expense)
        sut.selectedCategory = category

        let notes = sut.recentNotes()

        XCTAssertEqual(notes, [])
        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.loadRecentNotes)
    }
}
