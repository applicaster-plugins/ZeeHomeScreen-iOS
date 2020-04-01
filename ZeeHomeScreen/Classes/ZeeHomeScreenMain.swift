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

typealias PluginKeys = [String: String]

public class ZeeHomeScreenMain: NSObject, ZPPluggableScreenProtocol, ZPAppLoadingHookProtocol {
    
    public var configurationJSON: NSDictionary?
    
    public var screenPluginDelegate: ZPPlugableScreenDelegate?
    var mainViewController: SectionCompositeViewController?
    
    fileprivate var config: PluginKeys?
    fileprivate var style: PluginKeys?

    fileprivate var atomFeedUrl: String?
    var atomFeed: APAtomFeed?
    
    //MARK: ZPAppLoadingHookProtocol
    
    required public override init() {
        super.init()
    }

      public required init(configurationJSON: NSDictionary?) {
          self.configurationJSON = configurationJSON
      }

    public func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?) {

        // hardcode all translations to the TranslationResponse key
//        let translations_data = LocalStorage.sharedInstance.get(key: "translations_data", namespace: "zee5localstorage")
//        LocalStorage.sharedInstance.set(key: "TranslationResponse", value: translations_data!, namespace: "zee5localstorage")

        guard completion != nil else {
            return
        }
        completion!()
    }

    // MARK: ZPPluggableScreenProtocol
        
    required public init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.config = screenModel.general as? PluginKeys ?? PluginKeys()
        self.style = screenModel.style?.object as? PluginKeys ?? PluginKeys()
        
        guard
           // case let .atomFeed(model) = screenModel.dataSource,
            let atomFeed = dataSourceModel as? APAtomFeed else {
                
       
                return
        }
       
       
        self.atomFeed = atomFeed
        self.atomFeedUrl = atomFeed.link as String?
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
            model.dsUrl = self.atomFeedUrl
            
            return model
        }
        return nil
    }
}
