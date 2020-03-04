//
//  Pagination.swift
//  ZeeHomeScreen
//
//  Created by Miri on 16/01/2020.
//

import Foundation


open class Pagination {
    
    var hasNext: Bool = false
    var nextPageUrl: String?
 
    /// Init
    init(hasNext: Bool, nextPageUrl: String?) {
        self.hasNext = hasNext
        
        if let nextPageUrl = nextPageUrl {
            self.nextPageUrl = nextPageUrl
        }
    }
}
