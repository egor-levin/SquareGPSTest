//
// Created by Egor Levin
//

import Foundation

// MARK: - NavixyTrackerStatesDTO
struct NavixyTrackerStatesDTO: Decodable {
    let userTime: String
    let states: [String: NavixyTrackerStateDTO]
    let blocked: [Int]?
    let notExist: [Int]?
}

// MARK: - NavixyTrackerStateDTO
struct NavixyTrackerStateDTO: Decodable {
    let sourceId: Int
    let gps: NavixyTrackerGPSStateDTO
    let connectionStatus: String?
    let movementStatus: String?
    let movementStatusUpdate: String?
    let ignition: Bool?
    let ignitionUpdate: String?
    let gsm: NavixyTrackerGSMStateDTO?
    let lastUpdate: String?
    let batteryLevel: Double?
    let batteryUpdate: String?
    let inputs: [Bool]?
    let inputsUpdate: String?
    let outputs: [Bool]?
    let outputsUpdate: String?
    let actualTrackUpdate: String?
}

// MARK: - NavixyTrackerGPSStateDTO
struct NavixyTrackerGPSStateDTO: Decodable {
    let updated: String
    let signalLevel: Double
    let location: NavixyTrackerStateLocationDTO
    let heading: Double
    let speed: Double
    let alt: Double
}

// MARK: - NavixyTrackerStateLocationDTO
struct NavixyTrackerStateLocationDTO: Decodable {
    let lat: Double
    let lng: Double
}

// MARK: - NavixyTrackerGSMStateDTO
struct NavixyTrackerGSMStateDTO: Decodable {
    let updated: String?
    let signalLevel: Double?
    let networkName: String?
    let roaming: Bool?
}
