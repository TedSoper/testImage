//
//  ViewController.swift
//  TestImage
//
//  Created by Cape Crow on 9/14/15.
//  Copyright © 2015 Cape Crow. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var apiOperation: APIOperation!
    
    @IBOutlet weak var uploadPhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func uploadPhotoButtonPressed(sender: UIButton) {
        
        view.endEditing(true)
        
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo", message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            })
            
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Existing", style: UIAlertActionStyle.Default) { (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        imagePickerActionSheet.addAction(cancelButton)
        imagePickerActionSheet.popoverPresentationController?.sourceView = uploadPhotoButton
        presentViewController(imagePickerActionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        shouldAllowInteraction(false)
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let imageData = UIImagePNGRepresentation(selectedImage)!
        let encoded64Image = imageData.base64EncodedDataWithOptions([])
        let stringRepresentation64EncodedImage = NSString(data: encoded64Image, encoding: NSUTF8StringEncoding)!
        
        let parameters: [String:String] = ["image": String(stringRepresentation64EncodedImage)]

        apiOperation = APIOperation(parameters: parameters, api: "http://192.168.11.4:5000", httpMethod: "POST")
        
        apiOperation.successCallback = { (result, response) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.shouldAllowInteraction(true)
                self.alertForSuccess(true)
            })

            
        }
        
        apiOperation.failureCallback = { success, error in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.shouldAllowInteraction(true)
                self.alertForSuccess(false)
            })
        }
        
        apiOperation.progressCallback = { progress in
            print("Progress: \(progress)")
        }
        
        apiOperation.start()
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func alertForSuccess(success: Bool) {
        let message = success ? "Your image was uploaded successfully. Good job Ted!" : "Your image failed to upload. Bad job Ted!"
        let title = success ? "Success" : "FAILED"
        
        let alertController = UIAlertController(title: title, message:  message, preferredStyle: UIAlertControllerStyle.Alert)
        let continueButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(continueButton)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func shouldAllowInteraction(allowInteraction: Bool) {
        
        
        view.window?.tintAdjustmentMode = allowInteraction ? UIViewTintAdjustmentMode.Automatic : UIViewTintAdjustmentMode.Dimmed
        view.tintAdjustmentMode = allowInteraction ? UIViewTintAdjustmentMode.Automatic : UIViewTintAdjustmentMode.Dimmed
        view.userInteractionEnabled = allowInteraction
        
    }
    
}

