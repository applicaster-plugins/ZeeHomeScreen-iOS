//
//  DatasourceManager.swift
//
//  Created by Miri on 11.12.19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation

@testable import ZappPlugins
import ApplicasterSDK

@objc public class DatasourceManager: NSObject {
    
    class var swiftSharedInstance: DatasourceManager {
        struct DatasourceManagerSingleton {
            static let instance = DatasourceManager()
        }
        return DatasourceManagerSingleton.instance
    }
    
    @objc open class func sharedInstance() -> DatasourceManager {
        return DatasourceManager.swiftSharedInstance
    }
        
    // MARK: LOAD
    
    @objc open func load(model: ComponentModelProtocol, completion: @escaping (_ component: ComponentModelProtocol?) -> Void) {
        if let model = model as? ComponentModel,
            let feedUrl = model.dsUrl {
            APAtomFeedLoader.loadPipes(model: APAtomFeed(url:feedUrl)) { (success, atomFeed) in
                let component = self.parse(data: atomFeed, componentModel: model, isParentModel: false)
                 completion(component)
            }
        }
    }
        
    @objc open func load(atomFeedUrl: String, parentModel: ComponentModelProtocol, completion: @escaping (_ component: ComponentModelProtocol?) -> Void) {
        APAtomFeedLoader.loadPipes(model: APAtomFeed(url:atomFeedUrl)) { (success, atomFeed) in
            let component = self.parse(data: atomFeed, componentModel: parentModel as? ComponentModel, isParentModel: true)
            completion(component)
        }
    }
    
    
    func liveComponentsArray(componentsArray: [ComponentModelProtocol]?, liveComponents: [ComponentModelProtocol]?) -> [ComponentModelProtocol]? {

        var components = [ComponentModelProtocol]()
        var liveItems = [ComponentModelProtocol]()

        if let componentsArray = componentsArray {
            components = componentsArray
        }

        guard let liveComponents = liveComponents as [ComponentModelProtocol]?,
            let component = liveComponents[liveComponents.count - 1] as ComponentModelProtocol?,
            let lazyType = component.type,
            lazyType == "LAZY_LOADING" else {
                if let lazyComponent = self.lazyLoadingComponent() as ComponentModel? {
                    components.append(lazyComponent)
                }
                return components
        }

        liveItems = liveComponents
        let lazyComponentIndex = liveComponents.count - 1
        liveItems.append(contentsOf: components)
        liveItems.insert(liveItems.remove(at: lazyComponentIndex), at: liveItems.count)

        return liveItems
    }
    
    public func parse(data: NSObject?, componentModel: ComponentModel?, isParentModel: Bool) -> ComponentModelProtocol? {
      var components = [ComponentModelProtocol]()

        guard
            let feed = data as? APAtomFeed,
            let entries = feed.entries as? [APAtomEntryProtocol],
            let componentModel = componentModel else {
            return nil
        }
        
        var feedComponent: ComponentModel!
        if let extensions = componentModel.entry?.extensions, let _ = extensions["ui_component"] {
            feedComponent = ComponentModel.init(entry: componentModel.entry!, threshold: 3)
        } else {
            feedComponent = ComponentModel.init(entry: feed, threshold: 3)
        }

        if isParentModel == true {
            feedComponent.parentModel = componentModel
        }
        
        for (index, entry) in entries.enumerated() {
            if let component = self.parseComponent(at: index, entry: entry, componentModel: feedComponent) {
                component.parentModel = feedComponent
                components.append(component)
            }
        }
      
        feedComponent.childerns = components
        return feedComponent
    }
        
    fileprivate func parseComponent(at index: Int, entry: APAtomEntryProtocol, componentModel: ComponentModel?) -> ComponentModel? {

        if /*isChildComponent(for: entry) == true,*/
            let componentModel = componentModel,
            let cellModel = componentModel.cellModel {
            
            return CellModel.init(layoutStyle: cellModel.layoutStyle,
                                  aspectRatio: cellModel.aspectRatio,
                                  entry: entry,
                                  iphoneWidth: cellModel.iphoneWidth,
                                  ipadWidth: cellModel.ipadWidth,
                                  iphoneHeight: cellModel.iphoneHeight,
                                  ipadHeight: cellModel.ipadHeight,
                                  placeHolder: cellModel.placeHolder,
                                  imageKey: cellModel.imageKey,
                                  isClickable: cellModel.isClickable,
                                  containerType: cellModel.containerType,
                                  cellKey: cellModel.cellKey)
        }
        else {
            return ComponentModel.init(entry: entry,
                                       threshold: 3)
        }
    }
 
    func isChildComponent(for entry: APAtomEntryProtocol) -> Bool {
        guard let extentions = entry.extensions,
            let _ = extentions["ui_component"] as? [AnyHashable: Any] else {
                return true
        }
        return false
        
    }
    
    // MARK: LAZY LOADING
    func addLazyLoadingComponentIfNeeded(componentsArray: [ComponentModelProtocol]?, liveComponents: [ComponentModelProtocol]?) -> [ComponentModelProtocol]? {
        
        var components = [ComponentModelProtocol]()
        
        if let componentsArray = componentsArray {
            components = componentsArray
        }
        
        guard let liveComponents = liveComponents as [ComponentModelProtocol]?,
            let component = liveComponents[liveComponents.count - 1] as ComponentModelProtocol?,
            let lazyType = component.type,
            lazyType == "LAZY_LOADING" else {
                if let lazyComponent = self.lazyLoadingComponent() as ComponentModel? {
                    components.append(lazyComponent)
                }
                return components
        }
        return components
    }
    
    func lazyLoadingComponent() -> ComponentModel {
        let lazyComponent = ComponentModel.init(type: "LAZY_LOADING")
        lazyComponent.layoutStyle = "Family_Ganges_lazy_loading_1"
        return lazyComponent
    }
}

