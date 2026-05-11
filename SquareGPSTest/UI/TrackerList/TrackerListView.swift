//
// Created by Egor Levin
//

import SwiftUI

struct TrackerListView<Route: NavigationRouteProtocol, Destination: View>: View {
    @StateObject private var viewModel: TrackerListViewModel
    
    @Binding private var navigationPath: [Route]
    private let destination: (Route) -> Destination
    
    init(
        viewModel: TrackerListViewModel,
        navigationPath: Binding<[Route]>,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _navigationPath = navigationPath
        self.destination = destination
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                if !viewModel.trackers.isEmpty {
                    Section {
                        Button {
                            viewModel.mapButtonTapped()
                        } label: {
                            Label("Show on map", systemImage: "map")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                Section {
                    if let message = viewModel.offlineMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.white)
                            .listRowBackground(Color.orange)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    ForEach(viewModel.trackers) { tracker in
                        Button {
                            viewModel.trackerTapped(tracker)
                        } label: {
                            TrackerListItemView(tracker: tracker)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Section {
                    if viewModel.isLoading && viewModel.trackers.isEmpty {
                        ProgressView()
                    } else if viewModel.trackers.isEmpty {
                        ContentUnavailableView(
                            "No trackers",
                            systemImage: "location.slash",
                            description: Text("Trackers will appear after the first successful load.")
                        )
                    }
                }
            }
            .navigationTitle("Trackers")
            .navigationDestination(for: Route.self) { route in
                destination(route)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.load()
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.offlineMessage)
        }
    }
}
