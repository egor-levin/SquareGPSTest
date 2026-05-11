//
// Created by Egor Levin
//

import Foundation

protocol NetworkDTOToDomainConverter {
    associatedtype DTO: Decodable
    associatedtype Domain
    
    func convert(dto: DTO) -> Domain?
}
