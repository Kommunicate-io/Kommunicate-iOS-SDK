//
//  KMConversationService.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 26/02/18.
//

import Foundation
import Applozic

public protocol KMConservationServiceable {
    func createConversation(userId: String, agentId: String, botIds: [String]?)
}

public class KMConversationService: KMConservationServiceable {

    public init() {
    }
    
    public func createConversation(userId: String, agentId: String, botIds: [String]?) {

        var members: [KMGroupUser] = []
        members.append(KMGroupUser(groupRole: .user, userId: userId))
        members.append(KMGroupUser(groupRole: .agent, userId: agentId))

        if let botUsers = getBotGroupUser(userIds: botIds) {
            members.append(contentsOf: botUsers)
        }
        let alChannelService = ALChannelService()
        let membersList = NSMutableArray()
        alChannelService.createChannel("hello", orClientChannelKey: nil, andMembersList: membersList, andImageLink: nil, channelType: 10, andMetaData: nil, adminUser: agentId, withGroupUsers: members as? NSMutableArray, withCompletion: {
            channel, error in
            guard error == nil else {return}
            guard let channel = channel, let key = channel.key as? Int else {return}
            self.createNewConversation(groupId: key, userId: userId, agentId: agentId, completion:{
                _ in

            })
        })
    }

    private func createNewConversation(groupId: Int, userId: String, agentId: String, completion: ()->()) {
        // KM conv
        let user = KMGroupUser(groupRole: .user, userId: userId)
        let agent = KMGroupUser(groupRole: .agent, userId: agentId)
        guard let applicationKey = ALUserDefaultsHandler.getApplicationKey(),
            let LoggedInUser = ALUserDefaultsHandler.getUserId() else {
                completion()
                return
        }
        let detail = KMConversationDetail(
            groupId: groupId,
            user: user.id,
            agent:agent.id,
            applicationKey: applicationKey,
            createdBy: LoggedInUser)
        let api = "https://api.kommunicate.io/conversations"
        guard
            let paramData =  try? JSONEncoder().encode(detail),
            let paramString = String(data: paramData, encoding: .utf8)
            else {return }

        let request = ALRequestHandler.createPOSTRequest(withUrlString: api, paramString: paramString)
        ALResponseHandler.processRequest(request, andTag: "ConversationCreate", withCompletionHandler: {
            jsonResponse, error in
            print(jsonResponse, error)
        })

    }

    private func createBotUserFrom(userId: String) -> KMGroupUser {
        return KMGroupUser(groupRole: .bot, userId: userId)
    }

    /// Returns a list of KMGroupUser objects created from
    /// the userIds passed with role type set as bot.
    private func getBotGroupUser(userIds: [String]?) -> [KMGroupUser]? {
        guard let userIds = userIds else { return nil }
        return userIds.map {createBotUserFrom(userId: $0)}
    }
}

extension KMGroupUser {
    public enum RoleType: Int {
        case agent = 1
        case bot = 2
        case user = 3
    }

    public convenience init(groupRole: RoleType, userId: String) {
        self.init()
        self.groupRole = groupRole.rawValue as NSNumber
        self.userId = userId

    }
}
