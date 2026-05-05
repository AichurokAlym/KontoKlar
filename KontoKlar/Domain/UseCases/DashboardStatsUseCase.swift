import Foundation
import Combine

struct DashboardStats {
    let totalExpenses: Double
    let totalIncomes: Double
    let balance: Double
    let averageDailyExpense: Double
}

struct DashboardStatsUseCase {
    func compute(transactions: [TransactionItem]) -> DashboardStats {
        let totalExpenses = transactions
            .filter { $0.type == .expense }
            .reduce(0.0) { $0 + $1.amount }

        let totalIncomes = transactions
            .filter { $0.type == .income }
            .reduce(0.0) { $0 + $1.amount }

        let balance = totalIncomes - totalExpenses

        let averageDailyExpense = computeAverageDailyExpense(
            transactions: transactions,
            totalExpenses: totalExpenses
        )

        return DashboardStats(
            totalExpenses: totalExpenses,
            totalIncomes: totalIncomes,
            balance: balance,
            averageDailyExpense: averageDailyExpense
        )
    }

    private func computeAverageDailyExpense(transactions: [TransactionItem], totalExpenses: Double) -> Double {
        let expenseTransactions = transactions.filter { $0.type == .expense }
        guard !expenseTransactions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let uniqueExpenseDates = Set(expenseTransactions.map { calendar.startOfDay(for: $0.date) })
        let daysWithTransactions = uniqueExpenseDates.count
        guard daysWithTransactions > 0 else { return 0 }

        return totalExpenses / Double(daysWithTransactions)
    }
}
