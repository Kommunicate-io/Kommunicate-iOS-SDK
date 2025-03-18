//
//  KMConversationService.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 26/02/18.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import KommunicateCore_iOS_SDK

public enum ChannelMetadataKeys {
    static let conversationAssignee = "CONVERSATION_ASSIGNEE"
    static let skipRouting = "SKIP_ROUTING"
    static let kmConversationTitle = "KM_CONVERSATION_TITLE"
    static let kmOriginalTitle = "KM_ORIGINAL_TITLE"
    static let chatContext = "KM_CHAT_CONTEXT"
    static let languageTag = "kmUserLanguageCode"
    static let teamId = "KM_TEAM_ID"
    static let conversationMetaData = "conversationMetadata" // dictionary mapped with this key will be shown on  ConversationInfo section
    static let groupCreationURL = "GROUP_CREATION_URL"
    static let kmUserLocale = "kmUserLocale"
    static let kmPseudoUser = "KM_PSEUDO_USER"
    static let pseudoName = "pseudoName"
}

enum LocalizationKey {
    static let supportChannelName = "SupportChannelName"
}

public protocol KMConservationServiceable {
    associatedtype Response
    func createConversation(
        userId: String,
        agentIds: [String],
        botIds: [String]?,
        clientConversationId: String?,
        completion: @escaping (Response) -> Void
    )
}

public class KMConversationService: KMConservationServiceable, Localizable {
    /// Conversation API response
    public struct Response {
        public var success: Bool = false
        public var clientChannelKey: String?
        public var error: Error?
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
              !messageMetadata.isEmpty
        else {
            return metadata
        }
        metadata.addEntries(from: messageMetadata)
        return metadata
    }()

    let channelService = ALChannelService()

    // MARK: - Initialization

    public init() {}

    // MARK: - Public methods

    ///   Creates a new conversation with the KMConversation object.
    /// - Parameters:
    ///   - conversation: KMConversation object
    ///   - completion: Response object

