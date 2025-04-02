//
//  LocationViewModel.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import Foundation
import CoreLocation
import Combine

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
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
        // چک کردن وضعیت مجوز قبل از هر اقدامی
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // اگه هنوز مجوز گرفته نشده، درخواست مجوز کن
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // اگه مجوز داده شده، موقعیت رو بگیر
            locationManager.requestLocation()
        case .denied, .restricted:
            // اگه کاربر دسترسی رو رد کرده یا محدود شده، خطا نشون بده
            DispatchQueue.main.async {
                self.error = NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Location access was denied. Please enable it in Settings."]
                )
                self.isLoading = false
            }
        @unknown default:
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func fetchWeatherForCurrentLocation(latitude: Double, longitude: Double) async {
        do {
            let weather = try await weatherService.fetchWeather(
                for: .coordinates(latitude: latitude, longitude: longitude)
            )
            let location = Location(
                name: weather.name,
                temperature: weather.main.temp,
                weatherCondition: weather.weather.first?.main ?? "N/A",
                humidity: weather.main.humidity,
                windSpeed: weather.wind.speed,
                iconCode: weather.weather.first?.icon ?? "",
                genderPreference: .unisex,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
            // اگه کاربر اجازه داده، موقعیت رو بگیر
            locationManager.requestLocation()
        case .denied, .restricted:
            // اگه کاربر دسترسی رو رد کرده یا محدود شده، خطا نشون بده
            DispatchQueue.main.async {
                self.error = NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Location access was denied. Please enable it in Settings."]
                )
                self.isLoading = false
            }
        case .notDetermined:
            // اگه وضعیت هنوز مشخص نیست، منتظر تصمیم کاربر بمون
            break
        @unknown default:
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    // برای سازگاری با نسخه‌های قدیمی‌تر iOS
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.error = NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Location access was denied. Please enable it in Settings."]
                )
                self.isLoading = false
            }
        case .notDetermined:
            break
        @unknown default:
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
