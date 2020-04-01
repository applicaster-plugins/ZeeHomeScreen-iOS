//
//  CustomizationManager.swift
//  ZeeHomeScreen
//
//  Created by Miri on 27/01/2020.
//

import Foundation
import ZappPlugins

public protocol ComponentTypeProtocol {
    func componentType() -> String
    //    func uiTagWithUniqueIdentifier(_ uniqueIdentifier: String) -> String
    //    func cellComponentTypeKey() -> String
}


public struct ZappLayoutDependantComponentStyles {
    public init(componentType:ComponentTypeProtocol, containerCell:Bool) {
        self.componentType = componentType
        self.containerCell = containerCell
    }
    
    /// Type of component that will be used as dependant
    public let componentType:ComponentTypeProtocol
    
    /// Explain to search if dependent component need to be searched in containerCell
    public let containerCell:Bool
}


//MARK: API Keys
public enum CustomizationLayoutsKeys: String {
    case baseAttributes  = "baseAttributes"
    case families        = "families"
    case style           = "style"
    case container       = "container"
    case containerCell   = "cell"
    case devices         = "devices"
    case iphone          = "iphone"
    case ipad            = "ipad"
    case universal       = "universal"
    case universalFamily = "UniversalFamily"
}

public enum ComponentTypes: Equatable, ComponentTypeProtocol {
    case hero
    case horizontalList
    case grid
    case list
    case banner
    
    public static func ==(lhs: ComponentTypes, rhs: ComponentTypes) -> Bool {
        return lhs.componentType() == rhs.componentType()
    }
    
    public func componentType() -> String {
        switch self {
        case .hero:
            return "hero"
        case .grid:
            return "grid"
        case .list:
            return "list"
        case .horizontalList:
            return "horizontal_list"
        case .banner:
            return "banner"
        }
    }
}

@objc public class CustomizationManager: NSObject {
    static let manager = CustomizationManager()
    
    lazy var customizationLayoutsDict: [String: [String: [String: Any]]]? = {
        var retVal: [String: [String: [String: Any]]]?
        var currValue:NSMutableDictionary = [:]
        let plistFileName = "ZeeHomeScreen_ZLCustomizationLayouts"
        
//        if let path = CustomizationManager.plistPathForName(plistFileName),
//            let value = NSMutableDictionary(contentsOfFile: path) {
//            currValue += value
//        }
        
        for pluginModelOfCellStyleFamily in ZPPluginManager.pluginModels(.CellStyleFamily) ?? [] {
            if let classType = ZPPluginManager.adapterClass(pluginModelOfCellStyleFamily),
                let path = CustomizationManager.plistPath(forName: plistFileName, classType: classType),
                let value = NSMutableDictionary(contentsOfFile: path) {
                currValue += value
            }
        }
        
        return currValue as? [String: [String: [String: Any]]]
    }()
    
    
    class func plistPathForName(_ name: String) -> String? {
        return Bundle(for: CustomizationManager.self).path(forResource: name,
                                                           ofType: "plist")
    }
    
