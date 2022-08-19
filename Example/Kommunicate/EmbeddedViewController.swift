//
//  EmbeddedViewController.swift
//  Kommunicate_Example
//
//  Created by sathyan elangovan on 18/08/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Kommunicate
import UIKit

class EmbeddedViewController: UIViewController {
//    @IBOutlet var backButtonTapped: UITapGestureRecognizer!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        print("Back Button Tapped")
        self.navigationController?.popViewController(animated: true)
    }
    let activityIndicator = UIActivityIndicatorView(style: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
//        activityIndicator.center = CGPoint(x: view.bounds.size.width / 2,
//                                           y: view.bounds.size.height / 2)
//        view.addSubview(activityIndicator)
//        view.bringSubviewToFront(activityIndicator)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        
//        Kommunicate.showConversations(from: self,rootView: rootView)
        Kommunicate.createAndShowConversationV2(from: self, rootView:rootView,completion: {
                     error in
//                     self.activityIndicator.stopAnimating()
//                     self.view.isUserInteractionEnabled = true
                     if error != nil {
                         print("Error while launching")
                     }
                 })
    }

    @IBOutlet weak var rootView: UIView!
    

//    @IBAction func logoutAction(_: Any) {
//        Kommunicate.logoutUser { result in
//            switch result {
//            case .success:
//                print("Logout success")
//                self.dismiss(animated: true, completion: nil)
//            case .failure:
//                print("Logout failure, now registering remote notifications(if not registered)")
//                if !UIApplication.shared.isRegisteredForRemoteNotifications {
//                    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in
//                        if granted {
//                            DispatchQueue.main.async {
//                                UIApplication.shared.registerForRemoteNotifications()
//                            }
//                        }
//                        DispatchQueue.main.async {
//                            self.dismiss(animated: true, completion: nil)
//                        }
//                    }
//                } else {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
//    }
}
