//
//  CellViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 17/02/2020.
//

import Foundation
import ApplicasterSDK

@objc open class CellViewController : UIViewController, ComponentProtocol {
    public var componentDataSourceModel: NSObject?
    
    public var selectedModel: NSObject?
    
    public var delegate: ComponentDelegate?
    
    
    //MARK: Properties
    
    @IBOutlet public weak var itemNameLabel: UILabel!
    @IBOutlet public weak var itemShowNameLabel: UILabel!
    @IBOutlet public weak var itemTimeLabel: UILabel!
    @IBOutlet public weak var itemDescriptionLabel: UILabel!
    
    @IBOutlet public weak var itemImageView: APImageView!
    @IBOutlet public weak var shadowImageView: APImageView!
    @IBOutlet public weak var parentTitleLabel: UILabel!
    @IBOutlet public weak var authorLabel: UILabel!
    @IBOutlet public weak var updatedLabel: UILabel!
    @IBOutlet public weak var descriptionTextView: UITextView!
    
    @IBOutlet public weak var borderView: UIView!

    
    @IBOutlet public weak var promoVideoContainerView: UIView!

    @IBOutlet public var imageViewCollection: [UIImageView]!
    @IBOutlet public var buttonsViewCollection: [UIButton]!
    @IBOutlet public var labelsCollection: [UILabel]!
    @IBOutlet public var viewCollection: [UIView]!

    public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
//    override public func viewDidLoad()
//    {
//        super.viewDidLoad()
//    }
    
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
        
        if let componentModel = componentModel as? CellModel {
            let customization = ComponentModelCustomization()
            customization.customization(for: self.itemNameLabel, attributeKey: "label_title", withModel: componentModel, componentState: ZeeComponentState.normal)
            
             customization.customization(for: self.itemShowNameLabel, attributeKey: "label_subtitle", withModel: componentModel, componentState: ZeeComponentState.normal)

             customization.customization(for: self.itemDescriptionLabel, attributeKey: "label_description", withModel: componentModel, componentState: ZeeComponentState.normal)

            customization.customization(for: self.itemTimeLabel, attributeKey: "label_time", withModel: componentModel, componentState: ZeeComponentState.normal)
            
        }
    }
    
    func updateBorderColor() {
        let customization = ComponentModelCustomization()
        if let color = customization.color(forAttributeKey: kAttributeBorderColorKey, attributesDict: nil, withModel: (componentModel as! NSObject), componentState: ZeeComponentState.normal) {
            self.borderView.backgroundColor = color
        }
    }
 
}
