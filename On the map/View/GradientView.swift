//
//  GradientView.swift
//  On the map
//
//  Created by Eyvind on 17/5/22.
//

import Foundation
import UIKit

//@IBDesignable
class GradientView: UIView {
    
    var gradientLayer: CAGradientLayer!
    
    @IBInspectable var firstColor: UIColor = UIColor.red
    @IBInspectable var secondColor: UIColor = UIColor.green
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [firstColor, secondColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = frame
        
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        gradientLayer.frame = frame
    }
    
}
