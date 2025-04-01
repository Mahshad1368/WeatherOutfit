//
//  LocationDetailView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import SwiftUI

import SwiftUI

/// Detailed view for a single location
struct LocationDetailView: View {
    let location: Location
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                weatherSummarySection
                outfitRecommendationSection
                Spacer()
            }
            .padding()
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var weatherSummarySection: some View {
        VStack(spacing: 8) {
            WeatherIconView(iconCode: location.iconCode)
                .font(.largeTitle)
            
            Text("\(Int(location.temperature))°C")
                .font(.system(size: 50, weight: .thin))
            
            Text(location.weatherCondition)
                .font(.title3)
            
            HStack(spacing: 20) {
                Label("\(location.humidity)%", systemImage: "humidity")
                Label("\(Int(location.windSpeed)) km/h", systemImage: "wind")
            }
            .padding(.top, 8)
        }
    }
    
    private var outfitRecommendationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Outfit")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Clothing:").bold()
                Text(location.outfitRecommendation.clothing)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Accessories:").bold()
                Text(location.outfitRecommendation.accessories)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes:").bold()
                Text(location.outfitRecommendation.notes)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

//#Preview {
//    LocationDetailView()
//}
