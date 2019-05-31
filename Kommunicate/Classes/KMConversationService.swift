//
//  KMConversationService.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 26/02/18.
//

import Foundation
import Applozic
import ApplozicSwift

public struct ChannelMetadataKeys {
    static let conversationAssignee = "CONVERSATION_ASSIGNEE"
}

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

public protocol KMConservationServiceable {
    associatedtype Response
    func createConversation(
        userId: String,
        agentIds: [String],
        botIds: [String]?,
        clientConversationId: String?,
        completion: @escaping (Response) -> ())
}

public class KMConversationService: KMConservationServiceable {

    /// Conversation API response
    public struct Response {
        public var success: Bool = false
        public var clientChannelKey: String? = nil
        public var error: Error? = nil
    }

    public enum APIError: Error {
        case urlBuilding
        case jsonConversion
        case messageNotPresent
    }

    let groupMetadata: NSMutableDictionary = {
        let metadata = NSMutableDictionary(
            dictionary: ALChannelService().metadataToHideActionMessagesAndTurnOffNotifications())

        // Required for features like setting user language in server.
        guard let messageMetadata = Kommunicate.defaultConfiguration.messageMetadata,
            !messageMetadata.isEmpty else {
                return metadata
        }
        metadata.addEntries(from: messageMetadata)
        return metadata
    }()

    //MARK: - Initialization

    public init() { }

    //MARK: - Public methods

    /**
     Creates a new conversation with the details passed.

     - Parameters:
        - userId: User id of the participant.
        - agentId: User id of the agent.
        - botIds: A list of bot ids to be added in the conversation.
        - clientConversationId: client Id which will be associated with this conversation.

     - Returns: Response object.
    */
    public func createConversation(
        userId: String,
        agentIds: [String],
        botIds: [String]?,
        clientConversationId: String? = nil,
        completion: @escaping (Response) -> ()) {

        if let clientId = clientConversationId, !clientId.isEmpty {
            self.isGroupPresent(clientId: clientId, completion: {
                present in
                if present {
                    let response = Response(success: true, clientChannelKey: clientId, error: nil)
                    completion(response)
                } else {
                    self.createNewChannelAndConversation(clientChannelKey: clientId, userId: userId, agentIds: agentIds, botIds: botIds, completion: {
                        response in
                        completion(response)
                    })
                }
            })
        } else {
            self.createNewChannelAndConversation(clientChannelKey: nil, userId: userId, agentIds: agentIds, botIds: botIds, completion: {
                response in
                completion(response)
            })
        }
    }

