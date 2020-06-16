//
//  HomeContentClickApi.swift
//  Alamofire
//
//  Created by Anton Klysa on 15.06.2020.
//

import Foundation
import Zee5CoreSDK

class HomeContentClickApi {
    
    //MARK: variables
    
    var Model_name: String?
    var Model_ClickId: String?
    
    
    //MARK: main info
    
    func getCountry() -> String
    {
        let country = UserDefaults.standard.value(forKey: "Country")
        if country != nil
        {
            return country as! String
        }
        return "IN"
    }
    
    func getState() -> String{
       
        let state = UserDefaults.standard.value(forKey: "State")
        if state != nil
        {
            return state as! String
        }
        return "NA"
    }
    
    func getTranslation() -> String
    {
        let translation = UserDefaults.standard.value(forKey: "Translation")
        if translation != nil
        {
            return translation as! String
        }
        return "en"
    }
    
    func getAppVersion() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        let majorVersion = infoDictionary!["CFBundleShortVersionString"]
        
        return majorVersion as! String
    }
    
    func getUserAccessToken() -> String
       {
        
        var accesstoken: String = String()
           User.shared.getAccessToken { (token, error) in
            if (error != nil  && User.shared.getType() != .guest){
             // Need to Login here.
                Zee5DeepLinkingManager.shared.openURL(withURL: Zee5DeepLinkingManager.URLs.login.url)
                return
            }else{
                accesstoken = token
            }
        }
        return accesstoken
    }
    func getGwapi() -> String
    {
        return "https://gwapi.zee5.com/content/"
    }
    
    func getVideoClickApi() -> String
    {
        return "https://api.zee5.com/api/v1/click"
    }
    
    func getPlateFormToken() -> String
    {
        let platformToken = UserDefaults.standard.value(forKey: "plateFormToken")
        if platformToken != nil
        {
            return platformToken as! String
        }
        return "Plateform token not available"
    }
    
    func contentConsumption(for item: APAtomEntry) {
        var state = getCountry()
        
        if state == "IN" || state == "In"
        {
            state = "\(state)-\(getState())"
        }
        let requestParams = ["asset_id": item.identifier,
                             "translation": getTranslation(),
                             "languages": "en,hi",
                             "country": getCountry(),
                             "version": getAppVersion(),
                             "region": state]
        
        let userToken: String = getUserAccessToken()
        var guestToken: String = String()
        
        
        
        var requestheaders: [String: String] = ["Content-Type": "application/json",
                              "X-Access-Token": getPlateFormToken(),
                              "X-Z5-AppPlatform": "IOS Mobile",
                              "X-Z5-Appversion": getAppVersion()]
        
        if User.shared.getType() == .guest {
            guestToken = userToken
            requestheaders["X-Z5-Guest-Token"] = guestToken
        } else {
            requestheaders["Authorization"] = userToken
        }
        
        HomeNetworkManager.sharedInstance.makeHTTPGetRequest(urlString: "\(getGwapi())reco", params: requestParams, headers: requestheaders
            , successHandler: { (result) in
                if let buckets: [[String: AnyHashable]] = result["buckets"] as? [[String: AnyHashable]], let modelName: String = (buckets.first!)["modelName"] as? String {
                    self.Model_name = modelName
                }
                if let buckets: [[String: AnyHashable]] = result["buckets"] as? [[String: AnyHashable]], let items: [[String: AnyHashable]] = (buckets.first!)["items"] as? [[String : AnyHashable]], let clickID: String = (items.first!)["clickID"] as? String {
                    self.Model_ClickId = clickID
                }
                
                self.videoClickApi(for: item)
        }) { (error) in
           print("Content Consumption Failed")
        }
    }

    func videoClickApi(for item: APAtomEntry)
    {
        
        var postData: [String: String] = [:]
        postData["type"] = "zee5"
        postData["action"] = "click"
        postData["modelName"] = self.Model_name
        postData["itemID"] = item.identifier
        postData["clickID"] = self.Model_ClickId
        postData["origin"] = ""
        postData["region"] = "IN-MH"
        
        
        var userID = "a027e306-1707-48af-991d-4597a91e0a92"       // Get userId of User
        
        if User.shared.getType() == .guest
        {
            userID = getUserAccessToken()
        }
        
        let requestheaders: [String: String] = ["Content-Type": "application/json",
        "Authorization": userID,
        "X-Z5-AppPlatform": "IOS Mobile",
        "X-Z5-Appversion": getAppVersion()]
        
        HomeNetworkManager.sharedInstance.makeHttpRawPostRequest(requestname: "POST", requestUrl: getVideoClickApi(), params: postData, headers: requestheaders, successHandler: { (result) in
            print(result)
        }) { (error) in
            print("Failure Video Click Api")
        }
    }
}
