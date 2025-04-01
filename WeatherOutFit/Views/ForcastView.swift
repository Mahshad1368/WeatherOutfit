//
//  ForcastView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import SwiftUI

struct ForecastView: View {
    let location: Location
    @State private var forecast: ForecastResponse?
    @State private var isLoading = false
    @State private var error: Error?
    private let weatherService = WeatherService()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let forecast {
                forecastContent(forecast)
            } else if let error {
                ErrorView(error: error)
            }
        }
        .navigationTitle("\(location.name) Forecast")
        .task {
            await loadForecast()
        }
    }
    
    @ViewBuilder
    private func forecastContent(_ forecast: ForecastResponse) -> some View {
        List {
            ForEach(groupForecastsByDay(forecast.list), id: \.date) { day in
                Section(header: Text(day.date.formatted(date: .abbreviated, time: .omitted))) {
                    ForEach(day.items, id: \.dt) { item in
                        ForecastRow(item: item)
                    }
                }
            }
        }
        .listStyle(.grouped)
    }
    
    private func loadForecast() async {
        isLoading = true
        do {
            forecast = try await weatherService.fetchForecast(for: location.name)
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    private func groupForecastsByDay(_ items: [ForecastItem]) -> [ForecastDay] {
        let grouped = Dictionary(grouping: items) { item in
            let date = Date(timeIntervalSince1970: item.dt)
            return Calendar.current.startOfDay(for: date)
        }
        
        return grouped.map { date, items in
            ForecastDay(date: date, items: items)
        }.sorted { $0.date < $1.date }
    }
}

struct ForecastDay {
    let date: Date
    let items: [ForecastItem]
}

struct ForecastRow: View {
    let item: ForecastItem
    
    var body: some View {
        HStack {
            Text(item.dt_txt.formattedTime())
                .frame(width: 80, alignment: .leading)
            
            Image(systemName: WeatherIconManager.iconName(for: item.weather.first?.icon ?? ""))
                .foregroundColor(WeatherIconManager.iconColor(for: item.weather.first?.icon ?? ""))
                .frame(width: 30)
            
            Text("\(Int(item.main.temp))°C")
                .frame(width: 60, alignment: .leading)
            
            Text(item.weather.first?.main ?? "")
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Now using the correct method for ForecastItem
            Text(OutfitRecommender.recommendOutfit(for: item.toWeatherResponse()).clothing.components(separatedBy: ",").first ?? "")
                .font(.caption)
                .lineLimit(1)
        }
    }
}

extension String {
    func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: self) else { return self }
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ForecastView(location: Location(
            name: "Tokyo",
            temperature: 22,
            weatherCondition: "Clouds",
            humidity: 65,
            windSpeed: 10,
            iconCode: "03d",
            genderPreference: .unisex
        ))
    }
}
