//
//  StaticViewCollectionViewController.swift
//  ZeeHomeScreen
//
//  Created by Simon Borkin on 14.05.20.
//

import Foundation

import ApplicasterSDK
import ZappPlugins

fileprivate let defaultCellIdentifier = "default"

public class StaticViewCollectionViewController: UIViewController {
    fileprivate var sectionCompositeViewController: StaticViewSectionCompositeViewController?
    
    public func load(_ atomFeed: APAtomFeed, staticView: UIView) {
        guard let sectionCompositeViewController = StaticViewSectionCompositeViewController.create(for: atomFeed, staticView) else {
            return
        }
        
        self.sectionCompositeViewController = sectionCompositeViewController
        
        self.addChild(sectionCompositeViewController)
        self.view.addSubview(sectionCompositeViewController.view)

        sectionCompositeViewController.view.fillParent()
        
        sectionCompositeViewController.didMove(toParent: self)
        
        self.updateStaticView(staticView)
    }
    
    public func invalidateLayout() {
        guard
            let collectionView = self.sectionCompositeViewController?.collectionView,
            let flowLayout = collectionView.collectionViewLayout as? StaticViewFlowLayout else {
            return
        }
        
        flowLayout.prepare(forceUpdate: true)
        flowLayout.invalidateLayout()
    }
    
    fileprivate func updateStaticView(_ staticView: UIView) {
        guard
            let sectionCompositeViewController = self.sectionCompositeViewController,
            let collectionView = sectionCompositeViewController.collectionView,
            let flowLayout = collectionView.collectionViewLayout as? StaticViewFlowLayout else {
            return
        }

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: defaultCellIdentifier)
        
        if sectionCompositeViewController.sectionsDataSourceArray == nil {
            sectionCompositeViewController.sectionsDataSourceArray = []
        }
        
        sectionCompositeViewController.sectionsDataSourceArray?.insert(ComponentModel(type: defaultCellIdentifier), at: 0)
        flowLayout.staticView = staticView
        
        collectionView.reloadData()
    }
}

fileprivate class StaticViewSectionCompositeViewController: SectionCompositeViewController {
    public var staticView: UIView!
    
    public static func create(for atomFeed: APAtomFeed?, _ staticView: UIView) -> StaticViewSectionCompositeViewController? {
        let result = StaticViewSectionCompositeViewController()
        result.staticView = staticView
        
        var config: PluginKeys?
        var style: PluginKeys?
        
        if let screenModel = ZAAppConnector.sharedInstance().genericDelegate.screenModelForPluginID(pluginID: "zee5_home_screen", dataSource: nil) {
            config = screenModel.general as? PluginKeys ?? PluginKeys()
            style = screenModel.style?.object as? PluginKeys ?? PluginKeys()
        }
        
        var pluginConfiguration: NSDictionary?
        
        if let pluginModel = ZPPluginManager.pluginModelById("zee5_home_screen") {
            pluginConfiguration = pluginModel.configurationJSON
        }
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        result.collectionView = collectionView
        result.view.addSubview(collectionView)
        collectionView.fillParent()

        result.screenConfiguration = ScreenConfiguration.init(config: config, style: style, dataSource: atomFeed, configurationJSON: pluginConfiguration)
        result.setComponentModel((Zee5dsAdapter.getBaseComponent(for: atomFeed))!)
        result.atomFeedUrl = atomFeed?.link
        result.modalPresentationStyle = .fullScreen

        collectionView.delegate = result
        collectionView.dataSource = result
        
        return result
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var result: UICollectionViewCell!
                
        if let componentModel = self.sectionsDataSourceArray?.componentModel(at: indexPath), componentModel.type == defaultCellIdentifier {
            result = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellIdentifier, for: indexPath)
            
            if let view = self.staticView {
                result.contentView.addSubview(view)
                view.fillParent()
            }
            
        }
        
        if result == nil {
            result = super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        return result
    }
    
    override func collectionFlowLayout() -> UICollectionViewFlowLayout {
        let result = StaticViewFlowLayout()
        result.staticView = self.staticView
        
        return result
    }
}



fileprivate class StaticViewFlowLayout: SectionCompositeFlowLayout {
    var staticView: UIView?
    
    override func cellSize(for indexPath: IndexPath, сollectionItemTypes: ComponentHelper.ComponentItemTypes) -> CGSize? {
        if  let staticView = self.staticView,
            let componentModel = self.sectionsDataSourceArray?.componentModel(at: indexPath),
            componentModel.type == defaultCellIdentifier,
            let collectionView = self.collectionView  {

            let fullWidth = collectionView.bounds.width
            let targetSize = CGSize(width: fullWidth, height: UIView.layoutFittingCompressedSize.width)
            
            let result = staticView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
            
            return result
        }
        
        return super.cellSize(for: indexPath, сollectionItemTypes: сollectionItemTypes)
    }
}

fileprivate extension Array {
    func componentModel(at indexPath: IndexPath) -> ComponentModel? {
        var subarray = self
        subarray.removeLast()
        
        var index: Int
        if let _ = subarray as? [CellModel] {
            index = indexPath.row
        }
        else {
            index = indexPath.section
        }
        
        return self[index] as? ComponentModel
    }
}

fileprivate extension UIView {
    func fillParent() {
        guard let parent = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
    }
}
