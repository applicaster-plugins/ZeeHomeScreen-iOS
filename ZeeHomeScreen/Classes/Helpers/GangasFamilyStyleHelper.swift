//
//  GangasFamilyStyleHelper.swift
//  ZeeHomeScreen
//
//  Created by Miri on 23/01/2020.
//

import Foundation
import ApplicasterSDK

class GangasFamilyStyleHelper {

    var entry: APAtomEntryProtocol?
    var cellKey: String?
    var imageKey: String?
    
    var componentAspectRatio = 0.386
    var cellAspectRatio = 0.667
    var iphoneWidth: CGFloat = 0.0
    var ipadWidth: CGFloat = 0.0
    var iphoneHeight: CGFloat = 0.0
    var ipadHeight: CGFloat = 0.0
    var placeHolder = ""
    var isClickable = true
    var paddingVertical: Int = 16
    var paddingHorizontal = 16
    var divider = 8
    var cellStyle = ""
    var componentStyle = "component_rv_default"
    var containerType = ""
    var minimumLineSpacing: CGFloat = 8
    var minimumInteritemSpacing: CGFloat = 8
    
    //HEADERS
    var headerStyle: String?
    var headerUrlScheme: String?
    
    init(cellKey: String?, containerType: String?) {
        if let cellKey = cellKey {
            self.cellKey = cellKey
        }
        if let cellKey = cellKey {
            self.mappingCellStyles(key: cellKey)
        }
        if let containerType = containerType {
            self.containerType = containerType
        }
    }
    
    init(entry: APAtomEntryProtocol?, cellKey: String?, imageKey: String?, containerType: String?) {
        if let entry = entry {
            self.entry = entry
        }
        
        if let cellKey = cellKey {
            self.cellKey = cellKey
        }
        
        if let imageKey = imageKey {
            self.imageKey = imageKey
        }
        
        if let cellKey = cellKey {
            self.mappingCellStyles(key: cellKey)
        }
        
        if let containerType = containerType {
            self.containerType = containerType
        }
    }
    
