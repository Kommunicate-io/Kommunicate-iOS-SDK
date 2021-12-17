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
   
    func eventTriggered(eventName: ALKCustomEventMap, data: [String : Any]?) {
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
        let events = [
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_ATTACHMENT_ICON_CLICK, eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_FAQ_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_LOCATION_ICON_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_MESSAGE_SEND,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RESOLVE_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_NOTIFICATION_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_CHAT_OPEN_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_VOICE_ICON_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RICH_MESSAGE_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_CHAT_CLOSE_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_SUBMIT_RATING_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RATE_CONVERSATION_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RESTART_CONVERSATION_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_START_NEW_CONVERSATION_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RATE_CONVERSATION_EMOTIONS_CLICK,  eventCallBack: self),
            ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_GREETING_MESSAGE_NOTIFICATION_CLICK,  eventCallBack: self)
        ]
        Kommunicate.subscribeCustomEvents(events: events)
      
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
