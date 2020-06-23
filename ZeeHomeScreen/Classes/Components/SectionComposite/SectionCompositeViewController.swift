//
//  SectionCompositeViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 24/01/2020.
//

import ApplicasterSDK
import Foundation
import ZappPlugins
import Zee5CoreSDK

@objc class SectionCompositeViewController: BaseCollectionComponentViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ComponentProtocol, ComponentDelegate, UIScrollViewDelegate {
    
    // Don't want this to be too low, otherwise we would thrash the servers
    private static let minimumRefreshDelay = TimeInterval(2)
    
    @IBOutlet weak var backgroundImageView: APImageView?
    @IBOutlet weak var collectionView: UICollectionView?
//    @IBOutlet weak var loadingIndicatorContainerView:CAActivityIndicatorContainerView?
    
    @IBOutlet weak var noDataLabel:UILabel?
    @IBOutlet weak var horizontalListInnerLabel: UILabel?
    
    @IBOutlet weak var toggleSegmentedControl: CustomSegmentedControl?
    @IBOutlet weak var epgContentView: UIView?
    
    @IBOutlet weak var topDistanceConstraint:NSLayoutConstraint?
    
    public var atomFeedUrl: String?
    
    var screenConfiguration: ScreenConfiguration?
    var userType: UserType?
    var isUserSubscribed: Bool?
    var displayLanguage: String?
    var contentLanguages: String?
    var liveComponents = [ComponentModelProtocol]()
    
    private var cachedCells: [String: ComponentProtocol?] = [:]

    weak var delegate:ComponentDelegate?
    var collectionViewFlowLayout:SectionCompositeFlowLayout? {
        return collectionView?.collectionViewLayout as? SectionCompositeFlowLayout
    }
    
    /// Array of all sections
    var sectionsDataSourceArray:[ComponentModelProtocol]? {
        
        didSet {
            if let flowLayout = collectionView?.collectionViewLayout as? SectionCompositeFlowLayout {
                flowLayout.screenConfiguration = screenConfiguration
                flowLayout.sectionsDataSourceArray = sectionsDataSourceArray
                flowLayout.numberOfSections = self.sectionsDataSourceArray?.count ?? 0
            }
            refreshFromDataSourceArray()
        }
    }
    
    var componentModel: ComponentModelProtocol? {
        didSet {
            //customizeBackground()
            
            if let flowLayout = collectionView?.collectionViewLayout as? SectionCompositeFlowLayout {
                flowLayout.componentModel = componentModel
            }
            
            if let sectionsDataSourceArray = sectionsDataSourceArray,
                sectionsDataSourceArray.count > 0 {
                registerLayouts(sectionsArray: sectionsDataSourceArray)
                collectionView?.reloadData()
            }
        }
    }
    
    var currentComponentModel:ComponentModel? {
        return self.componentModel as? ComponentModel
    }
    
    var liveComponentModel:ComponentModel?
        
    var componentDataSourceModel: NSObject? {
        didSet {
            self.registerRefreshTaskIfNeeded(componentDataSourceModel)
        }
    }
    
    var isRTL = false
    var scrollDirection: UICollectionView.ScrollDirection = .vertical
    var componentInitialized = false
    var collectionViewBounces = true
    var collectionViewHorizontalScrollIndicator = true
    var collectionViewVerticalScrollIndicator = true
    var lastSelectedIndexPath: IndexPath?
    var pullToRefreshEnabled = true
    
    //MARK: ComponentDelegate
    
    func removeComponent(forModel model: NSObject?, andComponentModel componentModel: ComponentModelProtocol?) {
        if let componentModel = componentModel as? ComponentModel {
            if let index = sectionsDataSourceArray?.firstIndex(where: { (component) -> Bool in
                return componentModel.identifier == component.identifier && componentModel.containerType == component.containerType
            }) {
                collectionView?.performBatchUpdates({
                    let indexSet = IndexSet(integer: index)
                        self.sectionsDataSourceArray?.remove(at: index)
                    self.collectionViewFlowLayout?.sectionsDataSourceArray = self.sectionsDataSourceArray
                    if componentModel.type != "LAZY_LOADING" {
                       self.cachedCells["\(componentModel.entry?.identifier ?? componentModel.identifier!)_\(index)"] = nil
                        self.collectionView?.deleteSections(indexSet)
                    } else {
                        if let currentComponentModel = currentComponentModel, currentComponentModel.isVertical && currentComponentModel.type != "GRID" {
                            self.collectionView?.deleteSections(indexSet)
                        } else {
                            self.collectionView?.deleteItems(at: [IndexPath.init(row: index, section: 0)])
                        }
                    }
                }, completion: nil)
                
            }
        }
    }
    
