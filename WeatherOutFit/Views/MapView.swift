//
//  MapView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import SwiftUI
import MapKit

struct MapView: View {
    let locations: [Location]
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Default center coordinate (can be adjusted)
    private var centerCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // Default to Tokyo
    }
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(locations) { location in
                Annotation(
                    location.name,
                    coordinate: centerCoordinate, // Or use actual coordinates if available
                    anchor: .center
                ) {
                    VStack(spacing: 4) {
                        Image(systemName: WeatherIconManager.iconName(for: location.iconCode))
                            .symbolRenderingMode(.multicolor)
                            .font(.title3)
                            .padding(6)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                        
                        Text("\(Int(location.temperature))°")
                            .font(.caption)
                            .padding(4)
                            .background(Color(.systemBackground))
                            .cornerRadius(4)
                    }
                    .shadow(radius: 2)
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            setCameraPosition()
        }
    }
    
    private func setCameraPosition() {
        cameraPosition = .region(MKCoordinateRegion(
            center: centerCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
        ))
    }
}

// Preview Provider
#Preview {
    MapView(locations: [
        Location(
            name: "Tokyo",
            temperature: 22,
            weatherCondition: "Clouds",
            humidity: 65,
            windSpeed: 10,
            iconCode: "03d",
            genderPreference: .unisex
        ),
        Location(
            name: "Paris",
            temperature: 15,
            weatherCondition: "Rain",
            humidity: 80,
            windSpeed: 15,
            iconCode: "10d",
            genderPreference: .unisex
        )
    ])
}
