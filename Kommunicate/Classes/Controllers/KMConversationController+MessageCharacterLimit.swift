//
//  KMConversationController+MessageCharacterLimit.swift
//  Kommunicate
//
//  Created by Mukesh on 18/11/20.
//

import Foundation

extension KMConversationViewController: MessageCharacterLimitDelegate {
    func characterLimit(manager: MessageCharacterLimitManager, _ isHidden: Bool) {
        if (isHidden) {
            chatBar.headerViewHeight = self.isAwayMessageViewHidden ? 0 :  awayMessageheight
        } else {
            chatBar.headerViewHeight = isAwayMessageViewHidden ?  MessageCharacterLimitManager.charLimitViewHeight : awayMessageheight + MessageCharacterLimitManager.charLimitViewHeight
        }
    }

    func characterLimit(manager: MessageCharacterLimitManager, reachedTheLimit limit: Int, textCount: Int) {
        let messageLimit = CharacterLimit.charlimit
        let botLimit = CharacterLimit.botCharLimit
        if isConversationAssignedToDialogflowBot && textCount >= botLimit.soft && textCount <= messageLimit.soft {
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
