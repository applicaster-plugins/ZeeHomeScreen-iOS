import Zee5CoreSDK
import zee5mixpanelplugin
import Foundation
import SystemConfiguration

@objc public final class AnalyticsUtil: NSObject {
    
    func reportTabVisitedAnalyticsIfApplicable(atomFeedUrl: String?) {
        guard let atomFeedUrl = atomFeedUrl else { return }
        guard let base64Url = findQueryStringParameter(url: atomFeedUrl, parameter: "url") else { return }
        guard let dataSourceUrl = decodeBase64(from: base64Url) else { return }
        guard let screenType = findQueryStringParameter(url: dataSourceUrl, parameter: "screen_type") else { return }
        var source = UserDefaults.standard.string(forKey: "analyticsSource")
        let currentlyTab = UserDefaults.standard.string(forKey: "currentlyTab") ?? ""

        if currentlyTab != "" {
            source = currentlyTab
        }
        
        UserDefaults.standard.set(source, forKey: "analyticsSource")
        UserDefaults.standard.set(screenType, forKey: "currentlyTab")
        
        var properties = Set<TrackedProperty>()
        properties.insert("TAB_NAME" ~>> screenType)
        properties.insert("PAGE_NAME" ~>> screenType)
        if let source = UserDefaults.standard.string(forKey: "analyticsSource") {
            properties.insert("SOURCE" ~>> source)
        }
        properties.insert("TRACKINGMODE" ~>> String(isInternetAvailable()))
        properties.insert("SUGAR_BOX_VALUE" ~>> false) // is user of sugar box, currently not implemented so pass false]
        analytics.track(mapScreenTypeToVisitedEvent(screenType: screenType), trackedProperties: properties)
        analytics.track(mapScreenTypeToClickEvent(screenType: screenType), trackedProperties: properties)
                
    }
    
    private func getProperties(events: Events, componentModel: ComponentModel) -> Set<TrackedProperty>{
        var properties = Set<TrackedProperty>()
        guard let extention = componentModel.entry?.extensions as? Dictionary <String, Any> else { return properties }
        guard let parameters = extention["analytics"] as? Dictionary <String, Any> else { return properties }
        guard let assetType = extention.intNumber(key:"asset_type") else { return properties }
        let isFromRecomendation = parameters["type"] as? String == "reco"
        
        //saved properties
        let carousel_name = getCollectionName(parameters: parameters)
        let carousel_id = getCollectionId(parameters: parameters)
        let vertical_index = getItemVerticalPosition(parameters: parameters)
        let horisontal_index = getItemPosition(parameters: parameters)
        let talamoos_click_id = getClickedId(isFromRecomendation: isFromRecomendation, parameters: parameters)
        let talamoos_model_name = getModelName(isFromRecomendation: isFromRecomendation, parameters: parameters)
        let talamoos_origin = (isFromRecomendation ? "personalised" : "N/A")
        let preview_status = "N/A"
        
        UserDefaults.standard.set(carousel_name, forKey: "carousal_name")
        UserDefaults.standard.set(carousel_id, forKey: "carousal_id")
        UserDefaults.standard.set(vertical_index, forKey: "vertical_index")
        UserDefaults.standard.set(horisontal_index, forKey: "horisontal_index")
        UserDefaults.standard.set(talamoos_click_id, forKey: "talamoos_click_id")
        UserDefaults.standard.set(talamoos_model_name, forKey: "talamoos_model_name")
        UserDefaults.standard.set(talamoos_origin, forKey: "talamoos_origin")
        UserDefaults.standard.set(preview_status, forKey: "preview_status")

        // default for all
        properties.insert("TAB_NAME" ~>> getScreenName(extention: extention))
        properties.insert("PAGE_NAME" ~>> getScreenName(extention: extention))
        if let source = UserDefaults.standard.string(forKey: "analyticsSource") {
        properties.insert("SOURCE" ~>> source)
        }
        properties.insert("TRACKINGMODE" ~>> String(isInternetAvailable()))
        properties.insert("SUGAR_BOX_VALUE" ~>> false) // is user of sugar box, currently not implemented so pass false
        
        if events == Events.SCREEN_VIEW {
            return properties
        }
        
        if events == Events.ADD_TO_WATCHLIST || events == Events.REMOVE_FROM_WATCHLIST || events == Events.CAROUSAL_BANNER_SWIPE {
            properties.insert("ELEMENT" ~>> getScreenName(extention: extention))
        }
        
        // for all but not for View More selected
        properties.insert("CAROUSAL_NAME" ~>> carousel_name)
        properties.insert("CAROUSAL_ID" ~>> carousel_id)
        properties.insert("VERTICAL_INDEX" ~>> vertical_index)
                
        if events == Events.ADD_TO_WATCHLIST || events == Events.THUMBNAIL_CLICK || events == Events.CAROUSAL_BANNER_CLICK ||
            events == Events.REMOVE_FROM_WATCHLIST || events == Events.CTAS {
            properties.insert("HORIZONTAL_INDEX" ~>> horisontal_index)
        }
        
        if events == Events.CAROUSAL_BANNER_CLICK || events == Events.THUMBNAIL_CLICK || events == Events.SCREEN_VIEW {
            properties.insert( "TALAMOOS_ORIGIN" ~>> talamoos_origin)
            properties.insert( "TALAMOOS_MODELNAME" ~>> talamoos_model_name)
            properties.insert( "TALAMOOS_CLICKID" ~>> talamoos_click_id)
            properties.insert( "HORIZONTAL_INDEX" ~>> horisontal_index)
            properties.insert( "PREVIEW_STATUS" ~>> "N/A")
            properties.insert( "TOP_CATEGORY" ~>> getTopCategory(extention: extention, assetType: assetType))
            properties.insert( "CONTENT_SPECIFICATION" ~>> getContentSpecification(extention: extention, assetType: assetType))
        }
      
        return properties
    }
    
