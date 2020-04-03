//
//  ComponentModel.swift
//  ZeeHomeScreen
//
//  Created by Miri on 22/01/2020.
//

import Foundation
import ApplicasterSDK
//
//enum ComponentType: Int {
//    case undefined = 0
//    case hero
//    case horizontalList
//    case banner
//
//    var relatedTypeString: String {
//        var str: String
//        switch self {
//            case .undefined:
//                str = "undefined"
//                break
//            case .hero:
//                str = "HERO"
//                break
//            case .horizontalList:
//                str = "HORIZONTAL_LIST"
//                break
//            case .banner:
//                str = "BANNER"
//                break
//        }
//        return str
//    }
//}
 
@objc open class ComponentModel:NSObject, ComponentModelProtocol {
    
    @objc open var containerType: String?
    //, ComponentModelProtocol {
    
    open var parentModel: ComponentModel?
    open var title: String?
    
    open var identifier: String?
    
    open var uiTag: String?

    // the component type: Carousel, Horizontal list etc.
    open var type: String?
    
    // the content link to load
    open var dsUrl: String?
    
    // the content type: Atom_Feed, Http ( use to load an http request ) etc.
    open var dsType: String?
    
    open var layoutStyle: String?
    
    open var cellKey: String?

    open var aspectRatio: Double?
    
    open var entry: APAtomEntryProtocol?
    
    open var isVertical: Bool = true
    
    // use for grid
    var numberOfItemsPerRowColumn: Int?
    
    // the threshold that determine that need to load more items ( if set to 4 then when we arrives to the last 4 items need to fetch more data ).
    var cellsThresholdIndex: Int?
    
    var divider: Int?
    
    var nextPage: Pagination?
    
    open var componentHeaderModel: HeaderModel?
    
    // the component cellModel description.
    open var cellModel: CellModel?
    
    open var childerns: [ComponentModelProtocol]?
    
    var styleHelper: GangasFamilyStyleHelper?
        
    /// Init
    
    public init(type: String?) {
        super.init()
        if let type = type {
            self.type = type
        }
    }
    
    public init(entry: APAtomEntryProtocol?) {
        super.init()
        if let entry = entry {
            self.parse(entry: entry, threshold: 1)
        }
    }
    
    public init(entry: APAtomEntryProtocol, threshold: Int) {
        super.init()
        self.parse(entry: entry, threshold: threshold)
    }
    
    func parse(entry: APAtomEntryProtocol, threshold: Int) {
        self.entry = entry
        self.title = entry.title
        self.identifier = entry.identifier
        if let content = entry.content,
            let src = content.src {
            self.dsUrl = src
        }
        if let content = entry.content,
            let type = content.type {
            self.dsType = type
        }
        
        self.cellsThresholdIndex = threshold
        guard let extentions = entry.extensions else {
                return
        }
        
        // Base Component
        if (extentions["next_page_content"] != nil) {
            self.nextPage = self.getNextPageFromFeed(entry: entry)
        }
        
        // components model
        if let uiComponent = extentions["ui_component"] as? [AnyHashable: Any] {
            if let value = uiComponent["type"] as? String {
                       self.type = value
                   }
                   
                   switch self.type {
                   case "HERO":
                       self.isVertical = false
                       break
                   case "HORIZONTAL_LIST":
                       self.isVertical = false
                       break
                   case "BANNER":
                       self.isVertical = true
                       break
                   case "GRID":
                       self.isVertical = true
                       break
                   default:
                       self.isVertical = true
                   }
                   
                   self.cellsThresholdIndex = 1
                   self.divider = 10
                   
                   if let value = uiComponent["cellNum"] as? String {
                       self.numberOfItemsPerRowColumn = Int(value)
                   }
                   self.containerType = type

                   self.cellKey = uiComponent["cell_style"] as? String
                   let imageKey = uiComponent["image_key"] as? String
                   
                   self.styleHelper = GangasFamilyStyleHelper.init(entry: entry, cellKey: cellKey, imageKey: imageKey, containerType: self.type)
                   self.layoutStyle = self.styleHelper?.componentStyle
                   self.aspectRatio = self.styleHelper?.componentAspectRatio
                   
                   self.cellModel = self.styleHelper?.getCellModel()
                   self.nextPage = self.getNextPageFromFeed(entry: entry)
                   self.componentHeaderModel = self.getHeaderFromFeed(entry: entry)
        }
    }
    
    func getNextPageFromFeed(entry: APAtomEntryProtocol) -> Pagination {
        let pagination = Pagination.init(hasNext: false, nextPageUrl: "")
        if let extensions = entry.extensions ,
            let nextPageToLoad = extensions["next_page_content"] as? [String: Any],
            let nextPageDSUrl = nextPageToLoad["src"] as? String {
            pagination.hasNext = true
            pagination.nextPageUrl = nextPageDSUrl
        }
        return pagination
    }
    
    func getHeaderFromFeed(entry: APAtomEntryProtocol) -> HeaderModel? {
        guard let extensions = entry.extensions,
            let haederDict = extensions["header"] as? [String: Any]  else {
                return nil
        }
        
        let headerStyle = haederDict["cell_style"]  as? String
        let headerUrlScheme = haederDict["src"]  as? String
        return self.styleHelper?.getHeader(entry: entry, style: headerStyle, headerUrlScheme: headerUrlScheme)
    }
    
}
