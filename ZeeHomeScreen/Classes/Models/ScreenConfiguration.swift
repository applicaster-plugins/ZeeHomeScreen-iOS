//
//  ScreenConfiguration.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import Foundation
import ApplicasterSDK

struct ScreenConfiguration {
    
    var feed: APAtomFeed?
    
    // determined the screen ds
    var ds: String?
    
    var additionalContent: [AdditionalContent]?
    
    //the number of componentModels need to be load in each request.
    var numberOfComponentsToLoad: Int?
    
    // the threshold that determine that need to load more items
    var componentsThresholdIndex: Int?
    var paddingHorizontal: Int = 10
    var paddingTop: Int = 10
    var paddingBottom: Int = 10
    var divider: Int = 10

    /// Init
    public init(config: [String: Any]?, dataSource: APAtomFeed?) {
        guard let config = config else {
            return
        }
        
        if let dataSource = dataSource {
            self.feed = dataSource
        }
        
        if let numberOfComponentsToLoadStr = config["numberOfComponentsToLoad"] as? String,
            let numberOfComponentsToLoad = Int(numberOfComponentsToLoadStr) {
            self.numberOfComponentsToLoad = numberOfComponentsToLoad
        }
        
        if let componentsThresholdIndexStr = config["componentsThresholdIndex"] as? String,
            let componentsThresholdIndex = Int(componentsThresholdIndexStr) {
            self.componentsThresholdIndex = componentsThresholdIndex
        }
        
        if let paddingHorizontalStr = config["padding_horizontal"] as? String,
            let paddingHorizontal = Int(paddingHorizontalStr) {
            self.paddingHorizontal = paddingHorizontal
        }
        
        if let paddingTopStr = config["padding_top"] as? String,
            let paddingTop = Int(paddingTopStr) {
            self.paddingTop = paddingTop
        }
        
        if let paddingBottomStr = config["padding_bottom"] as? String,
            let paddingBottom = Int(paddingBottomStr) {
            self.paddingBottom = paddingBottom
        }
        
        if let dividerStr = config["list_divider"] as? String,
            let divider = Int(dividerStr) {
            self.divider = divider
        }

        
        // TO DO: SET THE additionalContent AND ds PARAMS
    }
}
