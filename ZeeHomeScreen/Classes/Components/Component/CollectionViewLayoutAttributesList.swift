//
//  CollectionViewLayoutAttributesList.swift
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

import Foundation

/// Container of the Flow layout sectino attributes
@objc open class CollectionViewLayoutAttributesList:NSObject {
    
    /// Array of sections attributes
    open var cachedSectionsAttributes:[SectionCollectionViewLayoutAttributes] = [] {
        didSet {
            originalAttributes = deepCopy()
        }
    }
    
    /// Array of the original sections attributes.
    /// - note: This attributes will not be changed and used only to retrieve origin place of animated cells like headers
    private(set) var originalAttributes:[SectionCollectionViewLayoutAttributes] = []
    
    /// Deep copy of the sections attributes
    /// - Returns: New array of the CASectionCollectionViewLayoutAttributes
    func deepCopy() -> [SectionCollectionViewLayoutAttributes] {
        return cachedSectionsAttributes.map{$0.deepCopy()}
    }
    
    /// Retrieve section attributes for original list
    /// - Params:
    ///     - changedAttribute: section from cachedSectionsAttributes array
    ///     - sectionIndex: Index ot existsing section
    /// - Returns: Original section or nil if can not find
    func originalSection(changedAttribute:UICollectionViewLayoutAttributes,
                         sectionIndex:NSInteger) -> SectionCollectionViewLayoutAttributes? {
        guard originalAttributes.count > sectionIndex else {
            return nil
        }
        return originalAttributes[sectionIndex]
        
    }
    
    /// Retrieve section attributes for section at index
    /// - Params:
    ///     - sectionIndex: Index ot existsing section
    /// - Returns: Section data attributes
    func sectionAttributes(for sectionIndex:NSInteger) -> SectionCollectionViewLayoutAttributes? {
        guard cachedSectionsAttributes.count > sectionIndex else {
            return nil
        }
        return cachedSectionsAttributes[sectionIndex]
    }
    
    
    /// Prepare sections for rtl mode
    /// - Params:
    ///     - collectionWidth: width of the collection
    func prepareToRTLMode(collectionWidth:CGFloat) {
        func frameForRrl(attribute:UICollectionViewLayoutAttributes,
                         collectionWidth:CGFloat) -> CGRect {
            return CGRect(x: collectionWidth - attribute.frame.size.width - attribute.frame.origin.x,
                          y: attribute.frame.origin.y,
                          width: attribute.frame.size.width,
                          height: attribute.frame.size.height)
        }
        
        for sections in cachedSectionsAttributes {
            if let header = sections.header {
                header.frame = frameForRrl(attribute: header,
                                           collectionWidth: collectionWidth)
            }
            
            sections.sectionData.forEach {
                $0.frame = frameForRrl(attribute: $0,
                                       collectionWidth: collectionWidth)
            }
            
            if let footer = sections.footer {
                footer.frame = frameForRrl(attribute: footer,
                                           collectionWidth: collectionWidth)
            }
        }
    }
    
    /// Retrieve visible attributes for rect
    /// - Params:
    ///     - rect: serached rect in collection view
    ///     - stickyHeaderEnabled: definition sticky header
    ///     - collectionViewFlowLayout: instance of CASectionCompositeFlowLayout that used by collection
    /// - Returns: Array of the UICollectionViewLayoutAttributes visible attributes in rect
    func visibleAttributes(in rect:CGRect,
                           stickyHeaderEnabled:Bool,
                           collectionViewFlowLayout: SectionCompositeFlowLayout) -> [UICollectionViewLayoutAttributes] {
        var retVal = [UICollectionViewLayoutAttributes] ()
        // Enum all avalible sections
        for section in cachedSectionsAttributes {
            // Try to retrieve header attributes
            if let headerAttributes = section.header {
                let newHeaderAttributes = prepareStickySupplementaryAttributes(attributes: headerAttributes,
                                                                               stickyHeaderEnabled: stickyHeaderEnabled,
                                                                               collectionViewFlowLayout: collectionViewFlowLayout,
                                                                               sectionIndex: section.sectionIndex)
                // We are adding all headers as visible items because we need to control sticky behaviour
                retVal.append(newHeaderAttributes)
            }
            
            // Enum all section body attributes
            retVal.append(contentsOf: section.sectionData.filter { $0.frame.intersects(rect) } )
            
            // Try to retrieve footer attributes
            if let footerAttributes = section.footer {
                let newfooterAttributes = prepareStickySupplementaryAttributes(attributes: footerAttributes,
                                                                               stickyHeaderEnabled: stickyHeaderEnabled,
                                                                               collectionViewFlowLayout: collectionViewFlowLayout,
                                                                               sectionIndex: section.sectionIndex)
                retVal.append(newfooterAttributes)
            }
        }
        
        return retVal
    }
 
