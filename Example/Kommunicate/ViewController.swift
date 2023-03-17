//
//  ViewController.swift
//  Kommunicate
//
//  Created by mukeshthawani on 02/19/2018.
//  Copyright (c) 2018 mukeshthawani. All rights reserved.
//

#if os(iOS)
    import Kommunicate
import KommunicateChatUI_iOS_SDK
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
//            activityIndicator.startAnimating()
//            view.isUserInteractionEnabled = false
//
//            Kommunicate.createAndShowConversation(from: self, completion: {
//                error in
//                self.activityIndicator.stopAnimating()
//                self.view.isUserInteractionEnabled = true
//                if error != nil {
//                    print("Error while launching")
//                }
//            })
//            let model = ALKContextTitleViewModel(data: ALKContextDat) ?? UICO
            
            let bg = UIColor(5, green: 163, blue: 191) ?? UIColor.blue
            let trailing = UIImage(named: "next") ?? UIImage()
            let leading = UIImage(named: "file") ?? UIImage()
            let font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
            let model = KMConversationInfoViewModel(infoContent: "Check out your ITR Summary", leadingImage: leading, trailingImage:trailing , backgroundColor: bg, contentColor: UIColor.white, contentFont:font)
            Kommunicate.defaultConfiguration.conversationInfoModel = model
            Kommunicate.showConversations(from: self)
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
#endif
