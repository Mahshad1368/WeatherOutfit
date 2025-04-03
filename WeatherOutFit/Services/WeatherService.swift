//
//  WeatherService.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import Foundation
import CoreLocation

///// Handles weather data fetching from API 

class WeatherService {
    @Published var currentWeather: WeatherResponse? // Adjust the type based on your model
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let apiKey = "9564ec2ac4daa340658af035197102c0" // Replace with your actual API key
    
    enum LocationQuery {
            case city(String)
            case coordinates(latitude: Double, longitude: Double)
        }
        
        func fetchWeather(for query: LocationQuery) async throws -> WeatherResponse {
            let urlString: String
            
            switch query {
            case .city(let name):
                guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    throw NetworkError.invalidURL
                }
                urlString = "\(baseURL)/weather?q=\(encodedName)&appid=\(apiKey)&units=metric"
                
            case .coordinates(let latitude, let longitude):
                urlString = "\(baseURL)/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
            }
            
            guard let url = URL(string: urlString) else {
                throw NetworkError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            
            do {
                return try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
            
            self.currentWeather = WeatherResponse(
                        name: "Sample",
                        main: Main(temp: 20, humidity: 60, temp_min: 18, temp_max: 22),
                        weather: [Weather(main: "Clouds", description: "", icon: "02d")],
                        wind: Wind(speed: 5, deg: 0),
                        dt: Date().timeIntervalSince1970
                    )
            
            
            // Simulate fetching weather data (replace with your actual API call)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.currentWeather = WeatherResponse(
                            name: "Paris",
                            main: Main(temp: 13, humidity: 60, temp_min: 11, temp_max: 15),
                            weather: [Weather(main: "Clouds", description: "Bewölkt", icon: "02d")],
                            wind: Wind(speed: 5, deg: 0),
                            dt: Date().timeIntervalSince1970
                        )
                    }
        }
        
        func fetchForecast(for city: String) async throws -> ForecastResponse {
            let urlString = "\(baseURL)/forecast?q=\(city)&appid=\(apiKey)&units=metric&cnt=40"
            
            guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
                throw NetworkError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            
            do {
                return try JSONDecoder().decode(ForecastResponse.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        }
        
        enum NetworkError: Error {
            case invalidURL
            case invalidResponse
            case decodingError
        }
    }
