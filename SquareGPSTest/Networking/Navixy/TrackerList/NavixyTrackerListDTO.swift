//
// Created by Egor Levin
//

import Foundation

// MARK: - NavixyTrackerListDTO
struct NavixyTrackerListDTO: Decodable {
    let list: [NavixyTrackerDTO]
}

// MARK: - NavixyTrackerDTO
struct NavixyTrackerDTO: Decodable {
    let id: Int
    let label: String
    let groupId: Int
    let source: NavixyTrackerSourceDTO
    let tagBindings: [Int]
    let clone: Bool
}

// MARK: - NavixyTrackerSourceDTO
struct NavixyTrackerSourceDTO: Decodable {
    let id: Int
    let creationDate: String
    let blocked: Bool
    let deviceId: String
    let tariffId: Int
    let model: String
    let tariffEndDate: String
    let phone: String?
}
