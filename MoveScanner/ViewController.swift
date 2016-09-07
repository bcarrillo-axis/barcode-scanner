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
//        let marsView = UIImageView(image: UIImage(named: "mars"))
//        self.view.addSubview(marsView)
        
        self.title = "Usage Scanner"
        //Scan button in nav bar
        let scanBtn = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(gotoScan))
        self.navigationItem.rightBarButtonItem = scanBtn
        
        
        //Set up instructions
        
        let instructionLbl = UILabel()
        let instructionText = "Instructions for Scanning: \n\n" +
                              "1. Ensure you are in a well lit environment \n\n" +
                              "2. Position so that entire barcode lies within center rectangle \n\n" +
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
        
        

        
    }
    

    func barcodeDetected(code: String) {
        let alert = UIAlertController(title: "Barcode Found", message: code, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: {action in self.navigationController?.popViewControllerAnimated(true)}))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    func gotoScan() {
        self.navigationController?.pushViewController(BarcodeReaderVc(), animated: true)
    }
    
    

}

