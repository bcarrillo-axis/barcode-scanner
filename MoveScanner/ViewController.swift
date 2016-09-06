//
//  ViewController.swift
//  MoveScanner
//
//  Created by Beau Carrillo on 9/2/16.
//  Copyright © 2016 Beau Carrillo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add mars for testing blur
        let marsView = UIImageView(image: UIImage(named: "mars"))
        self.view.addSubview(marsView)
        
        self.title = "Usage Scanner"
        //Scan button in nav bar
        let scanBtn = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(gotoScan))
        self.navigationItem.rightBarButtonItem = scanBtn
        
        
        //Set up instructions
        
        let instructionLbl = UILabel()
        let instructionText = "Instructions for Scanning: \n\n" +
                              "1. Ensure you are in a well lit environment \n" +
                              "2. Position so that entire barcode lies within center rectangle \n" +
                              "3. Hold the camera steady to allow a clear focus on the barcode"
        let attributedText = NSMutableAttributedString(string: instructionText)
        let textRange = NSMakeRange(0, 26)
        attributedText.addAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSFontAttributeName: UIFont.boldSystemFontOfSize(20)], range: textRange)
        instructionLbl.attributedText = attributedText
        instructionLbl.textColor = UIColor.blackColor()
        instructionLbl.numberOfLines = 0
        
        
        view.insertSubview(instructionLbl, atIndex: 1)
        instructionLbl.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activateConstraints([
            instructionLbl.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor, constant: 10),
            instructionLbl.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor, constant:10),
            instructionLbl.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor, constant: -10),
        ])
        
        createOverlay(CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))

        
    }
    
    func createOverlay(frame: CGRect) {
        
        //blur Effect
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.view.addSubview(blurEffectView)
        
        let overlayView = blurEffectView
        self.view.addSubview(overlayView)
        
        let maskLayer = CAShapeLayer()
        
        //create a path with the rect in in it
        let path = CGPathCreateMutable()
        
        CGPathAddRect(path, nil, CGRectMake(0, (overlayView.frame.height/4)+84, overlayView.frame.width, overlayView.frame.height/4))
        CGPathAddRect(path, nil, CGRectMake(0,0, overlayView.frame.width, overlayView.frame.height))
        
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        //release the path since its not covered by ARC
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
    }
    
    func gotoScan() {
        self.navigationController?.pushViewController(BarcodeReaderVc(), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

