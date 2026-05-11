//
// Created by Egor Levin
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class StoredTracker {
    @Attribute(.unique) var id: Int
    var label: String
    var model: String
    var deviceId: String
    var updatedAt: Date

    init(
        id: Int,
        label: String,
        model: String,
        deviceId: String,
        updatedAt: Date
    ) {
        self.id = id
        self.label = label
        self.model = model
        self.deviceId = deviceId
        self.updatedAt = updatedAt
    }
}
