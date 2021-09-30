//
//  KMConversationService.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 26/02/18.
//

import Foundation
import ApplozicCore
import ApplozicSwift

public struct ChannelMetadataKeys {
    static let conversationAssignee = "CONVERSATION_ASSIGNEE"
    static let skipRouting = "SKIP_ROUTING";
    static let kmConversationTitle = "KM_CONVERSATION_TITLE"
    static let kmOriginalTitle = "KM_ORIGINAL_TITLE"
    static let chatContext = "KM_CHAT_CONTEXT"
    static let languageTag = "kmUserLanguageCode"
    static let teamId = "KM_TEAM_ID"
}

struct LocalizationKey {
    static let supportChannelName = "SupportChannelName"
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

public class KMConversationService: KMConservationServiceable,Localizable {

    /// Conversation API response
    public struct Response {
        public var success: Bool = false
        public var clientChannelKey: String? = nil
        public var error: Error? = nil
    }

    enum ServiceError: Error {
        case urlCreation
        case jsonConversion
        case api(error: Error?)
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
    let channelService = ALChannelService()

    //MARK: - Initialization

    public init() { }

    //MARK: - Public methods

    ///   Creates a new conversation with the KMConversation object.
    /// - Parameters:
    ///   - conversation: KMConversation object
    ///   - completion: Response object

