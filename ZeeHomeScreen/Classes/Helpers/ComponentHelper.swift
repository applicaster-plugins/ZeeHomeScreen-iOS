//
//  ComponentHelper.swift
//  ZeeHomeScreen
//
//  Created by Miri on 27/01/2020.
//

import Foundation

class ComponentHelper {
    
    static let iPhoneMinWidth:CGFloat = 320.0
    static let iPadMinWidth:CGFloat   = 1024.0
    
    public enum ComponentItemTypes:String {
        case body
        case header
        case footer
    }
    
    
    static func shouldHideHeader(section: Int, sectionsDataSourceArray: [ComponentModelProtocol]?) -> Bool {
        guard let sectionsDataSourceArray = sectionsDataSourceArray,
        sectionsDataSourceArray.count > section,
            let componentModel = sectionsDataSourceArray[section] as? ComponentModel,
            let _ = componentModel.componentHeaderModel else {
                return true
        }
        return false
    }
    
    /// Retrieves bool value if the current device has min size
    ///
    /// - Returns: bool value
    public static var isDeviceWidthEqualsToMin:Bool {
        return deviceRealWidth() == iPhoneMinWidth
    }
    
    /// Retrieves real width of usable device
    public class func deviceRealWidth() -> CGFloat {
        var retVal:CGFloat = 0
        let screenBounds = UIScreen.main.bounds
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if UIDevice.current.userInterfaceIdiom == .pad {
            if statusBarOrientation.isPortrait {
                retVal = screenBounds.height
            } else if statusBarOrientation.isLandscape {
                retVal = screenBounds.width
            }
        } else {
            if statusBarOrientation.isPortrait {
                retVal = screenBounds.width
            } else if statusBarOrientation.isLandscape {
                retVal = screenBounds.height
            }
        }
        return retVal
    }
    
    public class func cellIndexFromModel(_ componentModel:ComponentModelProtocol?, indexPath:IndexPath) ->  Int {
        
        guard let componentModel = componentModel else {
            return 0
        }
        if componentModel.isVertical == true {
            return indexPath.section
        }
        else {
            return indexPath.row
        }
    }
    
    /// Retrieves string value of component style name
    ///
    /// - Returns: string value
    public class func layoutName(for componentModel: ComponentModel) -> String? {
        var layoutName: String? = nil
        if ComponentHelper.isChildComponent(for: componentModel.entry) == true,
            let cellModel = componentModel.cellModel {
            layoutName = cellModel.layoutStyle
        }
        else {
            layoutName = componentModel.layoutStyle
        }
        return layoutName
    }
    
    
    /// Retrieves bool value if the current conponent is a child component
    ///
    /// - Returns: bool value
    public class func isChildComponent(for entry: APAtomEntryProtocol?) -> Bool {
        guard let entry = entry,
            let extentions = entry.extensions,
            let _ = extentions["ui_component"] as? [AnyHashable: Any] else {
                return true
        }
        return false
        
    }
    
    class func isIPad() -> Bool {
           return UIDevice.current.userInterfaceIdiom == .pad
    }
}
