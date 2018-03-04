//
//  ViewController.swift
//  Kommunicate
//
//  Created by mukeshthawani on 02/19/2018.
//  Copyright (c) 2018 mukeshthawani. All rights reserved.
//

import UIKit
import Kommunicate
import Applozic

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let agentId = "suraj@kommunicate.io"
        let botId = "bot"
        let service = KMConversationService()
        if ALUserDefaultsHandler.isLoggedIn() {
            service.createConversation(userId: ALUserDefaultsHandler.getUserId(), agentId: agentId, botIds: [botId])
        } else {
            let chatManager = KMChatManager(applicationKey: KMChatManager.applicationId as NSString)
            let kmUser = ALUser()
            kmUser.userId = "testabcd"
            kmUser.applicationId = KMChatManager.applicationId

            chatManager.registerUser(kmUser, completion: {
                response, error in
                service.createConversation(userId: kmUser.userId, agentId: agentId, botIds: [botId])
            })
        }
    }
}

