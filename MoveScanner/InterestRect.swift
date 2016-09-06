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
        let context = UIGraphicsGetCurrentContext()
        
        var uRect = self.superview!.frame
        var oRect = self.frame
        
        var rectIntersect = CGRectIntersection(uRect, oRect)
        
        UIColor.clearColor().setFill()
        UIRectFill(rectIntersect)
        
    }
}