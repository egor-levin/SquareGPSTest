//
// Created by Egor Levin
//

import Foundation

struct NetworkEndpoint {
    var path: String
    var method: NetworkHTTPMethod
    var headers: [String: String]?
    var queryItems: [String: String]?
    var body: [String: Any]?
}
