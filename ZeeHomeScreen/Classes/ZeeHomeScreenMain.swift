//
//  ZeeHomeScreenMain.swift
//
//  Created by Miri on 29/12/2019.
//

import Foundation
import ZappPlugins
import UIKit
import ApplicasterSDK
import ZappSDK
import Zee5CoreSDK

typealias PluginKeys = [String: String]

public class ZeeHomeScreenMain: NSObject, ZPPluggableScreenProtocol {
    
    public var configurationJSON: NSDictionary?
    
    public var screenPluginDelegate: ZPPlugableScreenDelegate?
    var mainViewController: SectionCompositeViewController?
    
    fileprivate var config: PluginKeys?
    fileprivate var style: PluginKeys?

    fileprivate var atomFeedUrl: String?
    var atomFeed: APAtomFeed?
    

    // MARK: ZPPluggableScreenProtocol
        
    required public init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.config = screenModel.general as? PluginKeys ?? PluginKeys()
        self.style = screenModel.style?.object as? PluginKeys ?? PluginKeys()
        self.configurationJSON = pluginModel.object["configuration_json"] as? NSDictionary
        
        guard
            let atomFeed = dataSourceModel as? APAtomFeed else {
                return
        }
       
       
        self.atomFeed = atomFeed
        self.atomFeedUrl = atomFeed.link as String?
    }
    
    public func createScreen() -> UIViewController {
        let bundle = Bundle.init(for: type(of: self))
        let result = SectionCompositeViewController(nibName: "SectionCompositeViewController", bundle: bundle)
        mainViewController = result
        result.userType = User.shared.getType()
        result.isUserSubscribed = User.shared.isSubscribed()
        result.displayLanguage = Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage()
        result.contentLanguages = Zee5UserDefaultsManager.shared.getSelectedContentLanguages()
        result.screenConfiguration = ScreenConfiguration.init(config: config, style: style, dataSource: atomFeed, configurationJSON: configurationJSON)
        result.setComponentModel((self.getBaseComponent())!)
        result.atomFeedUrl = self.atomFeedUrl
        result.modalPresentationStyle = .fullScreen
        UserDefaults.standard.set("N/A", forKey: "analyticsSource")
        UserDefaults.standard.set("", forKey: "currentlyTab")
        
        return result
    }
    
    public var customTitle: String? {
        return mainViewController?.currentComponentModel?.title
        ?? String()
    }
    
    // MARK: Private
    
    func getBaseComponent() -> ComponentModelProtocol? {
        if let feed = self.atomFeed {
            let model = ComponentModel.init(entry: feed, threshold: 3)
            model.isVertical = true
            model.dsUrl = self.atomFeedUrl
            
            return model
        }
        return nil
    }
}
