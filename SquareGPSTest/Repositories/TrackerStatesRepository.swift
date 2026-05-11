//
// Created by Egor Levin
//

import Foundation
import Combine

@MainActor
final class TrackerStatesRepository {

    // MARK: - Public Properties

    var statesPublisher: AnyPublisher<NavixyTrackerStatesDomain, Never> {
        statesSubject.eraseToAnyPublisher()
    }

    var statesLoadingFailedPublisher: AnyPublisher<Void, Never> {
        statesLoadingFailedSubject.eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let pollingInterval: Duration = .seconds(5)

    private let trackerStatesService: NavixyTrackerStatesService
    private let statesSubject = PassthroughSubject<NavixyTrackerStatesDomain, Never>()
    private let statesLoadingFailedSubject = PassthroughSubject<Void, Never>()

    private var pollingTask: Task<Void, Never>?

    // MARK: - init deinit

    init(
        trackerStatesService: NavixyTrackerStatesService
    ) {
        self.trackerStatesService = trackerStatesService
    }

    deinit {
        pollingTask?.cancel()
    }

    // MARK: - Public Methods

    func startPolling(
        trackers: [Int]
    ) {
        stopPolling()

        guard !trackers.isEmpty else {
            return
        }

        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.loadStates(trackers: trackers)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    // MARK: - Private Methods

    private func loadStates(
        trackers: [Int],
        listBlocked: Bool = true,
        allowNotExist: Bool = true
    ) async {
        do {
            let states = try await trackerStatesService.getNavixyTrackerStates(
                trackers: trackers,
                listBlocked: listBlocked,
                allowNotExist: allowNotExist
            )

            guard !Task.isCancelled else {
                return
            }

            statesSubject.send(states)
            try await Task.sleep(for: pollingInterval)
        } catch is CancellationError {
            return
        } catch NetworkError.cancelled {
            return
        } catch {
            statesLoadingFailedSubject.send()
            try? await Task.sleep(for: pollingInterval)
        }
    }
}
