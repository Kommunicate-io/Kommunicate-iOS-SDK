//
//  KMConversationService.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 26/02/18.
//

import Foundation
import Applozic

public protocol KMConservationServiceable {
    associatedtype Response
    func createConversation(userId: String, agentId: String, botIds: [String]?,
                            completion: @escaping (Response) -> ())
}

public class KMConversationService: KMConservationServiceable {

    public init() {}

    /// Conversation API response
    public struct Response {
        var success: Bool = false
        var channelKey: Int? = nil
        var error: Error? = nil
    }
    
    public func createConversation(userId: String, agentId: String, botIds: [String]?, completion:@escaping (Response) -> ()) {

        let groupName = "Support"
        var members: [KMGroupUser] = []
        members.append(KMGroupUser(groupRole: .user, userId: userId))
        members.append(KMGroupUser(groupRole: .agent, userId: agentId))

        if let botUsers = getBotGroupUser(userIds: botIds) {
            members.append(contentsOf: botUsers)
        }
        let alChannelService = ALChannelService()
        let membersList = NSMutableArray()
        membersList.add(userId)
        alChannelService.createChannel(groupName, orClientChannelKey: nil, andMembersList: membersList, andImageLink: nil, channelType: 10, andMetaData: nil, adminUser: agentId, withGroupUsers: members as? NSMutableArray, withCompletion: {
            channel, error in
            guard error == nil else {return}
            guard let channel = channel, let key = channel.key as? Int else {
                completion(Response())
                return
            }
            self.createNewConversation(groupId: key, userId: userId, agentId: agentId, completion:{
                conversationResponse, error in
                var response = Response()
                guard conversationResponse != nil && error == nil else {
                    response.error = error
                    completion(response)
                    return
                }
                response.success = self.isGroupCreateSuccess(for: conversationResponse)
                response.channelKey = channel.key as? Int
                completion(response)
            })
        })
    }

    private func createNewConversation(groupId: Int, userId: String, agentId: String, completion: @escaping (_ response: Any?, _ error: Error?)->()) {
        let user = KMGroupUser(groupRole: .user, userId: userId)
        let agent = KMGroupUser(groupRole: .agent, userId: agentId)
        guard let applicationKey = ALUserDefaultsHandler.getApplicationKey(),
            let LoggedInUser = ALUserDefaultsHandler.getUserId() else {
                completion(nil, nil)
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
            else {
                completion(nil, nil)
                return
        }

        let request = ALRequestHandler.createPOSTRequest(withUrlString: api, paramString: paramString)
        ALResponseHandler.processRequest(request, andTag: "ConversationCreate", withCompletionHandler: {
            jsonResponse, error in
            completion(jsonResponse, error)
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

    private func isGroupCreateSuccess(for response: Any?) -> Bool {
        guard let response = response, let responseDict = response as? Dictionary<String, Any> else {
            return false
        }
        guard let code = responseDict["code"] as? String,
            code == "SUCCESS" else { return false }
        return true
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
