//
//  SectionCompositeViewController+LazyLoading.swift
//  ZeeHomeScreen
//
//  Created by Miri on 10/02/2020.
//

import Foundation
import ZappPlugins
import ApplicasterSDK



extension SectionCompositeViewController {
    
    private static let LOADING_EXTRA_CONTENT_DELAY = 0.5
    
    func prepareSections() {
        guard currentComponentModel != nil else {
            return
        }
        
        if sectionsDataSourceArray == nil {
            sectionsDataSourceArray = []
        }
        
        //check if we already have entries inside the feed
        
        if let component = currentComponentModel, component.childerns != nil, component.childerns!.count > 0 {
            
            self.liveComponentModel = component
            
            if let componentsArray = component.childerns,
                componentsArray.count > 0 {
                let liveComponentsArray = self.liveComponentsWithLazyLoading(componentsArray: componentsArray, liveComponents: self.sectionsDataSourceArray)
                
                if component.isVertical == true && !component.isGridType() {
                    self.prepareCollectionSections(sections: liveComponentsArray)
                }
                else {
                    self.prepareCollectionItems(items: liveComponentsArray)
                }
            }
            else {
                // delete lazy loading components if needed
            }
            
            self.setComponentModel(component)
            let additionalContent = self.prepareAdditionalContent(component)
            self.loadAdditionalContent(indexToInsert: 1, for: additionalContent, component: component)
            
            //load next content page if current screen == inner screen
            if let collectionView = collectionView,
                component.isVertical == true && component.isGridType() {
                //there should be a small delay because collectionView crashes when tries to remove loading cell that is not created yet, because response comes immediately (line 303 in this class)
                DispatchQueue.main.asyncAfter(deadline: .now() + SectionCompositeViewController.LOADING_EXTRA_CONTENT_DELAY) {
                    self.preloadNextContentPage(collectionView)
                }
            }
            return
        }
        
        
        //load entries for current component
        
        if let currentComponentModel = self.currentComponentModel {
            DatasourceManager.sharedInstance().load(model: currentComponentModel) { (component) in
                guard let component = component as? ComponentModel else {
                    return
                }
                
                self.liveComponentModel = component

                if let componentsArray = component.childerns,
                    componentsArray.count > 0 {
                    let liveComponentsArray = self.liveComponentsWithLazyLoading(componentsArray: componentsArray, liveComponents: self.sectionsDataSourceArray)
                    
                    if currentComponentModel.isVertical == true && !component.isGridType() {
                            self.prepareCollectionSections(sections: liveComponentsArray)
                        }
                        else {
                            self.prepareCollectionItems(items: liveComponentsArray)
                        }
                }
                else {
                    // delete lazy loading components if needed
                }
                
                self.setComponentModel(component)
                
                // update the title after setting ComponentModel. the nav bar is taking the title from the component
                if let zappNavigationController = self.navigationController as? ZPNavigationController {
                    zappNavigationController.navigationBarManager?.updateNavBarTitle()
                }
                
                let additionalContent = self.prepareAdditionalContent(component)
                self.loadAdditionalContent(indexToInsert: 1, for: additionalContent, component: component)
                
                //load next content page if current screen == inner screen
                if let collectionView = self.collectionView,
                    component.isVertical == true && component.isGridType() {
                    //there should be a small delay because collectionView crashes when tries to remove loading cell that is not created yet, because response comes immediately (line 303 in this class)
                    DispatchQueue.main.asyncAfter(deadline: .now() + SectionCompositeViewController.LOADING_EXTRA_CONTENT_DELAY) {
                        self.preloadNextContentPage(collectionView)
                    }
                }
            }
        }
    }
    
