//
//  BarcodeReaderVc.swift
//  MoveScanner
//
//  Created by Beau Carrillo on 9/2/16.
//  Copyright © 2016 Beau Carrillo. All rights reserved.
//

import UIKit
import AVFoundation


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
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code]
        } else {
            scanningNotPossible()
        }
        
        //add preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

