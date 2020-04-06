//
//  CollectionFlowLayout.swift
//  ZeeHomeScreen
//
//  Created by Miri on 24/01/2020.
//

import Foundation
import ZappPlugins
import ApplicasterSDK

@objc public class SectionCompositeFlowLayout: UICollectionViewFlowLayout {
    
    weak var componentModel:ComponentModelProtocol? {
        didSet {
            if let oldValue = oldValue as? ComponentModel,
                let componentModel = componentModel as? ComponentModel,
                oldValue != componentModel {
                setNeedsRebuild()
            }
        }
    }
    
    // Data source of the collection view
    var sectionsDataSourceArray:[ComponentModelProtocol]? {
        didSet {
            if oldValue == nil ||
                sectionsDataSourceArray == nil {
                setNeedsRebuild()
            }
            else if let oldValue = oldValue as? [ComponentModel],
                let sectionsArray = sectionsDataSourceArray as? [ComponentModel],
                oldValue != sectionsArray {
                setNeedsRebuild()
            }
        }
    }
    
    var numberOfSections:NSInteger = 0
    
    // Right to left mode
    var isRTL = false
    
    // This key is using to allow fully rebuild cells, next call of prepare method will allow fully rebuild collection flow layout
    private var allowRebuildFlowLayout = true
    // This key is using to allow temporary rebuild layout, can be used with collection batch updates where cell attributes will be changed
    public var isCollectionChangeCells = false
    
    // This key is using to allow temporary rebuild layout, can be used with collection batch updates where cells will be insert
    public var isCollectionInsertCells = false
    
