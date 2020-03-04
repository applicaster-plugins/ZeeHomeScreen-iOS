//
//  BaseModel.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import Foundation
import ApplicasterSDK

@objc open class BaseModel:NSObject {
    open fileprivate(set) var object: [String: Any] = [:]
    
    open var layoutStyle: String?
    open var aspectRatio: Double?
    open var entry: APAtomEntryProtocol?
    
    public init(layoutStyle: String?, aspectRatio: Double?, entry: APAtomEntryProtocol?) {
        if let layoutStyle = layoutStyle {
            self.layoutStyle = layoutStyle
        }
        
        if let aspectRatio = aspectRatio {
            self.aspectRatio = aspectRatio
        }
        
        if let entry = entry {
            self.entry = entry
        }
    }
        
    public init(entry: APAtomEntryProtocol?) {
        if let entry = entry {
            self.entry = entry
        }
    }
}

