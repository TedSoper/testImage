//
//  APIOperation.swift
//  WeCompeteApp
//
//  Created by Cape Crow on 9/4/15.
//  Copyright (c) 2015 Crow's Nest Digital. All rights reserved.
//

import Foundation
import UIKit

class APIOperation: NSOperation {

    var successCallback: ((Bool, AnyObject) -> ())?
    var failureCallback: ((Bool, NSError?) -> ())?
    
    lazy internal var urlSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 1
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        let urlSession = NSURLSession(configuration: configuration)
        return urlSession
        }()
    
    var apiKeyValues: [String:String]?
    var httpMethod: String? = "POST"
    var apiString: String? = "192.168.11.6"
    
    override var asynchronous: Bool {
        return true
    }
    
    private var isExecuting: Bool = false
    override var executing: Bool {
        get {
            return isExecuting
        }
        
        set {
            willChangeValueForKey("isExecuting")
            isExecuting = executing
            didChangeValueForKey("executing")
        }
    }
    
    private var isFinished: Bool = false
    override var finished: Bool {
        get {
            return isFinished
        }
        
        set {
            willChangeValueForKey("isFinished")
            isFinished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    init (parameters: [String:String], api: String, httpMethod: String) {
        super.init()
        
        self.apiKeyValues = parameters
        self.apiString = api
        self.httpMethod = httpMethod
    }
    
    override func start() {
        executing = true
        finished = false
        
        main()
        
        let mutableRequest = NSMutableURLRequest()
        mutableRequest.HTTPMethod = self.httpMethod!
        mutableRequest.URL = NSURL(string: self.apiString!)
        
        mutableRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        mutableRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        switch (self.httpMethod!) {
            case "POST":
                var postString = ""
                for (key, value) in self.apiKeyValues! {
                    if !postString.isEmpty {
                        postString += "&"
                    }
                    
                    postString += "\(key)=\(value)"
                }
                
                let postData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
                let postLength = String("\(postData!.length)")
                
                mutableRequest.setValue(postLength, forHTTPHeaderField: "Content-Length")
                mutableRequest.HTTPBody = postData
                break
            
            case "GET":
                
                break
            
            default:
            
                break
        }
        
        
        self.urlSession.dataTaskWithRequest(mutableRequest) { (data, response, error) -> Void in
            if error == nil {
                
                // do catch clauses are so beautiful
                // TIP: try throws an error if nil is returned
                // TIP: throw breaks out of the do clause so code is not ran afterwards
                do {
                
                    let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                    
                    print("\(self.apiString!) : \n\(dataDictionary!)")
                        
                    let status = dataDictionary!["status"] as? String
                    if status == "error" {
                        
                        let userInfo = [
                            NSLocalizedDescriptionKey as NSObject : dataDictionary!["message"]!
                            ] as [NSObject: AnyObject]?
                        
                        let statusError: NSError = NSError(domain: "WeCompeteAPI Error", code: 0, userInfo: userInfo)
                        
                        throw statusError
                        
                    }
                    
                    self.reportSuccess(dataDictionary!)

                } catch let error as NSError {
                    
                    print("Raw Data As String:\n\(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
                    self.reportFailedWithError(error)
                    
                }
                
            } else {
                self.reportFailedWithError(error)
            }

        }.resume()
        
        
    }
    
    
    
    func cancelExecution() {
        urlSession.invalidateAndCancel()
        completeOperation()
    }
    
    func completeOperation() {
        isFinished = true
        isExecuting = false
    }
    
    override func cancel() {
        super.cancel()
        cancelExecution()
    }
    
    func reportFailedWithError(error: NSError?, success: Bool = false) {
        print(error)
        dispatch_async(dispatch_get_main_queue(), {

        
            if self.failureCallback == nil {
                
                
                let alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            } else {
                self.failureCallback?(success, error)
            }
            
        })
        completeOperation()
    }
    
    func reportSuccess(results: AnyObject, success: Bool = true) {
        print("Finished task")
        dispatch_async(dispatch_get_main_queue(), {

            successCallback?(success, results)
            
        })
        completeOperation()
    }

    
}
