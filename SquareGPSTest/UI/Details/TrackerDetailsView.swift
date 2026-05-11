//
// Created by Egor Levin
//

import Foundation
import SwiftUI
import CoreLocation

struct TrackerDetailsView: View {
    @StateObject private var viewModel: TrackerDetailsViewModel
    
    init(viewModel: TrackerDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List {
            LabeledContent("Label", value: viewModel.label)
            LabeledContent("Model", value: viewModel.model)
            LabeledContent("Device ID", value: viewModel.deviceId)
            if let coordinate = viewModel.location?.coordinate {
                LabeledContent("Last coord") {
                    Text(
                        String(format: "%.5f", coordinate.latitude)
                        + ", "
                        + String(format: "%.5f", coordinate.longitude)
                    )
                }
            }
            Button {
                viewModel.mapButtonTapped()
            } label: {
                Label("Show on map", systemImage: "map")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle(viewModel.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}
