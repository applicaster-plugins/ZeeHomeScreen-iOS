//
//  HomeNetworkManager.swift
//  Alamofire
//
//  Created by Anton Klysa on 15.06.2020.
//

import Foundation

class HomeNetworkManager: NSObject, URLSessionDelegate {
    
    //MARK: static
    
    static let sharedInstance: HomeNetworkManager = HomeNetworkManager()
    
    
    //MARK: requests
    
    func makeHTTPGetRequest(urlString: String, params: [String: AnyHashable], headers: [String: String], successHandler: @escaping (([String: AnyHashable])->()), failureHandler: @escaping ((HomeZEE5SdkError)->())) {
        
        var full_Url_String = "\(urlString)?"
        
        params.forEach { (key,value) in
            full_Url_String.append("\(key)=\(value)&")
        }
        full_Url_String.removeLast(1)
        let request = NSMutableURLRequest()
        let escapedPath = full_Url_String.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        request.url = URL.init(string: escapedPath!)
        request.httpMethod = "GET"
        
        headers.forEach { (arg) in
            
            let (key, value) = arg
            request.setValue(value, forHTTPHeaderField: key)
        }

        let session: URLSession = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        let postDataTask: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            self.checkForValidity(data: data as Data?, response: response, error: error as NSError?, success: { result in
                successHandler(result as! [String : AnyHashable])
            }) { error in
                failureHandler(error)
            }
        })
        postDataTask.resume()
    }
    
    func makeHttpRawPostRequest(requestname: String, requestUrl: String, params: [String: AnyHashable], headers: [String: String], successHandler: @escaping (([String: AnyHashable])->()), failureHandler: @escaping ((HomeZEE5SdkError)->())) {

         let request = NSMutableURLRequest()
        var jsonData: Data?
        do {
             jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let _ {
            
        }
        let postLength = "\(jsonData?.count ?? 0)"
        request.httpBody = jsonData
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.url = URL.init(string: requestUrl)!
        request.httpMethod = requestname
   
        headers.forEach { (arg) in
            
            let (key, value) = arg
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let session: URLSession = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        let postDataTask: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let data = data {
                
                var jsonObj: Any
                do {
                    jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    successHandler(jsonObj as! [String : AnyHashable])
                } catch let error {
                    print(error)
                }
                
            }
        })
        postDataTask.resume()
    }
    
    
    //MARK: validation request
    
    func checkForValidity(data: Data?, response: URLResponse?, error: NSError?, success: (Any) -> (), failure: (HomeZEE5SdkError) -> ()) {
        
        var generalError = HomeZEE5SdkError.init(code: (response as! HTTPURLResponse).statusCode, zeeErrorCode: 0, message: "Unknown error")
        
        var jsonObj: Any
        if let data = data {
            do {
                jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            } catch let error {
                print(error)
                generalError = HomeZEE5SdkError.init(code: (error as NSError).code, zeeErrorCode: 0, message: error.localizedDescription)
                failure(generalError)
                return
            }
            
            switch (response as! HTTPURLResponse).statusCode {
            case 200:
                success(jsonObj)
            case 403, 404, 400, 401:
                if let jsonObj = jsonObj as? NSDictionary, let message = jsonObj["message"] as? String, let code = jsonObj["code"] as? Int {
                    generalError = HomeZEE5SdkError.init(code: (response as! HTTPURLResponse).statusCode, zeeErrorCode: code, message: message)
                }
                failure(generalError)
            default:
                failure(generalError)
            }
        }
    }
}


struct HomeZEE5SdkError {
    
    //MARK: variables
    
    let code: Int
    let zeeErrorCode: Int
    let message: String
    
    
    //MARK init
    
    init(code: Int, zeeErrorCode: Int, message: String) {
        self.code = code
        self.zeeErrorCode = zeeErrorCode
        self.message = message
    }
}
