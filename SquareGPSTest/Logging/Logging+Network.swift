//
// Created by Egor Levin
//

import Foundation

protocol NetworkLogger: Logging {
    func log(request: URLRequest)
    func log(response: HTTPURLResponse, data: Data)
}

extension ConsoleLogger: NetworkLogger {
    func log(request: URLRequest) {
        log("NetworkRequest: \n\n" + request.curlString)
    }
    
    func log(response: HTTPURLResponse, data: Data) {
        log("NetworkResponse: \n\n" + response.logDescription + "\nBody: \n" + data.prettyPrintedJSONString)
    }
}


private extension URLRequest {
    var curlString: String {
        guard let url = url else {
            return "Invalid URLRequest"
        }

        var components = ["curl -v"]

        if let method = httpMethod {
            components.append("-X \(method)")
        }

        allHTTPHeaderFields?.forEach {
            components.append("-H '\($0): \($1)'")
        }

        if let body = httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            components.append("-d '\(bodyString)'")
        }

        components.append("'\(url.absoluteString)'")

        return components.joined(separator: " \\\n\t")
    }
}

private extension HTTPURLResponse {
    var logDescription: String {
        """
        URL: \(url?.absoluteString ?? "")
        Status: \(statusCode)
        Headers:
        \(prettyHeaders)
        """
    }
    
    private var prettyHeaders: String {
        allHeaderFields
            .map { "\($0.key): \($0.value)" }
            .sorted()
            .joined(separator: "\n")
    }
}

private extension Data {
    var prettyPrintedJSONString: String {
        guard
            let object = try? JSONSerialization.jsonObject(with: self),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted]
            )
        else {
            return String(data: self, encoding: .utf8) ?? "Data is not JSON"
        }

        return String(data: prettyData, encoding: .utf8) ?? "Data is not utf8"
    }
}

