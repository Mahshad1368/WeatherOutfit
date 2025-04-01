//
//  Location.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import Foundation
import SwiftUICore
import CoreLocation


public struct Location: Identifiable, Equatable, Hashable, Codable {
    public let id = UUID()
    public let name: String
    public let temperature: Double
    public let weatherCondition: String
    public let humidity: Int
    public let windSpeed: Double
    public let iconCode: String
    public var genderPreference: Gender
    public let coordinate: CLLocationCoordinate2D?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, temperature, weatherCondition, humidity, windSpeed, iconCode, genderPreference
        case latitude, longitude
    }
    
    public var outfitRecommendation: OutfitRecommendation {
        let weatherResponse = WeatherResponse(
            name: name,
            main: Main(temp: temperature, humidity: humidity, temp_min: temperature-2, temp_max: temperature+2),
            weather: [Weather(main: weatherCondition, description: "", icon: iconCode)],
            wind: Wind(speed: windSpeed, deg: 0),
            dt: Date().timeIntervalSince1970
        )
        return OutfitRecommender.recommendOutfit(for: weatherResponse, gender: genderPreference)
    }
    
    public init(name: String,
                temperature: Double,
                weatherCondition: String,
                humidity: Int,
                windSpeed: Double,
                iconCode: String,
                genderPreference: Gender,
                coordinate: CLLocationCoordinate2D? = nil) {
        self.name = name
        self.temperature = temperature
        self.weatherCondition = weatherCondition
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.iconCode = iconCode
        self.genderPreference = genderPreference
        self.coordinate = coordinate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        temperature = try container.decode(Double.self, forKey: .temperature)
        weatherCondition = try container.decode(String.self, forKey: .weatherCondition)
        humidity = try container.decode(Int.self, forKey: .humidity)
        windSpeed = try container.decode(Double.self, forKey: .windSpeed)
        iconCode = try container.decode(String.self, forKey: .iconCode)
        
        // Decode genderPreference as String first, then convert to Gender
        let genderString = try container.decode(String.self, forKey: .genderPreference)
        genderPreference = Gender(rawValue: genderString) ?? .unisex
        
        if let latitude = try? container.decode(CLLocationDegrees.self, forKey: .latitude),
           let longitude = try? container.decode(CLLocationDegrees.self, forKey: .longitude) {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(weatherCondition, forKey: .weatherCondition)
        try container.encode(humidity, forKey: .humidity)
        try container.encode(windSpeed, forKey: .windSpeed)
        try container.encode(iconCode, forKey: .iconCode)
        try container.encode(genderPreference.rawValue, forKey: .genderPreference) // Encode as rawValue
        
        if let coordinate = coordinate {
            try container.encode(coordinate.latitude, forKey: .latitude)
            try container.encode(coordinate.longitude, forKey: .longitude)
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
}

