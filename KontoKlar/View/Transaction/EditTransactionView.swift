import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var deps: AppDependencies
    
    @StateObject private var vm: EditTransactionViewModel
    
    @Bindable var selectedTransaction: TransactionItem
    
    @FocusState private var amountIsFocused: Bool
    @FocusState private var noteIsFocused: Bool
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    init(viewModel: EditTransactionViewModel, selectedTransaction: TransactionItem) {
        _vm = StateObject(wrappedValue: viewModel)
        self.selectedTransaction = selectedTransaction
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                Section {
                    TextField(selectedTransaction.type == .expense ? "-100 \(appVM.currencySymbol)" : "+100 \(appVM.currencySymbol)", value: $selectedTransaction.amount, formatter: formatter)
                        .font(.title3)
                        .keyboardType(appVM.roundingNumbers ? .numberPad : .decimalPad)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("colorBalanceBG"))
                        .cornerRadius(10)
                        .padding(.bottom, 15)
                        .focused($amountIsFocused)
                } header: {
                    Text("Enter amount:")
                        .font(.caption).textCase(.uppercase)
                        .padding(.leading, 10)
                }
                .onTapGesture {
                    amountIsFocused = true
                }
                
                Section {
                    TextField("Note", text: $selectedTransaction.note)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("colorBalanceBG"))
                        .cornerRadius(10)
                        .focused($noteIsFocused)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            let notes = vm.recentNotes(for: selectedTransaction.category)
                            
                            ForEach(notes.reversed(), id: \.self) { note in
                                Button {
                                    selectedTransaction.note = note
                                } label: {
                                    Text(String(note.prefix(20)))
                                        .font(Font.caption)
                                        .foregroundColor(Color(.systemGray2))
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                                .strokeBorder(Color(.systemGray2))
                                        )
                                        .padding(.bottom, 10)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                } header: {
                    Text("Enter note:")
                        .font(.caption).textCase(.uppercase)
                        .padding(.leading, 10)
                }
                .onTapGesture {
                    noteIsFocused = true
                }
                
                Section {
                    HStack {
                        DatePicker("Date", selection: $selectedTransaction.date, displayedComponents: .date)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("colorBalanceBG"))
                    .cornerRadius(10)
                } header: {
                    Text("Enter date:")
                        .font(.caption).textCase(.uppercase)
                        .padding(.leading, 10)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 20)
        }
        .navigationBarTitle(NSLocalizedString("Editing", comment: ""), displayMode: .inline)
        .scrollDismissesKeyboard(.interactively)
        .background(Color("colorBG"))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(NSLocalizedString("Done", comment: "")) {
                    amountIsFocused = false
                    noteIsFocused = false
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if vm.save(transaction: selectedTransaction) {
                        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                        dismiss()
                    }
                } label: {
                    Text(NSLocalizedString("Edit", comment: ""))
                }
            }
        }
        .alert("Please enter amount", isPresented: $vm.alertAmount) {
            Button("Okay", role: .cancel) { }
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

struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        let (container, _, transaction) = try! PreviewModelContainer.makeInMemoryWithSampleTransaction()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let transactionRepo = SwiftDataTransactionRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: transactionRepo)
        return EditTransactionView(
            viewModel: EditTransactionViewModel(transactionRepository: transactionRepo),
            selectedTransaction: transaction
        )
        .modelContainer(container)
        .environmentObject(AppViewModel())
        .environmentObject(deps)
    }
}
