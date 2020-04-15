//
//  CellModel.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import Foundation
import ApplicasterSDK

@objc open class CellModel: ComponentModel {
    
    var iphoneWidth: CGFloat = UIScreen.main.bounds.width
    
    var ipadWidth: CGFloat = UIScreen.main.bounds.width

    var iphoneHeight: CGFloat = 20.0
    
    var ipadHeight: CGFloat = 20.0

    var placeHolder: String?
    
    var imageKey: String?
    
    var isClickable: Bool = true
    
    var itemsPerRow: Int?

    /// Init
    public init(layoutStyle: String?,
                aspectRatio: Double?,
                entry: APAtomEntryProtocol?,
                iphoneWidth:CGFloat,
                ipadWidth: CGFloat,
                iphoneHeight: CGFloat,
                ipadHeight: CGFloat,
                placeHolder: String?,
                imageKey: String?,
                isClickable: Bool,
                containerType: String?,
                cellKey: String?,
                itemsPerRow: Int?,
                divider: Int?) {
           
        super.init(type: "Cell")
        self.layoutStyle = layoutStyle
        self.aspectRatio = aspectRatio
        self.entry = entry
        self.iphoneWidth = iphoneWidth
        self.ipadWidth = ipadWidth
        self.iphoneHeight = iphoneHeight
        self.ipadHeight = ipadHeight
        self.placeHolder = placeHolder
        self.imageKey = imageKey
        self.isClickable = isClickable
        self.containerType = containerType
        self.cellKey = cellKey
        self.itemsPerRow = itemsPerRow
        self.divider = divider
    }
   
}