    /**
     Fetches away message for the given group id.

     - Parameters:
        - applicationkey: Application key for which away message has been set.
        - groupId: Group id for which away message has to be shown.

     - Returns: A Result of type `String`.

    **/
    public func awayMessageFor(
        applicationKey: String = ALUserDefaultsHandler.getApplicationKey(),
        groupId: NSNumber,
        completion: @escaping (Result<String>)->()) {


        // Set up the URL request
        guard let url = URLBuilder.awayMessageURLFor(applicationKey: applicationKey, groupId: String(describing: groupId)).url else {

            completion(.failure(APIError.urlBuilding))
            return
        }
        DataLoader.request(url: url, completion: {
            result in

            switch result {
            case .success(let data):
                do {
                    guard
                        let awayMessageJson = try JSONSerialization.jsonObject(with: data, options: [])
                        as? [String: Any]
                        else {
                            print("error trying to convert data to JSON")
                            completion(.failure(APIError.jsonConversion))
                            return
                    }
                    completion(self.makeAwayMessageFrom(json: awayMessageJson))
                } catch(let error) {
                    print("error trying to convert data to JSON")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    /**
     Fetches and returns the default agent id.

     - Parameters:
        - applicationkey: Application key for which a default agent has been set.

     - Returns: A Result of type `String`.

     **/
    public func defaultAgentFor(
        applicationKey: String = ALUserDefaultsHandler.getApplicationKey(),
        completion: @escaping (Result<String>)->()) {
        // Set up the URL request
        guard let url = URLBuilder.agentsURLFor(applicationKey: applicationKey).url
            else {
                completion(.failure(APIError.urlBuilding))
                return
        }
        DataLoader.request(url: url, completion: {
            result in

            switch result {
            case .success(let data):
                do {
                    guard let agentsJson = try JSONSerialization.jsonObject(with: data, options: [])
                        as? [String: Any] else {
                            print("error trying to convert data to JSON")
                            completion(.failure(APIError.jsonConversion))
                            return
                    }
                    completion(self.agentIdFrom(json: agentsJson))
                } catch  {
                    print("error trying to convert data to JSON")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    @available(*, deprecated, renamed: "createConversation(userId:agentIds:botIds:clientConversationId:completion:)")
    public func createConversation(
        userId: String,
        agentIds: [String],
        botIds: [String]?,
        useLastConversation: Bool,
        completion: @escaping (Response) -> ()) {
        var clientId: String? = nil
        var allAgentIds = agentIds
        var allBotIds = ["bot"] // Default bot that should be added everytime.
        if let botIds = botIds {allBotIds.append(contentsOf: botIds)}
        defaultAgentFor(completion: {
            result in
            switch result {
            case .success(let agentId):
                allAgentIds.append(agentId)
            case .failure(let error):
                print("Error while fetching agents id: \(error)")
            }
            allAgentIds = allAgentIds.uniqueElements
            if useLastConversation {
                // Sort and combine agent ids.
                var newClientId = allAgentIds
                    .sorted(by: <)
                    .reduce("", {$0+$1.lowercased()+"_"}) + userId.lowercased()

                // Sort and combine bot ids other than the default bot id.
                if let botIds = self.removeDefaultBotIdFrom(botIds: botIds) {
                    newClientId =
                        newClientId + Set(botIds)
                            .sorted(by: <)
                            .reduce("", {$0+"_"+$1.lowercased()})
                }
                clientId = newClientId
                self.isGroupPresent(clientId: newClientId, completion: {
                    present in
                    if present {
                        let response = Response(success: true, clientChannelKey: newClientId, error: nil)
                        completion(response)
                    } else {
                        self.createNewChannelAndConversation(clientChannelKey: clientId, userId: userId, agentIds: allAgentIds, botIds: allBotIds, completion: {
                            response in
                            completion(response)
                        })
                    }
                })
            } else {
                self.createNewChannelAndConversation(clientChannelKey: clientId, userId: userId, agentIds: allAgentIds, botIds: allBotIds, completion: {
                    response in
                    completion(response)
                })
            }
        })

    }


    func makeAwayMessageFrom(json: [String: Any]) -> Result<String> {
        guard
            let data = json["data"] as? [String: Any],
            let messageList = data["messageList"] as? [Any] else {
                return .failure(APIError.jsonConversion)
        }
        // When the agent is online or away message is not set
        // then the messageList will be empty.
        guard let firstMessage = messageList.first as? [String: Any],
            let message = firstMessage["message"] as? String else {
                return .failure(APIError.messageNotPresent)
        }
        return .success(message)
    }

    func agentIdFrom(json: [String: Any]) -> Result<String> {
        guard let response = json["response"] as? [String: Any],
            let agentId = response["agentId"] as? String
            else {
                return .failure(APIError.jsonConversion)
        }
        return .success(agentId)
    }

    func createClientIdFrom(userId: String, agentIds: [String], botIds: [String]) -> String {
        // Sort and combine agent ids.
        var newClientId = agentIds
            .sorted(by: <)
            .reduce("", {$0+$1.lowercased()+"_"}) + userId.lowercased()

        // Sort and combine bot ids other than the default bot id.
        if let botIds = self.removeDefaultBotIdFrom(botIds: botIds) {
            newClientId =
                newClientId + Set(botIds)
                    .sorted(by: <)
                    .reduce("", {$0+"_"+$1.lowercased()})
        }
        return newClientId
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

        alChannelService.createChannel(
            groupName,
            orClientChannelKey: clientChannelKey,
            andMembersList: membersList,
            andImageLink: nil,
            channelType: 10,
            andMetaData: groupMetadata,
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

