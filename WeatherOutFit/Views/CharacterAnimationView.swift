//
//  CharacterAnimationView.swift
//  WeatherOutFit
//
//  Created by Mahshad Jafari on 03.04.25.
//

import SwiftUI

import SwiftUI

// A SwiftUI view to display animated GIFs for characters
struct CharacterAnimationView: UIViewRepresentable {
    let imageName: String // e.g., "female_sunny", "male_rainy"
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Load the animated GIF
        if let gif = UIImage.animatedImageNamed(imageName, duration: 1.0) {
            imageView.image = gif
        } else {
            // Fallback to a static image if the GIF fails to load
            imageView.image = UIImage(named: imageName) ?? UIImage(named: "unisex_sunny")
        }
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the image if needed
        if let imageView = uiView.subviews.first as? UIImageView {
            if let gif = UIImage.animatedImageNamed(imageName, duration: 1.0) {
                imageView.image = gif
            } else {
                imageView.image = UIImage(named: imageName) ?? UIImage(named: "unisex_sunny")
            }
        }
    }
}

