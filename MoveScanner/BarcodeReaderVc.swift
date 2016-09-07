//
//  BarcodeReaderVc.swift
//  MoveScanner
//
//  Created by Beau Carrillo on 9/2/16.
//  Copyright © 2016 Beau Carrillo. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


class BarcodeReaderVc: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        
        
        
        
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
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        
        //begin the capture session
        session.startRunning()
        
        createOverlay(CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        
        let statusLbl = UILabel()
        let statusMessage = "Scanning..."
        
        statusLbl.text = statusMessage
        statusLbl.textColor = UIColor.whiteColor()
        statusLbl.textAlignment = .Center
        statusLbl.font = UIFont(name: "Arial", size: 30) //Use themed font
        statusLbl.sizeToFit()
        
        view.addSubview(statusLbl)
        statusLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            statusLbl.bottomAnchor.constraintEqualToAnchor(self.bottomLayoutGuide.topAnchor, constant: -20), //plan to use negative ThemeGutter
            statusLbl.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            statusLbl.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor)
            ])
        
        self.view.layoutIfNeeded()
        
        super.viewDidLoad()

    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .LandscapeRight
    }
    
    override func shouldAutorotate() -> Bool {
        return true
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
        
        CGPathAddRect(path, nil, CGRectMake(0, (overlayView.frame.height/4) + self.navigationController!.navigationBar.frame.size.height, overlayView.frame.width, overlayView.frame.height/4))
        CGPathAddRect(path, nil, CGRectMake(0,0, overlayView.frame.width, overlayView.frame.height))
        
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        //release the path since its not covered by ARC
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
      
        
    }
    
    override func viewWillLayoutSubviews() {
        view.setNeedsLayout()
        view.setNeedsDisplay()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (session?.running == false) {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (session?.running == true) {
            session.stopRunning()
        }
    }
    
    func scanningNotPossible() {
        let alert = UIAlertController(title: "Ineligible Device", message: "Please use a device with a camera", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))  //we should pop back automatically on navController instead of nil
        presentViewController(alert, animated: true, completion: nil)
        session = nil
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        //get first out object
        if let barcodeData = metadataObjects.first {
            
            //turn into machine readable code
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
            
            if let readableCode  = barcodeReadable {
                //send the barcode as a string to barcodeDetected()
                barcodeDetected(readableCode.stringValue)
            }
            
            //multiple forms of feedback for a hit
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) //iPhone only
            AudioServicesPlaySystemSound(SystemSoundID(1108)) //all devices -- camera shutter sound
            
            session.stopRunning()
        }
    }
    
    func barcodeDetected(code: String) {
        let alert = UIAlertController(title: "Barcode Found", message: code, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: {action in self.navigationController?.popViewControllerAnimated(true)}))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

