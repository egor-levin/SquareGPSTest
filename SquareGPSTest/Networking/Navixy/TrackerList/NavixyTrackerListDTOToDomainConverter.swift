//
// Created by Egor Levin
//

import Foundation

struct NavixyTrackerListDTOToDomainConverter: NetworkDTOToDomainConverter {
    func convert(dto: NavixyTrackerListDTO) -> NavixyTrackerListDomain? {
        NavixyTrackerListDomain(list: dto.list.map { convert(dto: $0) })
    }
    
    private func convert(dto: NavixyTrackerDTO) -> NavixyTrackerDomain {
        NavixyTrackerDomain(
            id: dto.id,
            label: dto.label,
            groupId: dto.groupId,
            source: convert(dto: dto.source),
            tagBindings: dto.tagBindings,
            clone: dto.clone
        )
    }
    
    private func convert(dto: NavixyTrackerSourceDTO) -> NavixyTrackerSourceDomain {
        NavixyTrackerSourceDomain(
            id: dto.id,
            creationDate: dto.creationDate,
            blocked: dto.blocked,
            deviceId: dto.deviceId,
            tariffId: dto.tariffId,
            model: dto.model,
            tariffEndDate: dto.tariffEndDate,
            phone: dto.phone
        )
    }
}
