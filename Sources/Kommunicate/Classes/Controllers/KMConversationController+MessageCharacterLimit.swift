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
        let messageLimit = CharacterLimit.charlimit
        let botLimit = CharacterLimit.botCharLimit
        let cxBotLimit = CharacterLimit.cxBotCharLimit
        if isConversationAssignedToDialogflowBot && isConversationAssignedToDialogflowCXBot {
            handleCharacterLimit(textCount: textCount, limit: cxBotLimit, manager: botCharLimitManager, isBotMessage: true)
        } else if isConversationAssignedToDialogflowBot && !isConversationAssignedToDialogflowCXBot {
            handleCharacterLimit(textCount: textCount, limit: botLimit, manager: botCharLimitManager, isBotMessage: true)
        } else {
            handleCharacterLimit(textCount: textCount, limit: messageLimit, manager: messageCharLimitManager, isBotMessage: false)
        }
    }

    private func handleCharacterLimit(textCount: Int, limit: CharacterLimit.Limit, manager: MessageCharacterLimitManager, isBotMessage: Bool) {
        if textCount >= limit.soft {
            manager.messageToShow = characterLimitMessage(textCount: textCount, limit: limit, isMessageforBot: isBotMessage)
            manager.showLimitView(true, disableButton: textCount > limit.hard)
        } else {
            manager.showLimitView(false)
        }
    }
}
