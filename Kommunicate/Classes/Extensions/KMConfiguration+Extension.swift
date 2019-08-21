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
            navigationItemsForConversationView.removeAll(where: { $0.identifier == faqIdentifier })
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
            navigationItemsForConversationList.removeAll(where: { $0.identifier == faqIdentifier })
        }
        get {
            /// Return value doesn't matter
            return true
        }
    }

    public var hideStartConversationButton: Bool {
        set {
            guard newValue else { return }
            navigationItemsForConversationList.removeAll(where: { $0.identifier == conversationCreateIdentifier })
        }
        get {
            /// Return value doesn't matter
            return true
        }
    }
}
