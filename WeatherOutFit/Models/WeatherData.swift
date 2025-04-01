//
//  WeatherData.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import Foundation

public struct WeatherResponse: Codable {
    public let name: String
    public let main: Main
    public let weather: [Weather]
    public let wind: Wind
    public let dt: TimeInterval
    
    public init(name: String, main: Main, weather: [Weather], wind: Wind, dt: TimeInterval) {
        self.name = name
        self.main = main
        self.weather = weather
        self.wind = wind
        self.dt = dt
    }
}

public struct Main: Codable {
    public let temp: Double
    public let humidity: Int
    public let temp_min: Double
    public let temp_max: Double
    
    public init(temp: Double, humidity: Int, temp_min: Double, temp_max: Double) {
        self.temp = temp
        self.humidity = humidity
        self.temp_min = temp_min
        self.temp_max = temp_max
    }
    
    public enum CodingKeys: String, CodingKey {
        case temp
        case humidity
        case temp_min
        case temp_max
    }
}


public struct Weather: Codable {
    public let main: String
    public let description: String
    public let icon: String
    
    public init(main: String, description: String, icon: String) {
        self.main = main
        self.description = description
        self.icon = icon
    }
}

public struct Wind: Codable {
    public let speed: Double
    public let deg: Int
    
    public init(speed: Double, deg: Int) {
        self.speed = speed
        self.deg = deg
    }
}
struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
}

public struct ForecastItem: Codable {
    public let dt: TimeInterval
    public let main: Main
    public let weather: [Weather]
    public let wind: Wind
    public let dt_txt: String
}

public struct City: Codable {
    public let name: String
    public let country: String
}

extension ForecastItem {
    func toWeatherResponse() -> WeatherResponse {
        return WeatherResponse(
            name: "", // Forecast items typically don't have location names
            main: self.main,
            weather: self.weather,
            wind: self.wind,
            dt: self.dt
        )
    }
}
