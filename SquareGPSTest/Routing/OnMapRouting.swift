//
// Created by Egor Levin
//

import Foundation
import SwiftUI

protocol OnMapRouting {
    func openMap(trackers: [Int: TrackerItem])
}

extension AppRouter: OnMapRouting {
    func openMap(trackers: [Int: TrackerItem]) {
        path.append(.trackersMap(trackers))
    }
    
    func trackerDetailsView(with tracker: TrackerItem) -> some View {
        TrackerDetailsView(
            viewModel: TrackerDetailsViewModel(
                tracker: tracker,
                router: self
            )
        )
        .id("\(tracker.id)_\(tracker.location?.description ?? "")")
    }
}
