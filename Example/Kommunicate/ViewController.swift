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
        let service = KMConversationService()
        if KMUserDefaultHandler.isLoggedIn() {
            service.createConversation(userId: KMUserDefaultHandler.getUserId(), agentId: agentId, botIds: [botId], completion: {
                response in
                service.launchGroupWith(groupId: response.channelKey!, from: self)
                print(response)
            })
        } else {
            let chatManager = KMChatManager(applicationKey: KMChatManager.applicationId as NSString)
            let kmUser = KMUser()
            kmUser.userId = ""
            kmUser.applicationId = KMChatManager.applicationId

            chatManager.registerUser(kmUser, completion: {
                response, error in
                service.createConversation(userId: kmUser.userId, agentId: agentId, botIds: [botId], completion: {
                    response in
                    print(response)
                })
            })
        }
    }
}