    class func plistPath(forName name: String, classType: AnyClass) -> String? {
        return Bundle(for: classType).path(forResource: name,
                                           ofType: "plist")
    }
    
    
    class func dataForZappLayout(_ zappLayoutName: String?,
                                 zappComponentType: String?,
                                 zappFamily: String?) -> (style: String, componentType: String, attributes: [String: Any])? {
        var retVal:(style: String, componentType: String, attributes: [String: Any])?
        guard let zappComponentType = zappComponentType else {
            return retVal
        }
        
        let dependantStylesArray = [ZappLayoutDependantComponentStyles(componentType:ComponentTypes.list, containerCell:false),
                                    ZappLayoutDependantComponentStyles(componentType:ComponentTypes.hero, containerCell:true)]
        // Try to get default styles
        retVal = dataForLayout(zappLayoutName,
                                   zappComponentType: zappComponentType,
                                   zappFamily: zappFamily)
        
        
        if zappComponentType == "hero" || zappComponentType == "horizontal_list" {
            if let dataForDependantComponent = dataForLayout(zappLayoutName,
                                                                            zappComponentType: zappComponentType,
                                                                            zappFamily: zappFamily) {
                if let dataForDependantComponentCell = dataForContainerCellZappLayout(zappLayoutName,
                                                                                      zappParentComponentType: zappComponentType,
                                                                                      zappParentFamily: zappFamily) {
                    //If container component cell style was retrieved, trying to copy attributes that relevant for sizing from top component, since in most cases all relevant attributes there. Relevant mostly for custom scaling and height.
                    retVal = (style: dataForDependantComponentCell.style,
                              componentType: dataForDependantComponentCell.componentType,
                              attributes: copySizeAttributes(from: dataForDependantComponent.attributes,
                                                             to: dataForDependantComponentCell.attributes))
                }
            }
            
        }
        
        // No default styles, trying to get style from dependand components
        if retVal == nil {
            for dependentStyle in dependantStylesArray {
                // Trying to get style from dependant component
                if let dataForDependantComponent = dataForLayout(zappLayoutName,
                                                                 zappComponentType: dependentStyle.componentType.componentType(),
                                                                 zappFamily: zappFamily) {
                    retVal = dataForDependantComponent
                    // If component has container cell requested in ZLZappLayoutDependantComponentStyles, trying to get style from dependant component container-cell
                    if dependentStyle.containerCell == true {
                        if let dataForDependantComponentCell = dataForContainerCellZappLayout(zappLayoutName,
                                                                                              zappParentComponentType: dependentStyle.componentType.componentType(),
                                                                                              zappParentFamily: zappFamily) {
                            //If container component cell style was retrieved, trying to copy attributes that relevant for sizing from top component, since in most cases all relevant attributes there. Relevant mostly for custom scaling and height.
                            retVal = (style: dataForDependantComponentCell.style,
                                      componentType: dataForDependantComponentCell.componentType,
                                      attributes: copySizeAttributes(from: dataForDependantComponent.attributes,
                                                                     to: dataForDependantComponentCell.attributes))
                        }
                    }
                }
                
                if retVal != nil {
                    break
                }
            }
        }
        
        
        return retVal
    }
    
    
    /// Retrive data of components Layout
    ///
    /// - Parameters:
    ///   - zappLayoutName: Requesteed layout name
    ///   - zappComponentType: Type of requested component
    ///   - zappFamily: Requested Family
    ///   - dependentStyles: Dependant styles from another components that may be used with current component. Check ZappLayoutDependantComponentStyles for more deatils
    /// - Returns: Data for requested component
    public class func dataForLayout(_ zappLayoutName: String?,
                                    zappComponentType: String?,
                                    zappFamily: String?) -> (style: String, componentType: String, attributes: [String: Any])? {
        //        var retVal:(style: String, componentType: String, attributes: [String: Any])?
        //        guard let zappComponentType = zappComponentType else {
        //            return retVal
        //        }
        //        // Try to get default styles
        //        retVal = dataForZappLayout(zappLayoutName,
        //                                   zappComponentType: zappComponentType,
        //                                   zappFamily: zappFamily)
        //
        //
        //        return retVal
        
        
        
        
        
        var retVal:(style: String, componentType: String, attributes: [String: Any])?
        if let layoutName = zappLayoutName,
            let componentType = zappComponentType,
            let family = zappFamily {
            if let componentStyle = layoutStyleForFamily(layoutName,
                                                         zappComponentType: componentType,
                                                         zappFamily: family) {
                //                if let componentData = componentTypeByLayout(componentStyle) {
                var attributes = layoutAttributes(layoutName,
                                                  zappComponentType: componentType,
                                                  zappFamily: family)
                //                    attributes = updateFavoriteButtonStateHidden(data: attributes)
                attributes = fillCustomizationAttributesForWithZappStylesDictionary(attributes)
                retVal = (componentStyle, componentType, attributes)
                //                }
            }
        }
        
        return retVal
    }
    
