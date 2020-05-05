//
//  SectionCompositeViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 24/01/2020.
//

import ApplicasterSDK
import Foundation
import ZappPlugins

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
    
    var liveComponents = [ComponentModelProtocol]()
    
    private var adPresenter: ZPAdPresenterProtocol?
    
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
            customizeBackground()
            
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
                    
                    self.sectionsDataSourceArray?.remove(at: index)
                    self.collectionView?.deleteSections(IndexSet(integer: index))
                    if self.shouldLoadMoreItems() == true && !isLoading {
                        self.loadMoreItems()
                    }
                    
                })
            }
        }
    }
    
    func reloadComponent(forModel model: NSObject!, andComponentModel componentModel: ComponentModelProtocol!) {
        if let componentModel = componentModel as? ComponentModel {
            if let index = sectionsDataSourceArray?.firstIndex(where: { (component) -> Bool in
                return componentModel.identifier == component.identifier && componentModel.containerType == component.containerType
            }) {
                collectionView?.performBatchUpdates({
                    
                    self.collectionView?.reloadSections(IndexSet.init(integer: index))
                    
                })
                
            }
        }
    }
    
    func insertBanners(indexes: [Int], from component: ComponentModelProtocol) {
        
        guard let components = component.childerns else {
            return
        }
        
        registerLayouts(sectionsArray: components)
        collectionView?.performBatchUpdates({
            
            var newIndexes: [Int] = []
            
            
            components.enumerated().forEach { (offset, item) in
                let index = getNewIndex(for: item, thatShouldBeInIndex: indexes[offset])
                self.sectionsDataSourceArray?.insert(item, at: index)
                newIndexes.append(index)
            }
            self.collectionView?.insertSections(IndexSet(newIndexes))
        })
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
                self.collectionView?.insertSections(indexSet)
            })
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
        
        toggle.isHidden = false
    }
    
    @IBAction private func toggleControlAction(sender: UISegmentedControl) {
        collectionView?.isHidden = sender.selectedSegmentIndex == 0 ? false : true
        epgContentView?.isHidden = sender.selectedSegmentIndex == 0 ? true : false
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
        
        prepareSections()
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let config = self.screenConfiguration {
            if config.shouldDisplayEPG && currentComponentModel?.title == "Live TV" {
                if config.epgScreenID != nil {
                    topDistanceConstraint?.constant = -64
                    prepareToggle()
                    prepareEPGView()
                }
            }
        }

        collectionView?.collectionViewLayout = collectionFlowLayout()
        self.view.backgroundColor = UIColor.black
        
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if componentInitialized == false {
            componentInitialized = true
            collectionView?.collectionViewLayout = collectionFlowLayout()
            loadComponent()
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
                    if layoutName == "Family_Ganges_lazy_loading_1" {
                        cell.backgroundColor = UIColor.clear
                    } else {
                        cell.backgroundColor = UIColor.darkGray
                    }
                    cell.setComponentModel(componentModel,
                                           model: componentModel,
                                           view: cell.contentView,
                                           delegate: self,
                                           parentViewController: self)
                    return cell
                }
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ZeeHomeScreen_Family_Ganges_horizontal_list_1", for: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let sectionsDataSourceArray = sectionsDataSourceArray,
            let componentModel = sectionsDataSourceArray[indexPath.row] as? ComponentModel {
            if let atomEntry = componentModel.entry as? APAtomEntry {
                
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
                        let linkURL = URL(string: urlstring),
                        APUtils.shouldOpenURLExternally(linkURL) {
                        self.dismiss(animated: true) {
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
        
        return reusableview
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.handleCellDidEndDisplaying(cell: cell, reason: .cellQueued)
    }
    
    func handleCellDidEndDisplaying(cell: UICollectionViewCell, reason: ZeeComponentEndDisplayingReason) {
        if  let universalCollectionViewCell = cell as? UniversalCollectionViewCell,
            let componentViewController = universalCollectionViewCell.componentViewController
        {
            componentViewController.didEndDisplaying?(with: reason)
        }
    }
    
    func handleCellDidStart(cell: UICollectionViewCell) {
        if  let universalCollectionViewCell = cell as? UniversalCollectionViewCell,
            let componentViewController = universalCollectionViewCell.componentViewController
        {
            componentViewController.didStartDisplaying?()
        }
    }
    
    func didStartDisplaying() {
        if let visibleCells = self.collectionView?.visibleCells {
            for visibleCell in visibleCells {
                self.handleCellDidStart(cell: visibleCell)
            }
        }
    }
    
    func didEndDisplaying(with reason: ZeeComponentEndDisplayingReason) {
        if let visibleCells = self.collectionView?.visibleCells {
            for visibleCell in visibleCells {
                self.handleCellDidEndDisplaying(cell: visibleCell, reason: .parent)
            }
        }
    }
    
    var isLoading = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.componentViewController?(self, didChangedContentOffset: scrollView.contentOffset)
        
        if collectionViewFlowLayout?.isVertical() == true  {
            let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
            if (bottomEdge >= scrollView.contentSize.height && !isLoading),
                shouldLoadMoreItems() == true {
                loadMoreItems()
            }
        }
        else {
            let rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width
            if rightEdge >= scrollView.contentSize.width && !isLoading,
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
                        let linkURL = URL(string: urlstring),
                        APUtils.shouldOpenURLExternally(linkURL) {
                        self.dismiss(animated: true) {
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
        view.backgroundColor = .black
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
            
             UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
        }
    }
}

extension SectionCompositeViewController: ZPAdViewProtocol {
    
    //MARK: ZPAdViewProtocol
    
    func adLoaded(view: UIView?) {
        adPresenter?.showInterstitial()
    }
    
    func stateChanged(adViewState: ZPAdViewState) {
    }
    
    func adLoadFailed(error: Error) {
    }
    
    func showInterstitial() {
        
        guard let screenConfiguration = self.screenConfiguration, screenConfiguration.shouldShowInterstitial == true else {
            return
        }
        
        guard let extensions = currentComponentModel?.entry?.extensions, let ad_config = extensions["ad_config"] as? [String: Any], let adID = ad_config["interstitial_ad_tag"] as? String, let _ = ad_config["interstitial_video_view_duration"] as? Int  else {
            return
        }
        let adPlugin = ZPAdvertisementManager.sharedInstance.getAdPlugin()
        adPresenter = adPlugin?.createAdPresenter(adView: self, parentVC: self)
        
        let adConfig: ZPAdConfig = ZPAdConfig.init(adUnitId: adID, adType: .interstitial)
        
        adPresenter?.load(adConfig: adConfig)
    }
}

class CustomSegmentedControl: UISegmentedControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "NotoSans-SemiBold", size: 12)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .normal)
        
        setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "NotoSans-SemiBold", size: 12)!,
            NSAttributedString.Key.foregroundColor: UIColor.init(hex: "ff0091")
        ], for: .selected)
        layer.cornerRadius = self.bounds.size.height / 2.0
        layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        tintColor = .red
        layer.borderWidth = 0.5
        layer.masksToBounds = true
        clipsToBounds = true
        for i in 0...subviews.count - 1 {
            if let subview = subviews[i] as? UIImageView{
                subview.layer.cornerRadius = self.bounds.size.height / 2.0
                if i == self.selectedSegmentIndex {
                    subview.backgroundColor = .white
                } else {
                    subview.backgroundColor = .clear
                }
            }
        }
    }
    
}
