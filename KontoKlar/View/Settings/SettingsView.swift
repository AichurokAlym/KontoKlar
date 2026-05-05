import SwiftUI

struct SettingView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var deps: AppDependencies
    @EnvironmentObject var vm: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    private let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f
    }()
    
    var body: some View {
        VStack {
            List {
                Section {
                    Button {
                        vm.openTransactions()
                    } label: {
                        HStack {
                            Image(systemName: "clock.circle")
                                .foregroundColor(Color("colorBlack"))
                                .frame(width: 30, height: 30)
                                .background(Color("colorYellow"))
                                .cornerRadius(7.5)
                            Text("Transactions")
                                .foregroundColor(Color("colorBalanceText"))
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color("colorBalanceText"))
                                .opacity(0.5)
                        }
                    }
                    
                    Button {
                        vm.openCategories()
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.circle")
                                .foregroundColor(Color("colorBlack"))
                                .frame(width: 30, height: 30)
                                .background(Color("colorBlue"))
                                .cornerRadius(7.5)
                            Text("Categories")
                                .foregroundColor(Color("colorBalanceText"))
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color("colorBalanceText"))
                                .opacity(0.5)
                        }
                    }
                } header: {
                    Text("Data")
                }
                
                Section(header: Text("Application")) {
                    HStack {
                        Text(vm.selectedCurrency.symbol)
                            .foregroundColor(Color("colorBlack"))
                            .frame(width: 30, height: 30)
                            .background(Color("colorBrown1"))
                            .cornerRadius(7.5)
                        Picker("Currency", selection: $vm.selectedCurrency) {
                            ForEach(Currency.sortedCases, id: \.self) { currency in
                                Text(currency.rawValue)
                                    .tag(currency)
                            }
                        }
                    }
                    HStack {
                        Image(systemName: appVM.selectedFeedbackHaptic ? "iphone.radiowaves.left.and.right.circle" : "iphone.slash.circle")
                            .foregroundColor(Color("colorBlack"))
                            .frame(width: 30, height: 30)
                            .background(Color("colorPurple2"))
                            .cornerRadius(7.5)
                        Toggle("Vibration", isOn: $appVM.selectedFeedbackHaptic)
                    }
                    
                    HStack {
                        Text(appVM.roundingNumbers ? "0" : "0.0")
                            .foregroundColor(Color("colorBlack"))
                            .frame(width: 30, height: 30)
                            .background(Color(Colors.colorGreen))
                            .cornerRadius(7.5)
                        Toggle("Rounding numbers", isOn: $appVM.roundingNumbers)
                    }
                }
                
                Section(header: Text("Budget & Goals")) {
                    HStack {
                        Image(systemName: "chart.pie")
                            .foregroundColor(Color("colorBlack"))
                            .frame(width: 30, height: 30)
                            .background(Color("colorGray1"))
                            .cornerRadius(7.5)
                        Text("Monthly budget")
                            .foregroundColor(Color("colorBalanceText"))
                        Spacer()
                        TextField("0", value: $appVM.monthlyBudget, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 110)
                    }
                    
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(Color("colorBlack"))
                            .frame(width: 30, height: 30)
                            .background(Color("colorYellow"))
                            .cornerRadius(7.5)
                        Text("Savings goal")
                            .foregroundColor(Color("colorBalanceText"))
                        Spacer()
                        TextField("0", value: $appVM.savingsGoal, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 110)
                    }
                }
                
                Section {
                    Button {
                        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                        openURL(URL(string: NSLocalizedString("https://t.me/AichurokCholoeva", comment: "https://t.me/AichurokCholoeva"))!)
                    } label: {
                        HStack {
                            Image(systemName: "envelope.circle")
                                .foregroundColor(Color("colorBlack"))
                                .frame(width: 30, height: 30)
                                .background(Color("colorGray1"))
                                .cornerRadius(7.5)
                            Text("Write to the developer")
                                .foregroundColor(Color("colorBalanceText"))
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color("colorBalanceText"))
                                .opacity(0.5)
                        }
                    }
                } header: {
                    Text("Feedback")
                }
            }
            
            VStack {
                Image(systemName: "exclamationmark.shield")
                Text("App version: 1.1.7")
            }
            .font(.caption2).bold()
            .padding()
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(Color("colorBG"))
        .onAppear {
            vm.syncFromAppSettings()
        }
        .onChange(of: vm.selectedCurrency) { _, _ in
            vm.onCurrencyChanged()
        }
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(AppViewModel())
    }
}
