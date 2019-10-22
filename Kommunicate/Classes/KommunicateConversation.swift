//
//  KommunicateConversation.swift
//  Kommunicate
//
//  Created by apple on 22/08/19.
//

import Foundation
import Applozic

/// KommunicateConversation is used for creating conversation
@objc public class KommunicateConversation : NSObject {

    var userId : String = ALUserDefaultsHandler.getUserId() ?? Kommunicate.randomId()
    var agentIds : [String] = []
    var clientConversationId : String?
    var botIds: [String]?
    var skipRouting: Bool = false
    var useLastConversation: Bool = false
    var useOriginalTitle: Bool = false
    var conversationTitle : String?
    var conversationMetadata =  [AnyHashable : Any]()
}

/// KommunicateConversationBuilder is used for building KommunicateConversation object
open class KommunicateConversationBuilder {

    private var conversation = KommunicateConversation()

    /// If you want to associate this conversation with a unique ID, then pass clientConversationId. If you pass clientConversationId then useLastConversation needs to be false.
    /// - Parameter clientConversationId: Pass your clientConversationId, If you want to create conversation with your own clientConversationId
    @discardableResult
    public func withClientConversationId(_ clientConversationId:String?) ->  KommunicateConversationBuilder {
        conversation.clientConversationId = clientConversationId
        return self
    }

    /// If you have want to add agents in converastion and if you have agentIds then pass.
    /// - Parameter agentIds: Pass agentIds, if you any  agentIds
    @discardableResult
    public func withAgentIds(_ agentIds: [String]) ->  KommunicateConversationBuilder {
        conversation.agentIds = agentIds
        return self
    }

    /// If you have bot ids that you  want to be in  a converastion then you can  set your withBotIds.
    /// - Parameter botIds: Pass botIds, If you have want to add the bots in conversations
    @discardableResult
    public func withBotIds(_ botIds: [String]?) ->  KommunicateConversationBuilder {
        conversation.botIds = botIds
        return self
    }

    /// If you pass this value true then it will skip routing rules set from conversation rules section in kommunicate dashboard.
    /// - Parameter skipRouting: By default it will be false, If you want skip routing then pass  true.
    @discardableResult
    public func skipRouting(_ skipRouting: Bool) ->  KommunicateConversationBuilder {
        conversation.skipRouting = skipRouting
        return self
    }

    /// If you pass useLastConversation as false, then a new conversation will be created everytime. If you pass useLastConversation as true, then it will use old conversation which is already created with this data.
    /// - Parameter useLastConversation: Pass  useLastConversation
    ///     @discardableResult
    public func useLastConversation(_ useLastConversation: Bool) ->  KommunicateConversationBuilder {
        conversation.useLastConversation = useLastConversation
        return self
    }

    /// If you want to show  the custom conversation title in chat screen then pass your title in withConversationTitle
    /// - Parameter conversationTitle: Pass custom conversation Title
    @discardableResult
    public func withConversationTitle(_ conversationTitle: String) ->  KommunicateConversationBuilder {
        conversation.conversationTitle = conversationTitle
        return self
    }

    /// If you want to pass extra data in the conversation then use the withMetaData to set the information
    /// - Parameter conversationMetadata: Pass  conversationMetadata
    @discardableResult
    public func withMetaData(_ conversationMetadata: [AnyHashable : Any]) ->  KommunicateConversationBuilder {
        conversation.conversationMetadata = conversationMetadata
        return self
    }

    /// Optional, If conversationTitle is set then by deafult isUseOriginalTitle will be true.
    /// - Parameter isUseOriginalTitle: isUseOriginalTitle description
    @discardableResult
    public func useOriginalTitle(_ isUseOriginalTitle: Bool) ->  KommunicateConversationBuilder {
        conversation.useOriginalTitle = isUseOriginalTitle
        return self
    }

    /// Finally call the build method on the KommunicateConversationBuilder to build the KommunicateConversation
    @discardableResult
    public  func build() ->  KommunicateConversation {
        return conversation
    }

    public init() {

    }
}


