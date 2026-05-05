import Foundation
import SwiftUI
import Combine

final class AppViewModel: ObservableObject {
    @AppStorage("playFeedbackHaptic") var selectedFeedbackHaptic: Bool = true
    @AppStorage("hasRunBefore") var hasRunBefore: Bool = false
    @AppStorage("currencySymbol") var currencySymbol: String = "USD"
    @AppStorage("roundingNumbers") var roundingNumbers: Bool = false
    
    // Budget & goals
    @AppStorage("monthlyBudget") var monthlyBudget: Double = 0
    @AppStorage("savingsGoal") var savingsGoal: Double = 0
}
