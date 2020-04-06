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
    
    func prepareSections() {
        guard currentComponentModel != nil else {
            return
        }
        
        if sectionsDataSourceArray == nil {
            sectionsDataSourceArray = []
        }
        
        if let currentComponentModel = self.currentComponentModel {
            DatasourceManager.sharedInstance().load(model: currentComponentModel) { (component) in
                guard let component = component as? ComponentModel else {
                    return
                }
              
                self.liveComponentModel = component

                if let componentsArray = component.childerns,
                    componentsArray.count > 0 {
                    let liveComponentsArray = self.liveComponentsWithLazyLoading(componentsArray: componentsArray, liveComponents: self.sectionsDataSourceArray)
                    
                        if currentComponentModel.isVertical == true && component.type != "GRID" {
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
                    self.isLoading = false
                    return
                }
                self.liveComponentModel = component

                if let componentsArray = component.childerns,
                    componentsArray.count > 0 {
                    let liveComponentsArray = self.liveComponentsWithLazyLoading(componentsArray: componentsArray, liveComponents: self.sectionsDataSourceArray)
                    DispatchQueue.main.async(execute: {
                        if self.currentComponentModel?.isVertical == true {
                            self.insertSections(sectionToInsert: liveComponentsArray)
                        }
                        else {
                            self.insertItems(itemToInsert: liveComponentsArray)
                        }
                    })
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
        if self.currentComponentModel?.isVertical == true {
            self.collectionView?.deleteSections(IndexSet(integer: lazyComponentIndex))
        }
        else {
            self.collectionView?.deleteItems(at: [IndexPath(row: lazyComponentIndex, section: 0)])
        }
        
        // add lazy loading cell at the end
        components.insert(lazyLoadingItem, at: components.count)
        liveItems.append(contentsOf: components)
        return components
    }
    
    func lazyLoadingComponent() -> ComponentModel {
        let lazyComponent = ComponentModel.init(type: "LAZY_LOADING")
        lazyComponent.layoutStyle = "Family_Ganges_lazy_loading_1"
        lazyComponent.isVertical = currentComponentModel?.isVertical ?? false
        lazyComponent.styleHelper = GangasFamilyStyleHelper.init(cellKey: "LAZY_LOADING", containerType: "LAZY_LOADING")
        return lazyComponent
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
            if self.currentComponentModel?.isVertical == true {
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
