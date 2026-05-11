//
// Created by Egor Levin
//

import Foundation
import CoreLocation

struct TrackerItem: Hashable {
    let id: Int
    let label: String
    let model: String
    let deviceId: String
    var location: CLLocation?
}
