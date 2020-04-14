//
//  AdditionalContent.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import Foundation

struct AdditionalContent {
    
    var dsType: AdditionalContentType!
    var dsUrl: String?
 
    /// Init
    init(dsType: AdditionalContentType!, dsUrl: String?) {
        self.dsType = dsType
        
        if let dsUrl = dsUrl {
            self.dsUrl = dsUrl
        }
    }
}
