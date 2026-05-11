//
// Created by Egor Levin
//

import Foundation
import SwiftUI

struct TrackerListItemView: View {
    let tracker: TrackerModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tracker.label)
                .font(.body)
            Text(tracker.model)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

