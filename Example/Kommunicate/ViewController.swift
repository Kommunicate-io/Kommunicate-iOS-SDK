//
//  ViewController.swift
//  Kommunicate
//
//  Created by mukeshthawani on 02/19/2018.
//  Copyright (c) 2018 mukeshthawani. All rights reserved.
//

import UIKit
import Kommunicate

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let userId = "testabc"
        let applicationKey = "<Pass your application key>"
        Kommunicate.setup(applicationId: applicationKey)
        if Kommunicate.isLoggedIn {
            Kommunicate.createConversation(
                userId: userId,
                botIds: nil,
                useLastConversation: true,
                completion: { response in
                    guard !response.isEmpty else {return}
                    DispatchQueue.main.async {
                        Kommunicate.showConversationWith(groupId: response, from: self, completionHandler: { success in
                            print("conversation was shown")
                        })
                    }
                })
        } else {
            let kmUser = KMUser()
            kmUser.userId = userId
            kmUser.applicationId = applicationKey

            Kommunicate.registerUser(kmUser, completion: {
                response, error in
                guard error == nil else {return}
                Kommunicate.createConversation(
                    userId: kmUser.userId,
                    botIds: nil,
                    useLastConversation: true,
                    completion: { response in
                    guard !response.isEmpty else {return}
                        DispatchQueue.main.async {
                            Kommunicate.showConversationWith(groupId: response, from: self, completionHandler: { success in
                                print("conversation was shown")
                            })
                        }
                })
            })
        }
    }
}
