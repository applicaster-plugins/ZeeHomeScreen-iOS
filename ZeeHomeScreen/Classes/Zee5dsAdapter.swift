//
//  Zee5dsAdapter.swift
//
//
//  Created by Miri.
//  Copyright © 2018 Applicaster. All rights reserved.
//

import Foundation
import ApplicasterSDK
import ZappPlugins

public class Zee5dsAdapter {
    
    public static func createScreen(for atomFeed: APAtomFeed?) -> UIViewController {
        let bundle = Bundle(for: Self.self)
        let result = SectionCompositeViewController(nibName: "SectionCompositeViewController", bundle: bundle)
        var config: PluginKeys?
        var style: PluginKeys?
        
        if let screenModel = ZAAppConnector.sharedInstance().genericDelegate.screenModelForPluginID(pluginID: "zee5_home_screen", dataSource: nil) {
            config = screenModel.general as? PluginKeys ?? PluginKeys()
            style = screenModel.style?.object as? PluginKeys ?? PluginKeys()
        }
        
        var pluginConfiguration: NSDictionary?

        if let pluginModel = ZPPluginManager.pluginModelById("zee5_home_screen") {
            pluginConfiguration = pluginModel.configurationJSON
        }
        
        result.screenConfiguration = ScreenConfiguration.init(config: config, style: style, dataSource: atomFeed, configurationJSON: pluginConfiguration)
        result.setComponentModel((Zee5dsAdapter.getBaseComponent(for: atomFeed))!)
        result.atomFeedUrl = atomFeed?.link
        result.modalPresentationStyle = .fullScreen

        return result
    }
    
    public static func getBaseComponent(for atomFeed: APAtomFeed?) -> ComponentModelProtocol? {
        if let feed = atomFeed {
            let model = ComponentModel.init(entry: feed, threshold: 3)
            model.isVertical = true
            model.dsUrl = atomFeed?.link
            return model
        }
        return nil
    }
    
}
