import Foundation
import Combine

struct GroupTransactionsByDateUseCase {
    func group(_ transactions: [TransactionItem]) -> [Date: [TransactionItem]] {
        var grouped: [Date: [TransactionItem]] = [:]
        let calendar = Calendar.current

        for transaction in transactions {
            let day = calendar.startOfDay(for: transaction.date)
            grouped[day, default: []].append(transaction)
        }

        return grouped
    }
}
