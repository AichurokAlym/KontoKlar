import SwiftData
import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var deps: AppDependencies
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryStore: CategoryStore
    
    @StateObject private var vm: CategoryListViewModel
    
    init(viewModel: CategoryListViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            List {
                let filtered = vm.categoriesForSelectedType()
                if filtered.isEmpty {
                    EmptyStateCard(preset: .categoriesSettingsListEmpty)
                } else {
                    ForEach(filtered, id: \.id) { category in
                        HStack {
                            Image(systemName: category.icon)
                                .font(.system(size: 15))
                                .foregroundColor(Color(.black))
                                .frame(width: 30, height: 30)
                                .background(Color(category.color))
                                .cornerRadius(7.5)
                            Text(category.localizedName)
                                .foregroundColor(Color("colorBalanceText"))
                        }
                    }
                    .onDelete(perform: { indexSet in
                        vm.delete(at: indexSet)
                        playFeedbackHaptic(appVM.selectedFeedbackHaptic)
                    })
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("colorBG"))
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: AddCategoryView(viewModel: deps.makeAddCategoryViewModel(initialType: vm.selectedType)),
                    label: {
                    Image(systemName: "plus")
                        .accessibilityLabel("New category")
                })
            }
            ToolbarItem(placement: .principal) {
                Picker("Type", selection: $vm.selectedType) {
                    ForEach(CategoryType.allCases, id: \.self) { type in
                        Text(type.localizedName())
                    }
                } .pickerStyle(.segmented)
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let (container, _) = try! PreviewModelContainer.makeInMemoryWithMultipleCategories()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let transactionRepo = SwiftDataTransactionRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: transactionRepo)
        return NavigationStack {
            CategoryView(viewModel: deps.makeCategoryListViewModel())
                .environmentObject(AppViewModel())
                .environmentObject(deps)
                .environmentObject(deps.categoryStore)
        }
        .modelContainer(container)
    }
}
