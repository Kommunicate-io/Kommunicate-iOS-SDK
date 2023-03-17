//
//  ViewController.swift
//  Kommunicate
//
//  Created by mukeshthawani on 02/19/2018.
//  Copyright (c) 2018 mukeshthawani. All rights reserved.
//

#if os(iOS)
import KommunicateChatUI_iOS_SDK
import Kommunicate
import KommunicateCore_iOS_SDK
import UIKit

class ViewController: UIViewController, ALKCustomEventCallback {
    func messageSent(message: ALMessage) {
        
    }
    
    func messageReceived(message: ALMessage) {
        
    }
    
    func conversationRestarted(conversationId: String) {
        
    }
    
    func onBackButtonClick(isConversationOpened: Bool) {
        
    }
    
    func faqClicked(url: String) {
        
    }
    
    func conversationCreated(conversationId: String) {
        
    }
    
    func ratingSubmitted(conversationId: String, rating: Int, comment: String) {
        
    }
    
    func richMessageClicked(conversationId: String, action: [String : Any], type: String) {
        
    }
    
    func conversationInfoClicked() {
        UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
        print("Closed conversation screen and moving to another screen")
    }
    
        let activityIndicator = UIActivityIndicatorView(style: .gray)

        override func viewDidLoad() {
            super.viewDidLoad()
            activityIndicator.center = CGPoint(x: view.bounds.size.width / 2,
                                               y: view.bounds.size.height / 2)
            view.addSubview(activityIndicator)
            view.bringSubviewToFront(activityIndicator)
        }
        let event: [CustomEvent] = [.conversationInfoClick  ]
        
        @IBAction func launchConversation(_: Any) {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false

            Kommunicate.createAndShowConversation(from: self, completion: {
                error in
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if error != nil {
                    print("Error while launching")
                }
            })
        }
        
        func getSubinfoView() {
//            let view = UIView()
//            let leadingImage = UIImage(named: "closeIcon")
//            let trainlingImage = UIImage(named: "icon_back")
//            let label = UILabel()
//            label.text = "Check out your ITR summary"
//            view.addViewsForAutolayout(views: label,leadingImage,trainlingImage)
//            view.
        }
        @IBAction func logoutAction(_: Any) {
            Kommunicate.logoutUser { result in
                switch result {
                case .success:
                    print("Logout success")
                    self.dismiss(animated: true, completion: nil)
                case .failure:
                    print("Logout failure, now registering remote notifications(if not registered)")
                    if !UIApplication.shared.isRegisteredForRemoteNotifications {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in
                            if granted {
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
#endif
