//
//  MapView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 02.04.25.
//


//
////  MapView.swift
////  WeatherOutFit
////
////  Created by Mahshad Jafari on 26.03.25.
////
//
//import SwiftUI
//import MapKit
//
//struct MapView: View {
//    let locations: [Location]
//    let onLocationSelected: (CLLocationCoordinate2D, String) -> Void
//    @State private var cameraPosition: MapCameraPosition = .automatic
//    @State private var tappedCoordinate: CLLocationCoordinate2D?
//    @State private var selectedLocation: Location?
//    
//    private var centerCoordinate: CLLocationCoordinate2D {
//        if let firstLocation = locations.first, let coordinate = firstLocation.coordinate {
//            return coordinate
//        }
//        return CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // Default to Tokyo
//    }
//    
//    var body: some View {
//        Map(position: $cameraPosition) {
‎//            // نمایش موقعیت‌های موجود به صورت Annotation
//            ForEach(locations) { location in
//                if let coordinate = location.coordinate {
//                    Annotation(
//                        location.name,
//                        coordinate: coordinate,
//                        anchor: .center
//                    ) {
//                        VStack(spacing: 4) {
//                            Image(systemName: WeatherIconManager.iconName(for: location.iconCode))
//                                .symbolRenderingMode(.multicolor)
//                                .font(.title3)
//                                .padding(6)
//                                .background(Color(.systemBackground))
//                                .clipShape(Circle())
//                            
//                            Text("\(Int(location.temperature))°")
//                                .font(.caption)
//                                .padding(4)
//                                .background(Color(.systemBackground))
//                                .cornerRadius(4)
//                        }
//                        .shadow(radius: 2)
//                        .onTapGesture {
//                            selectedLocation = location
//                            tappedCoordinate = nil
//                            if let coordinate = location.coordinate {
//                                onLocationSelected(coordinate, location.name)
//                            }
//                        }
//                    }
//                }
//            }
//            
//            // نمایش موقعیت کلیک‌شده روی نقشه به صورت Annotation
//            if let tappedCoordinate = tappedCoordinate {
//                Annotation(
//                    "Selected Location",
//                    coordinate: tappedCoordinate,
//                    anchor: .center
//                ) {
//                    Image(systemName: "mappin.circle.fill")
//                        .foregroundColor(.red)
//                        .font(.title2)
//                        .padding(6)
//                        .background(Color(.systemBackground))
//                        .clipShape(Circle())
//                        .onTapGesture {
//                            onLocationSelected(tappedCoordinate, "Custom Location")
//                        }
//                }
//            }
//        }
//        .mapStyle(.standard)
//        .mapControls {
//            MapUserLocationButton()
//            MapCompass()
//            MapScaleView()
//        }
//        .onTapGesture(perform: { point in
//            let coordinate = convertToCoordinate(from: point)
//            tappedCoordinate = coordinate
//            selectedLocation = nil
//        })
//        .onAppear {
//            setCameraPosition()
//        }
//        .overlay(alignment: .bottom) {
//            if let selectedLocation = selectedLocation {
//                Text("Selected: \(selectedLocation.name) (\(Int(selectedLocation.temperature))°C)")
//                    .padding()
//                    .background(Color(.systemBackground))
//                    .cornerRadius(8)
//                    .padding(.bottom, 20)
//            } else if let tappedCoordinate = tappedCoordinate {
//                Text("Tapped: \(tappedCoordinate.latitude), \(tappedCoordinate.longitude)")
//                    .padding()
//                    .background(Color(.systemBackground))
//                    .cornerRadius(8)
//                    .padding(.bottom, 20)
//            }
//        }
//    }
//    
//    private func setCameraPosition() {
//        cameraPosition = .region(MKCoordinateRegion(
//            center: centerCoordinate,
//            span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
//        ))
//    }
//    
//    private func convertToCoordinate(from point: CGPoint) -> CLLocationCoordinate2D {
//        let region = cameraPosition.region ?? MKCoordinateRegion(
//            center: centerCoordinate,
//            span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
//        )
//        let latDelta = region.span.latitudeDelta * Double(point.y / 300)
//        let lonDelta = region.span.longitudeDelta * Double(point.x / 300)
//        return CLLocationCoordinate2D(
//            latitude: region.center.latitude + latDelta,
//            longitude: region.center.longitude + lonDelta
//        )
//    }
//}
//
//// Preview Provider
//#Preview {
//    MapView(
//        locations: [
//            Location(
//                name: "Tokyo",
//                temperature: 22,
//                weatherCondition: "Clouds",
//                humidity: 65,
//                windSpeed: 10,
//                iconCode: "03d",
//                genderPreference: .unisex,
//                coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)
//            ),
//            Location(
//                name: "Paris",
//                temperature: 15,
//                weatherCondition: "Rain",
//                humidity: 80,
//                windSpeed: 15,
//                iconCode: "10d",
//                genderPreference: .unisex,
//                coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
//            )
//        ],
//        onLocationSelected: { coordinate, name in
//            print("Selected: \(name) at \(coordinate.latitude), \(coordinate.longitude)")
//        }
//    )
//}
