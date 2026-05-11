//
// Created by Egor Levin
//

import Combine
import Foundation
import CoreLocation

struct TrackerModel: Identifiable {
    let id: Int
    let label: String
    let model: String
    let deviceId: String
    var location: CLLocation?
}

private extension TrackerModel {
    init(trackerItem: TrackerItem) {
        self.init(
            id: trackerItem.id,
            label: trackerItem.label,
            model: trackerItem.model,
            deviceId: trackerItem.deviceId,
            location: trackerItem.location
        )
    }
}

@MainActor
final class TrackerListViewModel: ObservableObject {

    // MARK: - Public Properties

    @Published private(set) var trackers: [TrackerModel] = []
    @Published private(set) var isLoading = false
    @Published  var offlineMessage: String?

    // MARK: - Private Properties

    private let router: OnMapRouting & OnTrackerDetailsRouting
    private let repository: TrackersRepository

    private var rawTrackers: [Int: TrackerItem] = [:]
    private var cancellables = Set<AnyCancellable>()

    private var didLoad = false

    // MARK: - init deinit

    init(
        repository: TrackersRepository,
        router: OnMapRouting & OnTrackerDetailsRouting
    ) {
        self.repository = repository
        self.router = router
        setupBindings()
    }

    // MARK: - Public Methods

    func load() async {
        guard !didLoad else {
            return
        }
        didLoad = true

        loadCachedTrackers()
        await refresh()
    }

    func refresh() async {
        isLoading = trackers.isEmpty

        do {
            switch try await repository.refreshTrackers() {
            case .refreshed:
                offlineMessage = nil
            case .failedToUpdateCache:
                offlineMessage = "Could not update saved trackers."
            case .failedUsingCache:
                offlineMessage = "Offline mode. Could not refresh tracker list."
            }
        } catch {
            offlineMessage = "Could not load trackers."
        }

        isLoading = false
    }

    func mapButtonTapped() {
        router.openMap(trackers: rawTrackers)
    }

    func trackerTapped(_ tracker: TrackerModel) {
        guard let rawTracker = rawTrackers[tracker.id] else { return }
        router.openDetails(for: rawTracker)
    }

    // MARK: - Private Methods

    private func setupBindings() {
        repository.trackersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                var rawTrackers: [Int: TrackerItem] = [:]
                items.forEach { rawTrackers[$0.id] = $0 }
                self?.rawTrackers = rawTrackers
                self?.trackers = items.map { TrackerModel(trackerItem: $0) }
            }.store(in: &cancellables)
    }

    private func loadCachedTrackers() {
        do {
            try repository.loadCachedTrackers()
        } catch {
            offlineMessage = "Could not load saved trackers."
        }
    }
}
