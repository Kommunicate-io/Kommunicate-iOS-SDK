//
//  KMConversationViewConfiguration.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 14/12/18.
//

import Foundation
import UIKit

public struct KMConversationViewConfiguration {
    
    public var hideBackButton: Bool = false
    public var imageForBackButton: UIImage?
    public var conversationLaunchNotificationName = "ConversationLaunched"
    public var backButtonNotificationName = "ConversationClosed"
    public var isCSATOptionDisabled: Bool = false
     /// Start new conversation icon in conversation list.
    public var startNewButtonIcon : UIImage? = UIImage(named: "icon_new_chat_red", in: Bundle.kommunicate, compatibleWith: nil)
    /// If enabled, the user can't send a message when a conversation is assigned to a bot.
    public var restrictMessageTypingWithBots = false

    public init() { }
}
