//
// Created by Egor Levin
//

import Foundation

protocol NavixyTrackerListService {
    func getNavixyTrackerList() async throws -> NavixyTrackerListDomain
}

extension NavixyNetworkService: NavixyTrackerListService {
    func getNavixyTrackerList() async throws -> NavixyTrackerListDomain {
        let endpoint = NetworkEndpoint(
            path: "tracker/list",
            method: .POST
        )

        return try await request(
            endpoint: endpoint,
            converter: NavixyTrackerListDTOToDomainConverter()
        )
    }
}
