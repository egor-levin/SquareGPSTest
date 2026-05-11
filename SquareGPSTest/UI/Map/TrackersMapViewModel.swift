//
// Created by Egor Levin
//

import Foundation
import Combine
import CoreLocation

struct TrackerOnMapModel: Identifiable, Hashable {
    let id: Int
    let label: String
    let location: CLLocation
}

enum TrackerMapCameraModeModel: Equatable {
    case automatic
    case tracking(lat: Double, lon: Double, distance: Double)
    case manual
}

@MainActor
final class TrackersMapViewModel: ObservableObject {

    // MARK: - Public Properties

    @Published private(set) var trackersOnMap: [TrackerOnMapModel]
    @Published private(set) var cameraMode: TrackerMapCameraModeModel = .automatic
    @Published private(set) var isLoading: Bool
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties

    private let trackerRepository: TrackerStatesRepository
    private let router: OnTrackerDetailsRouting

    private var rawTrackers: [Int: TrackerItem]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - init deinit

    init(
        trackers: [Int: TrackerItem],
        trackerRepository: TrackerStatesRepository,
        router: OnTrackerDetailsRouting
    ) {
        self.rawTrackers = trackers
        let trackersOnMap: [TrackerOnMapModel] = trackers.values.compactMap {
            guard let location = $0.location else { return nil }
            return TrackerOnMapModel(id: $0.id, label: $0.label, location: location)
        }
        self.trackersOnMap = trackersOnMap
        self.trackerRepository = trackerRepository
        self.router = router
        self.isLoading = trackersOnMap.isEmpty
        self.errorMessage = nil
        self.cameraMode = cameraModeForTracking()
        setupBindings()
    }

    // MARK: - Public Methods

    func willAppear() {
        errorMessage = nil
        isLoading = trackersOnMap.isEmpty
        trackerRepository.startPolling(trackers: [Int](rawTrackers.keys))
    }

    func didDisappear() {
        trackerRepository.stopPolling()
    }

    func trackerTapped(_ trackerOnMap: TrackerOnMapModel) {
        guard
            var tracker = rawTrackers[trackerOnMap.id],
            let location = trackersOnMap.first(where: { $0.id == tracker.id })
        else {
            return
        }
        tracker.location = location.location
        router.openDetails(for: tracker)
    }

    func enableTrackingTapped() {
        cameraMode = cameraModeForTracking()
    }

    func cameraMovedByUser() {
        cameraMode = .manual
    }

    // MARK: - Private Methods

    private func setupBindings() {
        trackerRepository.statesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] states in
                guard let self else { return }
                isLoading = false
                errorMessage = nil
                trackersOnMap = states.states.map {
                    let label = self.rawTrackers[$0.key]?.label ?? ""
                    return TrackerOnMapModel(
                        id: $0.key,
                        label: label,
                        location: $0.value.gps.clLocation
                    )
                }
                if cameraMode != .manual {
                    cameraMode = cameraModeForTracking()
                }
            }
            .store(in: &cancellables)

        trackerRepository.statesLoadingFailedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                isLoading = false
                if trackersOnMap.isEmpty {
                    errorMessage = "Could not load tracker locations."
                }
            }
            .store(in: &cancellables)
    }

    private func cameraModeForTracking() -> TrackerMapCameraModeModel {
        if let coordinate = trackersOnMap.first?.location.coordinate,
           trackersOnMap.count == 1
        {
            return .tracking(
                lat: coordinate.latitude,
                lon: coordinate.longitude,
                distance: 4000
            )
        } else {
            return .automatic
        }
    }
}
