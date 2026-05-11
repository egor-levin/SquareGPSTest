//
// Created by Egor Levin
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidRequestData
    case notHttp
    case network(Error)
    case server(statusCode: Int, json: [String: Any]?)
    case invalidDTO(Error)
    case dtoConversion
    case cancelled
    case noInternet
}
