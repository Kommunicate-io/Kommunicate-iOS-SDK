//
//  BotCharLimitManager.swift
//  Kommunicate
//
//  Created by Sunil on 13/08/20.
//

// MARK: BotCharLimitDelegate
protocol BotCharLimitDelegate: AnyObject {
    func didBotCharacterLimitViewHide(_ isHidden: Bool)
}

import Foundation
import ApplozicSwift

class BotCharLimitManager: NSObject {

    // MARK: - Internal properties
    var isConversationAssignedToDialogflowBot = false
    enum CharacterLimit {
        static let hardLimit = 256
        static let softLimit = 55
    }
    let chatBar: ALKChatBar
    let botCharLimitView: BotCharacterLimitView
    static let charLimitForBotViewHeight = 80.0
    weak var delegate: BotCharLimitDelegate?
    
    // MARK: - Internal Initialization

    init(chatBar: ALKChatBar,
         botCharLimitView: BotCharacterLimitView) {
        self.chatBar = chatBar
        self.botCharLimitView = botCharLimitView
        super.init()
        chatBar.addTextView(delegate: self)
    }

    // MARK: - Internal methods

    /// This method will check the character limit.
    /// - Parameter text: Entred text in text view
    func checkCharLimit(_ text: String) {
        if text.isEmpty {
            chatBar.disableSendButton(isSendButtonDisabled: false)
            self.botCharLimitView.isHidden = true
            botCharLimitViewHeight(hide: true)
            return
        }

        let warningCount = CharacterLimit.hardLimit - CharacterLimit.softLimit
        let showWarning = text.count >= warningCount

        let extraCharacters = text.count - CharacterLimit.hardLimit

        let limitExceeded = extraCharacters > 0
        if  showWarning || limitExceeded {
            let botCharLimitText = BotCharacterLimitView.LocalizedText.botCharLimit
            var charInfoText = ""
            if (limitExceeded) {
                let removeCharMessage = BotCharacterLimitView.LocalizedText.removeCharMessage
                charInfoText =  String(format: removeCharMessage, extraCharacters)
            } else {
                let remainingCharMessage = BotCharacterLimitView.LocalizedText.remainingCharMessage
                charInfoText =  String(format: remainingCharMessage, -extraCharacters)
            }
            chatBar.disableSendButton(isSendButtonDisabled: limitExceeded)
            let botLimitmessage = String(format: botCharLimitText, CharacterLimit.hardLimit, charInfoText)
            botCharLimitView.set(message: botLimitmessage)
            self.botCharLimitView.isHidden = false
            botCharLimitViewHeight(hide: false)
        } else {
            chatBar.disableSendButton(isSendButtonDisabled: false)
            self.botCharLimitView.isHidden = true
            botCharLimitViewHeight(hide: true)
        }
    }

    func showDialogFlowBotView(_ isDialogflowBot: Bool) {
        if isDialogflowBot {
            self.checkCharLimit(chatBar.textView.text)
        } else {
            self.botCharLimitViewHeight(hide: true)
            self.chatBar.disableSendButton(isSendButtonDisabled: false)
        }
    }

    func hideBotView(_ hide: Bool) {
        botCharLimitView.constraint(withIdentifier: BotCharacterLimitView.ConstraintIdentifier.botCharacterLimitViewHeight.rawValue)?.constant = CGFloat(hide ?  0 : BotCharLimitManager.charLimitForBotViewHeight)
        botCharLimitView.hideView(hide: hide)
    }

    // MARK: - Private helper methods
    private func botCharLimitViewHeight(hide: Bool) {
        self.hideBotView(hide)
        delegate?.didBotCharacterLimitViewHide(hide)
    }
}

extension BotCharLimitManager: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        guard self.isConversationAssignedToDialogflowBot else {
            return
        }
        checkCharLimit(textView.text)
    }
}
