//
//  ErrorView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 26.03.25.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
            
            Text("Error occurred:")
                .font(.headline)
            
            Text(error.localizedDescription)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
//#Preview {
//    ErrorView()
//}
