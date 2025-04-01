////
////  LocationRow.swift
////  WeatherOutFit
////
////  Created by Mahshad Jafari on 26.03.25.
////
//
//import SwiftUI
//
//
///// A single row in the locations list
//struct LocationRow: View {
//    let location: Location
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            WeatherIconView(iconCode: location.iconCode)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(location.name)
//                    .font(.headline)
//                
//                Text("\(Int(location.temperature))°C • \(location.weatherCondition)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
////            Image(systemName: "chevron.right")
////                .foregroundColor(.gray)
//        }
//        .padding(.vertical, 8)
//    }
//}
//
///// Reusable weather icon view
//struct WeatherIconView: View {
//    let iconCode: String
//    
//    var body: some View {
//        Image(systemName: WeatherIconManager.iconName(for: iconCode))
//            .symbolRenderingMode(.multicolor)
//            .font(.title2)
//            .frame(width: 30)
//    }
//}
//
//#Preview {
//    LocationRow(location: Location(
//        name: "Berlin",
//        temperature: 22,
//        weatherCondition: "Sunny",
//        humidity: 65,
//        windSpeed: 10,
//        iconCode: "01d",
//        genderPreference: .unisex
//    ))
//}
