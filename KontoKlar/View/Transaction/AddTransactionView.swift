import SwiftData
import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var deps: AppDependencies
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var transactionStore: TransactionStore

    @StateObject private var vm: AddTransactionViewModel
    
    @FocusState private var amountIsFocused: Bool
    @FocusState private var noteIsFocused: Bool
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.zeroSymbol = ""
        return formatter
    }()
    
    init(viewModel: AddTransactionViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Section {
                        TextField(vm.selectedType == .expense ? "-100 \(appVM.currencySymbol)" : "+100 \(appVM.currencySymbol)", value: $vm.amount, formatter: formatter)
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
                        TextField("Note", text: $vm.note)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color("colorBalanceBG"))
                            .cornerRadius(10)
                            .focused($noteIsFocused)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                let notes = vm.recentNotes()
                                ForEach(notes.reversed(), id: \.self) { note in
                                    Button {
                                        vm.note = note
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
                        Picker("Category type", selection: $vm.selectedType) {
                            ForEach(CategoryType.allCases, id: \.self) { type in
                                Text(type.localizedName())
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("colorBalanceBG"))
                        .cornerRadius(10)
                        .onChange(of: vm.selectedType) { _, _ in
                            withAnimation() {
                                vm.onTypeChanged()
                            }
                            
                        }
                        
                        HStack {
                            NavigationLink(
                                destination: PickerCategoryView(
                                    selected: $vm.selectedCategory,
                                    viewModel: deps.makePickerCategoryViewModel(initialType: vm.selectedType)
                                ),
                                label: {
                                if vm.selectedCategory == nil {
                                    HStack {
                                        Spacer()
                                        Text("?")
                                            .font(.system(size: 15))
                                            .frame(width: 30, height: 30)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10, style: .circular)
                                                    .strokeBorder(Color(Colors.mainText))
                                            }
                                        
                                        Text("Select a category")
                                        Spacer()
                                    }
                                    .font(Font.subheadline)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(Colors.colorPickerBG))
                                    .cornerRadius(10)
                                } else {
                                    HStack {
                                        Text("Category:")
                                            .font(.headline)
                                        Spacer()
                                        Image(systemName: vm.selectedCategory?.icon ?? "")
                                            .font(.system(size: 15))
                                            .foregroundColor(.black)
                                            .frame(width: 30, height: 30)
                                            .background(Color(vm.selectedCategory?.color ?? Colors.colorBlue))
                                            .cornerRadius(7.5)
                                        Text(vm.selectedCategory?.name ?? "")
                                            .font(.headline)
                                            .fontWeight(.light)
                                    }
                                    .padding(5)
                                }
                            })
                            .foregroundColor(Color(Colors.mainText))
                            .padding(10)
                            .background(Color(Colors.colorBalanceBG))
                            .cornerRadius(10)
                        }
                    } header: {
                        Text("Purpose:")
                            .font(.caption).textCase(.uppercase)
                            .padding(.leading, 10)
                    }
                    
                    Section {
                        HStack {
                            DatePicker(NSLocalizedString("Date", comment: ""), selection: $vm.date, displayedComponents: .date)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("colorBalanceBG"))
                        .cornerRadius(10)
                    } header: {
                        Text(NSLocalizedString("Enter date:", comment: ""))
                            .font(.caption).textCase(.uppercase)
                            .padding(.leading, 10)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
                
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color("colorBG"))
            .navigationBarTitle(NSLocalizedString("Addendum", comment: ""), displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(NSLocalizedString("Done", comment: "")) {
                        amountIsFocused = false
                        noteIsFocused = false
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                        dismiss()
                    } label: {
                        Text(NSLocalizedString("Cancel", comment: ""))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if vm.submit() {
                            playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                            transactionStore.reload()
                            dismiss()
                        }
                    } label: {
                        Text(NSLocalizedString("Add", comment: ""))
                    }
                    .alert(NSLocalizedString("Please select a category", comment: ""), isPresented: $vm.alertCategory) {
                        Button(NSLocalizedString("Okay", comment: ""), role: .cancel) { }
                    }
                    .alert(NSLocalizedString("Please enter amount", comment: ""), isPresented: $vm.alertAmount) {
                        Button(NSLocalizedString("Okay", comment: ""), role: .cancel) { }
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
    
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        let (container, _) = try! PreviewModelContainer.makeInMemoryWithMultipleCategories()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let transactionRepo = SwiftDataTransactionRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: transactionRepo)
        return AddTransactionView(
            viewModel: AddTransactionViewModel(transactionRepository: transactionRepo, selectedType: .expense)
        )
        .modelContainer(container)
        .environmentObject(AppViewModel())
        .environmentObject(deps)
    }
}
