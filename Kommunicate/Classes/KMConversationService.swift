//
//  KMConversationService.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 26/02/18.
//

import Foundation
import Applozic
import ApplozicSwift

public protocol KMConservationServiceable {
    associatedtype Response
    func createConversation(
        userId: String,
        agentId: String,
        botIds: [String]?,
        useLastConversation: Bool,
        completion: @escaping (Response) -> ())
}

public class KMConversationService: KMConservationServiceable {

    /// Conversation API response
    public struct Response {
        public var success: Bool = false
        public var clientChannelKey: String? = nil
        public var error: Error? = nil
    }

    //MARK: - Initialization

    public init() { }

    //MARK: - Public methods

    /**
     Creates a new conversation with the details passed.

     - Parameters:
        - userId: User id of the participant.
        - agentId: User id of the agent.
        - botIds: A list of bot ids to be added in the conversation.
        - useLastConversation: If there is a conversation already present then that will be returned.

     - Returns: Response object.
    */
    public func createConversation(
        userId: String,
        agentId: String,
        botIds: [String]?,
        useLastConversation: Bool,
        completion: @escaping (Response) -> ()) {

        var clientId: String? = nil
        if useLastConversation {
            var newClientId = "\(agentId)_\(userId)"
            if let botIds = botIds {
                newClientId = newClientId + botIds.reduce("", {$0+"_"+$1})
            }
            clientId = newClientId
            isGroupPresent(clientId: newClientId, completion: {
                present in
                if present {
                    let response = Response(success: true, clientChannelKey: newClientId, error: nil)
                    completion(response)
                } else {
                    self.createNewChannelAndConversation(clientChannelKey: clientId, userId: userId, agentId: agentId, botIds: botIds, completion: {
                        response in
                        completion(response)
                    })
                }
            })
        } else {
            createNewChannelAndConversation(clientChannelKey: clientId, userId: userId, agentId: agentId, botIds: botIds, completion: {
                response in
                completion(response)
            })
        }
    }

    //MARK: - Private methods

    private func createNewConversation(groupId: Int, userId: String, agentId: String, completion: @escaping (_ response: Any?, _ error: Error?) -> ()) {
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
            agent: agent.id,
            applicationKey: applicationKey,
            createdBy: LoggedInUser)
        let api = "https://api.kommunicate.io/conversations"
        guard
            let paramData = try? JSONEncoder().encode(detail),
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
        return userIds.map { createBotUserFrom(userId: $0) }
    }

    /// Checks if API response returns success
    private func isConversationCreatedSuccessfully(for response: Any?) -> Bool {
        guard let response = response, let responseDict = response as? Dictionary<String, Any> else {
            return false
        }
        guard let code = responseDict["code"] as? String,
            code == "SUCCESS" else { return false }
        return true
    }

    private func getGroupMetadata() -> NSMutableDictionary {
        let metadata = NSMutableDictionary()
        metadata.setValue("", forKey: AL_CREATE_GROUP_MESSAGE)
        metadata.setValue("", forKey: AL_REMOVE_MEMBER_MESSAGE)
        metadata.setValue("", forKey: AL_ADD_MEMBER_MESSAGE)
        metadata.setValue("", forKey: AL_JOIN_MEMBER_MESSAGE)
        metadata.setValue("", forKey: AL_GROUP_NAME_CHANGE_MESSAGE)
        metadata.setValue("", forKey: AL_GROUP_ICON_CHANGE_MESSAGE)
        metadata.setValue("", forKey: AL_GROUP_LEFT_MESSAGE)
        metadata.setValue("", forKey: AL_DELETED_GROUP_MESSAGE)
        metadata.setValue("true", forKey: "HIDE")
        metadata.setValue("false", forKey: "ALERT")
        return metadata
    }

    private func isGroupPresent(clientId: String, completion:@escaping (_ isPresent: Bool)->()){
        let client = ALChannelService()
        client.getChannelInformation(byResponse: nil, orClientChannelKey: clientId, withCompletion: {
            error, channel, response in
            guard channel != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }

    private func createNewChannelAndConversation(
        clientChannelKey: String?,
        userId: String,
        agentId: String,
        botIds: [String]?,
        completion: @escaping (Response) -> ()) {
        let groupName = "Support"
        var members: [KMGroupUser] = []
        members.append(KMGroupUser(groupRole: .user, userId: userId))
        let membersList = NSMutableArray()
        if let botUsers = getBotGroupUser(userIds: botIds) {
            members.append(contentsOf: botUsers)
        }
        let alChannelService = ALChannelService()
        let groupUsers = members.map { $0.toDict() }
        let metadata = getGroupMetadata()

        alChannelService.createChannel(
            groupName,
            orClientChannelKey: clientChannelKey,
            andMembersList: membersList,
            andImageLink: nil,
            channelType: 10,
            andMetaData: metadata,
            adminUser: agentId,
            withGroupUsers: NSMutableArray(array: groupUsers),
            withCompletion: {
                channel, error in
                guard error == nil else {
                    completion(Response(success: false, clientChannelKey: nil, error: error))
                    return
                }
                guard let channel = channel, let key = channel.key as? Int else {
                    completion(Response(success: false, clientChannelKey: nil, error: nil))
                    return
                }
                self.createNewConversation(groupId: key, userId: userId, agentId: agentId, completion: {
                    conversationResponse, error in
                    var response = Response()
                    guard conversationResponse != nil && error == nil else {
                        response.error = error
                        completion(response)
                        return
                    }
                    response.success = self.isConversationCreatedSuccessfully(for: conversationResponse)
                    response.clientChannelKey = channel.clientChannelKey
                    completion(response)
                })
        })
    }
}
