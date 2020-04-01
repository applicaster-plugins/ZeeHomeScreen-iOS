//
//  CellViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 17/02/2020.
//

import Foundation
import ApplicasterSDK

@objc open class CellViewController : UIViewController, ComponentProtocol {
    
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

  //  var videoBackgroundView: APVideoBackgroundView?
    
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
    
    open var atomEntry: APAtomEntryProtocol? {
        get
        {
            var result: APAtomEntryProtocol? = nil
            if let componentModel = self.currentComponentModel as ComponentModel?,
                let atomEntry = componentModel.entry
            {
                result = atomEntry
            }
            return result
        }
    }
    
    
    open var componentModel: ComponentModelProtocol? {
        willSet(value) {
          
//            self.fillEntryData()
        }
    }
    
    open var componentDataSourceModel: NSObject? {
        didSet {
            self.fillEntryData()
        }
    }
    
    open var currentComponentModel: ComponentModel? {
        return self.componentModel as? ComponentModel
    }
    
    //MARK:
    
//    override public func viewDidLoad()
//    {
//        super.viewDidLoad()
//    }
    
    func componentState() -> ZeeComponentState {
        var retVal = ZeeComponentState.normal
        if let componentDataSourceModel = self.componentDataSourceModel as? APModel, let selectedModel = self.selectedModel as? APModel {
            if componentDataSourceModel.isEqual(toModel: selectedModel) {
                retVal = .selected
            }
        }
        return retVal
    }
    
    func updateCornerRadius() {
        let componentCustomization = ComponentModelCustomization()
        if let radius = componentCustomization.value(forAttributeKey: kAttributeCornerRadiusKey, withModel: self.componentDataSourceModel) as? NSNumber {
            view.layer.cornerRadius = CGFloat(radius.floatValue)
            view.layer.masksToBounds = true
            view.clipsToBounds = true
        }
    }
    
    func customizeViewCollection() {
        let componentCustomization = ComponentModelCustomization()
        guard viewCollection != nil else {
            return
        }
        for item in viewCollection {
            let viewKey = "view_\(viewCollection.firstIndex(of: item)!)"
            componentCustomization.customization(for: item, attibuteKey: viewKey, withModel: componentDataSourceModel)
        }
    }
//    func setPlaceholderNameAttributeFor(imageView: UIImageView, attributesDictionary: [String: AnyHashable]) {
//        let componentCustomization = ComponentModelCustomization()
//        let placeholderName = componentCustomization.value(ofCustomizationDictionary: attributesDictionary, forModel: componentDataSourceModel, withKey: kAttributeCellPlaceholderImageNameKey)
//
//
//        if let placeholderName = placeholderName as? String, !placeholderName.isEmptyOrWhitespace() {
//            imageView.image = UIImage.init(named: placeholderName)
//        }
//    }
    
    func setImageByNameAttributeFor(imageView: UIImageView, attributesDictionary: [String: AnyHashable]) {
        
        guard let imageName: String = attributesDictionary[kAttributeImageNameKey] as? String else {
            return
        }
        imageView.image = UIImage.init(named: imageName)
    }
    
    func setCornerRadiusFor(imageView: UIImageView, attributesDictionary: [String: AnyHashable]) {
        let componentCustomization = ComponentModelCustomization()
        if let radius = componentCustomization.value(ofCustomizationDictionary: attributesDictionary, forModel: componentDataSourceModel, withKey: kAttributeCornerRadiusKey) as? NSNumber {
            imageView.layer.cornerRadius = CGFloat(radius.floatValue)
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
        }
    }
 
    func setCornerRadiusFor(imageView: UIImageView) {
        let componentCustomization = ComponentModelCustomization()
        if let radius = componentCustomization.value(forAttributeKey: kAttributeCornerRadiusKey, withModel: componentDataSourceModel) as? NSNumber {
            imageView.layer.cornerRadius = CGFloat(radius.floatValue)
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
        } else if let radiusString = componentCustomization.value(forAttributeKey: kAttributeCornerRadiusKey, withModel: componentDataSourceModel) as? String {
            imageView.layer.cornerRadius = CGFloat(radiusString)!
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
        }
    }
    
    
    func customizeImageViewCollection() {
        
        let componentCustomization = ComponentModelCustomization()
        guard imageViewCollection != nil else {
            return
        }
        for item in imageViewCollection {
            item.image = nil
            let imageViewKey = "imageview_\(imageViewCollection.firstIndex(of: item)!)"
            
            componentCustomization.customization(for: item, attributeKey: imageViewKey, defaultAttributesDictionary: nil, withModel: componentDataSourceModel, componentState: componentState())
            /*
            let attributesDictionary = componentCustomization.value(forAttributeKey: imageViewKey, withModel: componentDataSourceModel)
            if let attributesDictionary = attributesDictionary as? [String: AnyHashable] {
                setImageByNameAttributeFor(imageView: item, attributesDictionary: attributesDictionary)
                setCornerRadiusFor(imageView: item, attributesDictionary: attributesDictionary)
            } */
        }
    }