    func prepareAdditionalContent(_ component: ComponentModel) -> [AdditionalContent] {
        
        guard let config = component.entry?.extensions else {
            return []
        }
        
        var additionalContent: [AdditionalContent] = []
        
        if let adConfigs = config["ad_config"] as? [AnyHashable: Any], let banners = adConfigs[AdditionalContentType.banners.rawValue] as? String {
            let banners = AdditionalContent.init(dsType: .banners, dsUrl: banners)
            additionalContent.append(banners)
        }
        
        if let continueWatching = config[AdditionalContentType.continueWatching.rawValue] as? String {
            let continueWatching = AdditionalContent.init(dsType: .continueWatching, dsUrl: continueWatching)
            additionalContent.append(continueWatching)
        }

        if let recommendation = config[AdditionalContentType.recommendations.rawValue] as? String {
            let recommendation = AdditionalContent.init(dsType: .recommendations, dsUrl: recommendation)
            additionalContent.append(recommendation)
        }
        
        if let relatedCollection = config[AdditionalContentType.relatedCollection.rawValue] as? String {
            let relatedCollection = AdditionalContent.init(dsType: .relatedCollection, dsUrl: relatedCollection)
            additionalContent.append(relatedCollection)
        }

        return additionalContent
    }
    
    func loadAdditionalContent(indexToInsert: Int, for contents: [AdditionalContent], component: ComponentModel) {
        
        if let additionalContent = contents.first, let type = additionalContent.dsType {
            if let typeLink = additionalContent.dsUrl, !typeLink.isEmptyOrWhitespace() {
                    let componentModel = ComponentModel.init(entry: APAtomFeed.init(url: typeLink))
                    componentModel.dsUrl = typeLink
                    DatasourceManager.sharedInstance().load(model: componentModel) { (feedComponent) in
                        
                        var nContents = contents
                        nContents.removeFirst()
                        
                        guard let feedComponent = feedComponent as? ComponentModel else {
                            
                            switch type {
                            case .continueWatching:
                                self.loadAdditionalContent(indexToInsert: indexToInsert + 1 , for: nContents, component: component)
                            case .recommendations:
                                self.loadAdditionalContent(indexToInsert: self.sectionsDataSourceArray!.count - 2, for: nContents, component: component)
                            case .relatedCollection:
                                break
                            case .banners:
                                self.loadAdditionalContent(indexToInsert: indexToInsert + 1 , for: nContents, component: component)
                            }
                            
                            return
                        }
                        
                        switch type {
                        case .continueWatching:
                            self.insertComponents(index: indexToInsert, from: [feedComponent])
                            self.loadAdditionalContent(indexToInsert: indexToInsert + 1 , for: nContents, component: component)
                        case .recommendations:
                            // This works with a data source version that supports feed of feeds (12.1.41 or higher)
                            if let children = feedComponent.childerns {
                                self.insertComponents(index: indexToInsert, from: children)
                            }
                            self.loadAdditionalContent(indexToInsert: self.sectionsDataSourceArray!.count - 2, for: nContents, component: component)
                        case .relatedCollection:
                            self.insertComponents(index: self.sectionsDataSourceArray!.count, from: feedComponent.childerns!)
                        case .banners:
                            if let childrens = feedComponent.childerns {
                                
                                var indexesArray: [Int] = []
                                for item in childrens {
                                    guard let extensions = item.entry?.extensions, let ad_config = extensions["ad_config"] as? [String: Any], let position = ad_config["position"] as? Int else {
                                        return
                                    }
                                    indexesArray.append(position)
                                }
                                
                                self.insertBanners(indexes: indexesArray, from: feedComponent)
                                self.loadAdditionalContent(indexToInsert: indexToInsert + 1, for: nContents, component: component)
                            }
                        }
                    }
                } else {
                    var nContents = contents
                    nContents.removeFirst()
                    
                    loadAdditionalContent(indexToInsert: indexToInsert, for: nContents, component: component)
            }
        }
    }
    
    func prepareCollectionSections(sections: [ComponentModelProtocol]) {
        if sectionsDataSourceArray == nil {
            sectionsDataSourceArray = []
        }
        sectionsDataSourceArray = sectionsDataSourceArray! + sections
    }
    
