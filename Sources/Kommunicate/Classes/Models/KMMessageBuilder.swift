//
//  KMMessageBuilder.swift
//  Kommunicate
//
//  Created by Mukesh on 22/10/20.
//

import Foundation
import ApplozicCore

public class KMMessage: NSObject {
    public var conversationId : String = ""
    public var text: String = ""
    public var metadata: [String : Any]?
}

public class KMMessageBuilder : NSObject {
    private var message = KMMessage()

    @discardableResult
    @objc public func withConversationId(_ conversationId: String) ->  KMMessageBuilder {
        message.conversationId = conversationId
        return self
    }

    @discardableResult
    @objc public func withText(_ text: String) ->  KMMessageBuilder {
        message.text = text
        return self
    }

    @discardableResult
    @objc public func withMetadata(_ metadata: [String: Any]) ->  KMMessageBuilder {
        message.metadata = metadata
        return self
    }

    @objc public func build() ->  KMMessage {
        return message
    }
}


extension KMMessage {
    func toALMessage() -> ALMessage {
        let alMessage = ALMessage()
        alMessage.to = nil
        alMessage.contactIds = nil
        alMessage.message = text
        alMessage.type = AL_OUT_BOX
        let date = Date().timeIntervalSince1970*1000
        alMessage.createdAtTime = NSNumber(value: date)
        alMessage.sendToDevice = false
        alMessage.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        alMessage.shared = false
        alMessage.fileMeta = nil
        alMessage.storeOnDevice = false
        alMessage.contentType = Int16(ALMESSAGE_CONTENT_DEFAULT)
        alMessage.key = UUID().uuidString
        alMessage.source = Int16(AL_SOURCE_IOS)
        alMessage.conversationId = nil
        alMessage.groupId = nil
        return alMessage
    }
}
