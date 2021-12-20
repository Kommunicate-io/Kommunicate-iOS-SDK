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
import ApplozicSwift

class ViewController: UIViewController, ALKCustomEventCallback {
   
    func eventTriggered(eventName: CustomEvent, data: [String : Any]?) {
        print("Custom Event \(eventName.rawValue) data \(String(describing: data))")
    }
    let activityIndicator = UIActivityIndicatorView(style: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2,
                                           y: view.bounds.size.height/2)
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
    }

    @IBAction func launchConversation(_ sender: Any) {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
       
        let eventList = [
            CustomEvent.attachmentClick,
            CustomEvent.faqClick,
            CustomEvent.locationClick,
            CustomEvent.messageSend,
            CustomEvent.resolveClick,
            CustomEvent.notificationClick,
            CustomEvent.voiceClick,
            CustomEvent.richMessageClick,
            CustomEvent.submitRatingClick,
            CustomEvent.rateConversationClick,
            CustomEvent.restartConversationClick,
            CustomEvent.newConversation,
            CustomEvent.rateConversationEmotionsClick]
            
        Kommunicate.subscribeCustomEvents(events: eventList, callback: self)
      
        Kommunicate.createAndShowConversation(from: self, completion: {
            error in
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            if error != nil {
                print("Error while launching")
            }
        })
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