    class func layoutAttributes(_ zappLayoutName: String,
                                zappComponentType: String,
                                zappFamily: String) -> [String: Any] {
        var retVal: [String: Any] = [:]
        
        if let layoutAttributes = layoutCombinedAttributesForFamily(zappLayoutName,
                                                                    zappComponentType: zappComponentType,
                                                                    zappFamily: zappFamily) {
            if let combinednDict = NSDictionary(byMerging: retVal, with: layoutAttributes) as? [String : Any] {
                retVal = combinednDict
            }
        }
        return retVal
    }
    
    @objc public class func dataForZappLayout(_ zappLayoutName: String?,
                                              zappComponentType: String?,
                                              zappFamily: String?) -> ([String: Any])? {
        var retVal:(style: String, componentType: String, attributes: [String: Any])?
        guard let zappComponentType = zappComponentType else {
            return retVal?.attributes
        }
        // Try to get default styles
        retVal = dataForZappLayout(zappLayoutName,
                                   zappComponentType: zappComponentType.lowercased(),
                                   zappFamily: zappFamily)
        
        
        return retVal?.attributes
    }
    
}

extension CustomizationManager {
    class func baseAttributes() -> [String: [String: Any]]? {
        return self.manager.customizationLayoutsDict?[CustomizationLayoutsKeys.baseAttributes.rawValue]
    }
    
    class func baseAtttiburesForZappComponentType(_ zappComponentType: String) -> [String: Any]? {
        return baseAttributes()?[zappComponentType]
    }
}

extension CustomizationManager {
    
    class func fillCustomizationAttributesForWithZappStylesDictionary(_ attributes: [String: Any]) -> [String: Any] {
        var retVal = attributes
        retVal.keys.forEach {
            let item = retVal[$0]
            if let dict = item as? [String: Any] {
                retVal[$0] = fillCustomizationAttributesForWithZappStylesDictionary(dict)
            } else if let string = item as? String {
                retVal[$0] = updateCustomizationItem(string)
            }
        }
        
        return retVal
    }
    
    class func updateCustomizationItem(_ customizationItem: String) -> String {
        var retVal = customizationItem
        
        let customizationPrefixMark = "$"
        if customizationItem.hasPrefix(customizationPrefixMark) {
            let preparedPrefix = "${ZAPP_STYLES}." + deviceSting()
            retVal = customizationItem.replace(customizationPrefixMark,
                                               withString:preparedPrefix)
        }
        return retVal
    }
}


extension CustomizationManager {
    class func families() -> [String: [String: Any]]? {
        return self.manager.customizationLayoutsDict?[CustomizationLayoutsKeys.families.rawValue]
    }
    
    class func familyDictForFamily(_ zappFamily: String) -> [String: Any]? {
        return families()?[zappFamily]
    }
    
    class func componentsLayoutsDictForFamily(_ zappComponentType: String,
                                              zappFamily: String) -> [String: Any]? {
        return familyDictForFamily(zappFamily)?[zappComponentType] as? [String: Any]
    }
    
    class func layoutDictForFamily(_ zappLayoutName: String,
                                   zappComponentType: String,
                                   zappFamily: String) -> [String: Any]? {
        return componentsLayoutsDictForFamily(zappComponentType,
                                              zappFamily:zappFamily)?[zappLayoutName] as? [String: Any]
    }
    
    class func layoutStyleForFamily(_ zappLayoutName: String,
                                    zappComponentType: String,
                                    zappFamily: String) -> String? {
        return layoutDictForFamily(zappLayoutName,
                                   zappComponentType: zappComponentType,
                                   zappFamily:zappFamily)?[CustomizationLayoutsKeys.style.rawValue] as? String
    }
    
