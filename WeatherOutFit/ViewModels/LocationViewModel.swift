//
//  LocationViewModel.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import Foundation
import CoreLocation
import Combine

class LocationViewModel: NSObject, ObservableObject {
    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: Location?
    @Published var isLoading = false
    @Published var error: Error?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        isLoading = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func fetchWeatherForCurrentLocation(latitude: Double, longitude: Double) async {
        do {
            let weather = try await weatherService.fetchWeather(for: .coordinates(latitude: latitude, longitude: longitude))
            let location = Location(
                name: weather.name,
                temperature: weather.main.temp,
                weatherCondition: weather.weather.first?.main ?? "N/A",
                humidity: weather.main.humidity,
                windSpeed: weather.wind.speed,
                iconCode: weather.weather.first?.icon ?? "",
                genderPreference: .unisex
            )
            
            DispatchQueue.main.async {
                self.currentLocation = location
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
            }
        }
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task {
            await fetchWeatherForCurrentLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = error
            self.isLoading = false
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        default:
            break
        }
    }
}

