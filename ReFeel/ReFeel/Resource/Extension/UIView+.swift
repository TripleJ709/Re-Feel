//
//  UIView+.swift
//  ReFeel
//
//  Created by 장주진 on 2/6/26.
//

import UIKit

extension UIView {
    
    func setSpaceGradientBackground() {
        if let oldLayer = layer.sublayers?.first as? CAGradientLayer {
            oldLayer.removeFromSuperlayer()
        }
        
        let gradientLayer = CAGradientLayer()
         
        let topColor = UIColor(red: 0.08, green: 0.08, blue: 0.16, alpha: 1.00)     // #14142B
        let bottomColor = UIColor(red: 0.16, green: 0.16, blue: 0.30, alpha: 1.00)  // #2A2A4E
        
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addTwinklingStars() {
        if self.layer.sublayers?.first(where: { $0.name == "starLayer" }) != nil {
            return 
        }
        let starCount = 30
        
        for _ in 0..<starCount {
            let starSize = CGFloat.random(in: 2...5)
            let star = UIView()
            star.backgroundColor = .white
            star.layer.cornerRadius = starSize / 2
            star.clipsToBounds = true
            star.alpha = 0.3
            star.layer.name = "starLayer"
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            let randomX = CGFloat.random(in: 0...screenWidth)
            let randomY = CGFloat.random(in: 0...screenHeight)
            
            star.frame = CGRect(x: randomX, y: randomY, width: starSize, height: starSize)
            
            self.insertSubview(star, at: 1)
            
            animateStar(star)
        }
    }
    
    private func animateStar(_ star: UIView) {
        let duration = Double.random(in: 1.5...3.0)
        let delay = Double.random(in: 0.0...1.5)
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction],
            animations: {
                star.alpha = 1.0
                star.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: nil
        )
    }
}
