//
// Created by Egor Levin
//

import Foundation
import SwiftUI

protocol OnTrackerDetailsRouting {
    func openDetails(for tracker: TrackerItem)
}

extension AppRouter: OnTrackerDetailsRouting {
    func openDetails(for tracker: TrackerItem) {
        var newPath: [AppRoute] = path
        if case .trackersMap = path.last,
           path.count >= 2,
           case .trackerDetails = path[path.count-2]
        {
            newPath.removeLast(2)
        }
        newPath.append(.trackerDetails(tracker))
        path = newPath
    }
    
    func trackersMapView(
        with trackers: [Int: TrackerItem],
        isDisplayed: Bool
    ) -> some View {
        TrackersMapView(
            viewModel: TrackersMapViewModel(
                trackers: trackers,
                trackerRepository: dc.trackerStatesRepositoryProvider(),
                router: self
            ),
            isDisplayed: isDisplayed
        )
    }
}
