//
//  ViewController.swift
//  TestImage
//
//  Created by Cape Crow on 9/14/15.
//  Copyright © 2015 Cape Crow. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var photoViewController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        photoViewController = UIImagePickerController()
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        if UIImagePickerController.availableCaptureModesForCameraDevice(UIImagePickerControllerCameraDevice.Front) != nil {
//            
//            photoViewController!.sourceType = UIImagePickerControllerSourceType.Camera
//            photoViewController!.cameraDevice = UIImagePickerControllerCameraDevice.Front
//            
//        } else if UIImagePickerController.availableCaptureModesForCameraDevice(UIImagePickerControllerCameraDevice.Rear) != nil {
//            
//            photoViewController!.sourceType = UIImagePickerControllerSourceType.Camera
//            photoViewController!.cameraDevice = UIImagePickerControllerCameraDevice.Rear
//            
//        } else {
//            
//            let alert = UIAlertView(title: "No Camera Available", message: "This device doesn't have a working camera.", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
//        }

        
        self.photoViewController!.delegate = self
        self.photoViewController!.allowsEditing = true
        self.photoViewController!.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(self.photoViewController!, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        let imageData = UIImagePNGRepresentation(selectedImage)!
        let encoded64Image = imageData.base64EncodedDataWithOptions([])
        let stringRepresentation64EncodedImage = NSString(data: encoded64Image, encoding: NSUTF8StringEncoding)!
        
        let parameters: [String:String] = ["image": String(stringRepresentation64EncodedImage)]
        let apiOperation = APIOperation(parameters: parameters, api: "www.test.com", httpMethod: "POST")
        
        apiOperation.successCallback = { (result, response) in
            
            
        }
        
    }
    
}

