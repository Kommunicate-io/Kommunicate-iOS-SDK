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
        let agentId = ""
        let botId = "bot"
        let userId = "testabc"
        let applicationKey = ""
        Kommunicate.setup(applicationId: applicationKey)
        if Kommunicate.isLoggedIn {
            Kommunicate.createConversation(
                userId: userId,
                agentIds: [agentId],
                botIds: [botId],
                useLastConversation: true,
                completion: { response in
                    guard !response.isEmpty else {return}
                    Kommunicate.showConversationWith(groupId: response, from: self, completionHandler: { success in
                        print("conversation was shown")
                    })
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
                    agentIds: [agentId],
                    botIds: [botId], completion: { response in
                    guard !response.isEmpty else {return}
                        Kommunicate.showConversationWith(groupId: response, from: self, completionHandler: { success in
                            print("conversation was shown")
                        })
                })
            })
        }
    }
}
