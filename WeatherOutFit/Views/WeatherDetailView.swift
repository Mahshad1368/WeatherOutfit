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
    
    var body: some View {
        ZStack {
            // Background based on weather
            weatherBackground
            
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
                
                // Character Illustration
                Image(characterImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
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






////import SwiftUI
////
/////// Detailed weather view with dynamic background
////struct WeatherDetailView: View {
////    let location: Location
////    let gender: Gender
////    
////    var body: some View {
////        ZStack {
////            // Dynamic background based on gender and weather
////            weatherBackground
////            
////            ScrollView {
////                VStack(spacing: 20) {
////                    weatherInfoCard
////                    outfitRecommendationCard
////                }
////                .padding()
////            }
////        }
////        .navigationTitle(location.name)
////        .navigationBarTitleDisplayMode(.inline)
////    }
////    
////    // MARK: - Background View
////    
////    private var weatherBackground: some View {
////        ZStack {
////            // Fallback colors if images aren't available
////            Color(backgroundColor)
////                .ignoresSafeArea()
////            
////            // If you add images later, use:
////           let imageName = ("\(gender.rawValue)_\(location.weatherCondition.lowercased())")
////            if UIImage(named: imageName) != nil {
////                Image(imageName)
////                    .resizable()
////                    .scaledToFill()
////                    .ignoresSafeArea()
////            }
////                
////        }
////    }
////    
////    // Background color based on gender and weather
////    private var backgroundColor: UIColor {
////        let weatherCondition = location.weatherCondition.lowercased()
////        
////        switch (gender, weatherCondition) {
////        case (.male, "sunny"): return .systemOrange
////        case (.male, "rainy"): return .systemBlue
////        case (.male, _): return .systemTeal
////            
////        case (.female, "sunny"): return .systemPink
////        case (.female, "rainy"): return .systemPurple
////        case (.female, _): return .systemMint
////            
////        case (.unisex, "sunny"): return .systemYellow
////        case (.unisex, "rainy"): return .systemIndigo
////        case (.unisex, _): return .systemGray
////        }
////    }
////    
////    // MARK: - Weather Info Card
////    
////    private var weatherInfoCard: some View {
////        VStack(spacing: 10) {
////            Text(location.weatherCondition)
////                .font(.title)
////            
////            Text("\(Int(location.temperature))°C")
////                .font(.system(size: 72, weight: .thin))
////            
////            HStack(spacing: 20) {
////                Image(systemName: "thermometer")
////                Text("Feels like \(Int(location.temperature))°C")
////            }
////            .font(.title3)
////        }
////        .padding()
////        .background(Color.black.opacity(0.3))
////        .cornerRadius(15)
////        .foregroundColor(.white)
////    }
////    
////    // MARK: - Outfit Recommendation Card
////    
////    private var outfitRecommendationCard: some View {
////        VStack(alignment: .leading, spacing: 15) {
////            Text("Recommended Outfit")
////                .font(.title2)
////                .bold()
////            
////            VStack(alignment: .leading, spacing: 8) {
////                Text("Clothing:")
////                    .bold()
////                Text(outfitRecommendation.clothing)
////            }
////            
////            VStack(alignment: .leading, spacing: 8) {
////                Text("Accessories:")
////                    .bold()
////                Text(outfitRecommendation.accessories)
////            }
////        }
////        .padding()
////        .background(Color.black.opacity(0.3))
////        .cornerRadius(15)
////        .foregroundColor(.white)
////    }
////    
////    // MARK: - Outfit Recommendation Logic
////    
////    private var outfitRecommendation: OutfitRecommendation {
////        let weatherResponse = WeatherResponse(
////            name: location.name,
////            main: Main(temp: location.temperature, humidity: 0, temp_min: 0, temp_max: 0),
////            weather: [Weather(main: location.weatherCondition, description: "", icon: location.iconCode)],
////            wind: Wind(speed: 0, deg: 0),
////            dt: Date().timeIntervalSince1970
////        )
////        
////        return OutfitRecommender.recommendOutfit(for: weatherResponse, gender: .female)
////    }
////}
//
///// Simple outfit recommendation structure
//
////#Preview {
////    WeatherDetailView()
////}
