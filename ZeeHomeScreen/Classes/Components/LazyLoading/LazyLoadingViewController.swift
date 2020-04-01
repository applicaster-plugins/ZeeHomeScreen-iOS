//
//  LazyLoadingViewController.swift
//  ZeeHomeScreen
//
//  Created by Miri on 06/02/2020.
//

import Foundation

class LazyLoadingViewController: UIViewController, ComponentProtocol, ComponentDelegate {
    var componentDataSourceModel: NSObject?
    
    let activityLoader: ActivityLoader = ActivityLoader(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView?
    
    public var componentModel: ComponentModelProtocol? {
        didSet {
            //activityLoader.startAnimating()
//            loadingIndicator?.startAnimating()
        }
    }
    
    public var currentComponentModel: ComponentModel? {
        return self.componentModel as? ComponentModel
    }
    
    //MARK:
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(activityLoader)
        activityLoader.startAnimating()
        activityLoader.translatesAutoresizingMaskIntoConstraints = false
        activityLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityLoader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    deinit {
        activityLoader.stopAnimating()
//        loadingIndicator?.stopAnimating()
    }
    
}


class ActivityLoader: UIView {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setActivityImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: Load loader image view
    func setActivityImage() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "img_loader", in: nil, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: frame.width),
            imageView.heightAnchor.constraint(equalToConstant: frame.height),
        ])
    }
    // MARK: Start animating
    func startAnimating() {
        isHidden = false
        rotate()
    }
    // MARK: Stop animating
    func stopAnimating() {
        isHidden = true
        removeRotation()
    }
    private func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.imageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    private func removeRotation() {
        self.imageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
