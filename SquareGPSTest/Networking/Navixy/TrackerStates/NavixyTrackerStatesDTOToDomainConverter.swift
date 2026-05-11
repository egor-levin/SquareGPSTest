//
// Created by Egor Levin
//

import Foundation

struct NavixyTrackerStatesDTOToDomainConverter: NetworkDTOToDomainConverter {
    func convert(dto: NavixyTrackerStatesDTO) -> NavixyTrackerStatesDomain? {
        let states = dto.states.reduce(into: [Int: NavixyTrackerStateDomain]()) { result, item in
            guard let trackerId = Int(item.key) else {
                return
            }
            
            result[trackerId] = convert(dto: item.value)
        }
        
        return NavixyTrackerStatesDomain(
            userTime: dto.userTime,
            states: states,
            blocked: dto.blocked ?? [],
            notExist: dto.notExist ?? []
        )
    }
    
    private func convert(dto: NavixyTrackerStateDTO) -> NavixyTrackerStateDomain {
        NavixyTrackerStateDomain(
            sourceId: dto.sourceId,
            gps: convert(dto: dto.gps),
            connectionStatus: dto.connectionStatus,
            movementStatus: dto.movementStatus,
            movementStatusUpdate: dto.movementStatusUpdate,
            ignition: dto.ignition,
            ignitionUpdate: dto.ignitionUpdate,
            gsm: dto.gsm.map { convert(dto: $0) },
            lastUpdate: dto.lastUpdate,
            batteryLevel: dto.batteryLevel,
            batteryUpdate: dto.batteryUpdate,
            inputs: dto.inputs,
            inputsUpdate: dto.inputsUpdate,
            outputs: dto.outputs,
            outputsUpdate: dto.outputsUpdate,
            actualTrackUpdate: dto.actualTrackUpdate
        )
    }
    
    private func convert(dto: NavixyTrackerGPSStateDTO) -> NavixyTrackerGPSStateDomain {
        NavixyTrackerGPSStateDomain(
            updated: convertToDate(dto.updated),
            signalLevel: dto.signalLevel,
            location: convert(dto: dto.location),
            heading: dto.heading,
            speed: dto.speed,
            alt: dto.alt
        )
    }
    
    private func convert(dto: NavixyTrackerStateLocationDTO) -> NavixyTrackerStateLocationDomain {
        NavixyTrackerStateLocationDomain(
            lat: dto.lat,
            lng: dto.lng
        )
    }
    
    private func convert(dto: NavixyTrackerGSMStateDTO) -> NavixyTrackerGSMStateDomain {
        NavixyTrackerGSMStateDomain(
            updated: dto.updated,
            signalLevel: dto.signalLevel,
            networkName: dto.networkName,
            roaming: dto.roaming
        )
    }
    
    private func convertToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)
    }
}
