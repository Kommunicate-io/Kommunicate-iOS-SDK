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
        agentIds: [String],
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
        agentIds: [String],
        botIds: [String]?,
        useLastConversation: Bool,
        completion: @escaping (Response) -> ()) {
        var clientId: String? = nil
        var allBotIds = ["bot"] // Default bot that should be added everytime.
        if let botIds = botIds {allBotIds.append(contentsOf: botIds)}
        if useLastConversation {
            // Sort and combine agent ids.
            var newClientId = Set(agentIds)
                .sorted(by: <)
                .reduce("", {$0+$1.lowercased()+"_"}) + userId.lowercased()

            // Sort and combine bot ids other than the default bot id.
            if let botIds = removeDefaultBotIdFrom(botIds: botIds) {
                newClientId =
                    newClientId + Set(botIds)
                    .sorted(by: <)
                    .reduce("", {$0+"_"+$1.lowercased()})
            }
            clientId = newClientId
            isGroupPresent(clientId: newClientId, completion: {
                present in
                if present {
                    let response = Response(success: true, clientChannelKey: newClientId, error: nil)
                    completion(response)
                } else {
                    self.createNewChannelAndConversation(clientChannelKey: clientId, userId: userId, agentIds: agentIds, botIds: allBotIds, completion: {
                        response in
                        completion(response)
                    })
                }
            })
        } else {
            createNewChannelAndConversation(clientChannelKey: clientId, userId: userId, agentIds: agentIds, botIds: allBotIds, completion: {
                response in
                completion(response)
            })
        }
    }

    //MARK: - Private methods

    private func createBotUserFrom(userId: String) -> KMGroupUser {
        return KMGroupUser(groupRole: .bot, userId: userId)
    }

    private func createAgentGroupUserFrom(agentId: String) -> KMGroupUser {
        return KMGroupUser(groupRole: .agent, userId: agentId)
    }

    /// Returns a list of KMGroupUser objects created from
    /// the userIds passed with role type set as bot.
    private func getBotGroupUser(userIds: [String]?) -> [KMGroupUser]? {
        guard let userIds = userIds else { return nil }
        return userIds.map { createBotUserFrom(userId: $0) }
    }

    private func agentGroupUsersFor(agentIds: [String]?) -> [KMGroupUser]? {
        guard let agentIds = agentIds else { return nil }
        return agentIds.map { createAgentGroupUserFrom(agentId: $0) }
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
        agentIds: [String],
        botIds: [String]?,
        completion: @escaping (Response) -> ()) {
        let groupName = "Support"
        var members: [KMGroupUser] = []
        members.append(KMGroupUser(groupRole: .user, userId: userId))
        let membersList = NSMutableArray()
        if let botUsers = getBotGroupUser(userIds: botIds) {
            members.append(contentsOf: botUsers)
        }
        if let agentUsers = agentGroupUsersFor(agentIds: agentIds) {
            members.append(contentsOf: agentUsers)
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
            adminUser: agentIds.first,
            withGroupUsers: NSMutableArray(array: groupUsers),
            withCompletion: {
                channel, error in
                guard error == nil else {
                    completion(Response(success: false, clientChannelKey: nil, error: error))
                    return
                }
                guard let channel = channel, let _ = channel.key as? Int else {
                    completion(Response(success: false, clientChannelKey: nil, error: nil))
                    return
                }
                var response = Response()
                response.clientChannelKey = channel.clientChannelKey
                completion(response)
        })
    }

    private func removeDefaultBotIdFrom(botIds: [String]?) -> [String]?{
        guard var allBotIds = botIds else {return nil}
        allBotIds.removeAll { (id) -> Bool in
            return id == "bot"
        }
        return allBotIds
    }
}
