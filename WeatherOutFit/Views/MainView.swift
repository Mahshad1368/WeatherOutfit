//
//  MainView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showingAddView = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.locations.isEmpty {
                    ContentUnavailableView(
                        "No Locations",
                        systemImage: "cloud.sun",
                        description: Text("Add your first location to see outfit recommendations")
                    )
                } else {
                    List {
                        ForEach(viewModel.locations) { location in
                            NavigationLink {
                                LocationDetailView(location: location)
                            } label: {
                                LocationRow(location: location)
                            }
                        }
                        .onDelete { indices in
                            viewModel.deleteLocation(at: indices)
                        }
                    }
                    .refreshable {
                        viewModel.refreshLocations()
                    }
                }
            }
            .navigationTitle("Weather Outfits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddView = true
                    } label: {
                        Label("Add Location", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddLocationView(viewModel: viewModel)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .onAppear {
                viewModel.loadLocations()
            }
        }
    }
}
#Preview {
    MainView()
}