    @objc public func carouselClickerAnalyticsIfApplicable(componentModel: ComponentModel) {
        let properties = getProperties(events: Events.CAROUSAL_BANNER_CLICK, componentModel: componentModel)
        analytics.track(Events.CAROUSAL_BANNER_CLICK, trackedProperties: properties)
    }
    
    @objc public func thumbnailClickerAnalyticsIfApplicable(componentModel: ComponentModel) {
        let properties = getProperties(events: Events.THUMBNAIL_CLICK, componentModel: componentModel)
        analytics.track(Events.THUMBNAIL_CLICK, trackedProperties: properties)
    }
    
    @objc public func carouselSwipeAnalyticsIfApplicable(componentModel: ComponentModel) {
        let properties = getProperties(events: Events.CAROUSAL_BANNER_SWIPE, componentModel: componentModel)
        analytics.track(Events.CAROUSAL_BANNER_SWIPE, trackedProperties: properties)
    }
    
    @objc public func contentBucketSwipeAnalyticsIfApplicable(componentModel: ComponentModel) {
        let properties = getProperties(events: Events.CONTENT_BUCKET_SWIPE, componentModel: componentModel)
        analytics.track(Events.CONTENT_BUCKET_SWIPE, trackedProperties: properties)
    }
    
    @objc public func viewMoreSelectedAnalyticsIfApplicable(componentModel: ComponentModel) {
        let properties = getProperties(events: Events.VIEW_MORE_SELECTED, componentModel: componentModel)
        analytics.track(Events.VIEW_MORE_SELECTED, trackedProperties: properties)
    }
    
    @objc public func pageScrollAnalyticsIfApplicable(componentModel: ComponentModel) {
        let properties = getMixpanelProperties(events: Events.PAGE_SCROLL, componentModel: componentModel)
        analytics.track(Events.PAGE_SCROLL, trackedProperties: properties)
    }
    
    private func getItemPosition (parameters: Dictionary<String, Any>) -> String{
       if let itemPosition = parameters["item_position"] as? Float {
        return String(itemPosition)
       } else{
           return "N/A"
       }
    }
    
    private func getItemVerticalPosition (parameters: Dictionary<String, Any>) -> String{
       if let itemVerticalPosition = parameters["vertical_position"] as? Int {
           return String(itemVerticalPosition)
       } else{
           return "N/A"
       }
    }
    
    private func getCollectionName (parameters: Dictionary<String, Any>) -> String{
       if let collectionName = parameters["collection_name"] as? String {
           return collectionName
       } else{
           return "N/A"
       }
    }
    
    private func getCollectionId (parameters: Dictionary<String, Any>) -> String{
       if let collectionId = parameters["collection_id"] as? String {
           return collectionId
       } else{
           return "N/A"
       }
    }
    
