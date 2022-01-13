//
//  ViewController.swift
//  Kommunicate
//
//  Created by mukeshthawani on 02/19/2018.
//  Copyright (c) 2018 mukeshthawani. All rights reserved.
//

#if os(iOS)
import UIKit
import Kommunicate

class ViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView(style: .gray)
let teamid = "67476167"
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2,
                                           y: view.bounds.size.height/2)
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
    }
// I have changed the launchConversation method for testing purpose, Will remove all the changes after
    @IBAction func launchConversation(_ sender: Any) {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        let kommunicateConversationBuilder = KMConversationBuilder()
            .useLastConversation(true)
        let conversation = kommunicateConversationBuilder.build()
        let teamid = "67476167"

        Kommunicate.createConversation(conversation: conversation) { (result) in
            switch result {
            case .success(let conversationId):
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                DispatchQueue.main.async {
                    Kommunicate.showConversationWith(groupId: conversationId, from: self, completionHandler: { success in
                        guard success else {
                            print("Failed to create show conversation")
//                            completion(KommunicateError.conversationNotPresent)
                            return
                        }
                        let teamid = "67476167"

//
                        Kommunicate.updateTeamId(conversation: conversation, teamId: teamid){ (result) in
                            switch result {
                            case .success(let groupId):
                                print("Successfully to udpated the team id \(groupId)")

                            case.failure(_):
                                print("Failed to udpate the team id")
                            }

                        }
//
                        print("Kommunicate: conversation was shown")
//                        completion(nil)
                    })
                }
            case .failure(_):
//                completion(KommunicateError.conversationCreateFailed)
                return
            }
        }
      
//
//        Kommunicate.createAndShowConversation(from: self, completion: {
//            error in
//            self.activityIndicator.stopAnimating()
//            self.view.isUserInteractionEnabled = true
//            if error != nil {
//                print("Error while launching")
//            }
//        })
    }
    @IBAction func logoutAction(_ sender: Any) {
        Kommunicate.logoutUser { (result) in
            switch result {
            case .success(_):
                print("Logout success")
                self.dismiss(animated: true, completion: nil)
            case .failure( _):
                print("Logout failure, now registering remote notifications(if not registered)")
                if !UIApplication.shared.isRegisteredForRemoteNotifications {
                    UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
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
