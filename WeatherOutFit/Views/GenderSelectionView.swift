//
//  GenderSelectionView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 27.03.25.
//

// GenderSelectionView.swift
import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender: Gender = .unisex
    @State private var isNavigatingToLocations = false
    @ObservedObject private var weatherVM = WeatherViewModel()
    @State private var buttonScale: [Gender: CGFloat] = [:]
    @State private var imageOpacity: [Gender: Double] = [:] // For animation
    
    var body: some View {
        NavigationStack {
            ZStack {
                // White Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("Select Your Style")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        .scaleEffect(isNavigatingToLocations ? 0.8 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isNavigatingToLocations)
                    
                    genderSelectionButtons
                    
                    continueButton
                    
                    NavigationLink(
                        destination: LocationSelectionView(gender: selectedGender, weatherVM: weatherVM),
                        isActive: $isNavigatingToLocations
                    ) { EmptyView() }
                }
                .padding()
//                .onAppear {
//                    weatherVM.fetchWeather()
//                    // Initialize opacity for animation
//                    Gender.allCases.forEach { gender in
//                        imageOpacity[gender] = 0.0
//                    }
//                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
        }
    }
    
    private var genderSelectionButtons: some View {
        VStack(spacing: 20) {
            ForEach(Gender.allCases, id: \.self) { gender in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedGender = gender
                        buttonScale[gender] = 1.1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            buttonScale[gender] = 1.0
                        }
                    }
                }) {
                    HStack(spacing: 15) {
                        // Animated Character Image
                                                CharacterAnimationView(imageName: characterImageName(for: gender))
                                                    .frame(width: 60, height: 60)
                                                    .background(
                                                        Circle()
                                                            .fill(Color.gray.opacity(0.1))
                                                            .frame(width: 70, height: 70)
                                                    )
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .opacity(imageOpacity[gender] ?? 0.0)
                                                        .animation(.easeInOut(duration: 0.5).delay(Double(Gender.allCases.firstIndex(of: gender) ?? 0) * 0.2), value: imageOpacity[gender])
                                                        .onAppear {
                                                            withAnimation {
                                                                imageOpacity[gender] = 1.0
                                                            }
                                                        }
                        
                        // Gender Button
                        Text(gender.rawValue.capitalized)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                ZStack {
                                    if selectedGender == gender {
                                        genderGradient(for: gender)
                                    } else {
                                        Color.white.opacity(0.8)
                                    }
                                }
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                            )
                            .foregroundColor(selectedGender == gender ? .white : .gray)
                    }
                    .scaleEffect(buttonScale[gender] ?? 1.0)
                }
                .onAppear {
                    buttonScale[gender] = 1.0
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var continueButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.5)) {
                isNavigatingToLocations = true
            }
        }) {
            Text("Continue")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.teal]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
        }
        .scaleEffect(isNavigatingToLocations ? 0.95 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isNavigatingToLocations)
        .padding(.horizontal, 40)
        .padding(.top, 20)
    }
    
    // Function to assign unique gradients per gender
    private func genderGradient(for gender: Gender) -> LinearGradient {
        switch gender {
        case .unisex:
            return LinearGradient(
                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .male:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .female:
            return LinearGradient(
                gradient: Gradient(colors: [Color.pink, Color.purple]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // Function to determine character image based on gender and weather
        private func characterImageName(for gender: Gender) -> String {
            // Map the weather condition to one of the asset weather types: "sunny", "rainy", "cold"
            let weatherCondition = weatherVM.currentWeather?.weather.first?.main.lowercased() ?? "sunny"
            let temperature = weatherVM.currentWeather?.main.temp ?? 20.0 // Use temperature to determine cold weather
            let weatherType: String
            
            switch weatherCondition {
            case "sunny", "clear":
                weatherType = "sunny"
            case "rainy", "rain", "shower rain", "thunderstorm":
                weatherType = "rainy"
            case "cloudy", "clouds", "few clouds", "scattered clouds", "broken clouds":
                // Use temperature to determine if it's cold
                weatherType = temperature < 10.0 ? "cold" : "sunny" // Adjust threshold as needed
            case "snow", "mist", "fog":
                weatherType = "cold"
            default:
                weatherType = temperature < 10.0 ? "cold" : "sunny"
            }
            
            // Construct the image name using the gender and mapped weather type
            let imageName = "\(gender.rawValue)_\(weatherType)"
            
            // Check if the image exists, otherwise fall back to a default
            if UIImage(named: imageName) != nil {
                return imageName
            } else {
                return "unisex_sunny" // Updated fallback image
            }
        }
}


#Preview {
    GenderSelectionView()
}
