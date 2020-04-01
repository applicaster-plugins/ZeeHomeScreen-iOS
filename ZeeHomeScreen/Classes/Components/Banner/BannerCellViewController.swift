//
//  BannerCellViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 18/02/2020.
//

import Foundation
import ApplicasterSDK

class BannerCellViewController : UIViewController, ComponentProtocol, ComponentDelegate, ZPAdViewProtocol {
    
    
    
    
        private static let kBannerTopContainerMargin = 18.0
        private static let kBannerBottomContainerMargin = 5.0

        @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
        @IBOutlet weak var bannerContainerView: UIView!

        @IBOutlet weak var bannerContainerWidthConstraint: NSLayoutConstraint!
        @IBOutlet weak var bannerTopContainerConstraint: NSLayoutConstraint!
        @IBOutlet weak var bannerBottomContainerConstraint: NSLayoutConstraint!
        @IBOutlet weak var backgroundView: UIView!
        @IBOutlet weak var advertisementLabel: UILabel!
        @IBOutlet weak var delegate: ComponentDelegate!
        
        @IBOutlet weak var contentView: UIView!
        
        private var adPresenter: ZPAdPresenterProtocol?
        private var backgroundEnabled: Bool?
        private var bannerView: UIView?
        
        var componentDataSourceModel: NSObject?
        var componentModel: ComponentModelProtocol? {
            didSet {
                //if I get the same componentModel I don't need to reload it unless the plugin requires it.
               /* if let adPlugin: ZPAdPluginProtocol = ZPAdvertisementManager.sharedInstance.getAdPlugin() {
                    if adPlugin.responds(to: #selector(ZPAdPluginRefreshProtocol.reloadOnPullToRefresh)) {
                        if adPlugin.perform(#selector(ZPAdPluginRefreshProtocol.reloadOnPullToRefresh)) != nil {
                            updateComponentData()
                        }
                    }
                }*/
                
                if let adPlugin: ZPAdPluginProtocol = ZPAdvertisementManager.sharedInstance.getAdPlugin() {
                    if adPlugin.conforms(to: ZPAdPluginRefreshProtocol.self) {
                        if let adPlugin = adPlugin as? ZPAdPluginRefreshProtocol, adPlugin.reloadOnPullToRefresh() {
                            updateComponentData()
                        }
                    }
                }
            }
        }

    func currentComponentModel() -> ComponentModel {
        return componentModel as! ComponentModel
    }
        
        //MARK: lifecycle
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            /*
            if let adPlugin: ZPAdPluginProtocol = ZPAdvertisementManager.sharedInstance.getAdPlugin() {
                if adPlugin.responds(to: #selector(ZPAdPluginRefreshProtocol.reloadOnDidAppear)) {
                    if adPlugin.perform(#selector(ZPAdPluginRefreshProtocol.reloadOnDidAppear)) != nil {
                        updateComponentData()
                    }
                }
            }*/
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            updateFlexibleCellSizeConstraints()
        }

        
        //MARK: CAComponentProtocol

        func prepareComponentForReuse() {
//            loadingActivityIndicator.stopAnimating()
        }
    
    
        
