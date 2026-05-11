//
// Created by Egor Levin
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class TrackerDetailsViewModel: ObservableObject {

    // MARK: - Public Properties

    @Published private(set) var label: String
    @Published private(set) var model: String
    @Published private(set) var deviceId: String
    @Published private(set) var location: CLLocation?

    // MARK: - Private Properties

    private let router: OnMapRouting

    private let rawTracker: TrackerItem

    // MARK: - init deinit

    init(
        tracker: TrackerItem,
        router: OnMapRouting
    ) {
        self.rawTracker = tracker
        self.label = tracker.label
        self.model = tracker.model
        self.deviceId = tracker.deviceId
        self.location = tracker.location
        self.router = router
    }

    // MARK: - Public Methods

    func mapButtonTapped() {
        router.openMap(trackers: [rawTracker.id: rawTracker])
    }
}
