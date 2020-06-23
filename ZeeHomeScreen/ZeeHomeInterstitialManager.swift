//
//  InterstitialManager.swift
//
//  Created by Anton Klysa on 22.06.2020.
//

import Foundation

class ZeeHomeInterstitialManager: ZPAdViewProtocol {
    
    //MARK: singleton
    
    static let instance: ZeeHomeInterstitialManager = ZeeHomeInterstitialManager()
    
    //MARK: variables
    
    private var adPresenter: ZPAdPresenterProtocol?
    private var viewCount: Int?
    
    //MARK: actions
    
    func showInterstitial(componentModel: ComponentModel, on: UIViewController) {
        
        guard let extensions = componentModel.entry?.extensions, let ad_config = extensions["ad_config"] as? [String: Any], let adID = ad_config["interstitial_ad_tag"] as? String, let _ = ad_config["interstitial_video_view_duration"] as? Int, let interstitialViewCount = ad_config["interstitial_video_view_count"] as? Int else {
            return
        }
        if viewCount == nil {
            viewCount = interstitialViewCount
        } else if viewCount == 0 {
            return
        }
        viewCount = viewCount! - 1
        
        let adPlugin = ZPAdvertisementManager.sharedInstance.getAdPlugin()
        adPresenter = adPlugin?.createAdPresenter(adView: self, parentVC: on)
        
        let adConfig: ZPAdConfig = ZPAdConfig.init(adUnitId: adID, adType: .interstitial)
        
        adPresenter?.load(adConfig: adConfig)
    }
    
    //MARK: ZPAdViewProtocol
    
    func adLoaded(view: UIView?) {
        adPresenter?.showInterstitial()
    }
    
    func stateChanged(adViewState: ZPAdViewState) {
    }
    
    func adLoadFailed(error: Error) {
    }
}
