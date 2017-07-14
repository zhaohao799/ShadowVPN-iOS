//
//  QRCodeShareVC.swift
//  ShadowVPN
//
//  Created by Joe on 16/2/11.
//  Copyright © 2016年 clowwindy. All rights reserved.
//

import UIKit
import Photos

class QRCodeShareVC: UIViewController {
    var configQuery: String?
    var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(QRCodeShareVC.save))
        self.title = "Share Configuration"
        
        self.displayQRCodeImage()
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
    
    func displayQRCodeImage() {
        // show Image
        let query: String = self.configQuery!
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(query.data(using: String.Encoding.utf8), forKey: "inputMessage")
        
        let width: CGFloat = 200
        let heigth: CGFloat = 200
        let x = (self.view.bounds.width - width) / 2
        let y = (self.view.bounds.height - heigth) / 2
        
        self.imageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: heigth))
        let codeImage = UIImage(ciImage: (filter?.outputImage)!.applying(CGAffineTransform(scaleX: 10, y: 10)))
        
        let iconImage = UIImage(named: "qrcode_avatar")
        
        let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        codeImage.draw(in: rect)
        let avatarSize = CGSize(width: rect.size.width * 0.25, height: rect.size.height * 0.25)
        let avatar_x = (rect.width - avatarSize.width) * 0.5
        let avatar_y = (rect.height - avatarSize.height) * 0.5
        iconImage!.draw(in: CGRect(x: avatar_x, y: avatar_y, width: avatarSize.width, height: avatarSize.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        // let tapGR = UITapGestureRecognizer(target: self, action: "tapImage:")
        // imageView.userInteractionEnabled = true
        // imageView.addGestureRecognizer(tapGR)
        
        self.imageView.image = resultImage
        self.view.addSubview(self.imageView)
    }
    
    // func tapImage(sender: UITapGestureRecognizer) {
    //     print("image view tapped")
    // }
    
    func save() {
        // save code image to album
        
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
            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(QRCodeShareVC.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }

    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if (error != nil) {
            NSLog("%@", error!)
        } else {
            let alert = UIAlertController(title: "Saved", message: "Image save to Photos", preferredStyle: UIAlertControllerStyle.alert)
            let done = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) -> Void in
                self.navigationController?.popToRootViewController(animated: true)
            })
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
            NSLog("saved image to album")
        }
    }

}
