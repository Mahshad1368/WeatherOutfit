//
//  LocationMapView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 27.03.25.
//

// LocationMapView.swift - New file for location selection
import SwiftUI
import MapKit

struct LocationMapView: View {
    let gender: Gender
    @StateObject private var locationManager = LocationManager()
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var searchText = ""
    @State private var mapItems: [MKMapItem] = []
    
    var body: some View {
        ZStack(alignment: .top) {
            // نقشه
            Map(position: $locationManager.cameraPosition) {
                // نمایش موقعیت کاربر
                UserAnnotation()
                
                // نمایش موقعیت انتخاب‌شده
                if let coordinate = selectedCoordinate {
                    Annotation("Selected", coordinate: coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            // قابلیت کلیک روی نقشه
            .onTapGesture(perform: { point in
                let coordinate = convertToCoordinate(from: point)
                selectedCoordinate = coordinate
                // گرفتن نام شهر از مختصات (اختیاری)
                getLocationName(from: coordinate) { name in
                    searchText = name
                }
            })
            // آپدیت region وقتی دوربین نقشه تغییر می‌کنه
            .onMapCameraChange { context in
                locationManager.region = context.region
            }
            
            // رابط کاربری جستجو
            VStack {
                searchBar
                
                if !mapItems.isEmpty {
                    searchResultsList
                }
                
                Spacer()
                
                if selectedCoordinate != nil {
                    continueButton
                }
            }
        }
    }
    
    // Search Bar
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
        .background(.background)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding()
    }
    
    // لیست نتایج جستجو
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
    
    // Button "Show Weather"
    private var continueButton: some View {
        NavigationLink {
            if let coordinate = selectedCoordinate {
                WeatherDetailView(
                    location: Location(
                        name: searchText.isEmpty ? "Selected Location" : searchText,
                        temperature: 0, // Will be updated by API
                        weatherCondition: "",
                        humidity: 0,
                        windSpeed: 0,
                        iconCode: "",
                        genderPreference: gender,
                        coordinate: coordinate
                    ),
                    gender: gender
                )
            }
        } label: {
            Text("Show Weather")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    // Search Location
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
    
    // انتخاب مکان از نتایج جستجو
    private func selectLocation(_ coordinate: CLLocationCoordinate2D, name: String) {
        selectedCoordinate = coordinate
        searchText = name
        mapItems = []
        locationManager.cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
    }
    
    // تبدیل نقطه کلیک‌شده به مختصات
    private func convertToCoordinate(from point: CGPoint) -> CLLocationCoordinate2D {
        let region = locationManager.region
        let latDelta = region.span.latitudeDelta * Double(point.y / 300) // 300 یه مقدار تخمینیه
        let lonDelta = region.span.longitudeDelta * Double(point.x / 300)
        return CLLocationCoordinate2D(
            latitude: region.center.latitude + latDelta,
            longitude: region.center.longitude + lonDelta
        )
    }
    
    // گرفتن نام شهر از مختصات (اختیاری)
    private func getLocationName(from coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first, let city = placemark.locality {
                completion(city)
            } else {
                completion("Selected Location")
            }
        }
    }
}

// کلاس LocationManager برای مدیریت موقعیت کاربر
class LocationManager: NSObject, ObservableObject {
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
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            region.center = location.coordinate
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
}