    /// Prepare sticky supplimentatry attributes
    /// - Params:
    ///     - attributes: current UICollectionViewLayoutAttributes attributes for supplimentary view
    ///     - stickyHeaderEnabled: definition sticky header
    ///     - collectionViewFlowLayout: instance of CASectionCompositeFlowLayout that used by collection
    ///     - sectionIndex: Index ot existsing section
    /// - Returns: Array of the UICollectionViewLayoutAttributes visible attributes in rect
    func prepareStickySupplementaryAttributes(attributes: UICollectionViewLayoutAttributes,
                                              stickyHeaderEnabled:Bool,
                                              collectionViewFlowLayout: SectionCompositeFlowLayout,
                                              sectionIndex:NSInteger) -> UICollectionViewLayoutAttributes {
        
        /// Return base position of unchanged attributes from originalAttributes
        /// - Params:
        ///     - originalSection: section from originalAttributes
        /// - Returns: CGFloat float value of origin Y for current attribute of if not availible Y of changed attribute
        func originalOriginY(originalSection:SectionCollectionViewLayoutAttributes) -> CGFloat {
            var retVal = attributes.frame.origin.y
            
            guard let isKindOfElement = attributes.representedElementKind else {
                //If not attribute we return in original origin Y of the attributes
                return retVal
            }
            
            switch isKindOfElement {
            case UICollectionView.elementKindSectionHeader:
                if let originalY = originalSection.header?.frame.origin.y {
                    retVal = originalY
                }
            case UICollectionView.elementKindSectionFooter:
                if let originalY = originalSection.footer?.frame.origin.y {
                    retVal = originalY
                }
            default:
                break
            }
            return retVal
        }
        
        let retVal = attributes
        
        // Check if sticky header enabled
        guard stickyHeaderEnabled == true,
            let collectionView = collectionViewFlowLayout.collectionView,
            let originalSection = originalSection(changedAttribute: attributes, sectionIndex: attributes.indexPath.section) else {
                return retVal
        }
        
        let contentOffset = collectionView.contentOffset
        
        // Check if attribute is supplementary view
        if retVal.representedElementCategory == .supplementaryView {
            
            let section:Int = retVal.indexPath.section
            let numberOfItemsInSection = collectionView.numberOfItems(inSection: section)
            let minimumInteritemSpacing: CGFloat = 0.0//collectionViewFlowLayout.estimatedMinimumInteritemSpacing(for: sectionIndex)
            
            if numberOfItemsInSection > 0 {
                // We get first and last cell at indePath of the group to find content size between this items
                let firstCellIndexPath = IndexPath(item: 0, section: section)
                let lastCellIndexPath = IndexPath(item: max(0, numberOfItemsInSection-1), section: section)
                
                if let firstCellAttributes = collectionViewFlowLayout.layoutAttributesForItem(at: firstCellIndexPath),
                    let lastCellAttributes = collectionViewFlowLayout.layoutAttributesForItem(at: lastCellIndexPath) {
                    
                    // Vertical type of the flow layout
                    if collectionViewFlowLayout.scrollDirection == .vertical {
                        let headerHeight = retVal.frame.height
                        var origin = retVal.frame.origin
                        
                        // We are retrieving original section Y without changes, to found start location of the supplementary view
                        let componentOriginY = originalOriginY(originalSection: originalSection)
                        
                        // Find new Y for current supplimentary attributes
                        origin.y = min(max(contentOffset.y, componentOriginY),
                                       lastCellAttributes.frame.maxY - headerHeight + minimumInteritemSpacing)
                        
                        // Assign new frame
                        retVal.frame = CGRect(origin: origin, size: retVal.frame.size)
                    }
                    else {
                        //TODO: Horizontall was never checked, please check logic if in future will need headers for horizontal. Should be same as vertical logic
                        let headerWidth = retVal.frame.width
                        var origin = retVal.frame.origin
                        
                        origin.x = min(max(contentOffset.x, (firstCellAttributes.frame.minX - headerWidth)),
                                       lastCellAttributes.frame.maxX - headerWidth)
                        
                        retVal.frame = CGRect(origin: origin, size: retVal.frame.size)
                    }
                    
                    retVal.zIndex = 1024
                }
            }
        }
        return retVal
    }
}
