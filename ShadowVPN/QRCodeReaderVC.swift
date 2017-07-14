//
//  QRCodeReaderVC.swift
//  ShadowVPN
//
//  Created by Joe on 16/2/10.
//  Copyright © 2016年 clowwindy. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_WIDTH = UIScreen.main.bounds.width


class QRCodeReaderVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession: AVCaptureSession?
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var focusFrame: UIView?
    var delegate: QRCodeWriteBackDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Albums", style: UIBarButtonItemStyle.plain, target: self, action: #selector(QRCodeReaderVC.selectFromAlbum(_:)))

        self.setupCapture()
        self.configureVideoPreviewLayer()
        self.initializeFocusFrame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func selectFromAlbum(_ sender: UIBarButtonItem) {
        if captureSession != nil {
            captureSession?.stopRunning()
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .denied, .restricted:
            let alert = UIAlertController(title: "No Permission", message: "You should approve ShadowVPN to access your photos", preferredStyle: UIAlertControllerStyle.alert)
            
            let settingAction = UIAlertAction(title: "Setup", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    let settingURL = URL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.shared.openURL(settingURL!)
                })
            })
            alert.addAction(settingAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        default:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { () -> Void in
            if self.captureSession != nil {
                self.captureSession?.startRunning()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = CIImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage)
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)
        let features = detector?.features(in: image!)
        if (features?.count)! > 0 {
            let feature = features?[0] as! CIQRCodeFeature
            self.parseQRCodeContext(context: feature.messageString!)
        } else {
            if captureSession != nil {
                captureSession?.startRunning()
            }
        }
    }
    
    func setupCapture() {
        self.view.backgroundColor = UIColor.black
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .denied, .restricted:
            let alert = UIAlertController(title: "No Permission", message: "You should approve ShadowVPN to access your video capture", preferredStyle: UIAlertControllerStyle.alert)
            
            let settingAction = UIAlertAction(title: "Setup", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                let settingURL = URL(string: UIApplicationOpenSettingsURLString)
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.openURL(settingURL!)
                })
            })
            alert.addAction(settingAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        default:
            self.configureInputDevice()
        }
    }
    
    func configureInputDevice() {
        let captureInput: AnyObject!
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            captureInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            NSLog("\(error)")
            captureInput = nil
        }
        
        captureSession = AVCaptureSession()
        captureSession!.addInput(captureInput as! AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        self.setupScanRect(captureMetaDataOutput: captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    func setupScanRect(captureMetaDataOutput output: AVCaptureMetadataOutput) {
        let scanRect = CGRect(x: (SCREEN_WIDTH - 300) / 2, y: (SCREEN_HEIGHT - 300) / 2, width: 300, height: 300)
        let y = scanRect.origin.x / SCREEN_WIDTH
        let x = scanRect.origin.y / SCREEN_HEIGHT
        let height = scanRect.width / SCREEN_WIDTH
        let width = scanRect.height / SCREEN_HEIGHT
        output.rectOfInterest = CGRect(x: x, y: y, width: width, height: height)
    }
    
    func configureVideoPreviewLayer() {
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        captureVideoPreviewLayer!.frame = self.view.bounds
        self.view.layer.addSublayer(captureVideoPreviewLayer!)
        
        let scanArea = UIView()
        scanArea.frame = CGRect(x: (SCREEN_WIDTH - 300) / 2, y: (SCREEN_HEIGHT - 300) / 2, width: 300, height: 300)
        scanArea.layer.borderColor = UIColor.white.cgColor
        scanArea.layer.borderWidth = 2.0
        self.view.addSubview(scanArea)

        captureSession?.startRunning()
    }
    
    func initializeFocusFrame() {
        focusFrame = UIView()
        focusFrame?.layer.borderColor = UIColor.green.cgColor
        focusFrame?.layer.borderWidth = 5
        self.view.addSubview(focusFrame!)
        self.view.bringSubview(toFront: focusFrame!)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            focusFrame?.frame = CGRect.zero
            return
        }
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = captureVideoPreviewLayer!.transformedMetadataObject(for: objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            focusFrame?.frame = barCodeObject.bounds;
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                self.parseQRCodeContext(context: objMetadataMachineReadableCodeObject.stringValue)
            }
        }
    }
    
    func parseQRCodeContext(context: String) {
        let url: URLComponents = URLComponents(string: context)!
        var config: Dictionary = [String: String]()
        
        if url.scheme == "shadowvpn" && url.host == "QRCode" {
            if captureSession != nil {
                captureSession?.stopRunning()
            }
            for item in url.queryItems! {
                config[item.name] = item.value
            }
            
            self.navigationController?.popViewController(animated: true)
            self.delegate?.writeBack(configuration: config as [String : AnyObject])
            
            // self.dismissViewControllerAnimated(true) { () -> Void in
            //     self.delegate?.writeBack(configuration: config)
            // }
        } else {
            NSLog(" Invalid QRCode Context: %@", context)
        }
        
    }
    
}
