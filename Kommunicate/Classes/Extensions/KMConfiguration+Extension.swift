//
//  KMConfiguration.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 20/08/19.
//

import Foundation
import ApplozicSwift

extension ALKConfiguration {

    /// If true, faq button in conversation view will be hidden.
    public var hideFaqButtonInConversationView: Bool {
        set {
            guard newValue else { return }
            navigationItemsForConversationView.removeAll(where: { $0.identifier == faqIdentifier })
            navigationItemsForConversationView = []
        }
        get {
            return navigationItemsForConversationView.contains { $0.identifier == faqIdentifier }
        }
    }

    /// If true, faq button in conversation list will be hidden.
    public var hideFaqButtonInConversationList: Bool {
        set {
            guard newValue else { return }
            navigationItemsForConversationList.removeAll(where: { $0.identifier == faqIdentifier })
        }
        get {
            return navigationItemsForConversationList.contains { $0.identifier == faqIdentifier }
        }
    }

    /// If true, start conversation button in conversation list will be hidden.
    public var hideStartConversationButton: Bool {
        set {
            guard newValue else { return }
            navigationItemsForConversationList.removeAll(where: { $0.identifier == conversationCreateIdentifier })
        }
        get {
            return navigationItemsForConversationList.contains { $0.identifier == conversationCreateIdentifier }
        }
    }
}
