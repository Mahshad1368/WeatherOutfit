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
    @Published var locations: [Location] = [] {
        didSet {
            saveLocations()
        }
    }
    @Published var isLoading = false
    @Published var error: String?
    // Store the last selected location
    @Published var lastSelectedLocation: Location? {
        didSet {
            saveLastSelectedLocation()
        }
    }
    private let weatherService = WeatherService()
    
    init() {
        loadLastSelectedLocation() // Load the last selected location on initialization
        loadLocations()
    }
    private var cancellables = Set<AnyCancellable>()

    func loadLocations() {
        if let data = UserDefaults.standard.data(forKey: "savedLocations"),
           let decoded = try? JSONDecoder().decode([Location].self, from: data) {
            locations = decoded
        }
    }
    
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
        }
    
    private func saveLastSelectedLocation() {
            if let location = lastSelectedLocation, let encoded = try? JSONEncoder().encode(location) {
                UserDefaults.standard.set(encoded, forKey: "lastSelectedLocation")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastSelectedLocation")
            }
        }
    
    private func loadLastSelectedLocation() {
            if let data = UserDefaults.standard.data(forKey: "lastSelectedLocation"),
               let decoded = try? JSONDecoder().decode(Location.self, from: data) {
                lastSelectedLocation = decoded
            }
        }
    
    func deleteLocation(at indices: IndexSet) {
        let deletedLocations = indices.map { locations[$0]}
        locations.remove(atOffsets: indices)
        if let lastSelected = lastSelectedLocation, deletedLocations.contains(where: {  $0.id == lastSelected.id }) {
            lastSelectedLocation = nil
            saveLastSelectedLocation()
        }
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
}
