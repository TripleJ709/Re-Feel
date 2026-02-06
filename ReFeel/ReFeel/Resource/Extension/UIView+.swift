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
}
