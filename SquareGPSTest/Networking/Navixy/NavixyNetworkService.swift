//
// Created by Egor Levin
//

import Foundation

enum NavixyNetworkError: Error {
    case authFailed
    case authNeeded
}

final class NavixyNetworkService {
    private let maxRetryCount = 2
    private let retryingStartDelay = 1
    
    private let baseNetworkService: NetworkService
    private let authRepository: AuthRepository
    
    init(
        baseNetworkService: NetworkService,
        authRepository: AuthRepository
    ) {
        self.baseNetworkService = baseNetworkService
        self.authRepository = authRepository
    }
    
    func request<Converter: NetworkDTOToDomainConverter>(
        endpoint: NetworkEndpoint,
        converter: Converter,
        shouldAppendAuth: Bool = true
    ) async throws -> Converter.Domain {
        try await request(
            endpoint: endpoint,
            converter: converter.convert,
            shouldAppendAuth: shouldAppendAuth
        )
    }
    
    func request<DTO: Decodable, Domain>(
        endpoint: NetworkEndpoint,
        converter: (DTO) -> Domain?,
        shouldAppendAuth: Bool = true
    ) async throws -> Domain {
        try await requestWithRetrying(
            endpoint: endpoint,
            converter: converter,
            shouldAppendAuth: shouldAppendAuth
        )
    }
    
    private func requestWithRetrying<DTO: Decodable, Domain>(
        retryAttempt: Int = 0,
        endpoint: NetworkEndpoint,
        converter: (DTO) -> Domain?,
        shouldAppendAuth: Bool = true
    ) async throws -> Domain {
        var endpoint = endpoint
        var authHashGeneration = -1
        
        if shouldAppendAuth {
            (endpoint, authHashGeneration) = try await getEndpointWithAuth(endpoint)
        }
        
        do {
            return try await baseNetworkService.request(endpoint: endpoint, converter: converter)
        } catch {
            switch error as? NetworkError {
            case .noInternet,
                    .cancelled,
                    .invalidURL,
                    .invalidRequestData,
                    .notHttp,
                    .invalidDTO(_),
                    .dtoConversion,
                    .none:
                throw error
            case .network, .server:
                guard retryAttempt < maxRetryCount else {
                    throw error
                }
                
                var retryingDelay = retryingStartDelay * (retryAttempt + 1)
                
                if error.isNavixyAuthInvalid {
                    if !shouldAppendAuth {
                        throw NavixyNetworkError.authNeeded
                    }
                    do {
                        try await authRepository.invalidateAuthHash(forGeneration: authHashGeneration)
                    } catch {
                        throw NavixyNetworkError.authFailed
                    }
                    retryingDelay = 0
                }
                
                try await Task.sleep(for: .seconds(retryingDelay))
                
                return try await requestWithRetrying(
                    retryAttempt: retryAttempt + 1,
                    endpoint: endpoint,
                    converter: converter,
                    shouldAppendAuth: shouldAppendAuth
                )
            }
        }
    }
    
    private func getEndpointWithAuth(
        _ endpoint: NetworkEndpoint
    ) async throws -> (NetworkEndpoint, authHashGeneration: Int) {
        do {
            var endpoint = endpoint
            var body = endpoint.body ?? [:]
            let authHash = try await authRepository.getAuthHash()
            body["hash"] = authHash.value
            endpoint.body = body
            return (endpoint, authHash.generation)
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch let error as NetworkError {
            switch error {
            case .noInternet, .cancelled, .network:
                throw error
            case .invalidURL, .invalidRequestData, .notHttp, .server, .invalidDTO, .dtoConversion:
                throw NavixyNetworkError.authFailed
            }
        } catch {
            throw NavixyNetworkError.authFailed
        }
    }
}

// MARK: - Auth Error

private extension Error {
    var isNavixyAuthInvalid: Bool {
        if case let .server(_, json) = self as? NetworkError,
            let json,
            let status = json["status"] as? [String: Any],
            let code = status["code"] as? Int,
            code == 2 || code == 3 || code == 4
        {
            return true
        } else {
            return false
        }
    }
}
