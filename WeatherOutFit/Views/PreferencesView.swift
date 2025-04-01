//
//  PreferencesView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var preferences: UserPreferences
    
    var body: some View {
        Form {
            Section(header: Text("Sensitivity Preferences")) {
                Picker("Cold Sensitivity", selection: $preferences.coldSensitivity) {
                    ForEach(UserPreferences.ColdSensitivity.allCases) { sensitivity in
                        Text(sensitivity.rawValue).tag(sensitivity)
                    }
                }
                
                Picker("Heat Sensitivity", selection: $preferences.heatSensitivity) {
                    ForEach(UserPreferences.HeatSensitivity.allCases) { sensitivity in
                        Text(sensitivity.rawValue).tag(sensitivity)
                    }
                }
            }
            
            Section(header: Text("Style Preference")) {
                Picker("Preferred Style", selection: $preferences.stylePreference) {
                    ForEach(UserPreferences.StylePreference.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Preferences")
    }
}

#Preview {
    PreferencesView()
}