//        func currentComponentModel() -> ComponentModel {
//            return componentModel as! ComponentModel
//        }

        //MARK: Private Methods
  
     private func customizeBackground() {
        
        let componentCustomization = ComponentModelCustomization()
        backgroundEnabled = ((componentCustomization.value(forAttributeKey: kAttributeBackgroundKey, withModel: componentDataSourceModel)) as AnyObject).boolValue
        if backgroundEnabled == true {
            advertisementLabel.isHidden = false
            bannerTopContainerConstraint.constant = CGFloat(BannerCellViewController.kBannerTopContainerMargin)
            bannerBottomContainerConstraint.constant = CGFloat(BannerCellViewController.kBannerBottomContainerMargin)
            backgroundView.isHidden = false
            
            let backgroundLabelText: String? = componentCustomization.value(forAttributeKey: kAttributeBackgroundLabelTextKey, withModel: componentDataSourceModel) as? String
            
            if let backgroundLabelText = backgroundLabelText {
                advertisementLabel.text = backgroundLabelText
            }
            componentCustomization.customization(for: advertisementLabel, attributeKey: kAttributeBackgroundLabelKey, withModel: componentDataSourceModel, componentState: .normal)
        
            
            let backgroundColor: UIColor? = componentCustomization.color(forAttributeKey: kAttributeBackgroundColorKey, attributesDict: nil, withModel: componentDataSourceModel, componentState: .normal)
            if let backgroundColor = backgroundColor {
                self.backgroundView.backgroundColor = backgroundColor;
            }
        } else {
            self.advertisementLabel.isHidden = true
            self.bannerTopContainerConstraint.constant = 0.0
            self.bannerBottomContainerConstraint.constant = 0.0
            self.backgroundView.isHidden = true
        }
    }

    func updateComponentData() {
        // Initialize view earlier - as the customization touch the view outlets
        customizeBackground()
        loadBanner()
    }
    
    
    func loadBanner() {
        
        let adPlugin = ZPAdvertisementManager.sharedInstance.getAdPlugin()
        adPresenter = adPlugin?.createAdPresenter(adView: self, parentVC: self)
        
        if let bannerModel = currentComponentModel().entry as? APBannerModel {
            bannerContainerView.removeAllSubviews()
            let adConfig: ZPAdConfig = ZPAdConfig.init(adUnitId: bannerModel.adUnitID()!, inlineBannerSize: bannerModel.type()!)
            if let size: CGSize = adPlugin?.size(forInlineBannerSize: bannerModel.type()!) {
                bannerContainerWidthConstraint.constant = size.width
            }
            adPresenter?.load(adConfig: adConfig)
        }
    }

    //MARK: - ZPAdViewProtocol

    func adLoaded(view: UIView?) {
        bannerView = view
        self.view.layoutIfNeeded()
        
        updateFlexibleCellSizeConstraints()
    }
    
    func stateChanged(adViewState: ZPAdViewState) {
        switch (adViewState) {
        case .loaded:
            loadingActivityIndicator.stopAnimating()
                break;
                
        case .impressed:
                reportBannerImpression()
                break;
                
        case .clicked:
                bannerPressed()
                break;
                
            default:
                break;
        }
    }
    
    func adLoadFailed(error: Error) {
        loadingActivityIndicator.stopAnimating()
        if delegate.responds(to: #selector(ComponentDelegate.removeComponent(forModel:andComponentModel:))) {
            delegate.removeComponent?(forModel: currentComponentModel().entry as? NSObject, andComponentModel: currentComponentModel())
        }
    }
    
    func updateFlexibleCellSizeConstraints() {
        
        guard let bannerView = bannerView else {
            return
        }
        view.layoutIfNeeded()
        bannerContainerView.removeAllSubviews()
        
        var frame: CGRect = view.frame
        frame.size.height = bannerView.size.height
        if backgroundEnabled == true {
            frame.size.height += CGFloat(BannerCellViewController.kBannerTopContainerMargin) + CGFloat(BannerCellViewController.kBannerBottomContainerMargin)
        }
        view.frame = frame
        if let model: APBannerModel = currentComponentModel().entry as? APBannerModel {
            bannerView.accessibilityIdentifier = model.adUnitID()
        }

        delegate.loadingFinished?(with: Notification.init(name: NSNotification.Name.ZeeComponentLoaded, object: self))

        setConstantConstraintWith(attribute: .height, value: bannerView.size.height, inView: bannerContainerView)
        setConstantConstraintWith(attribute: .width, value: view.size.width, inView: contentView)
        bannerContainerView.addSubview(bannerView)
        bannerView.centerInSuperview()
        view.layoutIfNeeded()
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstantConstraintWith(attribute: NSLayoutConstraint.Attribute, value:CGFloat, inView: UIView) {
        inView.setConstraint(for: attribute, secondView: nil, secondAttribute: .notAnAttribute, to: value, priority: .required)
    }

    //MARK: - analytics
    
    func reportBannerImpression() {
        ZAAppConnector.sharedInstance().analyticsDelegate.trackEvent(name: "Banner Impression", parameters: bannerDictionary())
    }

    func bannerPressed() {
        ZAAppConnector.sharedInstance().analyticsDelegate.trackEvent(name: "Tap Banner", parameters: bannerDictionary())
    }

    func adUnitDictionary() -> [String: AnyHashable] {
        var retVal: [String: AnyHashable] = [:]
        
        if let bannerModel = currentComponentModel().entry as? APBannerModel {
            retVal["Ad Provider"] = bannerModel.adProvider()
            retVal["Ad Unit"] = bannerModel.adUnitID()
        }
        retVal["Configuration Source"] = "Zapp"

        
        return retVal
    }
    
    func bannerDictionary() -> [String: AnyHashable] {
        
        var retVal: [String: AnyHashable] = [:]
        
        // Ad unit dictionary
        retVal["Ad Unit Dictionary"] = adUnitDictionary()
        
        // Banner sizing type and name
        var bannerSizingType = "Fixed Size"
        var bannerSizeName = "Standard Banner"
        
        if let bannerModel = currentComponentModel().entry as? APBannerModel {
        
            if bannerModel.type() == APBannerModel.uibuilderTypeSmartBanner {
                bannerSizingType = "Smart Banner"
                bannerSizeName = "Smart Banner"
            } else if bannerModel.type() == APBannerModel.uibuilderTypeBoxBanner {
                bannerSizeName = "Box Banner"
            }
        }
        retVal["Banner Sizing Type"] = bannerSizingType
        retVal["Banner Sizing Name"] = bannerSizeName

        
        // Banner Size Dimensions
        let dimensionString: String = String.init(format: "%ldx%ld", lround(Double(adPresenter!.getSize().width)), lround(Double(adPresenter!.getSize().height)))
        retVal["Banner Size Dimensions"] = dimensionString
        
        // Banner location
        retVal["Banner Location"] = "Inline Banner"
        
        return retVal
    }
}
