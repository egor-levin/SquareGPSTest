//
// Created by Egor Levin
//

import Foundation

final class NetworkService {
    private let session: URLSession
    private let baseURL: URL
    private let logger: NetworkLogger
    
    init(
        baseURL: URL,
        session: URLSession = URLSession(configuration: .default),
        logger: NetworkLogger
    ) {
        self.session = session
        self.baseURL = baseURL
        self.logger = logger
    }
    
    func request(endpoint: NetworkEndpoint) async throws {
        try await requestData(endpoint: endpoint)
    }
    
    func request<Converter: NetworkDTOToDomainConverter>(
        endpoint: NetworkEndpoint,
        converter: Converter
    ) async throws -> Converter.Domain {
        return try await request(endpoint: endpoint, converter: converter.convert)
    }
    
    func request<DTO: Decodable, Domain>(
        endpoint: NetworkEndpoint,
        converter: (DTO) -> Domain?
    ) async throws -> Domain {
        do {
            let data = try await requestData(endpoint: endpoint)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let dto: DTO
            do {
                dto = try decoder.decode(DTO.self, from: data)
            } catch {
                throw NetworkError.invalidDTO(error)
            }
            
            guard let domain = converter(dto) else {
                throw NetworkError.dtoConversion
            }
            return domain
        } catch {
            logger.log(error: error)
            throw error
        }
    }
    
    @discardableResult
    private func requestData(
        endpoint: NetworkEndpoint
    ) async throws -> Data {
        do {
            let request = try buildRequest(from: endpoint)
            logger.log(request: request)
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.notHttp
            }
            logger.log(response: httpResponse, data: data)
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                throw NetworkError.server(statusCode: httpResponse.statusCode, json: json)
            }
            
            return data
        } catch let error as NetworkError {
            throw error
        } catch URLError.cancelled {
            throw NetworkError.cancelled
        } catch URLError.notConnectedToInternet {
            throw NetworkError.noInternet
        } catch {
            throw NetworkError.network(error)
        }
    }
    
    private func buildRequest(from endpoint: NetworkEndpoint) throws -> URLRequest {
        guard
            var url = URL(string: endpoint.path, relativeTo: baseURL)
        else {
            throw NetworkError.invalidURL
        }
        
        if let rawQueryItems = endpoint.queryItems {
            let queryItems = rawQueryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
            url = url.appending(queryItems: queryItems)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        if let jsonBody = endpoint.body {
            guard let data = try? JSONSerialization.data(withJSONObject: jsonBody) else {
                throw NetworkError.invalidRequestData
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        }
        
        return request
    }
}
