//
//  BannerCellViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 18/02/2020.
//

import Foundation
import ApplicasterSDK

class BannerCellViewController : UIViewController, ComponentProtocol {

    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bannerContainerView: UIView!

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var advertisementLabel: UILabel!
    @IBOutlet weak var delegate: ComponentDelegate!
    
    @IBOutlet weak var contentView: UIView!
  
}
