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
                return "The list of transactions is currently empty,"
            case .categoriesSettingsListEmpty:
                return "The list of categories is currently empty,"
            case .pickerNoCategories:
                return "There are currently no categories."
            }
        }

        var messageLine2: String {
            switch self {
            case .homeCategoryStripEmpty, .transactionsListEmpty:
                return "Please add transaction."
            case .categoriesSettingsListEmpty:
                return "Please add category."
            case .pickerNoCategories:
                return "Please add."
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
                Text("KontoKlar")
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
