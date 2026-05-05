import SwiftUI

struct EmptyStateCard: View {
    enum Preset {
        case homeCategoryStripEmpty
        case transactionsListEmpty
        case categoriesSettingsListEmpty
        case pickerNoCategories

        var messageLine1: String {
            switch self {
            case .homeCategoryStripEmpty, .transactionsListEmpty:
                return NSLocalizedString("The list of transactions is currently empty,", comment: "")
            case .categoriesSettingsListEmpty:
                return NSLocalizedString("The list of categories is currently empty,", comment: "")
            case .pickerNoCategories:
                return NSLocalizedString("There are currently no categories.", comment: "")
            }
        }

        var messageLine2: String {
            switch self {
            case .homeCategoryStripEmpty, .transactionsListEmpty:
                return NSLocalizedString("Please add transaction.", comment: "")
            case .categoriesSettingsListEmpty:
                return NSLocalizedString("Please add category.", comment: "")
            case .pickerNoCategories:
                return NSLocalizedString("Please add.", comment: "")
            }
        }

        var usesBalancePanelBackground: Bool {
            switch self {
            case .homeCategoryStripEmpty, .pickerNoCategories: return true
            case .transactionsListEmpty, .categoriesSettingsListEmpty: return false
            }
        }
    }

    let preset: Preset

    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Spacer(minLength: 20)
                Image("icon")
                    .resizable()
                    .frame(width: 25, height: 25)
                Spacer()
                Text(NSLocalizedString("KontoKlar", comment: ""))
                    .foregroundColor(.gray).bold()
                    .font(.title)
                Spacer(minLength: 20)

                Text(preset.messageLine1)
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                Text(preset.messageLine2)
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .background(preset.usesBalancePanelBackground ? Color(Colors.colorBalanceBG) : Color.clear)
        }
    }
}
