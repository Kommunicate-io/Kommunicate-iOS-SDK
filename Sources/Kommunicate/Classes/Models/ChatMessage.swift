//
//  ChatMessage.swift
//  Kommunicate
//
//  Created by Mukesh on 26/05/20.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import UIKit

class ChatMessage: ALKChatViewModelProtocol, Localizable {
    var messageMetadata: NSMutableDictionary?
    var messageType: ALKMessageType
    var avatar: URL?
    var avatarImage: UIImage?
    var avatarGroupImageUrl: String?
    var name: String
    var groupName: String
    var theLastMessage: String?
    var hasUnreadMessages: Bool
    var totalNumberOfUnreadMessages: UInt
    var isGroupChat: Bool
    var contactId: String?
    var channelKey: NSNumber?
    var conversationId: NSNumber!
    var createdAt: String?
    var channelType: Int16
    var isMessageEmpty: Bool

    init(message: ALKChatViewModelProtocol) {
        avatar = message.avatar
        avatarImage = message.avatarImage
        avatarGroupImageUrl = message.avatarGroupImageUrl
        name = message.name
        groupName = message.groupName
        theLastMessage = message.theLastMessage
        hasUnreadMessages = message.hasUnreadMessages
        totalNumberOfUnreadMessages = message.totalNumberOfUnreadMessages
        isGroupChat = message.isGroupChat
        contactId = message.contactId
        channelKey = message.channelKey
        conversationId = message.conversationId
        createdAt = message.createdAt
        messageType = message.messageType
        isMessageEmpty = message.isMessageEmpty

        // Update message to show conversation assignee details
        let (_, channel) = ConversationDetail().conversationAssignee(groupId: channelKey, userId: contactId)
        channelType = message.channelType

        guard let alChannel = channel else {
            groupName = localizedString(forKey: KMLocalizationKey.noName, fileName: Kommunicate.defaultConfiguration.localizedStringFileName)
            return
        }
        groupName = alChannel.name ?? localizedString(forKey: KMLocalizationKey.noName, fileName: Kommunicate.defaultConfiguration.localizedStringFileName)
        avatarGroupImageUrl = alChannel.channelImageURL
    }
}
