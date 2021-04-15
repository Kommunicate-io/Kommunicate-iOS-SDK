//
//  MessageCharacterLimitManager.swift
//  Kommunicate
//
//  Created by Sunil on 13/08/20.
//

import Foundation
import ApplozicSwift
import UIKit

// MARK: MessageCharacterLimitDelegate
protocol MessageCharacterLimitDelegate: AnyObject {
    func characterLimit(manager: MessageCharacterLimitManager, _ isHidden: Bool)
    func characterLimit(manager: MessageCharacterLimitManager, reachedTheLimit limit: Int, textCount: Int)
}

class MessageCharacterLimitManager: NSObject {

    // MARK: - Internal properties
    static let charLimitViewHeight = 80.0
    weak var delegate: MessageCharacterLimitDelegate?
    var messageToShow: String = ""
    var isCharLimitCheckEnabled = true

    private let chatBar: ALKChatBar
    private let charLimitView: MessageCharacterLimitView
    private let limit: Int
    
    // MARK: - Internal Initialization

    init(chatBar: ALKChatBar,
         charLimitView: MessageCharacterLimitView,
         limit: Int
    ) {
        self.chatBar = chatBar
        self.charLimitView = charLimitView
        self.limit = limit
        super.init()
        chatBar.addTextView(delegate: self)
    }

    // MARK: - Internal methods

    /// This method will check the character limit.
    /// - Parameter text: Entered text in the text view
    func checkCharLimit(_ text: String) {
        guard isCharLimitCheckEnabled else { return }
        let extraCharacters = text.count - limit
        let limitExceeded = extraCharacters > 0
        guard !text.isEmpty && limitExceeded else {
            showLimitView(false)
            return
        }
        delegate?.characterLimit(manager: self, reachedTheLimit: limit, textCount: text.count)
    }

    func showLimitView(_ show: Bool, disableButton: Bool = true) {
        chatBar.disableSendButton(isSendButtonDisabled: show && disableButton)
        charLimitView.set(message: show ? messageToShow:"")
        self.charLimitView.isHidden = !show
        charLimitViewHeight(hide: !show)
    }

    private func hideCharLimitView(_ hide: Bool) {
        charLimitView.constraint(withIdentifier: MessageCharacterLimitView.ConstraintIdentifier.messageCharacterLimitViewHeight.rawValue)?.constant = CGFloat(hide ?  0 : MessageCharacterLimitManager.charLimitViewHeight)
        charLimitView.hideView(hide: hide)
    }

    // MARK: - Private helper methods
    private func charLimitViewHeight(hide: Bool) {
        self.hideCharLimitView(hide)
        delegate?.characterLimit(manager: self, hide)
    }
}

extension MessageCharacterLimitManager: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        checkCharLimit(textView.text)
    }
}
