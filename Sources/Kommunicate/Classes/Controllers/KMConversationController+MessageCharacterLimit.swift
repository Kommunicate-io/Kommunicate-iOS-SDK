//
//  KMConversationController+MessageCharacterLimit.swift
//  Kommunicate
//
//  Created by Mukesh on 18/11/20.
//

import Foundation

extension KMConversationViewController: MessageCharacterLimitDelegate {
    func characterLimit(manager _: MessageCharacterLimitManager, _ isHidden: Bool) {
        let emailAndAwayViewHidden = viewModel.emailCollectionAwayModeEnabled ? false : isAwayMessageViewHidden
        if isHidden {
            chatBar.headerViewHeight = emailAndAwayViewHidden ? 0 : awayMessageheight
        } else {
            chatBar.headerViewHeight = emailAndAwayViewHidden ? MessageCharacterLimitManager.charLimitViewHeight : awayMessageheight + MessageCharacterLimitManager.charLimitViewHeight
        }
    }

    func characterLimit(manager _: MessageCharacterLimitManager, reachedTheLimit _: Int, textCount: Int) {
        let limitConfig = determineCharacterLimit()
        handleCharacterLimit(textCount: textCount, limit: limitConfig.limit, manager: limitConfig.manager, isBotMessage: limitConfig.isBotMessage)
    }

    private func determineCharacterLimit() -> (limit: CharacterLimit.Limit, manager: MessageCharacterLimitManager, isBotMessage: Bool) {
        switch (isConversationAssignedToDialogflowBot, isConversationAssignedToDialogflowCXBot) {
        case (true, true):
            return (CharacterLimit.cxBotCharLimit, botCharLimitManager, true) /// Conversation is assigned to Dialogflow CX bot
        case (true, false):
            return (CharacterLimit.botCharLimit, botCharLimitManager, true)  /// Conversation is assigned to Dialogflow ES bot
        default:
            return (CharacterLimit.charlimit, messageCharLimitManager, false) /// Conversation is assigned to Non - Dialogflow bot
        }
    }

    private func handleCharacterLimit(textCount: Int, limit: CharacterLimit.Limit, manager: MessageCharacterLimitManager, isBotMessage: Bool) {
        let hasReachedSoftLimit = textCount >= limit.soft
        let hasExceededHardLimit = textCount > limit.hard
        
        if hasReachedSoftLimit {
            manager.messageToShow = characterLimitMessage(textCount: textCount, limit: limit, isMessageforBot: isBotMessage)
            manager.showLimitView(true, disableButton: hasExceededHardLimit)
        } else {
            manager.showLimitView(false)
        }
    }
}
