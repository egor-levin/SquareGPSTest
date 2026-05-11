//
// Created by Egor Levin
//

import Foundation
import Combine
import SwiftData
import CoreLocation

@MainActor
final class TrackersRepository {
    enum RefreshResult {
        case refreshed
        case failedToUpdateCache
        case failedUsingCache
    }

    // MARK: - Public Properties

    var trackersPublisher: AnyPublisher<[TrackerItem], Never> {
        trackersSubject.eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let trackersSubject = CurrentValueSubject<[TrackerItem], Never>([])
    private let trackerService: NavixyTrackerListService

    private var refreshTask: Task<RefreshResult, Error>?

    // MARK: - init deinit

    init(
        modelContext: ModelContext,
        trackerService: NavixyTrackerListService
    ) {
        self.modelContext = modelContext
        self.trackerService = trackerService
    }

    // MARK: - Public Methods

    func loadCachedTrackers() throws {
        try emitCachedTrackers()
    }

    func refreshTrackers() async throws -> RefreshResult {
        if let refreshTask {
            return try await refreshTask.value
        }

        let refreshTask = Task { @MainActor in
            try await refreshTrackersForce()
        }
        self.refreshTask = refreshTask

        do {
            let result = try await refreshTask.value
            self.refreshTask = nil
            return result
        } catch {
            self.refreshTask = nil
            throw error
        }
    }

    // MARK: - Private Methods

    private func refreshTrackersForce() async throws -> RefreshResult {
        let trackers: [TrackerItem]
        do {
            let trackerList = try await trackerService.getNavixyTrackerList()
            trackers = trackerList.list.map { TrackerItem(tracker: $0) }
        } catch {
            return .failedUsingCache
        }

        do {
            try save(trackers: trackers)
            try emitCachedTrackers()
            return .refreshed
        } catch {
            return .failedToUpdateCache
        }
    }

    private func emitCachedTrackers() throws {
        let descriptor = FetchDescriptor<StoredTracker>(
            sortBy: [SortDescriptor(\.label)]
        )

        let trackers = try modelContext.fetch(descriptor).map {
            TrackerItem(storedTracker: $0)
        }
        trackersSubject.send(trackers)
    }

    private func save(trackers: [TrackerItem]) throws {
        let storedTrackers = try modelContext.fetch(FetchDescriptor<StoredTracker>())
        let storedById = Dictionary(uniqueKeysWithValues: storedTrackers.map { ($0.id, $0) })
        let freshIds = Set(trackers.map(\.id))

        for tracker in trackers {
            if let storedTracker = storedById[tracker.id] {
                storedTracker.label = tracker.label
                storedTracker.model = tracker.model
                storedTracker.deviceId = tracker.deviceId
                storedTracker.updatedAt = Date()
            } else {
                modelContext.insert(
                    StoredTracker(
                        id: tracker.id,
                        label: tracker.label,
                        model: tracker.model,
                        deviceId: tracker.deviceId,
                        updatedAt: Date()
                    )
                )
            }
        }

        for storedTracker in storedTrackers where !freshIds.contains(storedTracker.id) {
            modelContext.delete(storedTracker)
        }

        try modelContext.save()
    }
}

private extension TrackerItem {
    init(tracker: NavixyTrackerDomain) {
        self.init(
            id: tracker.id,
            label: tracker.label,
            model: tracker.source.model,
            deviceId: tracker.source.deviceId,
        )
    }

    init(storedTracker: StoredTracker) {
        self.init(
            id: storedTracker.id,
            label: storedTracker.label,
            model: storedTracker.model,
            deviceId: storedTracker.deviceId
        )
    }
}
