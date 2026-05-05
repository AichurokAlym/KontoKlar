import XCTest
@testable import KontoKlar

final class EditTransactionViewModelTests: XCTestCase {
    @MainActor
    func test_save_whenAmountIsZero_setsAlertAmountAndReturnsFalse() {
        let repo = TestTransactionRepository()
        let sut = EditTransactionViewModel(transactionRepository: repo)
        let transaction = TransactionItem(amount: 0, type: .expense)

        let ok = sut.save(transaction: transaction)

        XCTAssertFalse(ok)
        XCTAssertTrue(sut.alertAmount)
        XCTAssertEqual(repo.saveChangesCallCount, 0)
    }

    @MainActor
    func test_save_whenSaveSucceeds_returnsTrue_clearsFeedback() {
        let repo = TestTransactionRepository()
        let sut = EditTransactionViewModel(transactionRepository: repo)
        let transaction = TransactionItem(amount: 10, type: .expense)

        let ok = sut.save(transaction: transaction)

        XCTAssertTrue(ok)
        XCTAssertEqual(repo.saveChangesCallCount, 1)
        XCTAssertNil(sut.persistenceFeedback)
    }

    @MainActor
    func test_save_whenSaveFails_returnsFalse_setsFeedback() {
        let repo = TestTransactionRepository()
        repo.saveChangesError = TestError.any
        let sut = EditTransactionViewModel(transactionRepository: repo)
        let transaction = TransactionItem(amount: 10, type: .expense)

        let ok = sut.save(transaction: transaction)

        XCTAssertFalse(ok)
        XCTAssertEqual(repo.saveChangesCallCount, 1)
        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.saveTransaction)
    }

    @MainActor
    func test_recentNotes_whenCategoryNil_returnsEmpty() {
        let repo = TestTransactionRepository()
        let sut = EditTransactionViewModel(transactionRepository: repo)

        let notes = sut.recentNotes(for: nil)

        XCTAssertEqual(notes, [])
        XCTAssertEqual(repo.fetchRecentNotesCallCount, 0)
    }

    @MainActor
    func test_recentNotes_whenRepoReturnsNotes_returnsThoseNotes() {
        let category = Category(type: .expense)
        let repo = TestTransactionRepository(transactions: [
            TransactionItem(note: "X", date: Date(timeIntervalSince1970: 2), category: category),
            TransactionItem(note: "Y", date: Date(timeIntervalSince1970: 1), category: category),
        ])
        let sut = EditTransactionViewModel(transactionRepository: repo)

        let notes = sut.recentNotes(for: category)

        XCTAssertEqual(repo.fetchRecentNotesCallCount, 1)
        XCTAssertEqual(notes, ["X", "Y"])
    }

    @MainActor
    func test_recentNotes_whenRepoThrows_setsFeedback_andReturnsEmpty() {
        let category = Category(type: .expense)
        let repo = TestTransactionRepository()
        repo.recentNotesError = TestError.any
        let sut = EditTransactionViewModel(transactionRepository: repo)

        let notes = sut.recentNotes(for: category)

        XCTAssertEqual(notes, [])
        XCTAssertNotNil(sut.persistenceFeedback)
        XCTAssertEqual(sut.persistenceFeedback?.titleKey, PersistenceFeedbackTitle.loadRecentNotes)
    }
}
