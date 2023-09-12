//
//  ViewController.swift
//  Kommunicate
//
//  Created by mukeshthawani on 02/19/2018.
//  Copyright (c) 2018 mukeshthawani. All rights reserved.
//

#if os(iOS)
    import Kommunicate
    import UIKit

    class ViewController: UIViewController {
        let activityIndicator = UIActivityIndicatorView(style: .gray)

        override func viewDidLoad() {
            super.viewDidLoad()
            activityIndicator.center = CGPoint(x: view.bounds.size.width / 2,
                                               y: view.bounds.size.height / 2)
            view.addSubview(activityIndicator)
            view.bringSubviewToFront(activityIndicator)
        }

        @IBAction func launchConversation(_: Any) {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false

            Kommunicate.showConversations(from: self)
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
#endif