    func prepareCollectionItems(items: [ComponentModelProtocol]) {
        if sectionsDataSourceArray == nil {
            sectionsDataSourceArray = []
        }
        sectionsDataSourceArray = sectionsDataSourceArray! + items
    }
    
    func shouldLoadMoreItems() -> Bool {
        if let sectionsDataSourceArray = sectionsDataSourceArray,
            let lastComponent = sectionsDataSourceArray[sectionsDataSourceArray.count - 1] as? ComponentModel,
            lastComponent.type == "LAZY_LOADING" {
            return true
        }
        return false
    }
    
    func loadMoreItems() {
        if !self.isLoading {
            self.isLoading = true
            // Download more data
            // Send the indexpath of the last component before lazy loading component
            self.loadNextComponents(lastIndexPath: self.sectionsDataSourceArray!.count - 2)
        }
    }
    
    func loadNextComponents(lastIndexPath: Int) {
        if let liveComponentModel = self.liveComponentModel,
            let nextPage = liveComponentModel.nextPage,
            let nextPageUrl = nextPage.nextPageUrl {
            
            DatasourceManager.sharedInstance().load(atomFeedUrl: nextPageUrl, parentModel: liveComponentModel) { (component) in
                guard let component = component as? ComponentModel else {
                    
                    var indexPath: IndexPath!
                    
                    if self.sectionsDataSourceArray?.last?.type == "LAZY_LOADING" {
                        self.removeComponent(forModel:  self.sectionsDataSourceArray?.last as? NSObject, andComponentModel:  self.sectionsDataSourceArray?.last)
                    }
           
                    return
                }
                self.isLoading = false
                self.liveComponentModel = component

                if let componentsArray = component.childerns,
                    componentsArray.count > 0 {
                    let liveComponentsArray = self.liveComponentsWithLazyLoading(componentsArray: componentsArray, liveComponents: self.sectionsDataSourceArray)

                        if let currentComponentModel = self.currentComponentModel, currentComponentModel.isVertical == true &&  !currentComponentModel.isGridType() {
                            self.insertSections(sectionToInsert: liveComponentsArray)
                        }
                        else {
                            self.insertItems(itemToInsert: liveComponentsArray)
                        }
                }
                else {
                    // delete lazy loading components if needed
                    
                }
            }
        }
    }
    
    func liveComponentsWithLazyLoading(componentsArray: [ComponentModelProtocol]?, liveComponents: [ComponentModelProtocol]?) -> [ComponentModelProtocol] {
        
        var components = [ComponentModelProtocol]()
        var liveItems = [ComponentModelProtocol]()
        
        if let componentsArray = componentsArray {
            components = componentsArray
        }
        
        guard let liveComponents = liveComponents as [ComponentModelProtocol]?,
            liveComponents.count > 0,
            let component = liveComponents[liveComponents.count - 1] as ComponentModelProtocol?,
            let lazyType = component.type,
            lazyType == "LAZY_LOADING" else {
                if let lazyComponent = self.lazyLoadingComponent() as ComponentModel? {
                    components.append(lazyComponent)
                }
                return components
        }
        
        // Remove lazy loading cell
        liveItems = liveComponents
        let lazyComponentIndex = liveComponents.count - 1
        let lazyLoadingItem = liveItems.remove(at: lazyComponentIndex)
        sectionsDataSourceArray = liveItems
        if let currentComponentModel = self.currentComponentModel, currentComponentModel.isVertical == true &&  !currentComponentModel.isGridType() {
            self.collectionView?.deleteSections(IndexSet(integer: lazyComponentIndex))
        }
        else {
            self.collectionViewFlowLayout?.isCollectionDeleteCells = true
            self.collectionView?.deleteItems(at: [IndexPath(row: lazyComponentIndex, section: 0)])
            self.collectionViewFlowLayout?.isCollectionDeleteCells = false
        }

        // add lazy loading cell at the end
        components.insert(lazyLoadingItem, at: components.count)
        liveItems.append(contentsOf: components)
        return components
    }
    
