//
//  KMConfiguration.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 20/08/19.
//

import Foundation
import ApplozicSwift

extension ALKConfiguration {
    public var hideFaqButtonInConversationView: Bool {
        set {
            guard newValue else { return }
            navigationItemsForConversationView = []
        }
        get {
            /// Return value doesn't matter
            return true
        }
    }

    public var hideFaqButtonInConversationList: Bool {
        set {
            guard newValue else { return }
            let icon =  UIImage(named: "fill_214", in:  Bundle(for: ALKConversationListViewController.self), compatibleWith: nil)!
            let createButton = ALKNavigationItem(identifier: conversationCreateIdentifier, icon: icon)
            navigationItemsForConversationList = [createButton]
        }
        get {
            /// Return value doesn't matter
            return true
        }
    }

    public var hideStartConversationButton: Bool {
        set {
            guard newValue else { return }
            let faqItem = ALKNavigationItem(identifier: faqIdentifier, text:  NSLocalizedString("FaqTitle", value: "FAQ", comment: ""))
            navigationItemsForConversationList = [faqItem]
        }
        get {
            /// Return value doesn't matter
            return true
        }
    }
}
