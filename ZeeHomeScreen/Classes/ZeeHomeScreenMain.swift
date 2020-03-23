//
//  ZeeHomeScreenMain.swift
//
//  Created by Miri on 29/12/2019.
//

import Foundation
import ZappPlugins
import UIKit
import ApplicasterSDK

typealias PluginKeys = [String: String]

public class ZeeHomeScreenMain: NSObject, ZPPluggableScreenProtocol{
    
    public var screenPluginDelegate: ZPPlugableScreenDelegate?
    var mainViewController: SectionCompositeViewController?
    
    fileprivate var config: PluginKeys
    fileprivate var style: PluginKeys

    fileprivate let atomFeedUrl: String?
    var atomFeed: APAtomFeed?

    // MARK: ZPPluggableScreenProtocol
        
    required public init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.config = screenModel.general as? PluginKeys ?? PluginKeys()
        self.style = screenModel.style?.object as? PluginKeys ?? PluginKeys()
        
        guard
           // case let .atomFeed(model) = screenModel.dataSource,
            let atomFeed = dataSourceModel as? APAtomFeed else {
                
                self.atomFeedUrl = nil
                return
        }
       
       
        self.atomFeed = atomFeed
        self.atomFeedUrl = atomFeed.linkURL as String?
    }
    
    public func createScreen() -> UIViewController {
        let bundle = Bundle.init(for: type(of: self))
        let result = SectionCompositeViewController(nibName: "SectionCompositeViewController", bundle: bundle)
        result.modalPresentationStyle = .fullScreen
        result.setComponentModel((self.getBaseComponent())!)
        result.atomFeedUrl = self.atomFeedUrl
        result.screenConfiguration = ScreenConfiguration.init(config: config, style: style, dataSource: atomFeed)
        return result
    }
    
    func getBaseComponent() -> ComponentModelProtocol? {
        if let feed = self.atomFeed {
            let model = ComponentModel.init(entry: feed, threshold: 3)
            model.isVertical = true
            if let feedUrl = self.atomFeedUrl {
                model.dsUrl = feedUrl
            }
            return model
        }
        return nil
    }
}