    func lazyLoadingComponent() -> ComponentModel? {
        let lazyComponent = ComponentModel.init(type: "LAZY_LOADING")
        lazyComponent.layoutStyle = "Family_Ganges_lazy_loading_1"
        lazyComponent.isVertical = currentComponentModel?.isVertical ?? false
        lazyComponent.styleHelper = GangasFamilyStyleHelper.init(cellKey: "LAZY_LOADING", containerType: "LAZY_LOADING")
        guard let currentComponentModel = currentComponentModel, let entry = currentComponentModel.entry else {
            return lazyComponent
        }
        return currentComponentModel.isContinueWatchingType() || currentComponentModel.isRecoType() || entry.isRelatedCollectionsType() ? nil :  lazyComponent
    }
    
    func insertItems(itemToInsert: [ComponentModelProtocol]) {
        
        var itemsIndexesPaths = [IndexPath]()
        let currentSectionsCount = self.sectionsDataSourceArray?.count ?? 0
        
        for item in 0..<itemToInsert.count {
            let indexPath = IndexPath(row: item + currentSectionsCount, section: 0)
            itemsIndexesPaths.append(indexPath)
        }
        
        registerLayouts(sectionsArray: itemToInsert)
        
        if itemsIndexesPaths.count > 0 {
            collectionView?.performBatchUpdates({
                
                if sectionsDataSourceArray == nil {
                    sectionsDataSourceArray = []
                }
                sectionsDataSourceArray = sectionsDataSourceArray! + itemToInsert
                collectionViewFlowLayout?.isCollectionInsertCells = true
                collectionView?.insertItems(at: itemsIndexesPaths)
                
            },completion: { (success) in
                self.collectionViewFlowLayout?.isCollectionInsertCells = false
                self.isLoading = false
            })
        }
    }
    
    func insertSections(sectionToInsert: [ComponentModelProtocol]) {
        
        let currentSectionsCount = self.sectionsDataSourceArray?.count ?? 0
        let sectionsIndexesInt = sectionToInsert.enumerated().map { offset, _ in
            currentSectionsCount + offset
        }
        let sectionIndexSet = IndexSet(sectionsIndexesInt)
        registerLayouts(sectionsArray: sectionToInsert)
        
        if sectionsIndexesInt.count > 0 {
            collectionView?.performBatchUpdates({
                
                if sectionsDataSourceArray == nil {
                    sectionsDataSourceArray = []
                }
                sectionsDataSourceArray = sectionsDataSourceArray! + sectionToInsert
                collectionViewFlowLayout?.isCollectionInsertCells = true
                collectionView?.insertSections(sectionIndexSet)
                
            },completion: { (success) in
                self.collectionViewFlowLayout?.isCollectionInsertCells = false
                self.isLoading = false
            })
        }
    }
    
    func deleteLazyLoadingCellIfNeeded(at index: Int) {
        if isLazyLoadingCellExists() == true,
            index > 0 {
            if let currentComponentModel = self.currentComponentModel, currentComponentModel.isVertical == true &&  !currentComponentModel.isGridType() {
                self.collectionView?.deleteSections(IndexSet(integer: index))
            }
            else {
                self.collectionView?.deleteItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
    
    func isLazyLoadingCellExists() -> Bool {
        if let sectionsDataSourceArray = sectionsDataSourceArray,
            let lastComponent = sectionsDataSourceArray[sectionsDataSourceArray.count - 1] as? ComponentModel,
            lastComponent.type == "LAZY_LOADING" {
            return true
        }
        else {
            return false
        }
    }
    
    func createNextComponent(url: String) -> ComponentModelProtocol? {
        if let feed = APAtomFeed.init(url: url) {
            let model = ComponentModel.init(entry: feed, threshold: 3)
            model.isVertical = true
            if let feedUrl = self.atomFeedUrl {
                model.dsUrl = feedUrl
            }
            return model
        }
        return nil
    }
}
