//
//  UIView+.swift
//  ReFeel
//
//  Created by 장주진 on 2/6/26.
//

import UIKit

extension UIView {
    
    func setSpaceGradientBackground() {
        if let oldLayer = layer.sublayers?.first(where: { $0.name == "spaceGradient" }) as? CAGradientLayer {
            oldLayer.frame = bounds

            if layer.sublayers?.first != oldLayer {
                oldLayer.removeFromSuperlayer()
                layer.insertSublayer(oldLayer, at: 0)
            }
            return
        }
        
        if let unnamedOldLayer = layer.sublayers?.first as? CAGradientLayer, unnamedOldLayer.name == nil {
            unnamedOldLayer.removeFromSuperlayer()
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "spaceGradient"
         
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
            star.alpha = 0.0
            star.layer.name = "starLayer"
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            let randomX = CGFloat.random(in: 0...screenWidth)
            let randomY = CGFloat.random(in: 0...screenHeight)
            
            star.frame = CGRect(x: randomX, y: randomY, width: starSize, height: starSize)
            
            self.insertSubview(star, at: 0)
            
            animateStar(star)
        }
    
        if let gradientLayer = self.layer.sublayers?.first(where: { $0.name == "spaceGradient" }) {
            gradientLayer.removeFromSuperlayer()
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    private func animateStar(_ star: UIView) {
        let duration = Double.random(in: 1.5...3.0)
        let delay = Double.random(in: 0.0...3.0)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        animationGroup.beginTime = CACurrentMediaTime() + delay
        animationGroup.autoreverses = true
        animationGroup.repeatCount = .infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.2
        opacityAnim.toValue = 0.55
        
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = 1.2
        
        animationGroup.animations = [opacityAnim, scaleAnim]
        
        star.layer.add(animationGroup, forKey: "twinkleAnimation")
    }
}
