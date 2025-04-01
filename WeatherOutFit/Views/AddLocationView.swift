import SwiftUI
import MapKit
import CoreLocation

struct AddLocationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WeatherViewModel
    @State private var gender: Gender = .unisex
    @State private var showMap = false
    
    var body: some View {
        NavigationStack {
            Form {
//                Section {
//                    Picker("Gender Preference", selection: $gender) {
//                        ForEach(Gender.allCases, id: \.self) { gender in
//                            Text(gender.rawValue.capitalized)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                }
                
                Section {
                    Button {
                        showMap = true
                    } label: {
                        HStack {
                            Image(systemName: "map")
                            Text("Select Location on Map")
                        }
                    }
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showMap) {
                LocationSelectionMapView(gender: gender) { coordinate, name in
                    viewModel.addLocation(
                        name: name,
                        coordinate: coordinate,
                        gender: gender
                    )
                    dismiss()
                }
            }
        }
    }
}

// Renamed to avoid conflict with existing MapView
struct LocationSelectionMapView: View {
    let gender: Gender
    var onLocationSelected: (CLLocationCoordinate2D, String) -> Void
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var locationManager = MapLocationManager()
    @State private var searchText = ""
    @State private var mapItems: [MKMapItem] = []
    @State private var selectedLocation: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $locationManager.cameraPosition) {
                    UserAnnotation()
                    
                    if let coordinate = selectedLocation {
                        Annotation("Selected", coordinate: coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                }
                .onMapCameraChange { context in
                    locationManager.region = context.region
                }
                
                VStack {
                    searchBar
                    
                    if !mapItems.isEmpty {
                        searchResultsList
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if selectedLocation != nil {
                        Button("Done") {
                            if let coordinate = selectedLocation {
                                onLocationSelected(
                                    coordinate,
                                    searchText.isEmpty ? "Selected Location" : searchText
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search location", text: $searchText)
                .onSubmit { searchLocation() }
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding()
    }
    
    private var searchResultsList: some View {
        List(mapItems, id: \.self) { item in
            Button {
                selectLocation(item.placemark.coordinate, name: item.name ?? "Location")
            } label: {
                VStack(alignment: .leading) {
                    Text(item.name ?? "Unknown")
                    Text(item.placemark.title ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.plain)
        .frame(height: 200)
    }
    
    private func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = locationManager.region
        
        Task {
            let search = MKLocalSearch(request: request)
            if let response = try? await search.start() {
                mapItems = response.mapItems
            }
        }
    }
    
    private func selectLocation(_ coordinate: CLLocationCoordinate2D, name: String) {
        selectedLocation = coordinate
        searchText = name
        mapItems = []
        locationManager.cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )}
}

// Renamed to avoid conflict
class MapLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map { location in
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            cameraPosition = .region(region)
        }
    }
}
