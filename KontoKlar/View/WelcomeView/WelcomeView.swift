import SwiftData
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var categoryStore: CategoryStore
    
    @State private var selectedCurrency: Currency = .usd
    @State private var createCategories: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {
                        VStack {
                            Spacer(minLength: 100)
                            Image("icon")
                                .resizable()
                                .frame(width: 100, height: 100)
                            Spacer(minLength: 20)
                            Text("KontoKlar")
                                .foregroundColor(.gray).bold()
                                .font(.largeTitle)
                            Spacer(minLength: 50)
                        }
                        Section {
                            HStack {
                                Text(selectedCurrency.symbol)
                                    .foregroundColor(Color("colorBlack"))
                                    .frame(width: 30, height: 30)
                                    .background(Color("colorBrown1"))
                                    .cornerRadius(7.5)
                                Text("Currency")
                                Spacer()
                                Picker("Currency", selection: $selectedCurrency) {
                                    ForEach(Currency.sortedCases, id: \.self) { currency in
                                        Text(currency.rawValue)
                                            .tag(currency)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color(Colors.colorBalanceBG))
                            .cornerRadius(12.5)
                        } header: {
                            HStack {
                                Text("Initial application setup").font(.caption).fontWeight(.light).padding(.leading).textCase(.uppercase)
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Text(appVM.roundingNumbers ? "0" : "0.0")
                                .foregroundColor(Color("colorBlack"))
                                .frame(width: 30, height: 30)
                                .background(Color(Colors.colorGreen))
                                .cornerRadius(7.5)
                            Toggle("Rounding numbers", isOn: $appVM.roundingNumbers)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(Colors.colorBalanceBG))
                        .cornerRadius(12.5)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Toggle("Basic categories", isOn: $createCategories)
                                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                            }
                            HStack {
                                Image(systemName: "exclamationmark.shield")
                                Text("Note: Enabling this feature will create base categories for expenses and income.")
                            }
                            .font(.subheadline)
                            .fontWeight(.ultraLight)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .background(Color(Colors.colorBalanceBG))
                        .cornerRadius(12.5)
                    }
                }
                VStack {
                    Button {
                        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                        appVM.currencySymbol = selectedCurrency.symbol
                        if createCategories {
                            categoryStore.createDefaultCategoriesIfNeeded()
                            if categoryStore.persistenceFeedback != nil {
                                return
                            }
                        }
                        appVM.hasRunBefore = true
                    } label: {
                        HStack(alignment: .center) {
                            Text("Continue")
                                .frame(maxWidth: .infinity, maxHeight: 20)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white).bold()
                                .cornerRadius(15)
                        }
                    }
                }
            }
            .padding(15)
            .background(Color(Colors.mainBG))
        }
        .onChange(of: selectedCurrency) { _, newCurrency in
            appVM.currencySymbol = newCurrency.symbol
            playFeedbackHaptic(appVM.selectedFeedbackHaptic)
        }
        .alert(
            categoryStore.persistenceFeedback?.localizedTitle ?? NSLocalizedString("Could not complete operation", comment: ""),
            isPresented: Binding(
                get: { categoryStore.persistenceFeedback != nil },
                set: { if !$0 { categoryStore.clearPersistenceError() } }
            )
        ) {
            Button(NSLocalizedString("Okay", comment: ""), role: .cancel) {
                categoryStore.clearPersistenceError()
            }
        } message: {
            Text(categoryStore.persistenceFeedback?.localizedMessage ?? "")
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! PreviewModelContainer.makeInMemoryEmpty()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: PreviewTransactionRepository())
        return WelcomeView()
            .modelContainer(container)
            .environmentObject(AppViewModel())
            .environmentObject(deps.categoryStore)
    }
}
