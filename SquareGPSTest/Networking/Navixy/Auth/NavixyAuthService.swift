//
// Created by Egor Levin
//

import Foundation

protocol NavixyAuthService {
    func getAuthHash(login: String, password: String) async throws -> String
}

extension NetworkService: NavixyAuthService {
    func getAuthHash(login: String, password: String) async throws -> String {
        let endpoint = NetworkEndpoint(
            path: "user/auth",
            method: .GET,
            queryItems: [
                "login": login,
                "password": password
            ]
        )
        
        return try await request(
            endpoint: endpoint,
            converter: { (dto: NavixyAuthDTO) in dto.hash }
        )
    }
}
