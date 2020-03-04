//
//  SectionCollectionViewLayoutAttributes.swift
//  ZeeHomeScreen
//
//  Created by Miri on 06/02/2020.
//

import Foundation

/// Section Flow layout attributes
@objc open class SectionCollectionViewLayoutAttributes:NSObject {
    open var sectionIndex:NSInteger = NSNotFound
    open var header: UICollectionViewLayoutAttributes?
    open var sectionData:[UICollectionViewLayoutAttributes] = []
    open var footer: UICollectionViewLayoutAttributes?
    
    /// Deep copy of the attributes section
    /// - Returns: New instance of the CASectionCollectionViewLayoutAttributes with copied all original items
    func deepCopy() -> SectionCollectionViewLayoutAttributes {
        let retVal = SectionCollectionViewLayoutAttributes(sectionIndex:sectionIndex)
        retVal.header = header?.copy() as? UICollectionViewLayoutAttributes
        retVal.sectionData = sectionData.map{$0.copy() as! UICollectionViewLayoutAttributes}
        retVal.footer = footer?.copy() as? UICollectionViewLayoutAttributes
        return retVal
    }
    
    public convenience init(sectionIndex:NSInteger) {
        self.init()
        self.sectionIndex = sectionIndex
    }
    
    /// Retrieve item from section data with index
    ///
    /// - Parameter indexPath: IndexPath of the requested item
    /// - Returns: UICollectionViewLayoutAttributes with requested index path if exists, otherwise nil
    func sectionItem(at indexPath:IndexPath) -> UICollectionViewLayoutAttributes? {
        guard sectionData.count > indexPath.item else {
            return nil
        }
        return sectionData[indexPath.item]
    }
}
