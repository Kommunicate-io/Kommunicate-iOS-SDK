//
//  ChatMessage.swift
//  Kommunicate
//
//  Created by Mukesh on 26/05/20.
//

import Foundation
import ApplozicSwift
import UIKit

class ChatMessage: ALKChatViewModelProtocol,Localizable {
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
        self.avatar = message.avatar
        self.avatarImage = message.avatarImage
        self.avatarGroupImageUrl = message.avatarGroupImageUrl
        self.name = message.name
        self.groupName = message.groupName
        self.theLastMessage = message.theLastMessage
        self.hasUnreadMessages = message.hasUnreadMessages
        self.totalNumberOfUnreadMessages = message.totalNumberOfUnreadMessages
        self.isGroupChat = message.isGroupChat
        self.contactId = message.contactId
        self.channelKey = message.channelKey
        self.conversationId = message.conversationId
        self.createdAt = message.createdAt
        self.messageType = message.messageType
        self.isMessageEmpty = message.isMessageEmpty

        // Update message to show conversation assignee details
        let (_,channel) = ConversationDetail().conversationAssignee(groupId: self.channelKey, userId: self.contactId)
        self.channelType = message.channelType

        guard let alChannel = channel  else {
            self.groupName = localizedString(forKey: KMLocalizationKey.noName, fileName: Kommunicate.defaultConfiguration.localizedStringFileName)
            return
        }
        self.groupName = alChannel.name ?? localizedString(forKey: KMLocalizationKey.noName, fileName: Kommunicate.defaultConfiguration.localizedStringFileName)
        self.avatarGroupImageUrl = alChannel.channelImageURL
    }
}
