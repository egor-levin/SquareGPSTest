//
// Created by Egor Levin
//

import Foundation

protocol Logging {
    func log(_ event: String)
    func log(error: Error)
}
