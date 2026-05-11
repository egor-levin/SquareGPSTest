//
// Created by Egor Levin
//

import Foundation
import CoreLocation

// MARK: - NavixyTrackerStatesDomain
struct NavixyTrackerStatesDomain: Decodable {
    let userTime: String
    let states: [Int: NavixyTrackerStateDomain]
    let blocked: [Int]
    let notExist: [Int]
}

// MARK: - NavixyTrackerStateDomain
struct NavixyTrackerStateDomain: Decodable {
    let sourceId: Int
    let gps: NavixyTrackerGPSStateDomain
    let connectionStatus: String?
    let movementStatus: String?
    let movementStatusUpdate: String?
    let ignition: Bool?
    let ignitionUpdate: String?
    let gsm: NavixyTrackerGSMStateDomain?
    let lastUpdate: String?
    let batteryLevel: Double?
    let batteryUpdate: String?
    let inputs: [Bool]?
    let inputsUpdate: String?
    let outputs: [Bool]?
    let outputsUpdate: String?
    let actualTrackUpdate: String?
}

// MARK: - NavixyTrackerGPSStateDomain
struct NavixyTrackerGPSStateDomain: Decodable {
    let updated: Date?
    let signalLevel: Double
    let location: NavixyTrackerStateLocationDomain
    let heading: Double
    let speed: Double
    let alt: Double
}

// MARK: - NavixyTrackerStateLocationDomain
struct NavixyTrackerStateLocationDomain: Decodable {
    let lat: Double
    let lng: Double
}

// MARK: - NavixyTrackerGSMStateDomain
struct NavixyTrackerGSMStateDomain: Decodable {
    let updated: String?
    let signalLevel: Double?
    let networkName: String?
    let roaming: Bool?
}

extension NavixyTrackerGPSStateDomain {
    var clLocation: CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng),
            altitude: alt,
            horizontalAccuracy: 1,
            verticalAccuracy: 1,
            course: heading,
            courseAccuracy: 1,
            speed: speed,
            speedAccuracy: 1,
            timestamp: updated ?? Date()
        )
    }
}
