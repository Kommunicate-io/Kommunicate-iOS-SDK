//
//  UIViewController+Extension.swift
//  Kommunicate
//
//  Created by Mukesh on 14/01/20.
//

import Foundation

extension UIViewController {

    class func topViewController() -> UIViewController? {
        return topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow?.rootViewController)
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
}
