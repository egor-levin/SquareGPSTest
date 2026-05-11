//
// Created by Egor Levin
//

import Foundation

// MARK: - NavixyTrackerListDomain
struct NavixyTrackerListDomain: Decodable {
    let list: [NavixyTrackerDomain]
}

// MARK: - NavixyTrackerDomain
struct NavixyTrackerDomain: Decodable {
    let id: Int
    let label: String
    let groupId: Int
    let source: NavixyTrackerSourceDomain
    let tagBindings: [Int]
    let clone: Bool
}

// MARK: - NavixyTrackerSourceDomain
struct NavixyTrackerSourceDomain: Decodable {
    let id: Int
    let creationDate: String
    let blocked: Bool
    let deviceId: String
    let tariffId: Int
    let model: String
    let tariffEndDate: String
    let phone: String?
}
