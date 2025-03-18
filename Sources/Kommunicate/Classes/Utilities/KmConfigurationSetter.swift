//
//  KMCustomisation.swift
//  Kommunicate
//
//  Created by Aman on 14/02/23.
//

import Foundation
import UIKit
import KommunicateChatUI_iOS_SDK

public class KMConfigurationSetter {
    
    class func createCustomSetting(settings: String) -> Bool {
        do {
            guard let data = settings.data(using: .utf8),
                  let settingDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return false
            }
            
            applyMessageStyleSettings(from: settingDict)
            applyNavigationBarSettings(from: settingDict)
            applyAttachmentSettings(from: settingDict)
            applyButtonSettings(from: settingDict)
            applyGeneralSettings(from: settingDict)

        } catch {
            print("Failed to read setting json string: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    // MARK: - Helper Methods
    
    private class func applyMessageStyleSettings(from settings: [String: Any]) {
        if let sentMessageBackgroundColor = settings["sentMessageBackgroundColor"] as? String, !sentMessageBackgroundColor.isEmpty {
            KMMessageStyle.sentBubble.color = UIColor(hexString: sentMessageBackgroundColor)
        }
        if let receivedMessageBackgroundColor = settings["receivedMessageBackgroundColor"] as? String, !receivedMessageBackgroundColor.isEmpty {
            KMMessageStyle.receivedBubble.color = UIColor(hexString: receivedMessageBackgroundColor)
        }
        if let sentMessageTextColor = settings["sentMessageTextColor"] as? String, !sentMessageTextColor.isEmpty {
            KMMessageStyle.sentMessage = KMStyle(font: .systemFont(ofSize: 14), text: UIColor(hexString: sentMessageTextColor))
        }
        if let receivedMessageTextColor = settings["receivedMessageTextColor"] as? String, !receivedMessageTextColor.isEmpty {
            KMMessageStyle.receivedMessage = KMStyle(font: .systemFont(ofSize: 14), text: UIColor(hexString: receivedMessageTextColor))
        }
    }
    
    private class func applyNavigationBarSettings(from settings: [String: Any]) {
        let kmNavigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [KMBaseNavigationViewController.self])
        
        if let toolbarTitleColor = settings["toolbarTitleColor"] as? String, !toolbarTitleColor.isEmpty {
            kmNavigationBarProxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: toolbarTitleColor)]
        }
        if let toolbarSubtitleColor = settings["toolbarSubtitleColor"] as? String, !toolbarSubtitleColor.isEmpty {
            kmNavigationBarProxy.tintColor = UIColor(hexString: toolbarSubtitleColor)
        }
        if let toolbarColor = settings["toolbarColor"] as? String, !toolbarColor.isEmpty {
            kmNavigationBarProxy.barTintColor = UIColor(hexString: toolbarColor)
        }
    }
    
    private class func applyAttachmentSettings(from settings: [String: Any]) {
        if let attachmentOptions = settings["attachmentOptions"] as? [String: Bool], !attachmentOptions.isEmpty {
            var attachments = [AttachmentType]()
            for (key, value) in attachmentOptions {
                switch key {
                case ":location": attachments.append(.location)
                case ":camera": attachments.append(.camera)
                case ":file": attachments.append(.document)
                case ":audio": Kommunicate.defaultConfiguration.hideAudioOptionInChatBar = !value
                default: break
                }
            }
            Kommunicate.defaultConfiguration.chatBar.optionsToShow = .some(attachments)
        }
        
        if let maxAttachmentAllowed = settings["maxAttachmentAllowed"] as? Int {
            Kommunicate.defaultConfiguration.chatBar.photosSelectionLimit = maxAttachmentAllowed
        }
    }
    
    private class func applyButtonSettings(from settings: [String: Any]) {
        if let showTopbarStartConversationButton = settings["showTopbarStartConversationButton"] as? Bool {
            Kommunicate.defaultConfiguration.hideStartChatButton = !showTopbarStartConversationButton
        }
        if let showStartNewConversation = settings["showStartNewConversation"] as? Bool {
            Kommunicate.defaultConfiguration.hideBottomStartNewConversationButton = !showStartNewConversation
        }
        if let startNewConversationButtonBackgroundColor = settings["startNewConversationButtonBackgroundColor"] as? String {
            Kommunicate.kmConversationViewConfiguration.startNewConversationButtonBackgroundColor = UIColor(hexString: startNewConversationButtonBackgroundColor)
        }
        if let startNewConversationButtonTextColor = settings["startNewConversationButtonTextColor"] as? String {
            Kommunicate.kmConversationViewConfiguration.startNewConversationButtonTextColor = UIColor(hexString: startNewConversationButtonTextColor)
        }
    }
    
    private class func applyGeneralSettings(from settings: [String: Any]) {
        let booleanSettings: [String: (Bool) -> Void] = [
            "enableFaqOption": { Kommunicate.defaultConfiguration.hideFaqButtonInConversationList = !$0 },
            "refreshOption": { Kommunicate.defaultConfiguration.isRefreshButtonEnabled = $0 },
            "restrictMessageTypingWithBots": { Kommunicate.kmConversationViewConfiguration.restrictMessageTypingWithBots = $0 },
            "oneTimeRating": { Kommunicate.defaultConfiguration.oneTimeRating = $0 },
            "hideSenderName": { KMCellConfiguration.hideSenderName = $0 },
            "hideBackButtonInConversationList": { Kommunicate.defaultConfiguration.hideBackButtonInConversationList = $0 },
            "disableRichMessageButtonAction": { Kommunicate.defaultConfiguration.disableRichMessageButtonAction = $0 },
            "isNewSystemPhotosUIEnabled": { Kommunicate.defaultConfiguration.isNewSystemPhotosUIEnabled = $0 },
            "rateConversationMenuOption": { Kommunicate.defaultConfiguration.rateConversationMenuOption = $0 },
            "restartConversationButtonVisibility": { Kommunicate.defaultConfiguration.hideRestartConversationButton = !$0 },
            "enableBackArrowOnConversationListScreen": { Kommunicate.defaultConfiguration.enableBackArrowOnConversationListScreen = $0 },
            "hideChatInHelpcenter": { Kommunicate.defaultConfiguration.hideChatInHelpcenter = $0 },
            "enableDeleteConversationOnLongpress": { Kommunicate.defaultConfiguration.enableDeleteConversationOnLongpress = $0 },
            "showTypingIndicatorWhileFetchingResponse": { KMConversationScreenConfiguration.showTypingIndicatorWhileFetchingResponse = $0 },
            "hideEmptyStateStartNewButtonInConversationList": { Kommunicate.defaultConfiguration.hideEmptyStateStartNewButtonInConversationList = $0 }
        ]
        
        for (key, setter) in booleanSettings {
            if let value = settings[key] as? Bool {
                setter(value)
            }
        }
        
        if let restrictedWordRegex = settings["restrictedWordRegex"] as? String, !restrictedWordRegex.isEmpty {
            Kommunicate.defaultConfiguration.restrictedMessageRegexPattern = restrictedWordRegex
        }
    }
}
