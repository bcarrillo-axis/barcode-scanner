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
        super.viewDidLoad()
        
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
        } else {
            scanningNotPossible()
        }
        
        //add preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        //target area -- everything outside this rect not considered for bar code recognition
        previewLayer.rectForMetadataOutputRectOfInterest(CGRect(x: 0, y: (view.frame.height/4)+84,width: view.frame.width, height: view.frame.height/4))
        
        //begin the capture session
        session.startRunning()
        
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

