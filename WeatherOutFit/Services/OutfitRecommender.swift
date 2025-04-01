//
//  OutfitRecommender.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//
//

import Foundation

public struct OutfitRecommendation {
    public let clothing: String
    public let accessories: String
    public let notes: String
    
    public init(clothing: String, accessories: String, notes: String) {
        self.clothing = clothing
        self.accessories = accessories
        self.notes = notes
    }
}

public final class OutfitRecommender {
    
    // Main method with gender support
    public static func recommendOutfit(for weather: WeatherResponse, gender: Gender = .unisex) -> OutfitRecommendation {
        let base = baseRecommendation(for: weather)
        return applyGenderSpecific(base: base, gender: gender)
    }
    
    // MARK: - Private Methods
    
    private static func applyGenderSpecific(base: OutfitRecommendation, gender: Gender) -> OutfitRecommendation {
        switch gender {
        case .male:
            return OutfitRecommendation(
                clothing: base.clothing
                    .replacingOccurrences(of: "dress", with: "button-down shirt")
                    .replacingOccurrences(of: "skirt", with: "chinos"),
                accessories: base.accessories + (base.accessories.isEmpty ? "" : ", watch"),
                notes: base.notes
            )
            
        case .female:
            return OutfitRecommendation(
                clothing: base.clothing
                    .replacingOccurrences(of: "pants", with: "leggings")
                    .replacingOccurrences(of: "t-shirt", with: "blouse"),
                accessories: base.accessories + (base.accessories.isEmpty ? "" : ", scarf"),
                notes: base.notes
            )
            
        case .unisex:
            return base
        }
    }
    
    private static func baseRecommendation(for weather: WeatherResponse) -> OutfitRecommendation {
        let temp = weather.main.temp
        let condition = weather.weather.first?.main.lowercased() ?? ""
        let windSpeed = weather.wind.speed
        let humidity = weather.main.humidity
        
        switch temp {
        case ..<(-10):
            return extremeColdOutfit(windSpeed: windSpeed)
        case -10..<0:
            return veryColdOutfit(windSpeed: windSpeed)
        case 0..<10:
            return coldOutfit(windSpeed: windSpeed, humidity: humidity)
        case 10..<20:
            return coolOutfit(condition: condition, windSpeed: windSpeed)
        case 20..<30:
            return warmOutfit(condition: condition, humidity: humidity)
        default:
            return hotOutfit(condition: condition, humidity: humidity)
        }
    }
    
    private static func extremeColdOutfit(windSpeed: Double) -> OutfitRecommendation {
        let windProtection = windSpeed > 10 ? "windproof " : ""
        return OutfitRecommendation(
            clothing: "\(windProtection)heavy winter parka, thermal underwear, insulated pants",
            accessories: "thermal gloves, scarf, balaclava, warm hat, insulated boots",
            notes: "Limit time outdoors in these extreme conditions"
        )
    }
    
    private static func veryColdOutfit(windSpeed: Double) -> OutfitRecommendation {
        let windProtection = windSpeed > 8 ? "windproof " : ""
        return OutfitRecommendation(
            clothing: "\(windProtection)heavy winter coat, sweater, thermal leggings",
            accessories: "warm gloves, scarf, wool hat",
            notes: "Dress in layers to stay warm"
        )
    }
    
    private static func coldOutfit(windSpeed: Double, humidity: Int) -> OutfitRecommendation {
        let windProtection = windSpeed > 5 ? "wind-resistant " : ""
        var clothing = "\(windProtection)winter coat, sweater, jeans"
        
        if humidity > 80 {
            clothing += ", waterproof outer layer"
        }
        
        return OutfitRecommendation(
            clothing: clothing,
            accessories: "gloves, scarf",
            notes: "Wear warm layers"
        )
    }
    
    private static func coolOutfit(condition: String, windSpeed: Double) -> OutfitRecommendation {
        var clothing = "jacket, long-sleeve shirt"
        if windSpeed > 5 {
            clothing += ", light windbreaker"
        }
        
        return OutfitRecommendation(
            clothing: clothing,
            accessories: condition.contains("rain") ? "umbrella" : "none needed",
            notes: "Dress for cool weather"
        )
    }
    
    private static func warmOutfit(condition: String, humidity: Int) -> OutfitRecommendation {
        var clothing = "t-shirt, shorts or skirt"
        if humidity > 70 {
            clothing += " (choose breathable fabrics)"
        }
        
        return OutfitRecommendation(
            clothing: clothing,
            accessories: condition.contains("sun") ? "sun hat, sunglasses" : "none needed",
            notes: "Apply sunscreen when outdoors"
        )
    }
    
    private static func hotOutfit(condition: String, humidity: Int) -> OutfitRecommendation {
        return OutfitRecommendation(
            clothing: "lightweight t-shirt, shorts",
            accessories: "wide-brimmed hat, sunglasses",
            notes: "Stay in shade and drink plenty of water"
        )
    }
}