    public func createConversation(
        conversation: KMConversation,
        completion: @escaping (Response) -> Void
    ) {
        if let clientId = conversation.clientConversationId, !clientId.isEmpty {
            isGroupPresent(clientId: clientId, completion: { present, channel in
                if present {
                    let groupID = Int(truncating: channel?.key ?? 0)
                    var response = Response(success: true, clientChannelKey: clientId, error: nil)

                    if let currentAssignee = self.assigneeUserIdFor(groupId: groupID), let newAssignee = conversation.conversationAssignee {
                        if !(newAssignee.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty), newAssignee != currentAssignee {
                           
                            self.assignConversation(groupId: groupID, to: newAssignee) { result in
                                switch result {
                                case .success:
                                    completion(response)
                                case let .failure(error):
                                    response.error = error
                                    response.success = false
                                    completion(response)
                                }
                            }
                        } else {
                            completion(response)
                        }
                    } else {
                        completion(response)
                    }
                } else {
                    self.createNewChannelAndConversation(conversation: conversation, completion: { response in
                        completion(response)
                    })
                }
            })
        } else {
            createNewChannelAndConversation(conversation: conversation, completion: { response in
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
        applicationKey: String,
        groupId: NSNumber,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        // Set up the URL request
        guard let url = URLBuilder.awayMessageURLFor(applicationKey: applicationKey, groupId: String(describing: groupId)).url else {
            completion(.failure(APIError.urlBuilding))
            return
        }
        DataLoader.request(url: url, completion: {
            result in

            switch result {
            case let .success(data):
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
                } catch {
                    print("error trying to convert data to JSON")
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
    
    func waitingQueueFor(
        teamID: String,
        completion: @escaping (Result<[Int], Error>) -> Void
    ) {
        guard let url = URLBuilder.waitingQueueFor(teamID: teamID).url else {
            completion(.failure(APIError.urlBuilding))
            return
        }
        DataLoader.request(url: url) { result in
            switch result {
            case let .success(data):
                do {
                    // Attempt to decode the JSON data
                    guard let waitingQueData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        print("Error: Unable to convert data to JSON")
                        completion(.failure(APIError.jsonConversion))
                        return
                    }
                    
                    // Call the method to extract and process the response
                    completion(self.extractWaitingQueResponse(from: waitingQueData))
                } catch {
                    // Handle JSON decoding errors
                    print("Error decoding JSON: \(error.localizedDescription)")
                    completion(.failure(APIError.jsonConversion))
                }
            case let .failure(error):
                // Handle the network or request error
                completion(.failure(error))
            }
        }
    }

    @available(*, deprecated, message: "Use createConversation(conversation:completion:)")
    public func createConversation(
        userId: String,
        agentIds: [String],
        botIds: [String]?,
        useLastConversation: Bool,
        completion: @escaping (Response) -> Void
    ) {
        var clientId: String?
        var allAgentIds = agentIds
        var allBotIds = ["bot"] // Default bot that should be added everytime.
        if let botIds = botIds { allBotIds.append(contentsOf: botIds) }

        let appSettingService = KMAppSettingService()
        var isSingleThreadedConversation = useLastConversation

        appSettingService.appSetting {
            result in
            switch result {
            case let .success(appSettings):
                if let chatWidget = appSettings.chatWidget,
                   let isSingleThreaded = chatWidget.isSingleThreaded {
                    isSingleThreadedConversation = isSingleThreaded
                }
            case let .failure(error):
                print("Error while fetching app settings: \(error)")
                return
            }

            allAgentIds = allAgentIds.uniqueElements
            if isSingleThreadedConversation {
                // Sort and combine agent ids.
                var newClientId = allAgentIds
                    .sorted(by: <)
                    .reduce("") { $0 + $1.lowercased() + "_" } + userId.lowercased()

                // Sort and combine bot ids other than the default bot id.
                if let botIds = self.removeDefaultBotIdFrom(botIds: botIds) {
                    newClientId += Set(botIds)
                            .sorted(by: <)
                            .reduce("") { $0 + "_" + $1.lowercased() }
                }
                clientId = newClientId
                self.isGroupPresent(clientId: newClientId, completion: {
                    present, _ in
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
        userId _: String,
        agentIds: [String],
        botIds: [String]?,
        clientConversationId: String? = nil,
        completion: @escaping (Response) -> Void
    ) {
        let kommunicateConversationBuilder = KMConversationBuilder()
            .withAgentIds(agentIds)
            .withBotIds(botIds ?? [])
            .withClientConversationId(clientConversationId)

        let conversation = kommunicateConversationBuilder.build()
        createConversation(conversation: conversation) { response in
            completion(response)
        }
    }

    func makeAwayMessageFrom(json: [String: Any]) -> Result<[String: Any], Error> {
        guard
            let data = json["data"] as? [String: Any],
            let messageList = data["messageList"] as? [Any]
        else {
            return .failure(APIError.jsonConversion)
        }

        // Check if the message list is empty
        if messageList.isEmpty {
            return .failure(APIError.messageNotPresent)
        }

        // Get the value of anonymousUser
        let isAnonymousUser = data["anonymousUser"] as? Bool ?? false
        
        // Get the value of collectEmailOnAwayMessage
        let collectEmailOnAwayMessage = data["collectEmailOnAwayMessage"] as? Bool ?? false

        // Extract the first message if available
        guard let firstMessage = messageList.first as? [String: Any],
              let message = firstMessage["message"] as? String
        else {
            return .failure(APIError.messageNotPresent)
        }

        // Return both the message and collectEmailOnAwayMessage in a dictionary
        return .success([
            "message": message,
            "collectEmailOnAwayMessage": isAnonymousUser ? collectEmailOnAwayMessage : false
        ])
    }

    func extractWaitingQueResponse(from json: [String: Any]) -> Result<[Int], Error> {
        guard
            let status = json["status"] as? String, status == "success",
            let response = json["response"] as? [Int]
        else {
            return .failure(APIError.jsonConversion)
        }

        // Ensure the response is not empty
        if response.isEmpty {
            return .failure(APIError.responseNotPresent)
        }

        return .success(response)
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
            .reduce("") { $0 + $1.lowercased() + "_" } + userId.lowercased()

        // Sort and combine bot ids other than the default bot id.
        if let botIds = removeDefaultBotIdFrom(botIds: botIds) {
            newClientId += Set(botIds)
                    .sorted(by: <)
                    .reduce("") { $0 + "_" + $1.lowercased() }
        }
        return newClientId
    }
    
    /// To check whether the app name does not contain only spaces.
    func isValidAppName(_ checkString: String?) -> Bool {
        guard let checkString = checkString else {
            return false // App name is nil
        }
        
        let trimmedString = checkString.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedString.isEmpty
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

        if let conversationAssignee = conversation.conversationAssignee, !conversationAssignee.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata.setValue(conversation.conversationAssignee, forKey: ChannelMetadataKeys.conversationAssignee)
            metadata.setValue("true", forKey: ChannelMetadataKeys.skipRouting)
        }
        
        if let defaultConversationAssignee = conversation.defaultConversationAssignee, !defaultConversationAssignee.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata.setValue(conversation.defaultConversationAssignee, forKey: ChannelMetadataKeys.conversationAssignee)
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
        
        if let appName = conversation.appName, isValidAppName(appName) {
            let originName = "iOS: " + appName
            metadata.setValue(originName, forKey: ChannelMetadataKeys.groupCreationURL)
        } else if let appID = KMUserDefaultHandler.getApplicationKey() {
            let originName = "iOS: " + appID
            metadata.setValue(originName, forKey: ChannelMetadataKeys.groupCreationURL)
        }

        let languageCode = NSLocale.preferredLanguages.first?.prefix(2)
        if languageCode?.description != ALUserDefaultsHandler.getDeviceDefaultLanguage() {
            ALUserDefaultsHandler.setDeviceDefaultLanguage(languageCode?.description)
        }
        updateMetadataChatContext(info: [ChannelMetadataKeys.kmUserLocale: languageCode as Any], metadata: metadata)
        
        guard let messageMetadata = Kommunicate.defaultConfiguration.messageMetadata,
              !messageMetadata.isEmpty
        else {
            return metadata
        }
        metadata.addEntries(from: messageMetadata)
        return metadata
    }
    
    private func updateMetadataChatContext(info: [String: Any], metadata: NSMutableDictionary) {
        var context: [String: Any] = [:]

        do {
            let contextDict = chatContextFromMetadata(messageMetadata: metadata as? [AnyHashable: Any])
            context = contextDict ?? [:]
            context.merge(info, uniquingKeysWith: { $1 })

            let messageInfoData = try JSONSerialization
                .data(withJSONObject: context, options: .prettyPrinted)
            let messageInfoString = String(data: messageInfoData, encoding: .utf8) ?? ""
            metadata["KM_CHAT_CONTEXT"] = messageInfoString
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func chatContextFromMetadata(messageMetadata: [AnyHashable: Any]?) -> [String: Any]? {
        guard
            let messageMetadata = messageMetadata,
            let chatContext = messageMetadata["KM_CHAT_CONTEXT"] as? String,
            let contextData = chatContext.data(using: .utf8)
        else {
            return nil
        }
        do {
            let contextDict = try JSONSerialization
                .jsonObject(with: contextData, options: .allowFragments) as? [String: Any]
            return contextDict
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    // MARK: - Private methods

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

    internal func isGroupPresent(clientId: String, completion: @escaping (_ isPresent: Bool, _ channel: ALChannel?) -> Void) {
        let client = ALChannelService()
        client.getChannelInformation(byResponse: nil, orClientChannelKey: clientId, withCompletion: {
            _, channel, _ in
            guard let channel = channel else {
                completion(false, nil)
                return
            }
            completion(true, channel)
        })
    }

    private func createNewChannelAndConversation(
        clientChannelKey: String?,
        userId _: String,
        agentIds: [String],
        botIds: [String]?,
        completion: @escaping (Response) -> Void
    ) {
        let kommunicateConversationBuilder = KMConversationBuilder()
            .withAgentIds(agentIds)
            .withBotIds(botIds ?? [])
            .withClientConversationId(clientChannelKey)

        let conversation = kommunicateConversationBuilder.build()
        createNewChannelAndConversation(conversation: conversation) { respsone in
            completion(respsone)
        }
    }

    private func createNewChannelAndConversation(conversation: KMConversation,
                                                 completion: @escaping (Response) -> Void) {
        let groupName = conversation.conversationTitle ?? localizedString(
            forKey: LocalizationKey.supportChannelName,
            fileName: Kommunicate.defaultConfiguration.localizedStringFileName
        )

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
            adminUser: nil,
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
                
                guard let zendeskAccountKey = ALApplozicSettings.getZendeskSdkAccountKey(),
                      !zendeskAccountKey.isEmpty,
                      let clientChannelKey = channel.clientChannelKey,
                      let metadata = channel.metadata,
                      let conversationMetaDict = ["source": "zopim"] as NSDictionary? as! [String: Any]?,
                      let jsonObject = try? JSONSerialization.data(withJSONObject: conversationMetaDict, options: []),
                      let jsonString = String(data: jsonObject, encoding: .utf8) else {
                    var response = Response()
                    response.clientChannelKey = channel.clientChannelKey
                    completion(response)
                    return
                }
                // Update conveersation meta data with source if zendesk is integrated
                metadata.setValue(jsonString, forKey: ChannelMetadataKeys.conversationMetaData)
                self.updateConversationMetadata(groupId: clientChannelKey, metadata: metadata, completion: { response in
                    var response = Response()
                    response.clientChannelKey = channel.clientChannelKey
                    completion(response)
                })
            }
        )
    }

    private func removeDefaultBotIdFrom(botIds: [String]?) -> [String]? {
        guard var allBotIds = botIds else { return nil }
        allBotIds.removeAll { id -> Bool in
            id == "bot"
        }
        return allBotIds
    }

    internal func assignConversation(
        groupId: Int,
        to user: String,
        completion: @escaping (Result<[String: Any], ServiceError>) -> Void
    ) {
        guard let url = URLBuilder
            .assigneeChangeURL(groupId: groupId, assigneeUserId: user).url
        else {
            completion(.failure(.urlCreation))
            return
        }

        let theRequest: NSMutableURLRequest? =
            ALRequestHandler.createPatchRequest(
                withUrlString: url.absoluteString,
                paramString: nil
            )
        ALResponseHandler().authenticateAndProcessRequest(theRequest, andTag: "KM-ASSIGNEE-CHANGE") {
            json, error in
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
              let assigneeUserId = channel.assigneeUserId
        else {
            return nil
        }
        return assigneeUserId
    }

    private func updateGroupMetadata(
        groupId: NSNumber,
        channelKey: String,
        metadata: NSMutableDictionary,
        completion: @escaping ((Response) -> Void)
    ) {
        ALChannelService().updateChannelMetaData(groupId, orClientChannelKey: channelKey, metadata: metadata) { error in
            guard error == nil else {
                completion(Response(success: false, clientChannelKey: nil, error: error))
                return
            }
            completion(Response(success: true, clientChannelKey: channelKey, error: nil))
        }
    }
    
    public func updateConversationMetadata(
        groupId: String,
        metadata: NSMutableDictionary,
        completion: @escaping ((Response) -> Void)
    ) {
        ALChannelService().updateChannelMetaData(nil, orClientChannelKey: groupId, metadata: metadata) { error in
            guard error == nil else {
                completion(Response(success: false, clientChannelKey: nil, error: error))
                return
            }
            completion(Response(success: true, clientChannelKey: groupId, error: nil))
        }
    }

    public func updateTeam(
        groupID: String,
        teamID: String,
        completion: @escaping ((Response) -> Void)
    ) {
        let metadata = NSMutableDictionary(
            dictionary: ALChannelService().metadataToHideActionMessagesAndTurnOffNotifications())
        if !teamID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata.setValue(teamID, forKey: ChannelMetadataKeys.teamId)
        }

        ALChannelService().updateChannelMetaData(NSNumber(pointer: groupID), orClientChannelKey: groupID, metadata: metadata) { error in
            guard error == nil else {
                completion(Response(success: false, clientChannelKey: nil, error: error))
                return
            }
            completion(Response(success: true, clientChannelKey: groupID, error: nil))
        }
    }
}
