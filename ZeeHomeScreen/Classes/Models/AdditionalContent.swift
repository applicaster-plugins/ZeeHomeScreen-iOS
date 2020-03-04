//
//  AdditionalContent.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import Foundation

struct AdditionalContent {
    
    var dsName: String?
    var dsUrl: String?
 
    /// Init
    init(dsName: String?, dsUrl: String?) {
        if let dsName = dsName {
            self.dsName = dsName
        }
        if let dsUrl = dsUrl {
            self.dsUrl = dsUrl
        }
    }
}
