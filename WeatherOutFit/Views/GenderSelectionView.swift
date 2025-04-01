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
    @StateObject private var weatherVM = WeatherViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Select Your Gender Preference")
                    .font(.title)
                    .padding(.bottom, 20)
                
                genderSelectionButtons
                
                continueButton
                
                NavigationLink(
                    destination: LocationSelectionView(gender: selectedGender, weatherVM: weatherVM),
                    isActive: $isNavigatingToLocations
                ) { EmptyView() }
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }
    
    private var genderSelectionButtons: some View {
        VStack(spacing: 15) {
            ForEach(Gender.allCases, id: \.self) { gender in
                Button(action: {
                    selectedGender = gender
                }) {
                    Text(gender.rawValue.capitalized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedGender == gender ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedGender == gender ? .white : .primary)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            isNavigatingToLocations = true
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top, 20)
    }
}
#Preview {
    GenderSelectionView()
}
