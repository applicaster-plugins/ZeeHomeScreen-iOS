//
//  LazyLoadingViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 06/02/2020.
//

import Foundation

class LazyLoadingViewController: UIViewController, ComponentProtocol, ComponentDelegate {
   
    public var componentModel: ComponentModelProtocol? {
        didSet {
//            self.fillEntryData()
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
    
}
