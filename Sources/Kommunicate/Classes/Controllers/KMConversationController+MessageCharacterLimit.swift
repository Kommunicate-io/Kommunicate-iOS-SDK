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
        if isConversationAssignedToDialogflowBot, textCount >= botLimit.soft, textCount <= messageLimit.soft {
            botCharLimitManager.messageToShow = characterLimitMessage(textCount: textCount, limit: botLimit, isMessageforBot: true)
            botCharLimitManager.showLimitView(true, disableButton: textCount > botLimit.hard)
        } else if textCount >= messageLimit.soft {
            messageCharLimitManager.messageToShow = characterLimitMessage(textCount: textCount, limit: messageLimit, isMessageforBot: false)
            messageCharLimitManager.showLimitView(true, disableButton: textCount > messageLimit.hard)
        } else {
            messageCharLimitManager.showLimitView(false)
        }
    }
}
