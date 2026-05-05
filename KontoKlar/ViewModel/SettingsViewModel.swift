import Foundation
import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selectedCurrency: Currency = .usd

    private let appVM: AppViewModel
    private let onNavigate: (SettingsNavigation) -> Void

    init(appVM: AppViewModel, onNavigate: @escaping (SettingsNavigation) -> Void) {
        self.appVM = appVM
        self.onNavigate = onNavigate
        syncFromAppSettings()
    }

    func syncFromAppSettings() {
        if let currency = Currency.allCases.first(where: { $0.symbol == appVM.currencySymbol }) {
            selectedCurrency = currency
        } else {
            selectedCurrency = .usd
        }
    }

    func onCurrencyChanged() {
        appVM.currencySymbol = selectedCurrency.symbol
        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
    }

    func openTransactions() {
        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
        onNavigate(.transactions)
    }

    func openCategories() {
        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
        onNavigate(.categories)
    }
}

enum SettingsNavigation: Hashable {
    case transactions
    case categories
}
