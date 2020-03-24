//
//  BannerCellViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 18/02/2020.
//

import Foundation
import ApplicasterSDK

class BannerCellViewController : UIViewController, ComponentProtocol, ComponentDelegate, ZPAdViewProtocol {
    
    func adLoaded(view: UIView?) {
        
    }
    
    func stateChanged(adViewState: ZPAdViewState) {
        
    }
    
    func adLoadFailed(error: Error) {
        
    }
    
    
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
            willSet(value) {
                //if I get the same componentModel I don't need to reload it unless the plugin requires it.
                let adPlugin = ZPAdvertisementManager.sharedInstance.getAdPlugin()
                
    //            if self.componentModel != value || (adPlugin?.responds(to: #selector(reloadOnPullToRefresh)) && adPlugin?.responds(to: #selector(reloadOnPullToRefresh))) {
    //                updateComponentData()
    //            }
            }
        }

        
        //MARK: lifecycle
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            let adPlugin = ZPAdvertisementManager.sharedInstance.getAdPlugin()
            
    //        if (adPlugin?.responds(to: #selector(reloadOnDidAppear)) && adPlugin.reloadOnDidAppear) {
    //            updateComponentData()
    //        }
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
    //        updateFlexibleCellSizeConstraints()
        }

        
        //MARK: CAComponentProtocol

        func prepareComponentForReuse() {
            loadingActivityIndicator.stopAnimating()
        }
    
    
        
//        func currentComponentModel() -> ComponentModel {
//            return componentModel as! ComponentModel
//        }

        //MARK: Private Methods
        
        private func customizeBackground() {
    //        self.backgroundEnabled = currentComponentModel()
        }
  
}
