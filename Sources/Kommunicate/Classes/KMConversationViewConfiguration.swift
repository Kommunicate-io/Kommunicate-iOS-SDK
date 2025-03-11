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
    public var startNewButtonIcon: UIImage? = UIImage(named: "icon_new_chat_red", in: Bundle.kommunicate, compatibleWith: nil)
    /// If enabled, the user can't send a message when a conversation is assigned to a bot.
    public var restrictMessageTypingWithBots = false
    public var toolbarSubtitleText: String = ""
    public var toolbarSubtitleRating: Float = -1.0
    /// Customize Text color of FAQ button on conversation, conversation list screen
    public var faqTextColor: UIColor = UIColor.white
    /// Customize Text dark color of FAQ button on conversation, conversation list screen
    public var faqTextDarkColor: UIColor = UIColor.white
    /// Customize background color of FAQ button on conversation, conversation list screen
    public var faqBackgroundColor: UIColor = UIColor(hexString: "ffffff", alpha: 0.24)
    /// Customize dark background color of FAQ button on conversation, conversation list screen
    public var faqDarkBackgroundColor: UIColor = UIColor(hexString: "ffffff", alpha: 0.24)
    /// Customize the Start New Conversation Button Background Color on Conversation List Screen
    public var startNewConversationButtonBackgroundColor: UIColor?
    /// Customize the Start New Conversation Button TextColor on Conversation List Screen
    public var startNewConversationButtonTextColor: UIColor = UIColor.white
    /// Customize the Start New Conversation Button Background Dark Color on Conversation List Screen
    public var startNewConversationButtonDarkBackgroundColor: UIColor?
    /// Customize the Start New Conversation Button TextDarkColor on Conversation List Screen
    public var startNewConversationButtonDarkTextColor: UIColor?
    public init() {}
}