    class func layoutAllDevicesAttributesForFamily(_ zappLayoutName: String,
                                                   zappComponentType: String,
                                                   zappFamily: String) -> [String: Any]? {
        return layoutDictForFamily(zappLayoutName,
                                   zappComponentType: zappComponentType,
                                   zappFamily: zappFamily)?[CustomizationLayoutsKeys.devices.rawValue] as? [String: Any]
    }
    
    class func layoutCurrentDevicesAttributesForFamily(_ zappLayoutName: String,
                                                       zappComponentType: String,
                                                       zappFamily: String) -> [String: Any]? {
        return layoutAllDevicesAttributesForFamily(zappLayoutName,
                                                   zappComponentType: zappComponentType,
                                                   zappFamily: zappFamily)?[deviceSting()] as? [String: Any]
    }
    
    class func layoutUniversalDevicesAttributesForFamily(_ zappLayoutName: String,
                                                         zappComponentType: String,
                                                         zappFamily: String) -> [String: Any]? {
        return layoutAllDevicesAttributesForFamily(zappLayoutName,
                                                   zappComponentType: zappComponentType,
                                                   zappFamily: zappFamily )?[CustomizationLayoutsKeys.universal.rawValue] as? [String: Any]
    }
    
    class func layoutCombinedAttributesForFamily(_ zappLayoutName: String,
                                                 zappComponentType: String,
                                                 zappFamily: String) -> [String: Any]? {
        var retVal: [String: Any]? = [:]
        
        if let universalAttributes = layoutUniversalDevicesAttributesForFamily(zappLayoutName,
                                                                               zappComponentType: zappComponentType,
                                                                               zappFamily: zappFamily) {
            retVal = universalAttributes
            
        }
        
        if let deviceAttributes = layoutCurrentDevicesAttributesForFamily(zappLayoutName,
                                                                          zappComponentType: zappComponentType,
                                                                          zappFamily: zappFamily) {
            if let combinednDict = NSDictionary.init(byMerging: retVal, with: deviceAttributes) as? [String : Any] {
                retVal = combinednDict
            } else {
                retVal = deviceAttributes
            }
            
        }
        return retVal
    }
}

extension CustomizationManager {
    class func dataForContainerCellZappLayout(_ zappParentLayoutName: String?,
                                              zappParentComponentType: String?,
                                              zappParentFamily: String?) -> (style: String, componentType: String, attributes: [String: Any])? {
        var retVal:(style: String, componentType: String, attributes: [String: Any])?
        if let zappParentLayoutName = zappParentLayoutName,
            let zappParentComponentType = zappParentComponentType,
            let family = zappParentFamily {
            if let componentStyle = layoutContainerCellStyleForFamily(zappParentLayoutName,
                                                                      zappComponentType: zappParentComponentType,
                                                                      zappFamily: family) {
                
                //                if let componentData = componentTypeByLayout(componentStyle) {
                var attributes = combinedBaseAndLayoutContainerCellAttributes(zappParentLayoutName,
                                                                              zappParentComponentType: zappParentComponentType,
                                                                              zappFamily: family)
                //                    attributes = updateFavoriteButtonStateHidden(data: attributes)
                attributes = fillCustomizationAttributesForWithZappStylesDictionary(attributes)
                retVal = (componentStyle, zappParentComponentType, attributes)
                //                }
            }
        }
        
        return retVal
    }
    
