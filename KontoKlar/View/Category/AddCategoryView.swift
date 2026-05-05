import SwiftData
import SwiftUI

struct AddCategoryView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var categoryStore: CategoryStore
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var nameIsFocused: Bool
    
    @StateObject private var vm: AddCategoryViewModel
    
    init(viewModel: AddCategoryViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Spacer()
                        Image(systemName: vm.selectedImage)
                            .foregroundColor(Color(.black))
                            .font(.system(size: 50))
                            .frame(width: 100, height: 100)
                            .background(Color(vm.selectedColor))
                            .cornerRadius(25)
                        Spacer()
                    } .padding(.bottom, 15)
                    
                    Section {
                        VStack(alignment: .leading) {
                            Picker("Type", selection: $vm.selectedType) {
                                ForEach(CategoryType.allCases, id: \.self) { type in
                                    Text(type.localizedName())
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color("colorBalanceBG"))
                            .cornerRadius(10)
                            .padding(.bottom, 15)
                        }
                    } header: {
                        Text("Select type:")
                            .font(.caption).textCase(.uppercase)
                            .padding(.leading, 10)
                    }
                    
                    Section {
                        VStack(alignment: .leading) {
                            TextField("Name", text: $vm.name)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color("colorBalanceBG"))
                                .cornerRadius(10)
                                .padding(.bottom, 15)
                                .focused($nameIsFocused)
                        }
                    } header: {
                        Text("Enter Name")
                            .font(.caption).textCase(.uppercase)
                            .padding(.leading, 10)
                    }
                    .onTapGesture {
                            nameIsFocused = true
                    }
                    
                    Section {
                        IconPickerView(selectedImage: $vm.selectedImage)
                            .foregroundColor(Color(.black))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color("colorBalanceBG"))
                            .cornerRadius(10)
                            .padding(.bottom, 15)
                    } header: {
                        Text("Choose an icon:")
                            .font(.caption).textCase(.uppercase)
                            .padding(.leading, 10)
                    }
                    Section {
                        ColorPickerView(selectedColor: $vm.selectedColor)
                            .padding(5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color("colorBalanceBG"))
                            .cornerRadius(10)
                        
                    } header: {
                        Text("Choose color:")
                            .font(.caption).textCase(.uppercase)
                            .padding(.leading, 10)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
            }
        }
        .background(Color("colorBG"))
        .navigationBarTitle("Create a category", displayMode: .inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    nameIsFocused = false
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if vm.addCategory() {
                        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                        categoryStore.reload()
                        dismiss()
                    }
                } label: {
                    if vm.name.isEmpty {
                        Text("Add")
                            .foregroundColor(.gray)
                    } else {
                        Text("Add")
                    }
                }
            }
        }
        .alert("Пожалуйста введите название категории", isPresented: $vm.showAlert) {
                Button("Okay", role: .cancel) {
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

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! PreviewModelContainer.makeInMemoryEmpty()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: PreviewTransactionRepository())
        return AddCategoryView(viewModel: AddCategoryViewModel(repository: categoryRepo, selectedType: .expense))
            .modelContainer(container)
            .environmentObject(AppViewModel())
            .environmentObject(deps.categoryStore)
    }
}
