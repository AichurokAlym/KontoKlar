import XCTest
@testable import KontoKlar

final class DashboardStatusUseCaseTests: XCTestCase {
    private let sut = DashboardStatsUseCase()

    func test_compute_whenEmpty_returnsZeros() {
        let stats = sut.compute(transactions: [])

        XCTAssertEqual(stats.totalExpenses, 0)
        XCTAssertEqual(stats.totalIncomes, 0)
        XCTAssertEqual(stats.balance, 0)
        XCTAssertEqual(stats.averageDailyExpense, 0)
    }

    func test_compute_whenOnlyExpenses_sumsExpenses_balanceNegative_averagePerUniqueExpenseDay() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let day1Later = cal.date(byAdding: .hour, value: 10, to: day1)!
        let day2 = cal.date(from: DateComponents(year: 2026, month: 1, day: 2))!

        let tx = [
            makeTransaction(amount: 10, type: .expense, date: day1),
            makeTransaction(amount: 5, type: .expense, date: day1Later),
            makeTransaction(amount: 15, type: .expense, date: day2),
        ]

        let stats = sut.compute(transactions: tx)

        XCTAssertEqual(stats.totalExpenses, 30, accuracy: 0.000_001)
        XCTAssertEqual(stats.totalIncomes, 0, accuracy: 0.000_001)
        XCTAssertEqual(stats.balance, -30, accuracy: 0.000_001)
        XCTAssertEqual(stats.averageDailyExpense, 15, accuracy: 0.000_001)
    }

    func test_compute_whenOnlyIncomes_sumsIncomes_balancePositive_averageDailyExpenseZero() {
        let tx = [
            makeTransaction(amount: 100, type: .income),
            makeTransaction(amount: 50, type: .income),
        ]

        let stats = sut.compute(transactions: tx)

        XCTAssertEqual(stats.totalExpenses, 0, accuracy: 0.000_001)
        XCTAssertEqual(stats.totalIncomes, 150, accuracy: 0.000_001)
        XCTAssertEqual(stats.balance, 150, accuracy: 0.000_001)
        XCTAssertEqual(stats.averageDailyExpense, 0, accuracy: 0.000_001)
    }

    func test_compute_whenMixed_sumsBoth_balanceIsIncomeMinusExpense() {
        let tx = [
            makeTransaction(amount: 100, type: .income),
            makeTransaction(amount: 40, type: .expense),
            makeTransaction(amount: 10, type: .expense),
        ]

        let stats = sut.compute(transactions: tx)

        XCTAssertEqual(stats.totalExpenses, 50, accuracy: 0.000_001)
        XCTAssertEqual(stats.totalIncomes, 100, accuracy: 0.000_001)
        XCTAssertEqual(stats.balance, 50, accuracy: 0.000_001)
    }

    func test_compute_averageDailyExpense_countsUniqueDaysOnlyForExpenses() {
        let cal = Calendar(identifier: .gregorian)
        let day1 = cal.date(from: DateComponents(year: 2026, month: 2, day: 1))!
        let day2 = cal.date(from: DateComponents(year: 2026, month: 2, day: 2))!

        let tx = [
            makeTransaction(amount: 100, type: .income, date: day1),
            makeTransaction(amount: 10, type: .expense, date: day1),
            makeTransaction(amount: 30, type: .expense, date: day2),
        ]

        let stats = sut.compute(transactions: tx)

        XCTAssertEqual(stats.averageDailyExpense, 20, accuracy: 0.000_001)
    }

    private func makeTransaction(
        amount: Double,
        type: CategoryType,
        date: Date = Date()
    ) -> TransactionItem {
        TransactionItem(amount: amount, note: "", date: date, type: type, category: nil)
    }

}
