import SwiftData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var deps: AppDependencies
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var categoryStore: CategoryStore
    @EnvironmentObject var transactionStore: TransactionStore
    @StateObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private let adaptive =
    [
        GridItem(.adaptive(minimum: 165))
    ]
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        Menu {
                            ForEach(DashboardDateRange.allCases) { range in
                                Button(range.title) {
                                    viewModel.dateRangeSelection.range = range
                                    if range == .custom {
                                        viewModel.showCustomDateRange = true
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(Colors.colorBlack))
                                    .frame(width: 30, height: 30)
                                    .background(Color(Colors.colorPurple1))
                                    .cornerRadius(7.5)
                                
                                Text(viewModel.dateRangeSelection.range.title)
                                    .font(.subheadline)
                                    .foregroundColor(Color("colorBalanceText"))
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(Color("colorBalanceText"))
                                    .opacity(0.6)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(Colors.colorBalanceBG))
                            .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 20)
                    
                    LazyVGrid(columns: adaptive) {
                        
                        BalanceView(amount: viewModel.balance, curren: viewModel.currencySymbol, type: NSLocalizedString("Balance", comment: "Balance"), icon: "equal.circle", iconBG: Color(Colors.colorBlue))
                        
                        BalanceView(amount: viewModel.averageDailyExpense, curren: viewModel.currencySymbol, type: NSLocalizedString("Expense average", comment: "Expense average"), icon: "plusminus.circle", iconBG: Color(Colors.colorYellow))
                        
                        BalanceView(amount: viewModel.totalIncomes, curren: viewModel.currencySymbol, type: NSLocalizedString("Income", comment: "Income"), icon: "plus.circle", iconBG: Color(Colors.colorGreen))
                        
                        BalanceView(amount: viewModel.totalExpenses, curren: viewModel.currencySymbol, type: NSLocalizedString("Expense", comment: "Expense"), icon: "minus.circle", iconBG: Color(Colors.colorRed))
                        
                    }
                   .padding(.horizontal)
                    
                    // Budget & Goal progress (current month)
                    if viewModel.monthlyBudget > 0 || viewModel.savingsGoal > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            if viewModel.monthlyBudget > 0 {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Monthly budget")
                                            .font(.caption).textCase(.uppercase)
                                            .foregroundColor(Color(.gray))
                                        Spacer()
                                        Text("\(viewModel.currentMonthExpenses.formattedWithSeparatorAndCurrency(roundingNumbers: appVM.roundingNumbers)) \(appVM.currencySymbol) / \(viewModel.monthlyBudget.formattedWithSeparatorAndCurrency(roundingNumbers: appVM.roundingNumbers)) \(appVM.currencySymbol)")
                                            .font(.caption2)
                                            .foregroundColor(Color(.gray))
                                    }
                                    ProgressView(value: viewModel.budgetProgress)
                                }
                            }
                            
                            if viewModel.savingsGoal > 0 {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Savings goal")
                                            .font(.caption).textCase(.uppercase)
                                            .foregroundColor(Color(.gray))
                                        Spacer()
                                        Text("\(max(viewModel.balance, 0).formattedWithSeparatorAndCurrency(roundingNumbers: appVM.roundingNumbers)) \(appVM.currencySymbol) / \(viewModel.savingsGoal.formattedWithSeparatorAndCurrency(roundingNumbers: appVM.roundingNumbers)) \(appVM.currencySymbol)")
                                            .font(.caption2)
                                            .foregroundColor(Color(.gray))
                                    }
                                    ProgressView(value: viewModel.savingsProgress)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(Colors.colorBalanceBG))
                        .cornerRadius(10)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 6)
                    }
                    
                    Picker("Тип", selection: $viewModel.selectedCategoryType) {
                        ForEach(CategoryType.allCases, id: \.self) { type in
                            Text(type.localizedName())
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(Colors.colorBalanceBG))
                    .cornerRadius(10)
                    .padding(.horizontal, 15)
                    
                    VStack(spacing: 0) {
                        let filteredCategoriesArray = viewModel.categoriesForSelectedTypeSortedByAmount()
                        
                        if filteredCategoriesArray.isEmpty {
                            EmptyStateCard(preset: .homeCategoryStripEmpty)
                        } else {
                            
                            ForEach(filteredCategoriesArray, id: \.self) { category in
                                let totalAmount = viewModel.amountForCategory(category, type: viewModel.selectedCategoryType)
                                Button {
                                    viewModel.openCategoryTransactions(category: category)
                                } label: {
                                    CategoryItemView(categoryColor: category.color, categoryIcon: category.icon, categoryName: category.name, totalAmount: totalAmount, currencySymbol: appVM.currencySymbol)
                                }
                            }
                        }
                    }
                    .cornerRadius(10)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 100)
                }
                .contentMargins(.top, 0, for: .scrollContent)
                
                
                HStack {
                    Button {
                        viewModel.openAddTransaction()
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 55, height: 55)
                                .foregroundColor(Color("colorBalanceText"))
                            Image(systemName: "plus")
                                .foregroundColor(Color("colorBG"))
                                .font(.system(size: 30))
                        }
                    }
                }
                .padding(.all, 25)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.openSettings()
                        } label: {
                            Image(systemName: "gearshape")
                                .accessibilityLabel("Settings")
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("KontoKlar")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("colorBalanceText"))
                    }
                }
            }
            .background(Color("colorBG"))
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .settings:
                    SettingView()
                        .environmentObject(settingsVM)
                case .settingsTransactions:
                    TransactionView(viewModel: deps.makeTransactionListViewModel())
                case .settingsCategories:
                    CategoryView(viewModel: deps.makeCategoryListViewModel())
                case .categoryTransactions(let categoryId):
                    if let category = viewModel.categoryForRoute(id: categoryId) {
                        TransactionCategoryView(viewModel: deps.makeTransactionCategoryViewModel(category: category))
                    } else {
                        Text("Category not found")
                    }
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
        .sheet(isPresented: $viewModel.showCustomDateRange) {
            NavigationStack {
                Form {
                    DatePicker("Start", selection: $viewModel.dateRangeSelection.customStartDate, displayedComponents: .date)
                    DatePicker("End", selection: $viewModel.dateRangeSelection.customEndDate, displayedComponents: .date)
                }
                .navigationTitle("Custom range")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            viewModel.showCustomDateRange = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddTransaction, onDismiss: {
            viewModel.refresh()
        }) {
            AddTransactionView(viewModel: deps.makeAddTransactionViewModel(initialType: viewModel.selectedCategoryType))
        }
        .alert(
            categoryStore.persistenceFeedback?.localizedTitle
                ?? transactionStore.persistenceFeedback?.localizedTitle
                ?? NSLocalizedString("Could not complete operation", comment: ""),
            isPresented: Binding(
                get: {
                    categoryStore.persistenceFeedback != nil
                        || transactionStore.persistenceFeedback != nil
                },
                set: { isPresented in
                    if !isPresented {
                        categoryStore.clearPersistenceError()
                        transactionStore.clearPersistenceError()
                    }
                }
            )
        ) {
            Button(NSLocalizedString("Okay", comment: ""), role: .cancel) {
                categoryStore.clearPersistenceError()
                transactionStore.clearPersistenceError()
            }
        } message: {
            Text(
                categoryStore.persistenceFeedback?.localizedMessage
                    ?? transactionStore.persistenceFeedback?.localizedMessage
                    ?? ""
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let (container, _, _) = try! PreviewModelContainer.makeInMemoryWithSampleTransaction()
        let context = container.mainContext
        let categoryRepo = SwiftDataCategoryRepository(context: context)
        let transactionRepo = SwiftDataTransactionRepository(context: context)
        let deps = AppDependencies(categoryRepository: categoryRepo, transactionRepository: transactionRepo)
        let appVM = AppViewModel()
        return HomeView(viewModel: HomeViewModel(appVM: appVM, categoryStore: deps.categoryStore, transactionStore: deps.transactionStore))
            .modelContainer(container)
            .environmentObject(appVM)
            .environmentObject(deps)
            .environmentObject(SettingsViewModel(appVM: appVM) { _ in })
            .environmentObject(deps.categoryStore)
            .environmentObject(deps.transactionStore)
    }
}