    public func createConversation(
        conversation: KMConversation,
        completion: @escaping (Response)->()) {
        
        let dispatchGroup = DispatchGroup()

        if let clientId = conversation.clientConversationId, !clientId.isEmpty {
            self.isGroupPresent(clientId: clientId, completion: { present, channel in
                if present {
                    let groupID = Int(truncating: channel?.key ?? 0)
                    var response = Response(success: true, clientChannelKey: clientId, error: nil)
                    
                    if let currentAssignee = self.assigneeUserIdFor(groupId: groupID), let newAssignee = conversation.conversationAssignee {
                        if (!(newAssignee.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) && newAssignee != currentAssignee) {
                            dispatchGroup.enter()
                            self.assignConversation(groupId: groupID, to: newAssignee) { result in
                                switch result {
                                case .success:
                                    dispatchGroup.leave()
                                case .failure(let error):
                                    response.error = error
                                    response.success = false
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                    dispatchGroup.enter()
                    if self.groupMetadata.count < 0 {
                        dispatchGroup.leave()
                    } else {
                        self.updateGroupMetadata(groupId: NSNumber(value: groupID), channelKey: clientId, metadata: self.groupMetadata) { result in
                            response = result
                            dispatchGroup.leave()
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        completion(response)
                    }
                } else {
                    self.createNewChannelAndConversation(conversation: conversation, completion: { response in
                        completion(response)
                    })
                }
            })
        } else {
            self.createNewChannelAndConversation(conversation: conversation, completion: { response in
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
        completion: @escaping (Result<String, Error>)->()) {


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

    @available(*, deprecated, message: "Use createConversation(conversation:completion:)")
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

        let appSettingService = KMAppSettingService()
        var isSingleThreadedConversation = useLastConversation

        appSettingService.appSetting {
            result in
            switch result {
            case .success(let appSettings):
                allAgentIds.append(appSettings.agentID)
                if let chatWidget = appSettings.chatWidget,
                    let isSingleThreaded = chatWidget.isSingleThreaded {
                    isSingleThreadedConversation = isSingleThreaded
                }
            case .failure(let error):
                print("Error while fetching app settings: \(error)")
                return
            }

            allAgentIds = allAgentIds.uniqueElements
            if isSingleThreadedConversation {
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
                    present, channel in
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
        }
    }

    /**
     Creates a new conversation with the details passed.

     - Parameters:
        - userId: User id of the participant.
        - agentId: User id of the agent.
        - botIds: A list of bot ids to be added in the conversation.
        - clientConversationId: client Id which will be associated with this conversation.

     - Returns: Response object.
    */
    @available(*, deprecated, message: "Use createConversation(conversation:completion:)")
    public func createConversation(
        userId: String,
        agentIds: [String],
        botIds: [String]?,
        clientConversationId: String? = nil,
        completion: @escaping (Response) -> ()) {

        let kommunicateConversationBuilder = KMConversationBuilder()
            .withAgentIds(agentIds)
            .withBotIds(botIds ?? [])
            .withClientConversationId(clientConversationId)

        let conversation =  kommunicateConversationBuilder.build()
        createConversation(conversation: conversation) { response in
            completion(response)
        }
    }


    func makeAwayMessageFrom(json: [String: Any]) -> Result<String, Error> {
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

    func agentIdFrom(json: [String: Any]) -> Result<String, Error> {
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

    func getMetaDataWith(_ conversation: KMConversation) -> NSMutableDictionary {

        let metadata = NSMutableDictionary(
            dictionary: ALChannelService().metadataToHideActionMessagesAndTurnOffNotifications())

        if !conversation.conversationMetadata.isEmpty {
            metadata.addEntries(from: conversation.conversationMetadata)
        }

        if conversation.skipRouting {
            metadata.setValue("true", forKey: ChannelMetadataKeys.skipRouting)
        }

        if  let conversationAssignee = conversation.conversationAssignee, !conversationAssignee.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata.setValue(conversation.conversationAssignee, forKey: ChannelMetadataKeys.conversationAssignee)
            metadata.setValue("true", forKey: ChannelMetadataKeys.skipRouting)
        }

        if let conversationTitle = conversation.conversationTitle {
            metadata.setValue(conversationTitle, forKey: ChannelMetadataKeys.kmConversationTitle)
            metadata.setValue("true", forKey: ChannelMetadataKeys.kmOriginalTitle)
        }

        if conversation.useOriginalTitle {
            metadata.setValue("true", forKey: ChannelMetadataKeys.kmOriginalTitle)
        }

        if let teamId = conversation.teamId, !teamId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata.setValue(teamId, forKey: ChannelMetadataKeys.teamId)
        }

        guard let messageMetadata = Kommunicate.defaultConfiguration.messageMetadata,
            !messageMetadata.isEmpty else {
                return metadata
        }
        metadata.addEntries(from: messageMetadata)
        return metadata
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

    private func isGroupPresent(clientId: String, completion:@escaping (_ isPresent: Bool, _ channel: ALChannel?)->()){
        let client = ALChannelService()
        client.getChannelInformation(byResponse: nil, orClientChannelKey: clientId, withCompletion: {
            error, channel, response in
            guard let channel = channel else {
                completion(false, nil)
                return
            }
            completion(true, channel)
        })
    }

    private func createNewChannelAndConversation(
        clientChannelKey: String?,
        userId: String,
        agentIds: [String],
        botIds: [String]?,
        completion: @escaping (Response) -> ()) {

        let kommunicateConversationBuilder = KMConversationBuilder()
            .withAgentIds(agentIds)
            .withBotIds(botIds ?? [])
            .withClientConversationId(clientChannelKey)

        let conversation =  kommunicateConversationBuilder.build()
        createNewChannelAndConversation(conversation: conversation) { respsone in
            completion(respsone)
        }
    }

    private func createNewChannelAndConversation(conversation:KMConversation,
                                                 completion: @escaping (Response) -> ()) {
        let groupName = conversation.conversationTitle ?? localizedString(
            forKey: LocalizationKey.supportChannelName,
            fileName: Kommunicate.defaultConfiguration.localizedStringFileName)

        var members: [KMGroupUser] = []
        members.append(KMGroupUser(groupRole: .user, userId: conversation.userId))
        let membersList = NSMutableArray()
        if let botUsers = getBotGroupUser(userIds: conversation.botIds) {
            members.append(contentsOf: botUsers)
        }
        if let agentUsers = agentGroupUsersFor(agentIds: conversation.agentIds) {
            members.append(contentsOf: agentUsers)
        }
        let alChannelService = ALChannelService()
        let groupUsers = members.map { $0.toDict() }

        alChannelService.createChannel(
            groupName,
            orClientChannelKey: conversation.clientConversationId,
            andMembersList: membersList,
            andImageLink: nil,
            channelType: 10,
            andMetaData: getMetaDataWith(conversation),
            adminUser: conversation.agentIds.first,
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

    private func assignConversation(
        groupId: Int,
        to user: String,
        completion: @escaping(Result<[String: Any], ServiceError>) -> ()
    ) {
        guard let url = URLBuilder
                .assigneeChangeURL(groupId: groupId, assigneeUserId: user).url else {
            completion(.failure(.urlCreation))
            return
        }

        let theRequest: NSMutableURLRequest? =
            ALRequestHandler.createPatchRequest(
                withUrlString: url.absoluteString,
                paramString: nil
            )
        ALResponseHandler().authenticateAndProcessRequest(theRequest, andTag: "KM-ASSIGNEE-CHANGE") {
            (json, error) in
            guard error == nil else {
                completion(.failure(.api(error: error)))
                return
            }
            guard let dict = json as? [String: Any] else {
                completion(.failure(.jsonConversion))
                return
            }
            completion(.success(dict))
        }
    }

    private func assigneeUserIdFor(groupId: Int) -> String? {
        guard let channel = channelService.getChannelByKey(groupId as NSNumber),
              let assigneeUserId = channel.assigneeUserId else {
            return nil
        }
        return assigneeUserId
    }
    
    private func updateGroupMetadata(
        groupId: NSNumber,
        channelKey: String,
        metadata: NSMutableDictionary,
        completion: @escaping((Response) -> ())
    ) {
        ALChannelService().updateChannelMetaData(groupId, orClientChannelKey: channelKey, metadata: metadata) { error in
            guard error == nil else {
                completion(Response(success: false, clientChannelKey: nil, error: error))
                return
            }
            completion(Response(success: true, clientChannelKey: channelKey, error: nil))
        }
    }
    
    public func updateTeam (
        groupID: String,
        teamID: String,
        completion: @escaping((Response) -> ())) {
        
        let metadata = NSMutableDictionary(
            dictionary: ALChannelService().metadataToHideActionMessagesAndTurnOffNotifications())
        if !teamID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata.setValue(teamID, forKey: ChannelMetadataKeys.teamId)
        }
    
        ALChannelService().updateChannelMetaData(NSNumber(pointer: groupID), orClientChannelKey: groupID , metadata: metadata) { error in
            guard error == nil else {
                completion(Response(success: false, clientChannelKey: nil, error: error))
                return
            }
            completion(Response(success: true, clientChannelKey: groupID, error: nil))
        }
    }
}

extension ALChannel {
    static let ConversationAssignee = "CONVERSATION_ASSIGNEE"

    var assigneeUserId: String? {
        guard type == Int16(SUPPORT_GROUP.rawValue),
              let assigneeId = metadata?[ALChannel.ConversationAssignee] as? String else {
            return nil
        }
        return assigneeId
    }
}