    func customizeButtonsViewCollection() {
        let componentCustomization = ComponentModelCustomization()
        guard buttonsViewCollection != nil else {
            return
        }
        for item in buttonsViewCollection {
            let buttonKey = "button_\(buttonsViewCollection.firstIndex(of: item)!)"
            componentCustomization.customization(for: item, attributeKey: buttonKey, defaultAttributesDictionary: nil, withModel: componentDataSourceModel, withDelegate: self)
            /*
            componentCustomization.customization(for: item, attributeKey: buttonKey, defaultAttributesDictionary: nil, withModel: componentDataSourceModel, withDelegate: self)
            let attributesDictionary = componentCustomization.value(forAttributeKey: buttonKey, withModel: componentDataSourceModel)
            if let attributesDictionary = attributesDictionary as? [String: AnyHashable] {
                setImageByNameAttributeFor(imageView: item.imageView!, attributesDictionary: attributesDictionary)
                setCornerRadiusFor(imageView: item.imageView!, attributesDictionary: attributesDictionary)
            } */
        }
    }
    
    func customizeLabelsCollection() {
        let componentCustomization = ComponentModelCustomization()
        guard labelsCollection != nil else {
            return
        }
        for item in labelsCollection {
            let labelKey = "label_\(labelsCollection.firstIndex(of: item)!)"
            componentCustomization.customization(for: item, attributeKey: labelKey, withModel: componentDataSourceModel, componentState: componentState())
        }
    }
    
    func customizeBackground() {
        let componentCustomization = ComponentModelCustomization()
        if let color: UIColor = componentCustomization.color(forAttributeKey: kAttributeBackgroundColorKey, attributesDict: nil, withModel: componentDataSourceModel, componentState: componentState()) {
            view.backgroundColor = color
        } else {
            view.backgroundColor = .black
        }
    }
    