    func reloadComponent(forModel model: NSObject!, andComponentModel componentModel: ComponentModelProtocol!) {
        if let componentModel = componentModel as? ComponentModel {
            if let index = sectionsDataSourceArray?.firstIndex(where: { (component) -> Bool in
                return componentModel.identifier == component.identifier && componentModel.containerType == component.containerType
            }) {

                sectionsDataSourceArray?.remove(at: index)
                sectionsDataSourceArray?.insert(componentModel, at: index)

                collectionViewFlowLayout?.sectionsDataSourceArray = sectionsDataSourceArray
                self.collectionView?.reloadData()
            }
        }
    }
    
    func insertBanners(indexes: [Int], from component: ComponentModelProtocol) {
        
        guard let components = component.childerns else {
            return
        }
        
        registerLayouts(sectionsArray: components)
            
            var newIndexes: [Int] = []
            
        collectionView?.performBatchUpdates({
            components.enumerated().forEach { (offset, item) in
                let index = getNewIndex(for: item, thatShouldBeInIndex: indexes[offset])
                self.sectionsDataSourceArray?.insert(item, at: index)
                newIndexes.append(index)
            }
            self.collectionViewFlowLayout?.sectionsDataSourceArray = self.sectionsDataSourceArray
            self.collectionView?.insertSections(IndexSet(newIndexes))
        }, completion: nil)
    }
    
    func getNewIndex(for banner: ComponentModelProtocol, thatShouldBeInIndex: Int) -> Int {
        
        guard thatShouldBeInIndex != 0 else {
            return thatShouldBeInIndex
        }
        var thatShouldBeInIndex = thatShouldBeInIndex
        let count: Int = sectionsDataSourceArray!.count
        var newIndex: Int = 0
        for index in 0..<count {
            if let componentModel: ComponentModel = sectionsDataSourceArray![index] as? ComponentModel {
                if componentModel.type == "BANNER" {
                    newIndex = newIndex + 1
                    continue
                } else if componentModel.type == "LAZY_LOADING" {
                    return newIndex
                } else {
                    if thatShouldBeInIndex == 0 {
                        return newIndex
                    } else {
                        newIndex = newIndex + 1
                        thatShouldBeInIndex = thatShouldBeInIndex - 1
                        continue
                    }
                }
            }
        }
        return newIndex
    }
    
    func insertComponents(index: Int, from components: [ComponentModelProtocol]) {
        
        var indexes: [Int] = []
        for item in components {
            let componentIndex = components.firstIndex(where: { (component) -> Bool in
                return component.identifier == item.identifier && component.containerType == item.containerType && component.title == item.title && (component.entry?.isEqual(item.entry))!
            })
            indexes.append(index + componentIndex!)
        }

        let indexSet = IndexSet(indexes)
        registerLayouts(sectionsArray: components)
        if let _ = componentModel as? ComponentModel {
            
            collectionView?.performBatchUpdates({
                self.sectionsDataSourceArray?.insert(contentsOf: components, at: index)
                self.collectionViewFlowLayout?.sectionsDataSourceArray = self.sectionsDataSourceArray
                self.collectionView?.insertSections(indexSet)
            }, completion: nil)
        }
    }
    
    //MARK: - ComponentProtocol
    
    func setComponentModel(_ model:ComponentModelProtocol) {
        componentModel = model
    }
    
    override func prepareComponentForReuse() {
        super.prepareComponentForReuse()
        
        componentModel = nil
        componentDataSourceModel = nil
        isLoading = false
        
    }
    
    func setupAppDefaultDefinitions() {
        isRTL = ZAAppConnector.sharedInstance().genericDelegate.isRTL()
    }
    
