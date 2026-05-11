//
// Created by Egor Levin
//

import Foundation

protocol NavixyTrackerStatesService {
    func getNavixyTrackerStates(
        trackers: [Int],
        listBlocked: Bool,
        allowNotExist: Bool
    ) async throws -> NavixyTrackerStatesDomain
}

extension NavixyNetworkService: NavixyTrackerStatesService {
    func getNavixyTrackerStates(
        trackers: [Int],
        listBlocked: Bool,
        allowNotExist: Bool
    ) async throws -> NavixyTrackerStatesDomain {
        let endpoint = NetworkEndpoint(
            path: "tracker/get_states",
            method: .POST,
            body: [
                "trackers": trackers,
                "list_blocked": listBlocked,
                "allow_not_exist": allowNotExist
            ]
        )

        return try await request(
            endpoint: endpoint,
            converter: NavixyTrackerStatesDTOToDomainConverter()
        )
    }
}
