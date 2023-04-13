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
            if let sentMessageBackgroundColor = settingDict["sentMessageBackgroundColor"] as? String,!sentMessageBackgroundColor.isEmpty {
                KMMessageStyle.sentBubble.color = UIColor(hexString: sentMessageBackgroundColor)
            }
            if let receivedMessageBackgroundColor = settingDict["receivedMessageBackgroundColor"] as? String,!receivedMessageBackgroundColor.isEmpty {
                KMMessageStyle.receivedBubble.color = UIColor(hexString: receivedMessageBackgroundColor)
            }
            if let chatBackgroundColorOrDrawable = settingDict["chatBackgroundColorOrDrawable"] as? String,!chatBackgroundColorOrDrawable.isEmpty {
                Kommunicate.defaultConfiguration.backgroundColor = UIColor(hexString: chatBackgroundColorOrDrawable)
            }
            if let sentMessageTextColor = settingDict["sentMessageTextColor"] as? String, !sentMessageTextColor.isEmpty {
                KMMessageStyle.sentMessage = KMStyle(font: .systemFont(ofSize: 14), text: UIColor(hexString: sentMessageTextColor))
            }
            if let receivedMessageTextColor = settingDict["receivedMessageTextColor"] as? String, !receivedMessageTextColor.isEmpty {
                KMMessageStyle.receivedMessage = KMStyle(font: .systemFont(ofSize: 14), text: UIColor(hexString: receivedMessageTextColor))
            }
            let kmNavigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [KMBaseNavigationViewController.self])
            if let toolbarTitleColor = settingDict["toolbarTitleColor"] as? String,!toolbarTitleColor.isEmpty {
                kmNavigationBarProxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: toolbarTitleColor)]
            }
            if let toolbarSubtitleColor = settingDict["toolbarSubtitleColor"] as? String,!toolbarSubtitleColor.isEmpty {
                kmNavigationBarProxy.tintColor = UIColor(hexString: toolbarSubtitleColor )
            }
            if let toolbarColor = settingDict["toolbarColor"] as? String,!toolbarColor.isEmpty {
                kmNavigationBarProxy.barTintColor = UIColor(hexString: toolbarColor )
            }
            if let attachmentIconsBackgroundColor = settingDict["attachmentIconsBackgroundColor"] as? String,!attachmentIconsBackgroundColor.isEmpty {
                Kommunicate.defaultConfiguration.chatBarAttachmentViewBackgroundColor = UIColor(hexString:attachmentIconsBackgroundColor)
            }
            if let enableFaqOption = settingDict["enableFaqOption"] as? [Bool], !enableFaqOption.isEmpty {
                Kommunicate.defaultConfiguration.hideFaqButtonInConversationList = !enableFaqOption[0]
                Kommunicate.defaultConfiguration.hideFaqButtonInConversationView = !enableFaqOption[1]
            }
            if let attachmentOptions = settingDict["attachmentOptions"] as? Dictionary<String, Bool>, !attachmentOptions.isEmpty {
                var attachments = [AttachmentType]()
                for(key, value) in attachmentOptions {
                    if(key.elementsEqual(":location")) {
                        attachments.append(AttachmentType.location)
                    } else if(key.elementsEqual(":camera")) {
                        attachments.append(AttachmentType.camera)
                    } else if(key.elementsEqual(":file")) {
                        attachments.append(AttachmentType.document)
                    } else if(key.elementsEqual(":audio")) {
                        //:audio value will represent bool to enable audio option. Need to reverse it for iOS Configuration hideAudioOptionInChatBar
                        Kommunicate.defaultConfiguration.hideAudioOptionInChatBar = !value
                    }
                }
                Kommunicate.defaultConfiguration.chatBar.optionsToShow = .some(attachments)
            }
            if let maxAttachmentAllowed = settingDict["maxAttachmentAllowed"] as? Int {
                Kommunicate.defaultConfiguration.chatBar.photosSelectionLimit = maxAttachmentAllowed
            }
            if let showTopbarStartConversationButton = settingDict["showTopbarStartConversationButton"] as? Bool {
                Kommunicate.defaultConfiguration.hideStartChatButton = !showTopbarStartConversationButton
            }
            if let showStartNewConversation = settingDict["showStartNewConversation"] as? Bool {
                Kommunicate.defaultConfiguration.hideBottomStartNewConversationButton = !showStartNewConversation
            }
            if let refreshOption = settingDict["refreshOption"] as? Bool {
                Kommunicate.defaultConfiguration.isRefreshButtonEnabled = refreshOption
            }
            if let restrictMessageTypingWithBots = settingDict["restrictMessageTypingWithBots"] as? Bool {
                Kommunicate.kmConversationViewConfiguration.restrictMessageTypingWithBots = restrictMessageTypingWithBots
            }
            if let oneTimeRating = settingDict["oneTimeRating"] as? Bool {
                Kommunicate.defaultConfiguration.oneTimeRating = oneTimeRating
            }
            if let hideSenderName = settingDict["hideSenderName"] as? Bool {
                KMCellConfiguration.hideSenderName = hideSenderName
            }
            if let hideBackButtonInConversationList = settingDict["hideBackButtonInConversationList"] as? Bool {
                Kommunicate.defaultConfiguration.hideBackButtonInConversationList = hideBackButtonInConversationList
            }
            if let disableRichMessageButtonAction = settingDict["disableRichMessageButtonAction"] as? Bool {
                Kommunicate.defaultConfiguration.disableRichMessageButtonAction = disableRichMessageButtonAction
            }
            if let isNewSystemPhotosUIEnabled = settingDict["isNewSystemPhotosUIEnabled"] as? Bool {
                Kommunicate.defaultConfiguration.isNewSystemPhotosUIEnabled = isNewSystemPhotosUIEnabled
            }
            if let restrictedWordRegex = settingDict["restrictedWordRegex"] as? String, !restrictedWordRegex.isEmpty {
                Kommunicate.defaultConfiguration.restrictedMessageRegexPattern = restrictedWordRegex
            }
            
            if let rateConversationMenuOption = settingDict["rateConversationMenuOption"] as? Bool {
                Kommunicate.defaultConfiguration.rateConversationMenuOption = rateConversationMenuOption
            }
            
            if let restartButtonVisibility = settingDict["restartConversationButtonVisibility"] as? Bool {
                Kommunicate.defaultConfiguration.hideRestartConversationButton = !restartButtonVisibility
            }
            
            if let enableBackArrowOnConversationListScreen = settingDict["enableBackArrowOnConversationListScreen"] as? Bool {
                Kommunicate.defaultConfiguration.enableBackArrowOnConversationListScreen = enableBackArrowOnConversationListScreen
            }
            
            if let showStartNewConversation = settingDict["showStartNewConversation"] as? Bool {
                Kommunicate.defaultConfiguration.hideBottomStartNewConversationButton = !showStartNewConversation
            }
            
            if let hideChatInHelpCenter = settingDict["hideChatInHelpcenter"] as? Bool {
                Kommunicate.defaultConfiguration.hideChatInHelpcenter = hideChatInHelpCenter
            }
            
            if let enableDeleteConversationOnLongPress = settingDict["enableDeleteConversationOnLongpress"] as? Bool {
                Kommunicate.defaultConfiguration.enableDeleteConversationOnLongpress = enableDeleteConversationOnLongPress
            }
            
        } catch let error as NSError {
            print("Failed to read setting json string \(error.description)")
            return false
        }
        return true
    }
}