    func setupComponentDefinitions() {
        if let componentModel = self.componentModel as? ComponentModel,
            componentModel.isVertical == true {
            scrollDirection = .vertical
        }
        else {
            scrollDirection = .horizontal
        }
        collectionViewBounces = true
        collectionView?.bounces = collectionViewBounces
        
        collectionViewHorizontalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = collectionViewHorizontalScrollIndicator
        
        collectionViewVerticalScrollIndicator = false
        
    }
    
    func setupLoadingActivityIndicator() {
        
    }
    
    func needUpdateLayout() {
        self.navigationController?.view.layoutIfNeeded()
        self.collectionView?.collectionViewLayout.invalidateLayout()
        if let childVC = self.children as? [ComponentProtocol] {
            
        }
    }
    
    // MARK: - Loading data
    func shouldLoadDataSource(forModel model: NSObject?,
                              componentModel: ComponentModelProtocol?,
                              completionBlock completion: (([Any]?) -> Void)?) -> Bool {
        return false
    }
    
    func registerLayouts(sectionsArray:[ComponentModelProtocol]) {
        for section in sectionsArray {
            
            if let section = section as? ComponentModel {
                if let layoutStyle = section.layoutStyle {
                    self.collectionView?.register(UniversalCollectionViewCell.self, forCellWithReuseIdentifier: layoutStyle)
                }
                if let headerComponent = section.componentHeaderModel,
                    let layoutStyle = headerComponent.layoutStyle {
                    self.collectionView?.register(UniversalCollectionViewHeaderFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: layoutStyle)
                }
            }
        }
    }
    
    private func prepareToggle() {
        guard let toggle = toggleSegmentedControl else {
            return
        }
        toggle.setButtonsTitles(buttonsTitles: ["nav_livetv".localized(hashMap: [:]), "EPG_Header_ChannelGuide_Text".localized(hashMap: [:])])
        toggle.changeToIndex = { [weak self] index in
            self?.collectionView?.isHidden = index == 0 ? false : true
            self?.epgContentView?.isHidden = index == 0 ? true : false
        }
        toggle.isHidden = false
    }
    
    private func prepareEPGView() {

        let screenID = screenConfiguration?.epgScreenID

        guard let viewController = GARootHelper.uiBuilderScreen(by: screenID!,
                                                                model: nil,
                                                                fromURLScheme:nil) else {
                                                                    APLoggerError("Can not create view controller with ScreenType: \(screenID!) isn't found")
                                                                    return
        }
        (viewController as! GAScreenPluginGenericViewController).isContainerViewController = true
        addChild(viewController)

        epgContentView!.addSubview(viewController.view)
        viewController.view.matchParent()
    }
    
    func prepareComponentToReuse() {
        if sectionsDataSourceArray == nil {
            if collectionView?.collectionViewLayout == nil {
                collectionView?.collectionViewLayout = collectionFlowLayout()
                self.view.backgroundColor = UIColor.black
                
                setupLoadingActivityIndicator()
                
                collectionView?.bounces = collectionViewBounces
                collectionView?.showsHorizontalScrollIndicator = collectionViewHorizontalScrollIndicator
                collectionView?.showsVerticalScrollIndicator = collectionViewVerticalScrollIndicator
            }
            prepareSections()
        }
    }
    
    func loadComponent() {
     
        noDataLabel?.isHidden = true

        cancelRefreshTask()
        
        //when loading feed url remove local feed cache if exists
        if self.scrollDirection == .vertical,
            let atomfeed = componentDataSourceModel as? APAtomFeed,
            let url = atomfeed.url as String? {
            _ = ZAAppConnector.sharedInstance().storageDelegate?.localStorageSetValue(for: url,
                                                                                      value: "",
                                                                                      namespace: nil)
        }
        if currentComponentModel?.identifier != "ContinueWatching" {
            prepareSections()
        }
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let config = self.screenConfiguration {
            if config.shouldDisplayEPG {
                if config.epgScreenID != nil {
                    topDistanceConstraint?.constant = -64
                    prepareToggle()
                    prepareEPGView()
                }
            }
            
        }

        
        
        collectionView?.collectionViewLayout = collectionFlowLayout()
        self.view.backgroundColor = UIColor.clear
        
        
        if let componentModel = componentModel,
            let uiTag = componentModel.uiTag,
            uiTag.isNotEmptyOrWhiteSpaces() == true {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(didReceiveActionNotification),
                                                   name:NSNotification.Name(rawValue: uiTag),
                                                   object: nil)
        }
        
