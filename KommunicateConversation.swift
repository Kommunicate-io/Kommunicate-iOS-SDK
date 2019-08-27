//
//  KommunicateConversation.swift
//  Kommunicate
//
//  Created by apple on 22/08/19.
//

import Foundation
import Applozic

@objc public class KommunicateConversation : NSObject {

    var userId : String = ALUserDefaultsHandler.getUserId()
    var agentIds : [String] = []
    var clientConversationId : String?
    var botIds: [String]?
    var skipRouting: Bool = false
    var isSingleConversation: Bool = true
    var useOriginalTitle: Bool = false
    var conversationAssignee : String?
    var conversationTitle : String?
    var conversationMetadata =  [AnyHashable : Any]()
}

/// KommunicateConversationBuilder is used for building KommunicateConversation object
open class KommunicateConversationBuilder {

    private  var conversation = KommunicateConversation()

    @discardableResult
    public func withClientConversationId(_ clientConversationId:String?) ->  KommunicateConversationBuilder {
        conversation.clientConversationId = clientConversationId
        return self
    }

    @discardableResult
    public func withAgentIds(_ agentIds: [String]) ->  KommunicateConversationBuilder {
        conversation.agentIds = agentIds
        return self
    }

    @discardableResult
    public func withBotIds(_ botIds: [String]?) ->  KommunicateConversationBuilder {
        conversation.botIds = botIds
        return self
    }

    @discardableResult
    public func skipRouting(_ skipRouting: Bool) ->  KommunicateConversationBuilder {
        conversation.skipRouting = skipRouting
        return self
    }

    @discardableResult
    public  func useLastConversation(_ isSingleConversation: Bool) ->  KommunicateConversationBuilder {
        conversation.isSingleConversation = isSingleConversation
        return self
    }

    @discardableResult
    public  func assignConversationTo(_ conversationAssignee: String) ->  KommunicateConversationBuilder {
        conversation.conversationAssignee = conversationAssignee
        return self
    }

    @discardableResult
    public func withConversationTitle(_ conversationTitle: String) ->  KommunicateConversationBuilder {
        conversation.conversationTitle = conversationTitle
        return self
    }
    
    @discardableResult
    public func withMetaData(_ conversationMetadata: [AnyHashable : Any]) ->  KommunicateConversationBuilder {
        conversation.conversationMetadata = conversationMetadata
        return self
    }

    @discardableResult
    public  func build() ->  KommunicateConversation {
        return conversation
    }

    public init() {

    }

}


