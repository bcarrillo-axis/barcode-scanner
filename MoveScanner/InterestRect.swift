//
//  InterestRect.swift
//  MoveScanner
//
//  Created by Beau Carrillo on 9/6/16.
//  Copyright © 2016 Beau Carrillo. All rights reserved.
//

import UIKit

class InterestRect: UIView {
    
    init() {
        super.init(frame: CGRectZero)
        self.opaque = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.opaque = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.opaque = false
    }
    
    override func drawRect(rect: CGRect) {
        self.backgroundColor?.setFill()
        UIRectFill(rect)
        
        let layer = CAShapeLayer()
        let path = CGPathCreateMutable()
        
        CGPathAddRect(path, nil, self.superview!.frame)
        CGPathAddRect(path, nil, bounds)
        
        layer.path = path
        layer.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = layer
    }
}