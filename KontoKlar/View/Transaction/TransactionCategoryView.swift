import SwiftData
import SwiftUI

struct TransactionCategoryView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var deps: AppDependencies
    @EnvironmentObject var transactionStore: TransactionStore
    @EnvironmentObject var categoryStore: CategoryStore
    @StateObject private var vm: TransactionCategoryViewModel
    
    init(viewModel: TransactionCategoryViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List {
            if vm.transactions.isEmpty {
                EmptyStateCard(preset: .transactionsListEmpty)
            } else {
                let groupedTransactions = vm.groupedByDate()
                ForEach(groupedTransactions.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                    Section(header: Text(date, style: .date).bold()) {
                        let sortedTransactions = groupedTransactions[date] ?? []
                        
                        ForEach(sortedTransactions, id: \.id) { transaction in
                            NavigationLink(destination: EditTransactionView(viewModel: deps.makeEditTransactionViewModel(), selectedTransaction: transaction)) {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        HStack {
                                            Divider()
                                                .foregroundColor(Color(vm.category.color))
                                                .frame(width: 5, height: 72)
                                                .background(Color(vm.category.color))
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
                                                    Text(vm.category.localizedName)
                                                        .foregroundColor(Color("colorBalanceText")).textCase(.uppercase)
                                                        .font(.caption)
                                                        .multilineTextAlignment(.trailing)
                                                        .dynamicTypeSize(.small)
                                                        .padding(0)
                                                    Image(systemName: vm.category.icon)
                                                        .font(.caption).dynamicTypeSize(.small)
                                                        .foregroundColor(.black)
                                                        .frame(width: 20, height: 20)
                                                        .background(Color(vm.category.color))
                                                        .cornerRadius(5)
                                                        .padding(0)
                                                } .padding(0)
                                            }
                                            HStack {
                                                Text(transaction.note)
                                                    .foregroundColor(Color(.gray)).textCase(.uppercase)
                                                    .font(.subheadline).dynamicTypeSize(.small)
                                                Spacer()
                                                Text(vm.category.type.localizedName())
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
                        .onDelete(perform: { indexSet in
                            vm.delete(at: indexSet, from: sortedTransactions)
                            playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                            transactionStore.reload()
                            categoryStore.reload()
                        })
                    }
                }
            }
        }
        .navigationTitle(vm.category.localizedName)
        .onDisappear {
            transactionStore.reload()
            categoryStore.reload()
        }
        .background(Color("colorBG"))
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.transactions.isEmpty {
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
}

struct TransactionCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let (container, category, _) = try! PreviewModelContainer.makeInMemoryWithSampleTransaction()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let transactionRepo = SwiftDataTransactionRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: transactionRepo)
        return TransactionCategoryView(viewModel: deps.makeTransactionCategoryViewModel(category: category))
            .modelContainer(container)
            .environmentObject(AppViewModel())
            .environmentObject(deps)
            .environmentObject(deps.transactionStore)
            .environmentObject(deps.categoryStore)
    }
}
