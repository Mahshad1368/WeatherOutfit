//
//  WeatherViewModel.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//


import Foundation
import Combine
import CoreLocation
import MapKit

class WeatherViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var lastSelectedLocation: Location? // Store the last selected location
    private let weatherService = WeatherService()
    
    init() {
        loadLastSelectedLocation() // Load the last selected location on initialization
    }
    private var cancellables = Set<AnyCancellable>()
    
    func addLocation(name: String, coordinate: CLLocationCoordinate2D, gender: Gender) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let weather = try await weatherService.fetchWeather(
                    for: .coordinates(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                )
                
                let newLocation = Location(
                    name: name.isEmpty ? weather.name : name,
                    temperature: weather.main.temp,
                    weatherCondition: weather.weather.first?.main ?? "",
                    humidity: weather.main.humidity,
                    windSpeed: weather.wind.speed,
                    iconCode: weather.weather.first?.icon ?? "",
                    genderPreference: gender,
                    coordinate: coordinate
                )
                
                DispatchQueue.main.async {
                    if !self.locations.contains(where: {
                        $0.coordinate?.latitude == coordinate.latitude &&
                        $0.coordinate?.longitude == coordinate.longitude
                    }) {
                        self.locations.append(newLocation)
                        self.lastSelectedLocation = newLocation // Update the last selected location
                        self.saveLastSelectedLocation() // Save the new selection
                        
                        self.saveLocations()
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    func setLastSelectedLocation(_ location: Location) {
            lastSelectedLocation = location
            saveLastSelectedLocation()
        }
    
    private func saveLastSelectedLocation() {
            if let location = lastSelectedLocation, let encoded = try? JSONEncoder().encode(location) {
                UserDefaults.standard.set(encoded, forKey: "lastSelectedLocation")
            }
        }
    
    private func loadLastSelectedLocation() {
            if let data = UserDefaults.standard.data(forKey: "lastSelectedLocation"),
               let decoded = try? JSONDecoder().decode(Location.self, from: data) {
                lastSelectedLocation = decoded
            }
        }
    
    func deleteLocation(at indices: IndexSet) {
        locations.remove(atOffsets: indices)
        saveLocations()
    }
    
    func refreshLocations() {
        isLoading = true
        let locationCopies = locations
        
        Task {
            for location in locationCopies {
                do {
                    let weather: WeatherResponse
                    
                    if let coordinate = location.coordinate {
                        weather = try await weatherService.fetchWeather(
                            for: .coordinates(
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude
                            )
                        )
                    } else {
                        weather = try await weatherService.fetchWeather(for: .city(location.name))
                    }
                    
                    let updatedLocation = Location(
                        name: weather.name,
                        temperature: weather.main.temp,
                        weatherCondition: weather.weather.first?.main ?? "",
                        humidity: weather.main.humidity,
                        windSpeed: weather.wind.speed,
                        iconCode: weather.weather.first?.icon ?? "",
                        genderPreference: location.genderPreference,
                        coordinate: location.coordinate
                    )
                    
                    DispatchQueue.main.async {
                        if let index = self.locations.firstIndex(where: { $0.id == location.id }) {
                            self.locations[index] = updatedLocation
                        }
                    }
                } catch {
                    continue
                }
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func saveLocations() {
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: "savedLocations")
        }
    }
    
    func loadLocations() {
        if let data = UserDefaults.standard.data(forKey: "savedLocations"),
           let decoded = try? JSONDecoder().decode([Location].self, from: data) {
            locations = decoded
        }
    }
}
