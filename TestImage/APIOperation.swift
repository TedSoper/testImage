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
    var progressCallback: ((CGFloat) -> ())?
    
    lazy internal var urlSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 1
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        let urlSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return urlSession
        }()
    
    var apiKeyValues: [String:String]?
    var httpMethod: String?
    var apiString: String?
    
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
        
        urlSession.dataTaskWithRequest(mutableRequest) { (data, response, error) -> Void in
            
            guard error == nil else {
                self.reportFailedWithError(error)
                return
            }
            
            // do catch clauses are so beautiful
            // TIP: try throws an error if nil is returned
            // TIP: throw breaks out of the do clause so code is not ran afterwards
            
            
            let resultString = String(data: data!, encoding: NSUTF8StringEncoding)!
            
            resultString.lowercaseString == "thanks" ? self.reportSuccess(resultString) : self.reportFailedWithError(nil)
            
            
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
        
        
        self.failureCallback?(success, error)
        
        completeOperation()
    }
    
    func reportSuccess(results: AnyObject, success: Bool = true) {
        print("Finished task")
        
        successCallback?(success, results)
        
        completeOperation()
    }
    
    
}

extension APIOperation: NSURLSessionTaskDelegate {
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
        progressCallback?(progress)
    }
    
    //    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    //
    //    }
    //
    //    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
    //
    //    }
}
