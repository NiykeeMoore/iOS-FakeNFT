//
//  StarRatingView.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 06.04.2025.
//

import UIKit

class StarRatingView: UIStackView {
    private let maxRating = 5
    
    var rating: Int = 0 {
        didSet {
            updateStars()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        axis = .horizontal
        alignment = .leading
        spacing = 2
        
        // Create initial star views
        for _ in 1...maxRating {
            addArrangedSubview(UIImageView())
        }
    }
    
    private func updateStars() {
        // Ensure rating is within bounds
        let clampedRating = min(max(rating, 0), maxRating)
        
        for (index, subview) in arrangedSubviews.enumerated() {
            guard let imageView = subview as? UIImageView else { continue }
            
            // Set star image
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 12)
            imageView.image = UIImage(systemName: "star.fill", withConfiguration: imageConfig)
            
            // Set color
            imageView.tintColor = index < clampedRating
            ? UIColor(named: "appYellow")
            : UIColor(named: "appLightGrayDynamic")
        }
    }
}
