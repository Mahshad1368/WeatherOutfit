import SwiftUI
import CoreLocation

struct LocationSelectionView: View {
    let gender: Gender
    @ObservedObject var weatherVM: WeatherViewModel
    @StateObject private var locationVM = LocationViewModel()
    @State private var selectedLocation: Location?
    @State private var showingAddLocation = false
    
    var body: some View {
        NavigationStack {
            List {
                // Current Location Section
                if locationVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let currentLocation = locationVM.currentLocation {
                    Section(header: Text("Current Location")) {
                        LocationRow(location: currentLocation)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedLocation = currentLocation
                                weatherVM.setLastSelectedLocation(currentLocation)
                            }
                    }
                }
                
                // Saved Locations Section
                if !weatherVM.locations.isEmpty {
                    Section(header: Text("Saved Locations")) {
                        ForEach(weatherVM.locations) { location in
                            LocationRow(location: location)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedLocation = location
                                    weatherVM.setLastSelectedLocation(location)
                                }
                        }
                        .onDelete { indices in
                            weatherVM.locations.remove(atOffsets: indices)
                        }
                    }
                }
            }
            .navigationTitle("Select Location")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddLocation = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                LocationSelectionMapView(gender: gender) { coordinate, name in
                    weatherVM.addLocation(name: name, coordinate: coordinate, gender: gender)
                }
            }
            .background(
                Group {
                    if let location = selectedLocation {
                        NavigationLink(
                            destination: WeatherDetailView(location: location, gender: gender),
                            tag: location,
                            selection: $selectedLocation
                        ) { EmptyView() }
                    }
                }
            )
            .alert("Error", isPresented: .constant(locationVM.error != nil)) {
                Button("OK", role: .cancel) { locationVM.error = nil }
            } message: {
                Text(locationVM.error?.localizedDescription ?? "Unknown error")
            }
            .onAppear {
                locationVM.requestLocation()
                // If there's a last selected location, set it as the selected location
                if let lastLocation = weatherVM.lastSelectedLocation {
                    selectedLocation = lastLocation
                } else if let currentLocation = locationVM.currentLocation {
                    // If no last selected location, use the current location on first launch
                    selectedLocation = currentLocation
                    weatherVM.setLastSelectedLocation(currentLocation)
                }
            }
        }
    }
}

// Simplified LocationRow as a nested struct
struct LocationRow: View {
    let location: Location
    
    var body: some View {
        HStack(spacing: 12) {
            WeatherIconView(iconCode: location.iconCode)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                
                Text("\(Int(location.temperature))°C • \(location.weatherCondition)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct WeatherIconView: View {
    let iconCode: String
    
    var body: some View {
        Image(systemName: WeatherIconManager.iconName(for: iconCode))
            .symbolRenderingMode(.multicolor)
            .font(.title2)
            .frame(width: 30)
    }
}