    // Content size of collection layout
    var contentSize:CGSize = CGSize.zero
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        return collectionView?.bounds.width ?? 0
    }
    
    fileprivate var horizontalContentHeight: CGFloat {
        return collectionView?.bounds.height ?? 0
    }
    
    fileprivate var horizontalContentWidth: CGFloat = 0
    
    var lazyLoadingWidth: CGFloat = 50.0

    var lazyLoadingHeight: CGFloat = 50.0
    
    override public var collectionViewContentSize: CGSize {
        if isVertical() {
            return CGSize(width: contentWidth, height: contentHeight)
        } else {
            return CGSize(width: horizontalContentWidth, height: horizontalContentHeight)
        }
    }
    
    //Stotres cached Collection Flow Layout attributes
    private(set) var cacheList = CollectionViewLayoutAttributesList()
    
    fileprivate var cachedIndexPathSizes = [IndexPath: CGSize]()
    
    var stickyHeader:Bool {

        return false
    }
    
    override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override public func prepare() {
        prepare(forceUpdate: false)
    }
    
    public func prepare(forceUpdate: Bool) {
        if isVertical() {
            prepareForVertical(forceUpdate: forceUpdate)
        } else {
            prepareForHorizontal(forceUpdate: forceUpdate)
        }
    }
    
    func prepareForHorizontal(forceUpdate: Bool) {
        
        //Check if flow layout can generate attributes, look variables description
        guard forceUpdate || allowRebuildFlowLayout || isCollectionChangeCells || isCollectionInsertCells,
            let collectionView = collectionView else {
                return
        }
        
        if forceUpdate {
            horizontalContentWidth = 0
        }
        
        // Creation of the new CACollectionViewLayoutAttributesList instance, that will store cached attributes sections
        let newCachedSectionList = CollectionViewLayoutAttributesList()
        
        //Retrieve default margin from collection
        minimumLineSpacing = 10
        //CAUIBuilderRealScreenSizeHelper.collectionMinimumLineSpacing(componentModel: componentModel)
        minimumInteritemSpacing = 10
        //CAUIBuilderRealScreenSizeHelper.collectionMinimumInteritemSpacing(componentModel: componentModel)
        sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        //CAUIBuilderRealScreenSizeHelper.collectionEdgeInsets(componentModel: componentModel,
        //                                                                            collectionItemTypes: .sectionBody)
        
        //Predefines before calculation
        numberOfSections = collectionView.numberOfSections
        var currentX:CGFloat = CGFloat.nan
        var currentY:CGFloat = sectionInset.top
        var lastAttributes:UICollectionViewLayoutAttributes? = nil
        
        // Enumeration of the all available sections
        for sectionIndex in 0..<numberOfSections {
            // Layout starts to rebuild, stop allowing to rebuild
            allowRebuildFlowLayout = false
            
            // Create empty instance for the Section data for the flow layout attributes
            let sectionAttributes = SectionCollectionViewLayoutAttributes(sectionIndex: sectionIndex)
            
            // Retrieve margings from Collection CAComponendtModel (base collection component) or Group Cell CAComponentModel,
            // Group component model rertrieving from first cell data from section body
            var minimumLineSpacing: CGFloat = 8
            var minimumInteritemSpacing: CGFloat = 8
            
            if sectionIndex < self.sectionsDataSourceArray!.count, let component: ComponentModel = self.sectionsDataSourceArray![sectionIndex] as? ComponentModel, let styleHelper = component.styleHelper {
                minimumLineSpacing = styleHelper.minimumLineSpacing
                minimumInteritemSpacing = styleHelper.minimumInteritemSpacing
            }
            
            let edgeInsets  = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)//estimatedEdgeInsets(for: sectionIndex,
            //                                                              сollectionItemTypes: .sectionBody)
            
            let numbersOfItemInSection = collectionView.numberOfItems(inSection: sectionIndex)
            
            //Enumeration of the all available items per specific section
            for itemIndex in 0..<numbersOfItemInSection {
                
                // Creation new attributes
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                let currentAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                //Calculate estimated cell size
                guard let cellSize = cellSize(for: indexPath, сollectionItemTypes: .body) else {
                    break
                }
                
                // Check if previous attributes exists
                if let lastAttributes = lastAttributes {
                    let nextOriginX = currentX + lastAttributes.frame.size.width
                    let nextOriginY = currentY + lastAttributes.frame.size.height
                    //Check if new Cell must be moved to new line
                    
                    if (nextOriginY + cellSize.height + minimumLineSpacing) <= (horizontalContentHeight - edgeInsets.bottom) {
                        // New line
                        currentY = currentY + cellSize.height + minimumLineSpacing
                    } else {
                        // Able to put new cell in same row near existing cell (Grid)
                        currentX = nextOriginX + minimumInteritemSpacing
                        currentY = edgeInsets.top
                    }
                } else {
                    // Position of the first Cell in the collection
                    currentX = edgeInsets.left
                }
                
                // Assign new frame for attributes
                currentAttributes.frame = CGRect(x: currentX,
                                                 y: currentY,
                                                 width: cellSize.width,
                                                 height: cellSize.height)
                
                lastAttributes = currentAttributes
                
                // Caclulate new content width
                horizontalContentWidth = max(horizontalContentWidth, currentAttributes.frame.maxX)
                currentAttributes.zIndex = 0
                
                // Add attributes to section data
                sectionAttributes.sectionData.append(currentAttributes)
            }
            
            newCachedSectionList.cachedSectionsAttributes.append(sectionAttributes)
        }
        // Assign new cached section list
        cacheList = newCachedSectionList
        
        //Add right inset only once per collection, and avoid adding every time collection is being scrolled to this section
        if let collection = self.collectionView, horizontalContentWidth > 0 {
            let string = "SectionCompositeFlowLayout.\(String(format: "%p", collection)).prepareForHorizontal"
            DispatchQueue.once(token: string) {
                horizontalContentWidth += sectionInset.right
            }
        }
        
        if isRTL {
            collectionView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func prepareForVertical(forceUpdate: Bool) {
        
        //Check if flow layout can generate attributes, look variables description
        guard forceUpdate || allowRebuildFlowLayout || isCollectionChangeCells || isCollectionInsertCells,
            let collectionView = collectionView else {
                return
        }
        
        if let collectionViewSuperview = collectionView.superview,
            collectionViewSuperview.width != collectionView.width {
            collectionView.width = collectionViewSuperview.width
        }
        
        // Reset content height calculation when prepering vertical layout
        contentHeight = 0
        
        // Creation of the new CACollectionViewLayoutAttributesList instance, that will store cached attributes sections
        let newCachedSectionList = CollectionViewLayoutAttributesList()

        
        //Retrieve default margin from collection
        minimumLineSpacing = 10.0
        //            CAUIBuilderRealScreenSizeHelper.collectionMinimumLineSpacing(componentModel: componentModel)
        minimumInteritemSpacing = 0.0
        //            CAUIBuilderRealScreenSizeHelper.collectionMinimumInteritemSpacing(componentModel: componentModel)
        let navBarAndStatusBarInsetTop:CGFloat = 0.0
        //            componentModel?.attributes?["nav_bar_and_status_bar_inset_top"] as? CGFloat ?? 0
        
        sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        
        //            CAUIBuilderRealScreenSizeHelper.collectionEdgeInsets(componentModel: componentModel,
        //                                                                            collectionItemTypes: .sectionBody)
        
        //Predefines before calculation
        numberOfSections = collectionView.numberOfSections
        
        var interLineFilling = false
        
        var currentX:CGFloat = CGFloat.nan
        var currentY:CGFloat = sectionInset.top + navBarAndStatusBarInsetTop
        var allowedMaxY:CGFloat = currentY
        
        var lastAttributes:UICollectionViewLayoutAttributes? = nil
        
        // Array to define if cell can be placed between other cells
        var lastInterLineAttributes = [UICollectionViewLayoutAttributes]()

        // Enumeration of the all available sections
        for sectionIndex in 0..<numberOfSections {
            // Layout starts to rebuild, stop allowing to rebuild
            allowRebuildFlowLayout = false
            
            // Create empty instance for the Section data for the flow layout attributes
            let sectionAttributes = SectionCollectionViewLayoutAttributes(sectionIndex: sectionIndex)
            
            // Retrieve margings from Collection CAComponentModel (base collection component) or Group Cell CAComponentModel,
            // Group component model rertrieving from first cell data from section body
            
            var minimumLineSpacing: CGFloat = 8
            var minimumInteritemSpacing: CGFloat = 8
            
            if sectionIndex < self.sectionsDataSourceArray!.count, let component: ComponentModel = self.sectionsDataSourceArray![sectionIndex] as? ComponentModel, let styleHelper = component.styleHelper {
                minimumLineSpacing = styleHelper.minimumLineSpacing
                minimumInteritemSpacing = styleHelper.minimumInteritemSpacing
            }

            let edgeInsets              =  UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            //                estimatedEdgeInsets(for: sectionIndex,
            //                                                              сollectionItemTypes: .body)
            
            let numbersOfItemInSection = collectionView.numberOfItems(inSection: sectionIndex)
            var newComponentNewLine = true
            
            // Creation header attributes
            let YPosition = sectionIndex == 0 ? allowedMaxY : allowedMaxY + minimumLineSpacing
            
            if ComponentHelper.shouldHideHeader(section: sectionIndex,
                                                sectionsDataSourceArray: sectionsDataSourceArray) == false,
                let headerCollectionViewLayoutAttributes = headerCollectionViewLayoutAttributes(for: sectionIndex,
                                                                                                currentYPosition: YPosition) {
                lastAttributes = headerCollectionViewLayoutAttributes
                
                // Calculate content height
                contentHeight = max(contentHeight, headerCollectionViewLayoutAttributes.frame.maxY)
                
                currentX = edgeInsets.left
                allowedMaxY = headerCollectionViewLayoutAttributes.frame.maxY
                headerCollectionViewLayoutAttributes.zIndex = 1024
                
                // Set header attributes to section data
                sectionAttributes.header = headerCollectionViewLayoutAttributes
                
                // Header starts from new line no interline items needed, remove all items from a list
                lastInterLineAttributes.removeAll()
            }
            
            //Enumeration of the all available items per specific section
            for itemIndex in 0..<numbersOfItemInSection {
                
                // Creation new attributes
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                let currentAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                //Calculate estimated cell size
                guard var cellSize = cellSize(for: indexPath, сollectionItemTypes: .body) else {
                    break
                }
                
                //Check if needed to ignore custom group collection margin
                let ignoreGroupCollectionMargin =  true//shouldIgnoreGroupCollectionMargin(for: indexPath, сollectionItemTypes: .sectionBody)
                
                func startFromNewLine(_ ignoreEdgeInsets:(shouldIgnore:Bool, isBanner:Bool, isInjectedBanner:Bool) = (false, false, false)) {
                    // New line
                    interLineFilling = false
                    
                    if ignoreEdgeInsets.shouldIgnore, ignoreEdgeInsets.isBanner {
                        let values = self.getCellSizeAndXForBanners(ignoreEdgeInsets,
                                                                    cellSize: cellSize,
                                                                    edgeInsets: edgeInsets)
                        currentX = values.currentX
                        cellSize = values.cellSize
                    }
                    else {
                        currentX = edgeInsets.left
                        
                    }
                    
                    currentY = allowedMaxY + minimumLineSpacing
                    allowedMaxY = cellSize.height + currentY
                    
                    // Since new line no interline items needed, remove all items from a list
                    lastInterLineAttributes.removeAll()
                }
                
                // Check if previous attributes exists
                if let lastAttributes = lastAttributes {
                    // We want to place new line in start of new section
                    if (newComponentNewLine == true) {
                        startFromNewLine((shouldIgnore: false, isBanner: false, isInjectedBanner: false))
                    } else {
                        let nextOriginX = currentX + lastAttributes.frame.size.width
                        //Check if new Cell must be moved to new line
                        if (nextOriginX + cellSize.width) > (collectionView.width - edgeInsets.right) || interLineFilling {
                            
                            // Need to place the item in a new line or in any open space in the current line
                            let foundRect = findPossibleRect(minimumLineSpacing: minimumLineSpacing,
                                                             sectionInset: edgeInsets,
                                                             forExpectedSize: cellSize,
                                                             for: lastInterLineAttributes,
                                                             allowedMaxBottomPosition: allowedMaxY)
                            // Check if rect was found
                            if foundRect != .null {
                                // Can place in any open space
                                currentX = foundRect.origin.x
                                currentY = foundRect.origin.y
                                interLineFilling = true
                            } else {
                                startFromNewLine()
                            }
                        } else {
                            // Able to put new cell in same row near existing cell (Grid)
                            currentX = nextOriginX + minimumInteritemSpacing
                            allowedMaxY = max(allowedMaxY, cellSize.height + currentY)
                        }
                    }
                } else {
                    // Position of the first Cell in the collection
                    currentX = edgeInsets.left
                    allowedMaxY = cellSize.height + currentY
                }
                newComponentNewLine = false
                
                // Assign new frame for attributes
                currentAttributes.frame = CGRect(x: currentX,
                                                 y: currentY,
                                                 width: cellSize.width,
                                                 height: cellSize.height)
                
                
                lastInterLineAttributes.append(currentAttributes)
                lastAttributes = currentAttributes
                
                // Caclulate new content height
                contentHeight = max(contentHeight, currentAttributes.frame.maxY)
                currentAttributes.zIndex = 0
                
                // Add attributes to section data
                sectionAttributes.sectionData.append(currentAttributes)
            }
            
            newCachedSectionList.cachedSectionsAttributes.append(sectionAttributes)
        }
        // Assign new cached section list
        cacheList = newCachedSectionList
        
        if isRTL {
            collectionView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cacheList.visibleAttributes(in: rect,
                                           stickyHeaderEnabled: stickyHeader,
                                           collectionViewFlowLayout: self)
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let sectionAttributes = cacheList.sectionAttributes(for: indexPath.section),
            sectionAttributes.sectionData.count > indexPath.item else {
                return nil
        }
        return sectionAttributes.sectionData[indexPath.item]
    }
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let sectionAttributes = cacheList.sectionAttributes(for: indexPath.section) else {
            return nil
        }
        
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return sectionAttributes.header
        case UICollectionView.elementKindSectionFooter:
            return sectionAttributes.footer
        default:
            return nil
        }
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    //MARK: Helpers
    
    /**
     Update collection view with changes, used to delete/insert cells
     - parameters:
     - sectionIndex: Index of the requested section
     - clearSectionData: This callback collection used to clear DS for expected section
     - updateSectionData: This callback collection used to add new DS for expected section
     - completion: This callback called when all updates finished
     */
    func performSectionUpdate(_ sectionIndex: Int,
                              clearSectionData: @escaping () -> Void,
                              updateSectionData: @escaping () -> Void,
                              completion: @escaping () -> Void) {
        // Allow to update collection flow layout attributes
        self.isCollectionChangeCells = true
        
        //Perform update to remove old and insert new cells based on new data
        self.collectionView?.performBatchUpdates({
           
           
            sectionsDataSourceArray?.remove(at: sectionIndex)
            self.collectionView?.deleteItems(at: [IndexPath.init(row: 0, section: sectionIndex)])
            clearSectionData()
            
        })
        
        //Callback before insert new cell, on this callback ds updated
        updateSectionData()
        
        self.collectionView?.performBatchUpdates({
            if let currentIndexPaths = modelSectionDataIndexPaths(at: sectionIndex) {
                self.collectionView?.insertItems(at: currentIndexPaths)
            }
        }, completion: { _ in
            // Stop to update collection flow layout attributes
            self.isCollectionChangeCells = false
            completion()
        })
    }
    
    /**
     Retrieve component model for supplimentary view
     - parameters:
     - sectionIndex: Index of the requested section
     - collectionItemTypes: Type of requested supplimentary model
     - returns: Requested CAComponentModel for collection item type
     */
    func supplimentaryModel(for sectionIndex:NSInteger,
                            collectionItemTypes:ComponentHelper.ComponentItemTypes) -> ComponentModel? {
        guard let sectionData = sectionsDataSourceArray?[sectionIndex] as? ComponentModel else {
            return nil
        }
        switch collectionItemTypes {
        case .body:
            return nil
        case .header:
            return sectionData.componentHeaderModel
        case .footer:
            return nil//sectionData.componentModel?.footer
        }
    }
    
    /**
     Retrieve UICollectionViewLayoutAttributes for supplimentary view
     - parameters:
     - sectionIndex: Index of the requested section
     - collectionItemTypes: Type of requested supplimentary model
     - supplementaryViewKind: Type of supplimentaryView
     - returns: Requested UICollectionViewLayoutAttributes for supplimentary view
     */
    func supplimentaryCollectionViewLayoutAttributes(for sectionIndex:NSInteger,
                                                     currentYPosition:CGFloat,
                                                     сollectionItemTypes:ComponentHelper.ComponentItemTypes,
                                                     supplementaryViewKind:String) -> UICollectionViewLayoutAttributes? {
        
        guard supplimentaryModel(for: sectionIndex, collectionItemTypes: сollectionItemTypes) != nil else {
            return nil
        }
        
        //Calculate estimated supplimentary view size
        if let supplimentaryViewSize = estimatedCellSize(for: IndexPath(item:0,
                                                                        section:sectionIndex),
                                                         сollectionItemTypes: сollectionItemTypes) {
            let supplimentaryAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: supplementaryViewKind,
                                                                           with: IndexPath(item: 0,
                                                                                           section:sectionIndex))
            let headerEdgeInsets = estimatedEdgeInsets(for: sectionIndex,
                                                       сollectionItemTypes:сollectionItemTypes)
            supplimentaryAttributes.frame = CGRect(x: headerEdgeInsets.left,
                                                   y: currentYPosition,
                                                   width: supplimentaryViewSize.width,
                                                   height: supplimentaryViewSize.height)
            
            
            return supplimentaryAttributes
        }
        return nil
    }
    
    /**
     Retrieve UICollectionViewLayoutAttributes for header supplimentary view
     - parameters:
     - sectionIndex: Index of the requested section
     - currentYPosition: placement Y position in collection flow layout attributes structure
     - returns: Requested UICollectionViewLayoutAttributes for the header supplimentary view
     */
    func headerCollectionViewLayoutAttributes(for sectionIndex:NSInteger,
                                              currentYPosition:CGFloat) -> UICollectionViewLayoutAttributes? {
        return supplimentaryCollectionViewLayoutAttributes(for: sectionIndex,
                                                           currentYPosition:currentYPosition,
                                                           сollectionItemTypes: .header,
                                                           supplementaryViewKind: UICollectionView.elementKindSectionHeader)
    }
  
    //    // MARK: -
    //
    //    /**
    //     Provide the flow layout with a concrete cell size.
    //     This is predominantly used for cells whose content is loaded asynchronously, e.g. React Native or HTML.
    //     The cache is wiped whenever the component model is changed.
    //
    //     - parameter size: The calculated size of the cell.
    //     - parameter indexPath: The index path of the received cell.
    //     */
    func cacheCellSize(_ size: CGSize, for indexPath: IndexPath) {
        if cachedIndexPathSizes[indexPath] != size {
            cachedIndexPathSizes[indexPath] = size
            prepare(forceUpdate: true)
            let context = UICollectionViewFlowLayoutInvalidationContext()
            context.invalidateItems(at: [indexPath])
            if let collectionView = collectionView {
                context.invalidateItems(at: collectionView.indexPathsForVisibleItems)
                context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader,
                                                        at: collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader))
                context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter,
                                                        at: collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter))
            }
            invalidateLayout(with: context)
        }
    }
    
    // MARK: - Private functions
    
    func getCellSizeAndXForBanners(_ ignoreEdgeInsets:(shouldIgnore:Bool, isBanner:Bool, isInjectedBanner:Bool),
                                   cellSize: CGSize,
                                   edgeInsets: UIEdgeInsets) -> (currentX:CGFloat, cellSize:CGSize) {
        //for the default, check if the there are section insets and if yes, take the max value between section and component insets
        //otherwise use the component insets
        var currentXbasevalue = sectionInset.left > 0 ? max(sectionInset.left, edgeInsets.left) : edgeInsets.left
        
        //if it is the injected banner the insets that should be used there are the section insets and ignore the edgeInsets on component
        if ignoreEdgeInsets.isInjectedBanner {
            currentXbasevalue = sectionInset.left
        }
        
        
        var updatedCellSize = cellSize
        //check if device is min width and dont use margins at all or get the section margins
        if ComponentHelper.isDeviceWidthEqualsToMin {
            currentXbasevalue = 0
            updatedCellSize.width = ComponentHelper.iPhoneMinWidth
        }
        return (currentXbasevalue, updatedCellSize)
    }
    
    /**
     Try to find possible placement for interline filling item
     - parameters:
     - minimumLineSpacing: Spacing between rows
     - sectionInset: section edge inset for current item.
     - forExpectedSize: expected size of the cell
     - currentCachedAttributes: Attributes that was placed before current cell
     
     - note:
     Can be good exmaple for case if:
     Insets: {10,10,10,10}
     Cell1: 96x96
     Cell2: 194x202
     Cell3: 96x96
     Cell3 must be placed on bottom of Cell1 and left from Cell2
     - returns: Requested UICollectionViewLayoutAttributes for the header supplimentary view
     */
    func findPossibleRect(minimumLineSpacing:CGFloat,
                          sectionInset:UIEdgeInsets,
                          forExpectedSize expectedNewItemSize:CGSize,
                          for currentCachedAttributes:[UICollectionViewLayoutAttributes],
                          allowedMaxBottomPosition:CGFloat) -> CGRect {
        var retVal:CGRect = CGRect.null
        
        for attribute in currentCachedAttributes {
            let possibleRect = CGRect(x: attribute.frame.origin.x,
                                      y: attribute.frame.origin.y + attribute.frame.size.height + minimumLineSpacing,
                                      width: expectedNewItemSize.width,
                                      height: expectedNewItemSize.height)
            let newItemBottomY = possibleRect.maxY
            if newItemBottomY <= allowedMaxBottomPosition,
                checkInterLineAttributesCanNotBePlaced(currentCachedAttributes,
                                                       interectsRect: possibleRect,
                                                       sectionInset: sectionInset) == false {
                retVal = possibleRect
                break
            }
        }
        
        return retVal
    }
    
    
    /**
     Check if posible attributes can be posted between items
     - attributes: array of availible attributes
     - interectsRect: rect for possible cell attributes
     - sectionInset: section edge inset for current item.
     
     - returns: True if item can not be placed
     */
    func checkInterLineAttributesCanNotBePlaced(_ attributes:[UICollectionViewLayoutAttributes],
                                                interectsRect rect:CGRect,
                                                sectionInset:UIEdgeInsets) -> Bool {
        var retValue = false
        if let collectionView = collectionView {
            retValue = attributes.contains(where: { element -> Bool in
                if isVertical() {
                    return rect.intersects(element.frame) || (element.frame.maxX) > (collectionView.width - sectionInset.right)
                } else {
                    return rect.intersects(element.frame) || (element.frame.maxY) > (collectionView.height - sectionInset.bottom)
                }
            })
        }
        return retValue
    }
    
    @objc public func isVertical() -> Bool {
        return scrollDirection == .vertical
    }
}

