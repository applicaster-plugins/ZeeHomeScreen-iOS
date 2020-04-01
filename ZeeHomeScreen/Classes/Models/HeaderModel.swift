//
//  HeaderModel.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import Foundation
import ApplicasterSDK

open class HeaderModel: ComponentModel {

//    var title: String?
    
    var actionUrlScheme: String?
        
    var imageKey: String?
    
    var isClickable: Bool = true
    
    var height: CGFloat?

    /// Init
    public init(entry: APAtomEntryProtocol, object: [String: Any]) {
        
        super.init(entry: entry)

        if let cellStyle = object["cell_style"] as? String {
            self.layoutStyle = cellStyle
        }
        
        if let src = object["src"] as? String {
            self.actionUrlScheme = src
        }
        
    }
    
    public init(entry: APAtomEntryProtocol?, layoutStyle: String?, imageKey: String?, isClickable: Bool, actionUrlScheme: String?, height: CGFloat?, containerType: String, cellKey: String) {
        
        super.init(type: "HEADER")

        self.entry = entry

        if let layoutStyle = layoutStyle {
            self.layoutStyle = layoutStyle
        }
        
        if let imageKey = imageKey {
            self.imageKey = imageKey
        }
        
        self.isClickable = isClickable

        if let actionUrlScheme = actionUrlScheme {
            self.actionUrlScheme = actionUrlScheme
        }
        
        if let height = height {
            self.height = height
        }
        
        self.cellKey = cellKey
        self.containerType = containerType
    }
}
