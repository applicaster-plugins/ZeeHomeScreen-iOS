//
//  ComponentModelProtocol.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import UIKit

@objc public protocol SectionComponentModelProtocol: ComponentModelProtocol {

      @objc var title:String? {get set}
      @objc var identifier:String? {get set}
      @objc var uiTag:String? {get set}
      @objc var type:String? {get set}
      @objc var isVertical:Bool {get}
      @objc var dsUrl:String? {get set}
      @objc var componentHeaderModel:HeaderModel? {get set}
      @objc var cellModel:CellModel? {get set}
      @objc var children:[ComponentModel]? {get set}
      @objc var layoutStyle:String? {get set}
}
