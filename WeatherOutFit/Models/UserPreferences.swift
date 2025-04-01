//
//  UserPreferences.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import Foundation


class UserPreferences: ObservableObject {
    @Published var coldSensitivity: ColdSensitivity = .normal
    @Published var heatSensitivity: HeatSensitivity = .normal
    @Published var stylePreference: StylePreference = .casual
    
    enum ColdSensitivity: String, CaseIterable, Identifiable {
        case low = "Not sensitive"
        case normal = "Normal"
        case high = "Very sensitive"
        
        var id: String { rawValue }
        
        var temperatureAdjustment: Double {
            switch self {
            case .low: return 3.0
            case .normal: return 0.0
            case .high: return -3.0
            }
        }
    }
    
    enum HeatSensitivity: String, CaseIterable, Identifiable {
        case low = "Not sensitive"
        case normal = "Normal"
        case high = "Very sensitive"
        
        var id: String { rawValue }
        
        var temperatureAdjustment: Double {
            switch self {
            case .low: return -3.0
            case .normal: return 0.0
            case .high: return 3.0
            }
        }
    }
    
    enum StylePreference: String, CaseIterable, Identifiable {
        case casual = "Casual"
        case business = "Business"
        case sporty = "Sporty"
        
        var id: String { rawValue }
    }
}