    private func getModelName (isFromRecomendation: Bool, parameters: Dictionary<String, Any>) -> String{
        if let modelName = parameters["model_name"] as? String, isFromRecomendation {
            return modelName
        } else{
            return "N/A"
        }
     }
    
    private func getMainGenre (extention: Dictionary<String, Any>) -> String{
       if let mainGenre = extention["main_genre"] as? String {
           return mainGenre
       } else{
           return ""
       }
    }
    
    private func getScreenName (extention: Dictionary<String, Any>) -> String{
       if let screenName = extention["screen_name"] as? String {
           return screenName
       } else{
           return "N/A"
       }
    }
    
    private func getTopCategory (extention: Dictionary<String, Any>, assetType: Int) -> String{
        let subtype = getSubType(extention: extention)
        let mainGenre = getMainGenre(extention: extention)
        print("subtype main genre \(subtype) ____ \(assetType) _______\(mainGenre)")
        
        if assetType == 0 {
            if subtype == "movie" {
                return "Movie"
            } else if subtype == "video" && mainGenre == "news" {
                return "News"
            } else if subtype == "video" && mainGenre == "music" {
                return "music"
            } else if subtype == "video" {
                return "Video"
            } else {
            return "N/A"
            }
        }
        
        else if assetType == 1 {
            if subtype != "original" {
                return "Tv show"
            } else {
                return "Original"
            }
        }
        
        else if assetType == 6 {
            return subtype
        }
        
        else {
            return "N/A"
        }
    }
    
    private func getSubType (extention: Dictionary<String, Any>) -> String{
       if let subType = extention["asset_subtype"] as? String {
           return subType
       } else{
           return ""
       }
    }
    
    private func getClickedId (isFromRecomendation: Bool, parameters: Dictionary<String, Any>) -> String{
       if let modelClickedId = parameters["click_id"] as? String, isFromRecomendation {
           return modelClickedId
       } else{
           return "N/A"
       }
    }
    
    private func getContentSpecification (extention: Dictionary<String, Any>, assetType: Int) -> String{

        if (assetType == 0 || assetType == 1 || assetType == 6) {
           return getSubType(extention: extention)
        } else {
            return "N/A"
        }
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func reportHomeLandingOnHomeScreenIfApplicable(atomFeedUrl: String?) {
        guard let atomFeedUrl = atomFeedUrl,
              let base64Url = findQueryStringParameter(url: atomFeedUrl, parameter: "url"),
              let dataSourceUrl = decodeBase64(from: base64Url),
              let screenType = findQueryStringParameter(url: dataSourceUrl, parameter: "screen_type")
        else { return }
            
        if screenType == "home" {
            analytics.track(Events.LANDING_ON_HOME_SCREEN, trackedProperties: Set<TrackedProperty>())
        }
    }

    func findQueryStringParameter(url: String, parameter: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == parameter })?.value
    }

    func decodeBase64(from: String) -> String? {
        guard let data = Data(base64Encoded: from) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func mapScreenTypeToVisitedEvent(screenType: String) -> Events {
        switch (screenType) {
        case "home":
            return Events.HOMEPAGE_VISITED
        case "tvshows":
            return Events.TVSHOWSSECTION_VISITED
        case "premium":
            return Events.PREMIUMSECTION_VISITED
        case "movies":
            return Events.MOVIESECTION_VISITED
        case "videos":
            return Events.VIDEOSECTION_VISITED
        case "livetv":
            return Events.LIVETVSECTION_VISITED
        case "news":
            return Events.NEWSSECTION_VISITED
        case "originals":
            return Events.ORIGINALSECTION_VISITED
        default:
            return Events.HOMEPAGE_VISITED
        }
    }
    
    private func mapScreenTypeToClickEvent(screenType: String) -> Events {
        switch (screenType) {
        case "home":
            return Events.HOME_CLICK_HOME
        case "tvshows":
            return Events.HOME_CLICK_TVSHOWS
        case "premium":
            return Events.HOME_CLICK_PREMIUM
        case "movies":
            return Events.HOME_CLICK_MOVIES
        case "videos":
            return Events.HOME_CLICK_VIDEOS
        case "livetv":
            return Events.HOME_CLICK_LIVETV
        case "news":
            return Events.HOME_CLICK_NEWS
        case "originals":
            return Events.HOME_CLICK_ORIGINALS
        default:
            return Events.HOME_CLICK_HOME
        }
    }
}
