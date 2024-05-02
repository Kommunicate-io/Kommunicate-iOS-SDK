//
//  KMFiveStarView.swift
//  Kommunicate
//
//  Created by Abhijeet Ranjan on 02/05/24.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import UIKit

class KMFiveStarView: UIView {
    
    var ratingSelected: ((KMStarRatingType) -> Void)?
    
    var starButtons: [UIButton] = []
    private var rating: Int = 0 {
        didSet {
            updateStars()
        }
    }
        
    var maxRating: Int = 5 {
        didSet {
            setupStars()
        }
    }
        
    var ratingDidChange: ((Int) -> Void)?
        
    var filledStarImage: UIImage?
    var emptyStarImage: UIImage?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStars()
    }
        
    func setupStars() {
        starButtons.forEach { $0.removeFromSuperview() }
        starButtons.removeAll()
        for i in 0..<maxRating {
            let starButton = UIButton()
            starButton.tag = i
            starButton.setImage(emptyStarImage, for: .normal)
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            addSubview(starButton)
            starButtons.append(starButton)
        }
        updateStars()
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        let starSize = CGSize(width: self.bounds.height, height: self.bounds.height)
        let spacing = (self.bounds.width - CGFloat(maxRating) * starSize.width) / CGFloat(maxRating + 1)
            
        for (index, starButton) in starButtons.enumerated() {
            let x = CGFloat(index) * (starSize.width + spacing) + spacing
            starButton.frame = CGRect(origin: CGPoint(x: x, y: 0), size: starSize)
        }
    }
        
    @objc private func starTapped(_ sender: UIButton) {
        rating = sender.tag + 1
        ratingDidChange?(rating)
    }
        
    private func updateStars() {
        for (index, starButton) in starButtons.enumerated() {
            let starImage = index < rating ? filledStarImage : emptyStarImage
            starButton.setImage(starImage, for: .normal)
        }
    }
}
