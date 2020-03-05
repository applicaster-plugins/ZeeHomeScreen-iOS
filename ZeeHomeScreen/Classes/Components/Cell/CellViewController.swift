//
//  CellViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 17/02/2020.
//

import Foundation
import ApplicasterSDK

//MARK: - ComponentProtocol

class CellViewController : UIViewController, ComponentProtocol {
    
    //MARK: Properties
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemShowNameLabel: UILabel!
    @IBOutlet weak var itemTimeLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    
    @IBOutlet weak var itemImageView: APImageView!
    @IBOutlet weak var shadowImageView: APImageView!
    @IBOutlet weak var parentTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var borderView: UIView!

    
    @IBOutlet weak var promoVideoContainerView: UIView!

    @IBOutlet var imageViewCollection: [UIImageView]!
    @IBOutlet var buttonsViewCollection: [UIButton]!
    @IBOutlet var labelsCollection: [UILabel]!
    @IBOutlet var viewCollection: [UIView]!


    var atomEntry: APAtomEntry? {
        get
        {
            var result: APAtomEntry? = nil
            if let componentModel = self.currentComponentModel as ComponentModel?,
                let atomEntry = componentModel.entry as? APAtomEntry
            {
                result = atomEntry
            }
            return result
        }
    }
    
    
    public var componentModel: ComponentModelProtocol? {
        didSet {
            self.fillEntryData()
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
    
    func fillEntryData() {
        if self.isViewLoaded
        {
            if  self.itemNameLabel != nil {
                self.itemNameLabel.text = self.atomEntry?.title
            }
            
            if  self.itemDescriptionLabel != nil {
                self.itemDescriptionLabel.text = self.atomEntry?.summary
            }
            configureImages()
            updateLabels()
            updateBorderColor()
        }
    }
    
    func configureImages() {
        if let componentModel = self.currentComponentModel as? CellModel {
            let placeholderImage: UIImage? = UIImage(named: componentModel.placeHolder ?? "image_placeholder")
            
            if let imageMediaGroup = (componentModel.entry as AnyObject).mediaGroup(with: .image),
                let imageUrl = imageMediaGroup.mediaItemStringURL(forKey: componentModel.imageKey ?? "image_base"),
                let parsedImageUrl = URL(string: imageUrl) {
                self.itemImageView.setImageWith(parsedImageUrl, placeholderImage:placeholderImage, serverResizable: true)
            }
            else {
                 self.itemImageView.image = placeholderImage
            }
        }
        
    }
    
    func updateLabels() {
        
//        if let componentModel = componentModel as? CellModel {
//            self.currentComponentModel?.customization(for: self.itemNameLabel, attributeKey: "label_title", withModel: componentModel, componentState: ZeeComponentState.normal)
//            
//             self.currentComponentModel?.customization(for: self.itemShowNameLabel, attributeKey: "label_subtitle", withModel: componentModel, componentState: ZeeComponentState.normal)
//            
//             self.currentComponentModel?.customization(for: self.itemDescriptionLabel, attributeKey: "label_description", withModel: componentModel, componentState: ZeeComponentState.normal)
//            
//            self.currentComponentModel?.customization(for: self.itemTimeLabel, attributeKey: "label_time", withModel: componentModel, componentState: ZeeComponentState.normal)
//            
//        }
    }
    
    func updateBorderColor() {
//        if let color = self.currentComponentModel?.color(forAttributeKey: kAttributeBorderColorKey, attributesDict: nil, withModel: (componentModel as! NSObject), componentState: ZeeComponentState.normal) {
//            self.borderView.backgroundColor = color
//        }
    }
 
}
