//
//  BarcodeReaderView.swift
//  MoveScanner
//
//  Created by Beau Carrillo on 9/6/16.
//  Copyright © 2016 Beau Carrillo. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class BarcodeReaderView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    func viewDidLoad() {
        
        let value = UIInterfaceOrientation.LandscapeRight.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        
        //create the session
        session = AVCaptureSession()
        
        //create capture device
        let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        //create input object
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        //Add input to the session
        
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            scanningNotPossible()
        }
        
        //create output object
        let metadataOutput = AVCaptureMetadataOutput()
        
        //Add output to the session
        if (session.canAddOutput(metadataOutput)){
            session.addOutput(metadataOutput)
            
            //send captured data to the delegate object via a serial queue
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            //send captured data to the delegate object via a serial queue
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode128Code]
            
            let interestRect = CGRectMake(0, 0.25, 1, 0.75)
            metadataOutput.rectForMetadataOutputRectOfInterest(interestRect)
            
        } else {
            scanningNotPossible()
        }
        
        //add preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = self.layer.bounds
        self.layer.addSublayer(previewLayer)
        
        
        //begin the capture session
        session.startRunning()
        
        createOverlay(CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        
        let statusLbl = UILabel()
        let statusMessage = "Scanning..."
        
        statusLbl.text = statusMessage
        statusLbl.textColor = UIColor.whiteColor()
        statusLbl.textAlignment = .Center
        statusLbl.font = UIFont(name: "Arial", size: 30) //Use themed font
        statusLbl.sizeToFit()
        
        self.addSubview(statusLbl)
        statusLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            statusLbl.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -20), //plan to use negative ThemeGutter
            statusLbl.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor),
            statusLbl.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor)
            ])
        
        self.layoutIfNeeded()
        
    }
    
    //    override func viewDidAppear(animated: Bool) {
    //        super.viewDidAppear(animated)
    //
    //        self.willRotateToInterfaceOrientation(UIInterfaceOrientation.LandscapeRight, duration: 0.0)
    //    }
    //
    //    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    //        return .LandscapeRight
    //    }
    //
    //    override func shouldAutorotate() -> Bool {
    //        return false
    //    }
    
    
    
    func createOverlay(frame: CGRect) {
        
        //blur Effect
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        self.addSubview(blurEffectView)
        
        let overlayView = blurEffectView
        self.addSubview(overlayView)
        
        let maskLayer = CAShapeLayer()
        
        //create a path with the rect in in it
        let path = CGPathCreateMutable()
        
        CGPathAddRect(path, nil, CGRectMake(0, (overlayView.frame.height/4), overlayView.frame.width, overlayView.frame.height/4))
        CGPathAddRect(path, nil, CGRectMake(0,0, overlayView.frame.width, overlayView.frame.height))
        
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        //release the path since its not covered by ARC
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        
        
    }
    
    //    override func viewWillLayoutSubviews() {
    //        view.setNeedsLayout()
    //        view.setNeedsDisplay()
    //    }
    
    func viewWillAppear(animated: Bool) {

        
        if (session?.running == false) {
            session.startRunning()
        }
    }
    
    func viewWillDisappear(animated: Bool) {

        
        if (session?.running == true) {
            session.stopRunning()
        }
    }
    
    func scanningNotPossible() {
        let alert = UIAlertController(title: "Ineligible Device", message: "Please use a device with a camera", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))  //we should pop back automatically on navController instead of nil
        self.presentViewController(alert, animated: true, completion: nil)
        view.session = nil
    }
    

    

    

    
    

}

