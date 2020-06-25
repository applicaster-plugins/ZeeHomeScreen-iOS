import Foundation

@objc public final class ViewControllerRepository: NSObject {
    
    @objc public static let shared = ViewControllerRepository()
    private var repository: [String:UIViewController & ComponentProtocol] = [:]
    
    @objc public func clearRepository() {
        repository.removeAll()
    }
    
    @objc public func addViewController(viewController: UIViewController & ComponentProtocol) {
        if let type = viewController.componentModel?.type {
            if (repository[type] == nil) {
                repository[type] = viewController
            }
        }
    }
    
    @objc public func removeViewController(type: String) -> (UIViewController & ComponentProtocol)? {
        if let viewController = repository[type] {
            repository.removeValue(forKey: type)
            return viewController
        }
        return nil
    }
    
    private override init() {
        
    }
}

