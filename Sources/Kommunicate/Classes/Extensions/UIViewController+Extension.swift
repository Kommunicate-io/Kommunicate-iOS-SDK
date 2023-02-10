//
//  UIViewController+Extension.swift
//  Kommunicate
//
//  Created by Mukesh on 14/01/20.
//

import Foundation
import UIKit

extension UIViewController {
    var bottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return view.bottomAnchor
        }
    }

    var topAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return view.topAnchor
        }
    }

    var leadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.leadingAnchor
        } else {
            return view.leadingAnchor
        }
    }

    var trailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.trailingAnchor
        } else {
            return view.trailingAnchor
        }
    }

    var width: CGFloat {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.layoutFrame.width
        }
        return UIScreen.main.bounds.width
    }

    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    class func topViewController() -> UIViewController? {
        guard let application  = UIApplication.sharedUIApplication() , let keyWindow = application.keyWindow else { return nil }
        return topViewControllerWithRootViewController(rootViewController: keyWindow.rootViewController)
    }

    class func topViewControllerWithRootViewController(rootViewController: UIViewController?) -> UIViewController? {
        if rootViewController is UITabBarController {
            let control = rootViewController as! UITabBarController
            return topViewControllerWithRootViewController(rootViewController: control.selectedViewController)
        } else if rootViewController is UINavigationController {
            let control = rootViewController as! UINavigationController
            return topViewControllerWithRootViewController(rootViewController: control.visibleViewController)
        } else if let control = rootViewController?.presentedViewController {
            return topViewControllerWithRootViewController(rootViewController: control)
        }
        return rootViewController
    }
    
    public func getBackTextButton(title: String,target:Any, action: Selector) -> UIBarButtonItem {
           return  UIBarButtonItem(title: title, style: .plain, target: target, action: action)
    }
    
    public func getBackArrowButton(target:Any, action: Selector) -> UIBarButtonItem {
        var backImage = UIImage(named: "icon_back", in: Bundle.kommunicate, compatibleWith: nil)
        backImage = backImage?.imageFlippedForRightToLeftLayoutDirection()
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: target, action: action)
        backButton.accessibilityIdentifier = "BackButton"
        return backButton
    }
}
