//
//  ScreenConfiguration.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import Foundation
import ApplicasterSDK

enum AdditionalContentType: String {
    case continueWatching = "continue_watching"
    case recommendations = "recommendation"
    case relatedCollection = "related_collections"
    case banners = "banner_ds"
}

struct ScreenConfiguration {
    
    var feed: APAtomFeed?
    
    // determined the screen ds
    var ds: String?
    
    var additionalContent: [AdditionalContent] = []
    
    //the number of componentModels need to be load in each request.
    var numberOfComponentsToLoad: Int?
    
    // the threshold that determine that need to load more items
    var componentsThresholdIndex: Int?
    var paddingHorizontal: Int = 10
    var paddingTop: Int = 10
    var paddingBottom: Int = 10
    var divider: Int = 10
    var shouldShowInterstitial = true
    var shouldDisplayEPG = false
    var epgScreenID: String?

    /// Init
    public init(config: [String: Any]?, style: [String: Any]?, dataSource: APAtomFeed?, configurationJSON: NSDictionary?) {
        guard let config = config, let style = style else {
            return
        }
        
        if let dataSource = dataSource {
            self.feed = dataSource
        }
        
        if let shouldDisplayEPG = config["should_display_epg"] as? String {
            self.shouldDisplayEPG = Int(shouldDisplayEPG) != 0
            
            if let epgScreenID = config["epg_screen_id"] as? String {
                self.epgScreenID = epgScreenID
            }
        }
        
        if let numberOfComponentsToLoadStr = style["numberOfComponentsToLoad"] as? String,
            let numberOfComponentsToLoad = Int(numberOfComponentsToLoadStr) {
            self.numberOfComponentsToLoad = numberOfComponentsToLoad
        }
        
        if let componentsThresholdIndexStr = style["componentsThresholdIndex"] as? String,
            let componentsThresholdIndex = Int(componentsThresholdIndexStr) {
            self.componentsThresholdIndex = componentsThresholdIndex
        }
        
        if let paddingHorizontalStr = style["padding_horizontal"] as? String,
            let paddingHorizontal = Int(paddingHorizontalStr) {
            self.paddingHorizontal = paddingHorizontal
        }
        
        if let paddingTopStr = style["padding_top"] as? String,
            let paddingTop = Int(paddingTopStr) {
            self.paddingTop = paddingTop
        }
        
        if let paddingBottomStr = style["padding_bottom"] as? String,
            let paddingBottom = Int(paddingBottomStr) {
            self.paddingBottom = paddingBottom
        }
        
        if let dividerStr = style["list_divider"] as? String,
            let divider = Int(dividerStr) {
            self.divider = divider
        }
        
        if let configurationJSON = configurationJSON as? [String: Any], let showInterstitial: Int = configurationJSON["should_display_interstitial"] as? Int {
            shouldShowInterstitial = showInterstitial != 0
        }
        
        ds = dataSource?.linkURL as String?
    }
}
