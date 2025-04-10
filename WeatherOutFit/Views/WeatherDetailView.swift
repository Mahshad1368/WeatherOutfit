////
////  WeatherDetailView.swift
////  WeatherOutFit
////
////  Created by Mahshad Jafari on 27.03.25.
////
import SwiftUI

struct WeatherDetailView: View {
    let location: Location
    let gender: Gender
    @State private var imageOpacity: Double = 0.0 // For Animation 
    
    var body: some View {
        ZStack {
            // Background based on weather
            // Character Illustration
            Image(characterImageName)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Weather Info
                VStack(spacing: 10) {
                    Text(location.name)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: WeatherIconManager.iconName(for: location.iconCode))
                            .foregroundColor(.white)
                            .font(.title)
                        Text("\(Int(location.temperature))°C")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(location.weatherCondition)
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Feels like \(Int(location.temperature))°C")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Outfit Recommendation
                VStack(alignment: .leading, spacing: 10) {
                    Text("What to Wear")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text(outfitRecommendation.clothing)
                        .foregroundColor(.white)
                    
                    Text("Accessories: \(outfitRecommendation.accessories)")
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Notes: \(outfitRecommendation.notes)")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
                .shadow(radius: 5)
                
                Spacer()
            }
            .padding()
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Background
    private var weatherBackground: some View {
        let weatherCondition = location.weatherCondition.lowercased()
        let gradient: LinearGradient
        
        switch weatherCondition {
        case "sunny", "clear":
            gradient = LinearGradient(
                gradient: Gradient(colors: [.yellow, .orange]),
                startPoint: .top,
                endPoint: .bottom
            )
        case "rainy", "rain", "shower rain", "thunderstorm":
            gradient = LinearGradient(
                gradient: Gradient(colors: [.blue, .cyan]),
                startPoint: .top,
                endPoint: .bottom
            )
        case "cloudy", "clouds", "few clouds", "scattered clouds", "broken clouds":
            gradient = LinearGradient(
                gradient: Gradient(colors: [.gray, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
        case "snow":
            gradient = LinearGradient(
                gradient: Gradient(colors: [.white, .gray.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
        case "mist", "fog":
            gradient = LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.5), .white]),
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            gradient = LinearGradient(
                gradient: Gradient(colors: [.gray, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        return gradient
            .ignoresSafeArea()
    }
    
    // MARK: - Character Illustration
    private var characterImageName: String {
        let weatherCondition = location.weatherCondition.lowercased()
        let weatherType: String
        
        switch weatherCondition {
        case "sunny", "clear":
            weatherType = "sunny"
        case "rainy", "rain", "shower rain", "thunderstorm":
            weatherType = "rainy"
        case "cloudy", "clouds", "few clouds", "scattered clouds", "broken clouds":
            weatherType = "cloudy"
        default:
            weatherType = "cloudy" // Fallback to cloudy
        }
        
        let imageName = "\(gender.rawValue)_\(weatherType)"
        
        if UIImage(named: imageName) != nil {
            return imageName
        } else {
            return "unisex_cloudy" // Fallback to a default image
        }
    }
    
    // MARK: - Outfit Recommendation
    private var outfitRecommendation: OutfitRecommendation {
        let weatherResponse = WeatherResponse(
            name: location.name,
            main: Main(temp: location.temperature, humidity: location.humidity, temp_min: 0, temp_max: 0),
            weather: [Weather(main: location.weatherCondition, description: "", icon: location.iconCode)],
            wind: Wind(speed: location.windSpeed, deg: 0),
            dt: Date().timeIntervalSince1970
        )
        return OutfitRecommender.recommendOutfit(for: weatherResponse, gender: gender)
    }
}





