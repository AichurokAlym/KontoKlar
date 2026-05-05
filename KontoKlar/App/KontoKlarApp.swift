import SwiftUI
import SwiftData
import Combine

@main
struct KontoKlarApp: App {
    @StateObject private var appVM: AppViewModel
    @StateObject private var homeVM: HomeViewModel
    @StateObject private var settingsVM: SettingsViewModel
    @StateObject private var deps: AppDependencies
    
    private let modelContainer: ModelContainer
    
    init() {
        do {
            let container = try AppModelContainerFactory.makeContainer()
            self.modelContainer = container
            
            let context = container.mainContext
            let categoryRepository = SwiftDataCategoryRepository(context: context)
            let transactionRepository = SwiftDataTransactionRepository(context: context)
            
            let appVM = AppViewModel()
            let deps = AppDependencies(categoryRepository: categoryRepository, transactionRepository: transactionRepository)

            let homeVM = HomeViewModel(
                appVM: appVM,
                categoryStore: deps.categoryStore,
                transactionStore: deps.transactionStore
            )
            let settingsVM = SettingsViewModel(appVM: appVM) { nav in
                switch nav {
                case .transactions:
                    homeVM.path.append(HomeDestination.settingsTransactions)
                case .categories:
                    homeVM.path.append(HomeDestination.settingsCategories)
                }
            }
            
            _appVM = StateObject(wrappedValue: appVM)
            _homeVM = StateObject(wrappedValue: homeVM)
            _settingsVM = StateObject(wrappedValue: settingsVM)
            _deps = StateObject(wrappedValue: deps)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {

        WindowGroup {
            if !appVM.hasRunBefore {
                WelcomeView()
                    .environmentObject(appVM)
                    .environmentObject(settingsVM)
                    .environmentObject(deps)
                    .environmentObject(deps.categoryStore)
                    .environmentObject(deps.transactionStore)
                
            } else {
                HomeView(viewModel: homeVM)
                    .environmentObject(appVM)
                    .environmentObject(settingsVM)
                    .environmentObject(deps)
                    .environmentObject(deps.categoryStore)
                    .environmentObject(deps.transactionStore)
            }
        }
        .modelContainer(modelContainer)
    }
}
