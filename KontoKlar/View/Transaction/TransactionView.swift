import SwiftData
import SwiftUI

struct TransactionView: View {
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var deps: AppDependencies
    @EnvironmentObject var transactionStore: TransactionStore
    @EnvironmentObject var categoryStore: CategoryStore

    @StateObject private var vm: TransactionListViewModel

    init(viewModel: TransactionListViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Menu {
                        ForEach(DashboardDateRange.allCases) { range in
                            Button(range.title) {
                                vm.selectedDateRange = range
                                if range == .custom {
                                    vm.showCustomDateRange = true
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                            Text(vm.selectedDateRange.title)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .font(.subheadline)
                        .foregroundColor(Color("colorBalanceText"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(Colors.colorBalanceBG))
                        .cornerRadius(10)
                    }
                    Spacer()
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color("colorBG"))
            }
            
            if vm.groupedByDate().isEmpty {
                EmptyStateCard(preset: .transactionsListEmpty)
            } else {
                let groupedTransactions = vm.groupedByDate()
                ForEach(groupedTransactions.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                    Section(header: Text(date, style: .date).bold()) {
                        let sortedTransactions = groupedTransactions[date] ?? []
                        
                        ForEach(sortedTransactions, id: \.id) { transaction in
                            if let category = transaction.category {
                                NavigationLink(destination: EditTransactionView(viewModel: deps.makeEditTransactionViewModel(), selectedTransaction: transaction)) {
                                    transactionRow(transaction: transaction, category: category)
                                }
                            }
                        }
                        .onDelete(perform: { indexSet in
                            vm.delete(at: indexSet, from: sortedTransactions)
                            playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                        })
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("colorBG"))
        .navigationBarTitle(NSLocalizedString("Transactions", comment: ""), displayMode: .inline)
        .onDisappear {
            // Ensure Home dashboard reflects changes done here (delete/edit).
            transactionStore.reload()
            categoryStore.reload()
        }
        .sheet(isPresented: $vm.showCustomDateRange) {
            NavigationStack {
                Form {
                    DatePicker(NSLocalizedString("Start", comment: ""), selection: $vm.customStartDate, displayedComponents: .date)
                    DatePicker(NSLocalizedString("End", comment: ""), selection: $vm.customEndDate, displayedComponents: .date)
                }
                .navigationTitle(NSLocalizedString("Custom range", comment: ""))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(NSLocalizedString("Done", comment: "")) {
                            vm.showCustomDateRange = false
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isFilteredEmpty {
                    EditButton().disabled(true)
                } else {
                    EditButton()
                }
            }
        }
        .alert(
            vm.persistenceFeedback?.localizedTitle ?? NSLocalizedString("Could not complete operation", comment: ""),
            isPresented: Binding(
                get: { vm.persistenceFeedback != nil },
                set: { if !$0 { vm.clearPersistenceError() } }
            )
        ) {
            Button(NSLocalizedString("Okay", comment: ""), role: .cancel) {
                vm.clearPersistenceError()
            }
        } message: {
            Text(vm.persistenceFeedback?.localizedMessage ?? "")
        }
    }

    @ViewBuilder
    private func transactionRow(transaction: TransactionItem, category: Category) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack {
                    Divider()
                        .foregroundColor(Color(category.color))
                        .frame(width: 5, height: 72)
                        .background(Color(category.color))
                } .padding(.trailing, 3)
                
                VStack(alignment: .leading) {
                    HStack {
                        if transaction.type == CategoryType.expense {
                            Text("-\(transaction.amount.formattedWithSeparatorAndCurrency(roundingNumbers: appVM.roundingNumbers)) \(appVM.currencySymbol)")
                                .font(.title3).bold()
                        } else {
                            Text("\(transaction.amount.formattedWithSeparatorAndCurrency(roundingNumbers: appVM.roundingNumbers)) \(appVM.currencySymbol)")
                                .font(.title3).bold()
                        }
                        Spacer()
                        HStack {
                            Text(category.localizedName)
                                .foregroundColor(Color("colorBalanceText")).textCase(.uppercase)
                                .font(.caption)
                                .multilineTextAlignment(.trailing)
                                .dynamicTypeSize(.small)
                                .padding(0)
                            Image(systemName: category.icon)
                                .font(.caption).dynamicTypeSize(.small)
                                .foregroundColor(.black)
                                .frame(width: 20, height: 20)
                                .background(Color(category.color))
                                .cornerRadius(5)
                                .padding(0)
                        } .padding(0)
                    }
                    HStack {
                        Text(transaction.note)
                            .foregroundColor(Color(.gray)).textCase(.uppercase)
                            .font(.subheadline).dynamicTypeSize(.small)
                        Spacer()
                        Text(category.type.localizedName())
                            .foregroundColor(Color(.gray)).textCase(.uppercase)
                            .font(.subheadline).dynamicTypeSize(.small)
                    }
                }    .padding(.leading, 10)
            }
        }
        .padding(.vertical, 5)
        .frame(height: 50)
    }
    
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        let (container, _, _) = try! PreviewModelContainer.makeInMemoryWithSampleTransaction()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let transactionRepo = SwiftDataTransactionRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: transactionRepo)
        return NavigationStack {
            TransactionView(viewModel: deps.makeTransactionListViewModel())
                .environmentObject(AppViewModel())
                .environmentObject(deps)
                .environmentObject(deps.transactionStore)
                .environmentObject(deps.categoryStore)
        }
        .modelContainer(container)
    }
}