        setupLoadingActivityIndicator()
        
        collectionView?.bounces = collectionViewBounces
        collectionView?.showsHorizontalScrollIndicator = collectionViewHorizontalScrollIndicator
        collectionView?.showsVerticalScrollIndicator = collectionViewVerticalScrollIndicator
        
        AnalyticsUtil().reportHomeLandingOnHomeScreenIfApplicable(atomFeedUrl: self.atomFeedUrl)
    }
    
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        if currentComponentModel?.containerType == nil{
               let gradient:CAGradientLayer = CAGradientLayer()
               gradient.frame.size = self.view.size
               gradient.colors = [hexStringToUIColor(hex: "#130014").cgColor,hexStringToUIColor(hex: "#2b0225").cgColor]
               self.view.layer.insertSublayer(gradient, at:0)
           }
       }
       
   func hexStringToUIColor (hex:String) -> UIColor {
       var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

       if (cString.hasPrefix("#")) {
           cString.remove(at: cString.startIndex)
       }

       if ((cString.count) != 6) {
           return UIColor.gray
       }

       var rgbValue:UInt64 = 0
       Scanner(string: cString).scanHexInt64(&rgbValue)

       return UIColor(
           red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
           green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
           blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
           alpha: CGFloat(1.0)
       )
   }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if componentInitialized == false {
            componentInitialized = true
            collectionView?.collectionViewLayout = collectionFlowLayout()
            loadComponent()
        }
            if !updateContentAndDisplayLanguageIfNeeded() {
                if !updateUserStatusIfNeeded() {
                    if !updateUserSubscriptionsIfNeeded() {
                        reloadContinueWatchingRailsIfNeeded()
                    }
                }
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let componentModel = componentModel,
            let uiTag = componentModel.uiTag,
            uiTag.isNotEmptyOrWhiteSpaces() == true {
            
            NotificationCenter.default.removeObserver(self,
                                                      name: NSNotification.Name(rawValue: uiTag),
                                                      object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(didReceiveActionNotification),
                                                   name: NSNotification.Name(rawValue: uiTag),
                                                   object: nil)
        }
        AnalyticsUtil().reportTabVisitedAnalyticsIfApplicable(atomFeedUrl: self.atomFeedUrl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let componentModel = componentModel,
            let uiTag = componentModel.uiTag,
            uiTag.isNotEmptyOrWhiteSpaces() == true {
            NotificationCenter.default.removeObserver(self,
                                                      name: NSNotification.Name(rawValue: uiTag),
                                                      object: nil)
        }
//        self.loadingIndicatorContainerView?.stopAnimating()
    }
    
    deinit {
        
    }
    
    private func reloadContinueWatchingRailsIfNeeded() {
        if currentComponentModel?.identifier == "ContinueWatching" {
            sectionsDataSourceArray = []
            prepareSections()
        }
    }
    
    private func updateUserStatusIfNeeded() -> Bool {
        if let userType = userType, userType != User.shared.getType() {
            self.userType = User.shared.getType()
            self.showActivityIndicator()
            DispatchQueue.main.async {
                ZAAppConnector.sharedInstance().navigationDelegate.reloadRootViewController()
            }
            return true
        }
        return false
    }
    
    private func updateUserSubscriptionsIfNeeded() -> Bool {
        if let isSubscribed = isUserSubscribed, isSubscribed != User.shared.isSubscribed() {
            isUserSubscribed = User.shared.isSubscribed()
         self.showActivityIndicator()
            DispatchQueue.main.async {
                
                ZAAppConnector.sharedInstance().navigationDelegate.reloadRootViewController()
            }
            return true
        }
        return false
    }
    
    private func updateContentAndDisplayLanguageIfNeeded() -> Bool {
        if let oldDisplayLanguage = displayLanguage, let oldContentLanguages = contentLanguages {
            
            if oldDisplayLanguage != Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage() || oldContentLanguages != Zee5UserDefaultsManager.shared.getSelectedContentLanguages() {
                displayLanguage = Zee5UserDefaultsManager.shared.getSelectedDisplayLanguage()
                contentLanguages = Zee5UserDefaultsManager.shared.getSelectedContentLanguages()
             self.showActivityIndicator()
                DispatchQueue.main.async {
                    
                    ZAAppConnector.sharedInstance().navigationDelegate.reloadRootViewController()
                }
                return true
            }
        }
        return false
    }
    
    // MARK: - CollectionFlowLayout Customization
    func collectionFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = SectionCompositeFlowLayout()
        flowLayout.isRTL = isRTL
        flowLayout.componentModel = componentModel
        
        flowLayout.scrollDirection = scrollDirection
        flowLayout.minimumLineSpacing = collectionMinimumLineSpacing
        flowLayout.minimumInteritemSpacing = collectionMinimumInteritemSpacing
        flowLayout.sectionInset = collectionInsets
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        return flowLayout
    }
    
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let currentComponentModel = currentComponentModel,
        currentComponentModel.isVertical == true && currentComponentModel.type != "GRID" {
            return 1
        }
        return sectionsDataSourceArray?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sectionsDataSourceArray = sectionsDataSourceArray else {
            return 1
        }
        if let currentComponentModel = currentComponentModel,
        currentComponentModel.isVertical == true && currentComponentModel.type != "GRID"  {
            return sectionsDataSourceArray.count
        }
        return  1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let sectionsDataSourceArray = self.sectionsDataSourceArray {
            
            var subarray = sectionsDataSourceArray
            subarray.removeLast()
            var index: Int
            if let _ = subarray as? [CellModel] {
                index = indexPath.row
            } else { index = indexPath.section }
            
            if let componentModel = sectionsDataSourceArray[index] as? ComponentModel,
                let layoutName = componentModel.layoutStyle {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: layoutName, for: indexPath) as? UniversalCollectionViewCell {
                    componentModel.screenConfiguration = screenConfiguration
                    cell.backgroundColor = UIColor.clear
                    
                        if layoutName != "Family_Ganges_lazy_loading_1", let componentViewController: UIViewController = cachedCells["\(componentModel.entry?.identifier ?? componentModel.identifier!)_\(index)"] as? UIViewController {
                            cell.componentViewController = componentViewController as! UIViewController & ComponentProtocol
               
                        } else {
                            let componentViewController = cell.setComponentModel(componentModel,
                                                                                 model: componentModel,
                                                                                 view: cell.contentView,
                                                                                 delegate: self,
                                                                                 parentViewController: self)
                            if layoutName != "Family_Ganges_lazy_loading_1"
                            {
                                if let extensions = componentModel.entry?.extensions, let subtype: String = extensions["asset_subtype"] as? String, subtype == "Reco" {
                                    return cell
                                }
                                cachedCells["\(componentModel.entry?.identifier ?? componentModel.identifier!)_\(index)"] = componentViewController
                            }
                            
                        }
                            return cell
                    
                    let _ = cell.setComponentModel(componentModel,
                    model: componentModel,
                    view: cell.contentView,
                    delegate: self,
                    parentViewController: self)


                    cell.layer.shouldRasterize = true
                    cell.layer.rasterizationScale = UIScreen.main.scale
                    
                    return cell
                }
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ZeeHomeScreen_Family_Ganges_horizontal_list_1", for: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        ZAAppConnector.sharedInstance().analyticsDelegate.trackEvent(name: "Click Reco", parameters: <#T##Dictionary<String, Any>#>)
        
        
        if let sectionsDataSourceArray = sectionsDataSourceArray,
            let componentModel = sectionsDataSourceArray[indexPath.row] as? ComponentModel {
            if let atomEntry = componentModel.entry as? APAtomEntry {
                
                //check if selected item is reco entry
                if let extensions = atomEntry.extensions, let analytics = extensions["analytics"] as? [String: AnyHashable], let type = analytics["type"] as? String, type == "reco" {
                    let homeClickEvent = HomeContentClickApi()
                    homeClickEvent.contentConsumption(for: atomEntry)
                }
                
                
                CustomizationManager.manager.customTitle = componentModel.title
                ZAAppConnector.sharedInstance().analyticsDelegate.trackEvent(name: "Thumbnail Click", parameters: analyticsParams(for: componentModel))

                if atomEntry.entryType == .video ||  atomEntry.entryType == .channel || atomEntry.entryType == .audio {
                    if let playable = atomEntry.playable() {
                        if let p = atomEntry.parentFeed,
                            let pipesObject = p.pipesObject {
                            playable.pipesObject = pipesObject as NSDictionary
                        }
                        playable.play()
                    }
                }
                else if atomEntry.entryType == .link {
                    if let urlstring = atomEntry.link,
                        let linkURL = URL(string: urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!),
                        APUtils.shouldOpenURLExternally(linkURL) {
                        self.dismiss(animated: false) {
                            UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview: UICollectionReusableView!
        
        if kind == UICollectionView.elementKindSectionHeader,
            let sectionsDataSourceArray = sectionsDataSourceArray,
            let componentModel = sectionsDataSourceArray[indexPath.section] as? ComponentModel,
            let header =  componentModel.componentHeaderModel,
            let layoutName =  header.layoutStyle {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: layoutName, for: indexPath) as? UniversalCollectionViewHeaderFooterView {
                
                headerView.delegate = self
                /*if headerView.componentViewController == nil,*/
                    if let currentModel = header.entry as? APModel {
                    headerView.componentViewController =  ComponenttFactory.componentViewController(with: header,
                                                              andModel: currentModel,
                                                              for: headerView,
                                                              delegate: self,
                                                              parentViewController: self)
                    if headerView.componentViewController?.responds(to: #selector(setter: ComponentProtocol.delegate)) == true {
                        _ = headerView.componentViewController?.perform(#selector(setter: ComponentProtocol.delegate), with: self)
                    }
                }
                if headerView.componentViewController?.responds(to: #selector(setter: ComponentProtocol.componentModel)) == true {
                    _ = headerView.componentViewController?.perform(#selector( setter: ComponentProtocol.componentModel), with: header)
                }
                if headerView.componentViewController?.responds(to: #selector(setter: ComponentProtocol.componentDataSourceModel)) == true {
                    _ = headerView.componentViewController?.perform(#selector( setter: ComponentProtocol.componentDataSourceModel), with: header)
                }
                reusableview = headerView
            }
        }
        
        if reusableview == nil {
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ZeeHomeScreen_Family_Ganges_header_cell_1", for: indexPath) as? UniversalCollectionViewHeaderFooterView
            reusableview.frame.size.height = 0
            reusableview.frame.size.width = 0
        }
        
        reusableview.layer.shouldRasterize = true
        reusableview.layer.rasterizationScale = UIScreen.main.scale
        
        return reusableview
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? UniversalCollectionViewCell {
            if !children.contains(cell.componentViewController!) {
                DispatchQueue.main.async {
                    cell.addViewController(toParentViewController: self)
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? UniversalCollectionViewCell {
            cell.removeViewControllerFromParentViewController()
 
        }
    }
    
    func handleCellDidEndDisplaying(cell: UICollectionViewCell, reason: ZeeComponentEndDisplayingReason) {
//        if  let universalCollectionViewCell = cell as? UniversalCollectionViewCell,
//            let componentViewController = universalCollectionViewCell.componentViewController
//        {
//            componentViewController.didEndDisplaying?(with: reason)
//        }
    }
    
    func handleCellDidStart(cell: UICollectionViewCell) {
//        if  let universalCollectionViewCell = cell as? UniversalCollectionViewCell,
//            let componentViewController = universalCollectionViewCell.componentViewController
//        {
//            componentViewController.didStartDisplaying?()
//        }
    }
    
    func didStartDisplaying() {
//        if let visibleCells = self.collectionView?.visibleCells {
//            for visibleCell in visibleCells {
//                self.handleCellDidStart(cell: visibleCell)
//            }
//        }
    }
    
    func didEndDisplaying(with reason: ZeeComponentEndDisplayingReason) {
//        if let visibleCells = self.collectionView?.visibleCells {
//            for visibleCell in visibleCells {
//                self.handleCellDidEndDisplaying(cell: visibleCell, reason: .parent)
//            }
//        }
    }
    
    var isLoading = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.componentViewController?(self, didChangedContentOffset: scrollView.contentOffset)
        
        if collectionViewFlowLayout?.isVertical() == true  {
            let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
            let reloadMargin:CGFloat = scrollView.frame.size.height*2 // load next items before getting to the end of the collection view
            if (bottomEdge >= scrollView.contentSize.height - reloadMargin && !isLoading),
                shouldLoadMoreItems() == true {
                loadMoreItems()
            }
        }
        else {
            let rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width
            let reloadMargin:CGFloat = scrollView.frame.size.width*2 // load next items before getting to the end of the collection view
            if rightEdge >= scrollView.contentSize.width - reloadMargin && !isLoading,
                shouldLoadMoreItems() == true {
                loadMoreItems()
            }
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if collectionViewFlowLayout?.isVertical() == false {
            ZAAppConnector.sharedInstance().analyticsDelegate.trackEvent(name: "Carousal Bucket Swipe", parameters: analyticsParams(for: self.currentComponentModel))

        }
    }

    // MARK: - ComponentDelegate
    
    @objc public func componentViewController(_ componentViewController: (UIViewController & ComponentProtocol)?,
                                 didSelectModel model: NSObject?,
                                 componentModel: ComponentModelProtocol?,
                                 at indexPath: IndexPath?,
                                 completion: ((UIViewController?) -> Void)?) {
        
        
        if let componentModel = componentModel as? ComponentModel {
            if let atomEntry = componentModel.entry as? APAtomEntry {
                if atomEntry.entryType == .video ||  atomEntry.entryType == .channel || atomEntry.entryType == .audio {
                    if let playable = atomEntry.playable() {
                        if let p = atomEntry.parentFeed,
                            let pipesObject = p.pipesObject {
                            playable.pipesObject = pipesObject as NSDictionary
                            playable.play()
                        }
                        else {
                            playable.play()
                        }
                    }
                }
                else if atomEntry.entryType == .link {
                    if let urlstring = atomEntry.link,
                        let linkURL = URL(string: urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!),
                        APUtils.shouldOpenURLExternally(linkURL) {
                        self.dismiss(animated: false) {
                            UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Customization
    func customizeBackground() {
        self.customizeBackgroundColor()
    
        if let atomFeed = self.componentDataSourceModel as? APAtomFeed {
            setHorizontalListInnerHeaderFrom(atomFeed: atomFeed)
        }
    }
    
    func setHorizontalListInnerHeaderFrom(atomFeed:APAtomFeed) {
        if let horizontalListTitle = atomFeed.title {
            if let horizontalListInnerLabel = self.horizontalListInnerLabel {
                horizontalListInnerLabel.text = horizontalListTitle
                self.horizontalListInnerLabel?.isHidden = horizontalListTitle.isEmptyOrWhitespace()
            }
        }
    }
    
    func customizeBackgroundColor() {
    let componentCustomization = ComponentModelCustomization()
      let color = componentCustomization.color(forAttributeKey: kAttributeBackgroundColorKey,
                                               attributesDict: nil,
                                               withModel: componentDataSourceModel,
                                               componentState: .normal)

      if let color = color, color.isNotEmpty() {
          view.backgroundColor = color
      } else {
        
      }
    }
    
      
    // MARK: - Helper functions
    
    private func refreshFromDataSourceArray() {
        // In case on none connected screens - componentDataSourceModel is nil. Therefore in this case the refresh will be defined by the earliest of the section's datasource.
    }
    
    // MARK: - Notifications
    override func refreshComponentNotification(_ notification:Notification) {
        super.refreshComponentNotification(notification)
        self.shouldInvalidateCache = true
    }
    
    @objc func didReceiveActionNotification(_ notification:Notification) {
        if let object = notification.object as? NSDictionary, let componentType = object[kActionComponentType] as? NSNumber {
            let actionType: CAActionType = CAActionType(rawValue: UInt(truncating: componentType))
            if actionType == .updateSectionBody {
                if let _ = object[kActionCallerComponentModel] as? ComponentModel,
                    let model = object[kActionComponentDataSourceModel] as? APModel {
                    ZAAppConnector.sharedInstance().analyticsDelegate.trackEvent(name: model.screenViewTitle(true), parameters: [:])
                }
            }
        }
    }
    
    func performCompletionAndStopLoadingIndicator() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "kCANotificationsLoadingFinishedKey"),
                                            object: self)
        }
    }
    
    // MARK: - Analytics

    func analyticsParams(for model: ComponentModel?) -> [String : Any] {
        guard let model = model,
            let entry = model.entry,
            let extensions = entry.extensions,
            let analyticsParams = extensions["analytics"] as? [String : Any] else {
                return [:]
        }
        return analyticsParams
    }
}

extension SectionCompositeViewController: UniversalCollectionViewHeaderFooterViewDelegate {
    
    func headerFooterViewDidSelect(_ headerFooterView: UniversalCollectionViewHeaderFooterView?) {
        
        func tryPerformHeaderFooterView(ofKind kind:String) -> Bool {
            guard let headerFooterView = headerFooterView,
                let visisbleIndexPathes = collectionView?.indexPathsForVisibleSupplementaryElements(ofKind: kind),
                visisbleIndexPathes.count > 0 else {
                    return false
            }
            
            for indexPath in visisbleIndexPathes {
                if let supplementaryItem = collectionView?.supplementaryView(forElementKind: kind,
                                                                             at: indexPath),
                    supplementaryItem == headerFooterView {
                    self.headerFooterViewDidSelect(headerFooterView,
                                                   at: indexPath)
                    return true
                }
            }
            return false
        }
        
        if tryPerformHeaderFooterView(ofKind: UICollectionView.elementKindSectionHeader) == false {
            _ = tryPerformHeaderFooterView(ofKind: UICollectionView.elementKindSectionFooter)
        }
        
    }
    
    func headerFooterViewDidSelect(_ headerFooterView: UniversalCollectionViewHeaderFooterView,
                                   at indexPath: IndexPath) {
        
        if let sectionsDataSourceArray = sectionsDataSourceArray,
            let componentModel = sectionsDataSourceArray[indexPath.section] as? ComponentModel {
           
            CustomizationManager.manager.customTitle = componentModel.title
            ZAAppConnector.sharedInstance().analyticsDelegate.trackEvent(name: "View More Selected", parameters: analyticsParams(for: componentModel))
            
            guard let headerModel =  componentModel.componentHeaderModel,
                let urlScheme = headerModel.actionUrlScheme,
                let linkURL = URL(string: urlScheme),
                APUtils.shouldOpenURLExternally(linkURL) else {
                    return
            }
            self.dismiss(animated: true)
            ZAAppConnector.sharedInstance().audioSessionDelegate?.deactivateAudioSession()
            UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
        }
    }
}

extension SectionCompositeViewController {

    func showInterstitial() {
        
        guard let screenConfiguration = self.screenConfiguration, screenConfiguration.shouldShowInterstitial == true else {
            return
        }
        
        ZeeHomeInterstitialManager.instance.showInterstitial(componentModel: currentComponentModel!, on: self)
    }
}

class CustomSegmentedControl: UIView {
    
    private var buttonsTitles: [String]!
    private var buttons: [UIButton]!
    
    var changeToIndex: ((Int)->())!
    
    var textColor: UIColor = .white
    var selectorTextColor: UIColor = UIColor.init(hex: "ff0091")
    var selectorViewColor: UIColor = .white
    
    private func configStackView() {
        let stack = UIStackView.init(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    private func createButtons() {
        buttons = []
        buttons.removeAll()
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        for title in buttonsTitles {
            let button = UIButton.init(type: .custom)
            button.setTitle(title, for: .normal)
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            button.backgroundColor = .clear
            button.titleLabel?.font = UIFont(name: "NotoSans-SemiBold", size: 12)!
            button.layer.cornerRadius = bounds.size.height / 2.0
            button.setTitleColor(textColor, for: .normal)
            buttons.append(button)
        }
        buttons.first?.setTitleColor(selectorTextColor, for: .normal)
        buttons.first?.backgroundColor = selectorViewColor
    }
    
    @objc private func buttonAction(sender: UIButton) {
        for (index, button) in buttons.enumerated() {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .clear
            
            if button == sender {
                button.setTitleColor(selectorTextColor, for: .normal)
                button.backgroundColor = selectorViewColor
                changeToIndex(index)
            }
        }
    }
    
    private func updateView() {
        backgroundColor = .clear
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        layer.cornerRadius = bounds.size.height / 2.0
        createButtons()
        configStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setButtonsTitles(buttonsTitles: [String]!) {
        self.buttonsTitles = buttonsTitles
        updateView()
    }

}
