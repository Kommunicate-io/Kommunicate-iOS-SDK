//
//  KMConfiguration.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 20/08/19.
//

import Foundation
import KommunicateChatUI_iOS_SDK

public extension ALKConfiguration {
    /// If true, faq button in conversation view will be hidden.
    var hideFaqButtonInConversationView: Bool {
        set {
            guard newValue else { return }
            navigationItemsForConversationView.removeAll(where: { $0.identifier == faqIdentifier })
            navigationItemsForConversationView = []
        }
        get {
            return navigationItemsForConversationView.contains { $0.identifier == faqIdentifier }
        }
    }
    
    //  assignee id to be added with the conversation when the conversation created from ConversationListScreen
    var defaultAssignee: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: ConversationDefaultSettings.defaultAssignee)
        }
        get {
            return UserDefaults.standard.string(forKey:ConversationDefaultSettings.defaultAssignee)
        }
    }
    
    // teamId to be added with the conversation when the conversation created from ConversationListScreen
    var defaultTeamId: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: ConversationDefaultSettings.defaultTeam)
        }
        get {
            return UserDefaults.standard.string(forKey: ConversationDefaultSettings.defaultTeam)
        }
    }
    
    //  skipRouting flag to be added with the conversation when the conversation created from ConversationListScreen
    var defaultSkipRouting: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: ConversationDefaultSettings.defaultSkipRouting)
        }
        get {
            return UserDefaults.standard.bool(forKey: ConversationDefaultSettings.defaultSkipRouting)
        }
    }
    
    // List of AgentIds to be added with the conversation when the conversation created from ConversationListScreen
    var defaultAgentIds: [String]? {
        set {
            UserDefaults.standard.set(newValue, forKey: ConversationDefaultSettings.defaultAgentIds)
        }
        get {
            return UserDefaults.standard.object(forKey: ConversationDefaultSettings.defaultAgentIds) as? [String]
        }
    }
    
    // List of botIds to be added the conversation when the conversation created from ConversationListScreen
    var defaultBotIds: [String]? {
        set {
            UserDefaults.standard.set(newValue, forKey: ConversationDefaultSettings.defaultBotIds)
        }
        get {
            return UserDefaults.standard.object(forKey: ConversationDefaultSettings.defaultBotIds) as? [String]
        }
    }
    
    // To clear the default conversation settings like defaultAssignee,defaultBotIds..etc
    func clearDefaultConversationSettings(){
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: ConversationDefaultSettings.defaultBotIds)
        userDefaults.removeObject(forKey: ConversationDefaultSettings.defaultAgentIds)
        userDefaults.removeObject(forKey: ConversationDefaultSettings.defaultAssignee)
        userDefaults.removeObject(forKey: ConversationDefaultSettings.defaultSkipRouting)
        userDefaults.removeObject(forKey: ConversationDefaultSettings.defaultTeam)
    }

    /// If true, faq button in conversation list will be hidden.
    var hideFaqButtonInConversationList: Bool {
        set {
            guard newValue else { return }
            navigationItemsForConversationList.removeAll(where: { $0.identifier == faqIdentifier })
        }
        get {
            return navigationItemsForConversationList.contains { $0.identifier == faqIdentifier }
        }
    }

    /// Use this to pass extra information as metadata, it will be
    /// passed with each message as value of `KM_CHAT_CONTEXT` key.
    ///
    /// - Parameter info: Info that should be passed with each message
    mutating func updateChatContext(with info: [String: Any]) throws {
        var metadata = messageMetadata ?? [:]
        var context: [String: Any] = [:]

        do {
            let contextDict = try chatContextFromMetadata()
            context = contextDict ?? [:]
            context.merge(info, uniquingKeysWith: { $1 })

            let messageInfoData = try JSONSerialization
                .data(withJSONObject: context, options: .prettyPrinted)
            let messageInfoString = String(data: messageInfoData, encoding: .utf8) ?? ""
            metadata[ChannelMetadataKeys.chatContext] = messageInfoString
            messageMetadata = metadata
        } catch {
            throw error
        }
    }

    /// Use this to update user's language, it will be passed with
    /// each message in the metadata.
    ///
    /// - Parameter tag: Language tag to set user's language
    mutating func updateUserLanguage(tag: String) throws {
        do {
            try updateChatContext(with: [ChannelMetadataKeys.languageTag: tag])
        } catch {
            throw error
        }
    }

    private func chatContextFromMetadata() throws -> [String: Any]? {
        guard
            let messageMetadata = messageMetadata,
            let chatContext = messageMetadata[ChannelMetadataKeys.chatContext] as? String,
            let contextData = chatContext.data(using: .utf8)
        else {
            return nil
        }
        do {
            let contextDict = try JSONSerialization
                .jsonObject(with: contextData, options: .allowFragments) as? [String: Any]
            return contextDict
        } catch {
            throw error
        }
    }
}
private enum ConversationDefaultSettings {
    static let defaultBotIds = "DEFAULT_BOT_IDS"
    static let defaultAgentIds = "DEFAULT_AGENT_IDS"
    static let defaultAssignee = "DEFAULT_ASSIGNEE"
    static let defaultTeam = "DEFAUT_TEAM_ID"
    static let defaultSkipRouting = "DEFAULT_SKIP_ROUTING"

}
