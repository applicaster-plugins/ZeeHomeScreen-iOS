//
//  BaseComponentModelProtocol.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import UIKit

@objc public protocol ComponentModelProtocol: NSObjectProtocol {

       @objc var title:String? {get set}
       @objc var identifier:String? {get set}
       @objc var uiTag:String? {get set}
       @objc var type:String? {get set}
       @objc var isVertical:Bool {get}
       @objc var dsUrl:String? {get set}
       @objc var dsType:String? {get set}
       @objc var componentHeaderModel:HeaderModel? {get set}
       @objc var cellModel:CellModel? {get set}
       @objc var layoutStyle:String? {get set}
       @objc var cellKey:String? {get set}
       @objc var entry:APAtomEntryProtocol? {get set}
       @objc var containerType:String? {get set}
       @objc var childerns:[ComponentModelProtocol]? {get set}
    }
