//
//  KMConfiguration.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 20/08/19.
//

import Foundation
import ApplozicSwift

extension ALKConfiguration {

    /// If true, faq button in conversation view will be hidden.
    public var hideFaqButtonInConversationView: Bool {
        set {
            guard newValue else { return }
            navigationItemsForConversationView.removeAll(where: { $0.identifier == faqIdentifier })
            navigationItemsForConversationView = []
        }
        get {
            return navigationItemsForConversationView.contains { $0.identifier == faqIdentifier }
        }
    }

    /// If true, faq button in conversation list will be hidden.
    public var hideFaqButtonInConversationList: Bool {
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
    public mutating func updateChatContext(with info: [String: Any]) throws {
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
    public mutating func updateUserLanguage(tag: String) throws {
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
            let contextData = chatContext.data(using: .utf8) else {
                return nil
        }
        do {
            let contextDict = try JSONSerialization
                .jsonObject(with: contextData, options : .allowFragments) as? Dictionary<String, Any>
            return contextDict
        }
        catch {
            throw error
        }
    }
}