    func mappingCellStyles(key: String) {
        switch key {
        case "LAZY_LOADING":
            self.componentStyle = "LazyLoadingViewController"
            self.cellStyle = "Family_Ganges_lazy_loading_1"
            self.iphoneHeight = 50.0
            self.ipadWidth = 50.0
        case "GRID_1":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_grid_1"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_grid_1"
            self.iphoneHeight = 159.0
            self.iphoneWidth = 106.0
            
            self.minimumLineSpacing = 16
            self.minimumInteritemSpacing = 16
            
            self.ipadHeight = 210.0
            self.ipadWidth = 140.0
            break
        case "GRID_2":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_grid_2"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_grid_2"
            self.iphoneHeight = 1000.0
            self.iphoneWidth = 106.0
            
            self.minimumLineSpacing = 16
            self.minimumInteritemSpacing = 16
            
            self.ipadHeight = 210.0
            self.ipadWidth = 140.0
            break
        case "GRID_3":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_grid_3"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_grid_3"
            self.iphoneHeight = 159.0
            self.iphoneWidth = 106.0
            
            self.minimumLineSpacing = 16
            self.minimumInteritemSpacing = 16
            
            self.ipadHeight = 210.0
            self.ipadWidth = 140.0
            break
        case "GRID_4":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_grid_4"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_grid_4"
            self.iphoneHeight = 159.0
            self.iphoneWidth = 106.0
            
            self.minimumLineSpacing = 16
            self.minimumInteritemSpacing = 16
            
            self.ipadHeight = 210.0
            self.ipadWidth = 140.0
            break
        case "HORIZONTAL_LIST_1":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_1"
            self.iphoneHeight = 167.0
            self.iphoneWidth = 106.0
            
            self.ipadHeight = 218.0
            self.ipadWidth = 140.0
            break
        case "HORIZONTAL_LIST_2":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_2"
            self.iphoneHeight = 167.0
            self.iphoneWidth = 106.0
            
            self.ipadHeight = 218.0
            self.ipadWidth = 140.0
            break
        case "HORIZONTAL_LIST_3":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_3"
            self.iphoneHeight = 194.0
            self.iphoneWidth = 106.0
            
            self.ipadHeight = 245.0
            self.ipadWidth = 140.0
            break
        case "HORIZONTAL_LIST_4":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_4"
            self.iphoneHeight = 241.0
            self.iphoneWidth = 155.0
            
            self.ipadHeight = 308.0
            self.ipadWidth = 200.0
            break
        case "HORIZONTAL_LIST_5":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_5"
            self.iphoneHeight = 73.0
            self.iphoneWidth = 87.0
            
            self.ipadHeight = 92.0
            self.ipadWidth = 112.0
            break
        case "HORIZONTAL_LIST_6":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_6"
            self.iphoneHeight = 186.0
            self.iphoneWidth = 316.0
            
            self.ipadHeight = 233.0
            self.ipadWidth = 400.0
            break
        case "HORIZONTAL_LIST_7":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_7"
            self.iphoneHeight = 186.0
            self.iphoneWidth = 316.0
            
            self.ipadHeight = 233.0
            self.ipadWidth = 400.0
            break
        case "HORIZONTAL_LIST_8":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_8"
            self.iphoneHeight = 186.0
            self.iphoneWidth = 316.0
            
            self.ipadHeight = 233.0
            self.ipadWidth = 400.0
            break
        case "HORIZONTAL_LIST_9":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_9"
            self.iphoneHeight = 186.0
            self.iphoneWidth = 316.0
            
            self.ipadHeight = 233.0
            self.ipadWidth = 400.0
            break
        case "HORIZONTAL_LIST_10":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_10"
            self.iphoneHeight = 126.0
            self.iphoneWidth = 151.0
            
            self.ipadHeight = 152.0
            self.ipadWidth = 195.0
            break
        case "HORIZONTAL_LIST_11":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_11"

            self.iphoneHeight = 93.0
            self.iphoneWidth = 151.0
            
            self.ipadHeight = 118.0
            self.ipadWidth = 195.0
            break
        case "HORIZONTAL_LIST_12":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_12"

            self.iphoneHeight = 86.0
            self.iphoneWidth = 138.0
            
            self.ipadWidth = 184.0
            self.ipadHeight = 99.0
            break
        case "HORIZONTAL_LIST_13":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_13"

            self.iphoneHeight = 86.0
            self.iphoneWidth = 138.0
            
            self.ipadHeight = 107.0
            self.ipadWidth = 176.0
            break
        case "HORIZONTAL_LIST_14":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_14"

            self.iphoneHeight = 146.0
            self.iphoneWidth = 94.0
            
            self.ipadHeight = 166.0
            self.ipadWidth = 120.0
            break
        case "HORIZONTAL_LIST_15":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_15"

            self.iphoneHeight = 152.0
            self.iphoneWidth = 151.0
            
            self.ipadHeight = 177.0
            self.ipadWidth = 195.0
            break
        case "HORIZONTAL_LIST_16":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_16"

            self.iphoneHeight = 152.0
            self.iphoneWidth = 151.0
            
            self.ipadHeight = 177.0
            self.ipadWidth = 195.0
            break
        case "HORIZONTAL_LIST_17":
            self.componentStyle = "SectionCompositeViewController"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_horizontal_list_16"

            self.iphoneHeight = 126.0
            self.iphoneWidth = 151.0
            
            self.ipadHeight = 152.0
            self.ipadWidth = 195.0
            break
        case "HERO_CELL_1":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_hero_1"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_hero_cell_1"
            self.iphoneHeight = 188.0
            self.ipadHeight = 458.0
            break
        case "HERO_CELL_2":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_hero_2"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_hero_cell_2"
            self.iphoneHeight = 188.0
            self.ipadHeight = 440.0
            break
        case "HERO_CELL_3":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_hero_2"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_hero_cell_3"
            self.iphoneHeight = 178.0
            self.ipadHeight = 432.0
            break
        case "HERO_CELL_4":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_hero_3"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_hero_cell_4"
            self.iphoneHeight = 170.0
            self.ipadHeight = 424.0
            break
        case "HERO_CELL_5":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_hero_3"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_hero_cell_5"
            self.iphoneHeight = 170.0
            self.ipadHeight = 424.0
            break
        case "BANNER_1":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_banner_1"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_banner_1"
            self.iphoneHeight = 73.0
            self.ipadHeight = 92.0
        case "HEADER_1":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_header_cell_1"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_header_cell_1"
            self.iphoneHeight = 25.0
            self.ipadHeight = 25.0
        case "HEADER_2":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_header_cell_2"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_header_cell_2"
            self.iphoneHeight = 40.0
            self.ipadHeight = 40.0
        case "HEADER_3":
            self.componentStyle = "ZeeHomeScreen_Family_Ganges_header_cell_3"
            self.cellStyle = "ZeeHomeScreen_Family_Ganges_header_cell_3"
            self.iphoneHeight = 36.0
            self.ipadHeight = 36.0
        default:
            break
        }

        self.iphoneWidth = (self.iphoneWidth == 0.0 ?  UIScreen.main.bounds.width : self.iphoneWidth)
        self.ipadWidth = (self.ipadWidth == 0.0 ?  UIScreen.main.bounds.width : self.ipadWidth)
      
    }
    
    func getCellModel() -> CellModel {
        return CellModel.init(layoutStyle: self.cellStyle, aspectRatio: self.cellAspectRatio, entry: self.entry, iphoneWidth: self.iphoneWidth, ipadWidth: self.ipadWidth, iphoneHeight: self.iphoneHeight, ipadHeight: self.ipadHeight, placeHolder: self.placeHolder, imageKey: self.imageKey, isClickable: self.isClickable, containerType: self.containerType, cellKey: self.cellKey)
    }
    
    func getHeader(entry: APAtomEntryProtocol, style: String?, headerUrlScheme: String?) -> HeaderModel? {
        var cell: String? = nil
        var height: CGFloat? = 30.0
        let containerType: String = "HEADER"
        var cellKey: String = String()
        switch style {
        case "header_01":
            cell = "ZeeHomeScreen_Family_Ganges_header_cell_1"
            cellKey = "HEADER_1"
            height = 25.0
            break
            
        case "header_02":
            cell = "ZeeHomeScreen_Family_Ganges_header_cell_2"
            cellKey = "HEADER_2"
            height = 40.0
            break
            
        case "header_03":
            cell = "ZeeHomeScreen_Family_Ganges_header_cell_3"
            cellKey = "HEADER_3"
            height = 36.0
            break
        default:
            cell = "ZeeHomeScreen_Family_Ganges_header_cell_1"
        }
        if let cell = cell {
            return HeaderModel.init(entry: entry, layoutStyle: cell, imageKey: "image_base", isClickable: true, actionUrlScheme: headerUrlScheme, height: height, containerType: containerType, cellKey: cellKey)
        }
        return nil
    }
    
    func dictionaryFromComponentModel(componentModel: ComponentModelProtocol?) {
        if let componentModel = componentModel {
            
        }
    }

}

