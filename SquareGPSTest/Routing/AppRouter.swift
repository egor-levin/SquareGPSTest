//
// Created by Egor Levin
//

import Combine
import SwiftUI
import CoreLocation

protocol NavigationRouteProtocol: Hashable {}

enum AppRoute: NavigationRouteProtocol {
    case trackerDetails(TrackerItem)
    case trackersMap([Int: TrackerItem])
}

final class AppRouteDependencyContainer {
    let trackerStatesRepositoryProvider: () -> TrackerStatesRepository
    
    init(
        trackerStatesRepositoryProvider: @escaping () -> TrackerStatesRepository
    ) {
        self.trackerStatesRepositoryProvider = trackerStatesRepositoryProvider
    }
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []
    
    let dc: AppRouteDependencyContainer
    
    init(
        dependencyContainer: AppRouteDependencyContainer
    ) {
        self.dc = dependencyContainer
    }
    
    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .trackerDetails(let tracker):
            trackerDetailsView(with: tracker)
        case .trackersMap(let trackers):
            trackersMapView(
                with: trackers,
                isDisplayed: path.last == route
            )
        }
    }
}
