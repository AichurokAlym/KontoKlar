import SwiftData
import SwiftUI

struct PickerCategoryView: View {
    @EnvironmentObject var deps: AppDependencies
    @Environment(\.dismiss) var dismiss
    
    @Binding var selected: Category?
    @StateObject private var vm: PickerCategoryViewModel
    
    init(selected: Binding<Category?>, viewModel: PickerCategoryViewModel) {
        self._selected = selected
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            let categories = vm.categoriesForSelectedType()
            if categories.isEmpty {
                VStack {
                    VStack {
                        EmptyStateCard(preset: .pickerNoCategories)
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    HStack {
                        NavigationLink(
                            destination: AddCategoryView(viewModel: deps.makeAddCategoryViewModel(initialType: vm.selectedType)),
                            label: {
                            HStack {
                                Text("Create category")
                            }
                        })
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color(Colors.colorBalanceBG))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(categories, id: \.id) { category in
                        Button {
                            selected = category
                            dismiss()
                        } label: {
                            HStack {
                                HStack {
                                    Divider()
                                        .foregroundColor(Color(category.color))
                                        .frame(width: 5, height: 50)
                                        .background(Color(category.color))
                                }
                                Image(systemName: category.icon)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    .frame(width: 30, height: 30)
                                    .background(Color(category.color))
                                    .cornerRadius(7.5)
                                    .padding(0)
                                
                                Text(category.localizedName)
                                    .font(.headline)
                                    .fontWeight(.light)
                                    .foregroundColor(Color(Colors.mainText))
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(Colors.colorBalanceBG))
                        
                        Divider()
                    }
                }
                .cornerRadius(10)
                .padding()
            }
        }
        .background(Color(Colors.mainBG))
        .navigationTitle(NSLocalizedString("Categories", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
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

struct PickerCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let (container, categories) = try! PreviewModelContainer.makeInMemoryWithMultipleCategories()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let transactionRepo = SwiftDataTransactionRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: transactionRepo)
        let expenseCategory = categories.first(where: { $0.type == .expense }) ?? categories[0]
        return PickerCategoryView(
            selected: .constant(Optional(expenseCategory)),
            viewModel: deps.makePickerCategoryViewModel(initialType: .expense)
        )
        .modelContainer(container)
        .environmentObject(deps)
    }
}
