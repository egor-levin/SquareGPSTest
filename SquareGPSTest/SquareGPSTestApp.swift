//
// Created by Egor Levin
//

import SwiftUI
import SwiftData

@main
struct SquareGPSTestApp: App {
    private let modelContainer: ModelContainer
    private let viewModel: TrackerListViewModel
    @StateObject private var router: AppRouter
    
    @MainActor
    init() {
        let modelContainer = try! ModelContainer(for: StoredTracker.self)
        let modelContext = ModelContext(modelContainer)
        let baseNetworkService = NetworkService(
            baseURL: URL(string: "https://api.eu.navixy.com/v2/")!,
            logger: ConsoleLogger(category: "Network")
        )
        let authHashStorage = KeychainAuthHashStorage(
            logger: ConsoleLogger(category: "Keychain")
        )
        let authRepository = AuthRepository(
            loginProvider: { "demo-eu@navixy.com" },
            passwordProvider: { "123456" },
            authService: baseNetworkService,
            authHashStorage: authHashStorage
        )
        let navixyNetworkService = NavixyNetworkService(
            baseNetworkService: baseNetworkService,
            authRepository: authRepository
        )
        let repository = TrackersRepository(
            modelContext: modelContext,
            trackerService: navixyNetworkService
        )
        
        self.modelContainer = modelContainer
        
        let routerDependencyContainer = AppRouteDependencyContainer(
            trackerStatesRepositoryProvider: {
                TrackerStatesRepository(
                    trackerStatesService: navixyNetworkService
                )
            }
        )
        let router = AppRouter(dependencyContainer: routerDependencyContainer)
        _router = StateObject(wrappedValue: router)
        self.viewModel = TrackerListViewModel(
            repository: repository,
            router: router
        )
    }
    
    var body: some Scene {
        WindowGroup {
            TrackerListView(
                viewModel: viewModel,
                navigationPath: $router.path,
                destination: { route in
                    router.destination(for: route)
                }
            )
        }
    }
}
