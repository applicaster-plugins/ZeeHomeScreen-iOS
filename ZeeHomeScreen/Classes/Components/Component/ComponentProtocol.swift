//
//  ComponentProtocol.swift
//  Alamofire
//
//  Created by Anton Klysa on 24.03.2020.
//

import Foundation

//MARK: - ComponentProtocol

@objc public protocol ComponentProtocol: NSObjectProtocol {
    
    @objc var componentDataSourceModel:NSObject? {get set}
    @objc var componentModel:ComponentModelProtocol? {get set}
    
    @objc optional var selectedModel:NSObject? {get set}
    @objc optional var delegate:ComponentDelegate? {get set}
    
    @objc optional func setDataSource(dataSource: Any)
    @objc optional func setComponentDataSource(componentDataSource: Any)
    
    @objc optional func setupCustomizationDictionary()
    
    @objc optional func setupAppDefaultDefinitions()
    @objc optional func setupComponentDefinitions()
    
    @objc optional func prepareComponentForReuse()
    @objc optional func loadComponent()
    @objc optional func reloadComponent()
    @objc optional func reloadComponentWithNotification(notification: NSNotification)
    @objc optional func rebuildComponent()
    @objc optional func needUpdateLayout()
    @objc optional func didEndDisplaying(with: ZeeComponentEndDisplayingReason)
    @objc optional func didStartDisplaying()
    @objc optional func didEndDisplaying()
}
