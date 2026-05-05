import Foundation

extension Double {
    func formattedWithSeparatorAndCurrency(roundingNumbers: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if roundingNumbers == true {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }
        let formattedNumber = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return formattedNumber
    }
}
