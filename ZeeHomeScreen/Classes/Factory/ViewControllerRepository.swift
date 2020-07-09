import Foundation

@objc public final class ViewControllerRepository: NSObject {
    
    @objc public static let shared = ViewControllerRepository()
    private var repository: [String:[UIViewController & ComponentProtocol]] = [:]
    
    @objc public func clearRepository() {
        repository.removeAll()
    }
    
    @objc public func addViewController(viewController: UIViewController & ComponentProtocol) {
        if let type = viewController.componentModel?.type {
            if (repository[type] == nil) {
                repository[type] = []
            }
            repository[type]?.append(viewController)
        }
    }
    
    @objc public func removeViewController(type: String) -> (UIViewController & ComponentProtocol)? {
        return (repository[type]?.count ?? 0 > 0) ? repository[type]?.removeFirst() : nil
    }
    
    private override init() {
        
    }
}