    class func layoutContainerCellStyleForFamily(_ zappLayoutName: String,
                                                 zappComponentType: String,
                                                 zappFamily: String) -> String? {
        return layoutContainerCellDictForFamily(zappLayoutName,
                                                zappComponentType: zappComponentType,
                                                zappFamily:zappFamily)?["style"] as? String
    }
    
    
    class func combinedBaseAndLayoutContainerCellAttributes(_ zappParentLayoutName: String,
                                                            zappParentComponentType: String,
                                                            zappFamily: String) -> [String: Any] {
        var retVal: [String: Any] = [:]
        
        if let baseAttributes = baseContainerCellAtttiburesForZappComponentType(zappParentComponentType) {
            retVal = baseAttributes
        }
        
        if let layoutAttributes = layoutCombinedCellAttributesForFamily(zappParentLayoutName,
                                                                        zappParentComponentType: zappParentComponentType,
                                                                        zappFamily: zappFamily) {
            if let combinednDict = NSDictionary.init(byMerging: retVal, with: layoutAttributes) as? [String : Any] {
                retVal = combinednDict
            }
        }
        return retVal
    }
    
    class func baseContainerCellAtttiburesForZappComponentType(_ zappComponentType: String) -> [String: Any]? {
        var retVal: [String : Any]?
        if let baseComponentAttributes = baseAttributes()?[zappComponentType],
            let containerAttributes = baseComponentAttributes["container"] as? [String : Any],
            let containerCellAttributes = containerAttributes["cell"] as? [String : Any] {
            retVal = containerCellAttributes
        }
        
        return retVal
    }
    
    class func layoutCombinedCellAttributesForFamily(_ zappParentLayoutName: String,
                                                     zappParentComponentType: String,
                                                     zappFamily: String) -> [String: Any]? {
        var retVal: [String: Any]?
        
        if let containerCellAttributes = layoutContainerCellDictForFamily(zappParentLayoutName,
                                                                          zappComponentType: zappParentComponentType,
                                                                          zappFamily: zappFamily)?[CustomizationLayoutsKeys.devices.rawValue] as? [String : Any] {
            if let universalAttributes = containerCellAttributes[CustomizationLayoutsKeys.universal.rawValue] as? [String : Any] {
                retVal = universalAttributes
            }
            
            if let deviceAttributes = containerCellAttributes[deviceSting()] as? [String : Any] {
                if let combinedDict = NSDictionary.init(byMerging: retVal, with: deviceAttributes) as? [String : Any] {
                    retVal = combinedDict
                } else {
                    retVal = deviceAttributes
                }
            }
        }
        
        return retVal
    }
    
    class func layoutContainerCellDictForFamily(_ zappLayoutName: String,
                                                zappComponentType: String,
                                                zappFamily: String) -> [String: Any]? {
        var retVal: [String: Any]?
        if let componentLayoutDict = componentsLayoutsDictForFamily(zappComponentType,
                                                                    zappFamily:zappFamily)?[zappLayoutName] as? [String: Any],
            let containerDict = componentLayoutDict[CustomizationLayoutsKeys.container.rawValue] as? [String: Any],
            let cellDict = containerDict[CustomizationLayoutsKeys.containerCell.rawValue] as? [String: Any]{
            retVal = cellDict
        }
        return retVal
    }
}


extension CustomizationManager {
    class func deviceSting() -> String {
        return ComponentHelper.isIPad() ? CustomizationLayoutsKeys.ipad.rawValue : CustomizationLayoutsKeys.iphone.rawValue
    }
}

extension CustomizationManager {
    
    /// Copy attributes that relevant for sizing from one component dictionary to another
    ///
    /// - Parameters:
    ///   - fromDictionary: component dictionary that will be copy from
    ///   - toDictionary: component dictionary that will be copy to
    /// - Returns: new dictionary with copied attributes
    class func copySizeAttributes(from fromDictionary:[String:Any], to toDictionary:[String:Any]) -> [String:Any] {
        var retVal = toDictionary
//        if let heightPixel = fromDictionary[kAttributesHeightPixelKey],
//            retVal[kAttributesHeightPixelKey] == nil {
//            retVal[kAttributesHeightPixelKey] = heightPixel
//        }
        
        if let customScaling = fromDictionary["custom_scaling"],
            retVal["custom_scaling"] == nil {
            retVal["custom_scaling"] = customScaling
        }
        return retVal
    }
}