extension SectionCompositeFlowLayout {
 
    //    /**
    //     Retrieve edge insets for the section
    //     - note:
    //     Method will try to get first from groupCompnentModel edge insets. If not exist will take from main component of collection
    //     - sectionIndex: Index of the requested section
    //     - сollectionItemTypes: Items type of the section group
    //
    //     - returns: UIEdgeInsets struct representation of the section insets
    //     */
    func estimatedEdgeInsets(for sectionIndex:NSInteger,
                             сollectionItemTypes:ComponentHelper.ComponentItemTypes) -> UIEdgeInsets {
        //        guard let groupComponentModel = groupComponentModel(for: sectionIndex),
        //            let groupSectionInset = CAUIBuilderRealScreenSizeHelper.groupCollectionEdgeInsets(groupComponentModel: groupComponentModel,
        //                                                                                              collectionItemTypes: сollectionItemTypes) else {
        //                                                                                                return CAUIBuilderRealScreenSizeHelper.collectionEdgeInsets(componentModel: componentModel,
        //                                                                                                                                                               collectionItemTypes:сollectionItemTypes)
        //        }
        //        var newGroupSectionInset = groupSectionInset
        //        newGroupSectionInset.top = sectionInset.top
        //        newGroupSectionInset.bottom = sectionInset.bottom
        //        return newGroupSectionInset
//        if сollectionItemTypes == .header {
//            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
//        } else if сollectionItemTypes == .body {
//            return UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
//        }
        return  UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    /**
     Retrieve estimated cell size for current attribute.
     
     - indexPath: IndexPath for expected cell
     - сollectionItemTypes: Items type of the section group
     
     - returns: UIEdgeInsets struct representation of the section insets
     */
    func estimatedCellSize(for indexPath:IndexPath,
                           сollectionItemTypes:ComponentHelper.ComponentItemTypes) -> CGSize? {
        
        guard let sectionsDataSourceArray = sectionsDataSourceArray else {
            return CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 4)
        }
        
        if сollectionItemTypes == .body {
            if indexPath.row == sectionsDataSourceArray.count - 1 { //LAZY LOADING CELL
                if isVertical() == true  {
                    return CGSize.init(width: UIScreen.main.bounds.width, height: lazyLoadingHeight)
                }
                else  {
                    return CGSize.init(width: lazyLoadingWidth, height: horizontalContentHeight)
                }
            }
            else if let cellModel = sectionsDataSourceArray[indexPath.row] as? CellModel,
                let layoutStyle: String = cellModel.layoutStyle {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return CGSize.init(width: cellModel.ipadWidth, height: cellModel.ipadHeight)
                }
                else {
                    return CGSize.init(width: cellModel.iphoneWidth, height: cellModel.iphoneHeight)
                }
            }
            else if sectionsDataSourceArray.count > indexPath.section, let componentModel = sectionsDataSourceArray[indexPath.section] as? ComponentModel,
                let componentHelper = componentModel.styleHelper {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return CGSize.init(width: contentWidth, height: componentHelper.ipadHeight)
                }
                else {
                    return CGSize.init(width: contentWidth, height: componentHelper.iphoneHeight)
                }
            }
        }
        else if сollectionItemTypes == .header,
            let componentModel = sectionsDataSourceArray[indexPath.section] as? ComponentModel,
            let componentHeaderModel = componentModel.componentHeaderModel,
            let height = componentHeaderModel.height {
            
            return CGSize.init(width: UIScreen.main.bounds.width, height: height)
        }
        
        return CGSize.zero //init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 4)
    }

    //    /**
    //     For a given index path, retrieve the cached cell size, if it exists, otherwise get the estimated size from the
    //     cell's component attributes.
    //
    //     - parameters indexPath: The index path of the cell whose size is being calculated.
    //     - parameters сollectionItemTypes: Items type of the section group
    //
    //     - returns: The size to be used for the cell.
    //     */
    func cellSize(for indexPath: IndexPath,
                  сollectionItemTypes: ComponentHelper.ComponentItemTypes) -> CGSize? {
        //        return CGSize.init(width: 150.0, height: 150.0)
        return  /*cachedIndexPathSizes[indexPath] ??*/ estimatedCellSize(for: indexPath, сollectionItemTypes: сollectionItemTypes)
    }
    
    //    /**
    //     Retrieve array of indexPathes for expected section
    //
    //     - sectionIndex: Index of the requested section
    //
    //     - returns: Array of index paths in exists, otherwise nil
    //     */
    fileprivate func modelSectionDataIndexPaths(at sectionIndex: Int) -> [IndexPath]? {
//        return []sectionsDataSourceArray[sectionIndex]?.enumerated().map({ (offset, _) -> IndexPath in
//            IndexPath(item: offset, section: sectionIndex)
//        }).nilIfEmpty()
        return nil
    }
    
    fileprivate func setNeedsRebuild() {
        allowRebuildFlowLayout = true
    }
}
