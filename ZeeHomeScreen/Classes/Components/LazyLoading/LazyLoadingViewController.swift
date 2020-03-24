//
//  LazyLoadingViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 06/02/2020.
//

import Foundation

class LazyLoadingViewController: UIViewController, ComponentProtocol, ComponentDelegate {
    var componentDataSourceModel: NSObject?
    
   
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView?
    
    public var componentModel: ComponentModelProtocol? {
        didSet {
            loadingIndicator?.startAnimating()
        }
    }
    
    public var currentComponentModel: ComponentModel? {
        return self.componentModel as? ComponentModel
    }
    
    //MARK:
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    deinit {
        loadingIndicator?.stopAnimating()
    }
    
}
