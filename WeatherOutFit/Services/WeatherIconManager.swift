//
//  WeatherIconManager.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import Foundation
import SwiftUI

/// Provides appropriate weather icons based on condition codes
class WeatherIconManager {
    
    /// Returns system image name for weather condition code
    /// - Parameter code: OpenWeatherMap icon code
    /// - Returns: SF Symbol name for the weather condition
    static func iconName(for code: String) -> String {
        switch code {
        case "01d": return "sun.max.fill"        // Clear sky (day)
        case "01n": return "moon.fill"           // Clear sky (night)
        case "02d", "03d", "04d": return "cloud.sun.fill"     // Few/scattered/broken clouds (day)
        case "02n", "03n", "04n": return "cloud.moon.fill"    // Few/scattered/broken clouds (night)
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"     // Rain
        case "11d", "11n": return "cloud.bolt.fill"           // Thunderstorm
        case "13d", "13n": return "snow"                      // Snow
        case "50d", "50n": return "cloud.fog.fill"            // Mist/fog
        default: return "questionmark.circle"
        }
    }
    
    /// Returns color for weather condition code
    /// - Parameter code: OpenWeatherMap icon code
    /// - Returns: Color that matches the weather condition
    static func iconColor(for code: String) -> Color {
        switch code {
        case "01d": return .yellow       // Sunny
        case "01n": return .blue         // Clear night
        case "11d", "11n": return .purple    // Thunderstorm
        case "13d", "13n": return .white     // Snow
        case "50d", "50n": return .gray       // Fog
        default: return .orange          // Other conditions
        }
    }
}
