//
//  LocationStore.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import Foundation

class LocationStore: ObservableObject {
    @Published var locations: [Location] = []
    private let weatherService = WeatherService()
    
    func addLocation(city: String) async {
        do {
            let weather = try await weatherService.fetchWeather(for: .city(city))
            let newLocation = Location(
                name: weather.name,
                temperature: weather.main.temp,
                weatherCondition: weather.weather.first?.main ?? "N/A",
                humidity: weather.main.humidity,
                windSpeed: weather.wind.speed,
                iconCode: weather.weather.first?.icon ?? "" ,
                genderPreference: .unisex
            )
            
            DispatchQueue.main.async {
                if !self.locations.contains(where: { $0.name.lowercased() == newLocation.name.lowercased() }) {
                    self.locations.append(newLocation)
                }
            }
        } catch {
            print("Error fetching weather: \(error)")
        }
    }
    
    func removeLocation(_ location: Location) {
        locations.removeAll { $0.id == location.id }
    }
    
    func refreshLocation(_ location: Location) async {
        do {
            let weather = try await weatherService.fetchWeather(for: .city(location.name))
            let updatedLocation = Location(
                name: weather.name,
                temperature: weather.main.temp,
                weatherCondition: weather.weather.first?.main ?? "N/A",
                humidity: weather.main.humidity,
                windSpeed: weather.wind.speed,
                iconCode: weather.weather.first?.icon ?? "",
                genderPreference: .unisex
            )
            
            DispatchQueue.main.async {
                if let index = self.locations.firstIndex(where: { $0.id == location.id }) {
                    self.locations[index] = updatedLocation
                }
            }
        } catch {
            print("Error refreshing location: \(error)")
        }
    }
}
