//
// Created by Egor Levin
//

import Foundation
import MapKit
import SwiftUI

struct TrackersMapView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: TrackersMapViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    private let isDisplayed: Bool

    init(
        viewModel: TrackersMapViewModel,
        isDisplayed: Bool,
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.isDisplayed = isDisplayed
    }

    var body: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            ForEach(viewModel.trackersOnMap) { trackerOnMap in
                Annotation(
                    "",
                    coordinate: trackerOnMap.location.coordinate) {
                        VStack {
                            Text(String(trackerOnMap.label))
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            Image(systemName: "location.north.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(.pink)
                                .rotationEffect(.degrees(trackerOnMap.location.course))
                        }
                        .onTapGesture {
                            viewModel.trackerTapped(trackerOnMap)
                        }

                    }
                    .annotationTitles(.hidden)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                viewModel.enableTrackingTapped()
            } label: {
                Image(systemName: "location.magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 52, height: 52)
                    .background(.regularMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 16)
            .padding(.bottom, 24)
        }
        .overlay {
            if viewModel.isLoading || viewModel.errorMessage != nil {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()

                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.large)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isLoading)
        .animation(.easeInOut(duration: 0.25), value: viewModel.errorMessage)
        .animation(.easeInOut(duration: 0.25), value: viewModel.trackersOnMap)
        .simultaneousGesture(
            DragGesture(minimumDistance: 1)
                .onChanged { _ in
                    viewModel.cameraMovedByUser()
                }
        )
        .simultaneousGesture(
            MagnifyGesture()
                .onChanged { _ in
                    viewModel.cameraMovedByUser()
                }
        )
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded {
                    viewModel.cameraMovedByUser()
                }
        )
        .onChange(of: viewModel.cameraMode, initial: true) { _, _ in
            updateCameraPosition()
        }
        .onChange(of: isDisplayed, initial: true) { _, _ in
            if isDisplayed {
                viewModel.willAppear()
            } else {
                viewModel.didDisappear()
            }
        }
        .onChange(of: scenePhase) { _, _ in
            if scenePhase == .active {
                viewModel.willAppear()
            } else {
                viewModel.didDisappear()
            }
        }
        .onDisappear {
            viewModel.didDisappear()
        }
    }

    private func updateCameraPosition() {
        switch viewModel.cameraMode {
        case .automatic:
            withAnimation(.easeInOut(duration: 0.35)) {
                cameraPosition = .automatic
            }
        case .tracking(let lat, let lon, let distance):
            withAnimation(.easeInOut(duration: 0.35)) {
                cameraPosition = .camera(
                    MapCamera(
                        centerCoordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        distance: distance
                    )
                )
            }
        case .manual:
            break
        }
    }
}