    func updateShadowImage() {
        let componentCustomization = ComponentModelCustomization()
        let attributesDictionary = componentCustomization.value(forAttributeKey: kAttributeImageShadowKey, withModel: componentDataSourceModel)
        guard attributesDictionary != nil else {
            return
        }
        let imageName = componentCustomization.value(ofCustomizationDictionary: attributesDictionary as? [AnyHashable : Any], forModel: componentDataSourceModel, withKey: kAttributeImageNameKey)
        
        if let imageName = imageName as? String, !imageName.isEmptyOrWhitespace() {
            shadowImageView.image = UIImage.init(named: imageName)
        }
    }
    /*
    func setupPromoVideo() {
        var promoVideoURL: URL?
        let componentCustomization = ComponentModelCustomization()
        if let componentDataSourceModel = componentDataSourceModel as? APAtomEntryProtocol {
            let atomEntry: APAtomEntryProtocol = componentDataSourceModel
            var promoVideoKey: String? = componentCustomization.value(forAttributeKey: kAttributePromoVideoKey, withModel: componentDataSourceModel as? NSObject) as? String
            if promoVideoKey == nil {
                promoVideoKey = "promo_video"
            }
            promoVideoURL = URL.init(string: APAtomMediaGroup.stringURL(fromMediaItems: atomEntry.mediaGroups as? [Any], key: promoVideoKey))
        } else if let apModel = componentDataSourceModel as? APModel {
            promoVideoURL = apModel.promoVideoURL as URL?
        }

        if let promoVideoContainerView = self.promoVideoContainerView, promoVideoURL != nil {
            componentCustomization.customization(for: promoVideoContainerView, attibuteKey: kAttributePromoVideoContainer, withModel: componentDataSourceModel)
 
            stopPromoVideo()
            videoBackgroundView = APVideoBackgroundView()
            promoVideoContainerView.addSubview(videoBackgroundView!)
            videoBackgroundView!.setVideoNSURL(videoURL: promoVideoURL! as NSURL)
            videoBackgroundView!.player!.isMuted = true
            videoBackgroundView?.matchParent()
            promoVideoContainerView.alpha = 1.0;
            animatePromoVideo()
        }
    }
    
    func stopPromoVideo() {
        guard promoVideoContainerView != nil, videoBackgroundView != nil else {
            return
        }
        promoVideoContainerView.alpha = 0.0;
        videoBackgroundView?.removeFromSuperview()
        videoBackgroundView = nil
    }
    
    func animatePromoVideo() {
        let componentCustomization = ComponentModelCustomization()
        let promoVideoContainer = componentCustomization.value(forAttributeKey: kAttributePromoVideoContainer, withModel: componentDataSourceModel)
        if let promoVideoContainer = promoVideoContainer as? [String: String], !promoVideoContainer.isEmpty {
            let animationType = promoVideoContainer[kAttributePromoDisplayAnimation]
            if animationType! == "fade" {
                UIView.animate(withDuration: 1.5, animations: {
                    self.itemImageView.alpha = 0.0
                }) { (isFinished) in
                    self.swapPromoIndexToTop(true)
                    self.itemImageView.alpha = 1.0
                }
                return
            }
        }
        swapPromoIndexToTop(true)
    }
    
    func swapPromoIndexToTop(_ toTop: Bool) {
        // In case promo container is behind item image to allow for fade animation
        let indexOfItemImage: Int = view.subviews.firstIndex(of: itemImageView)!
        let indexOfPromoContainer: Int = view.subviews.firstIndex(of: promoVideoContainerView)!
        if toTop == true, indexOfPromoContainer < indexOfItemImage {
            view.exchangeSubview(at: indexOfItemImage, withSubviewAt: indexOfPromoContainer)
        } else if indexOfPromoContainer > indexOfItemImage {
            view.exchangeSubview(at: indexOfPromoContainer, withSubviewAt: indexOfItemImage)
        }
    }
 */
    open func fillEntryData() {
        if self.isViewLoaded
        {
            if (componentModel?.layoutStyle?.contains("header"))! {
                print("")
            }
            view.layoutIfNeeded()
            updateCornerRadius()
            customizeViewCollection()
            customizeImageViewCollection()
            customizeButtonsViewCollection()
            customizeLabelsCollection()
            
            customizeBackground()
            updateShadowImage()
            //setupPromoVideo()
            /*x

             [self setupPromoVideo];
             [self setupHTMLTicker];
             self.shouldSendLoadingFinishedDelegate = YES;
             
             // Setup accessibility identifier for automaiton matters
             [self setupAccessibilityIdentifiers];
             */
            
            if  self.itemNameLabel != nil {
                
                self.itemNameLabel.text = self.atomEntry?.title
            }
            
            if  self.itemDescriptionLabel != nil {
                self.itemDescriptionLabel.text = self.atomEntry?.summary
            }
            configureItemImage()
            updateLabels()
            updateBorderColor()
            if ZAAppConnector.sharedInstance().genericDelegate.isRTL() {
                // Currently we do it only for RTL languages, if we will have this problem with LTR we can append \u200E in the begining.
                itemNameLabel.text = itemNameLabel.text != nil ? itemNameLabel.text!.rtl() : String()
                 itemShowNameLabel.text = itemShowNameLabel.text != nil ? itemShowNameLabel.text!.rtl() : String()
                 itemDescriptionLabel.text = itemDescriptionLabel.text != nil ? itemDescriptionLabel.text!.rtl() : String()
            }
        }
    }
    
    func configureItemImage() {
        
        guard let itemImageView = itemImageView else {
            return
        }
        let componentCustomization = ComponentModelCustomization()
        
        componentCustomization.customization(for: itemImageView, attributeKey: kAttributeImageItemKey, defaultAttributesDictionary: nil, withModel: componentDataSourceModel, componentState: componentState())
        
        setCornerRadiusFor(imageView: itemImageView)
        
        if let componentModel = self.currentComponentModel as? CellModel {
            var placeholderImage: UIImage?
            
            if let placeholderImageString: String = componentCustomization.value(forAttributeKey: kAttributeCellPlaceholderImageNameKey, withModel: componentDataSourceModel) as? String {
                placeholderImage = UIImage(named: placeholderImageString)
            }
                
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
        let customization = ComponentModelCustomization()
        customization.customization(for: self.itemNameLabel, attributeKey: "label_title", withModel: componentDataSourceModel, componentState: ZeeComponentState.normal)
        
         customization.customization(for: self.itemShowNameLabel, attributeKey: "label_subtitle", withModel: componentDataSourceModel, componentState: ZeeComponentState.normal)

         customization.customization(for: self.itemDescriptionLabel, attributeKey: "label_description", withModel: componentDataSourceModel, componentState: ZeeComponentState.normal)

        customization.customization(for: self.itemTimeLabel, attributeKey: "label_time", withModel: componentDataSourceModel, componentState: ZeeComponentState.normal)
    }
    
    func updateBorderColor() {
        let customization = ComponentModelCustomization()
        if let color = customization.color(forAttributeKey: kAttributeBorderColorKey, attributesDict: nil, withModel: (componentModel as! NSObject), componentState: ZeeComponentState.normal) {
            self.borderView.backgroundColor = color
        }
    }
 
}
