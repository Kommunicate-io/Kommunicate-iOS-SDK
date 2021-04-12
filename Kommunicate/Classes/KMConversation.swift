//
//  KMConversation.swift
//  Kommunicate
//
//  Created by apple on 22/08/19.
//

import Foundation
import ApplozicCore

/// KMConversation is used for creating conversation
@objc public class KMConversation : NSObject {

    let userId : String
    public var agentIds : [String] = []
    public var clientConversationId : String?
    public var botIds: [String]?
    public var skipRouting: Bool = false
    public var useLastConversation: Bool = false
    public var useOriginalTitle: Bool = false
    public var conversationTitle : String?
    public var conversationMetadata =  [AnyHashable : Any]()
    public var conversationAssignee : String?
    public var teamId: String?

    public init(userId: String){
        self.userId = userId
    }

}

/// KMConversationBuilder is used for building KMConversation object
@objc public class KMConversationBuilder : NSObject {

    private var conversation = KMConversation(userId: KMUserDefaultHandler.getUserId() ?? Kommunicate.randomId())

    /// If you want to associate this conversation with a unique ID, then pass clientConversationId. If you pass clientConversationId then useLastConversation needs to be false.
    /// - Parameter clientConversationId: Pass your clientConversationId, If you want to create conversation with your own clientConversationId
    @discardableResult
    @objc public func withClientConversationId(_ clientConversationId:String?) ->  KMConversationBuilder {
        conversation.clientConversationId = clientConversationId
        return self
    }

    /// If you have want to add agents in converastion and if you have agentIds then pass.
    /// - Parameter agentIds: Pass agentIds, if you any  agentIds
    @discardableResult
    @objc public func withAgentIds(_ agentIds: [String]) ->  KMConversationBuilder {
        conversation.agentIds = agentIds
        return self
    }

    /// If you have bot ids that you  want to be in  a converastion then you can  set your withBotIds.
    /// - Parameter botIds: Pass botIds, If you have want to add the bots in conversations
    @discardableResult
    @objc public func withBotIds(_ botIds: [String]) ->  KMConversationBuilder {
        conversation.botIds = botIds
        return self
    }

    /// If you pass this value true then it will skip routing rules set from conversation rules section in kommunicate dashboard.
    /// - Parameter skipRouting: By default it will be false, If you want skip routing then pass  true.
    @discardableResult
    @objc public func skipRouting(_ skipRouting: Bool) ->  KMConversationBuilder {
        conversation.skipRouting = skipRouting
        return self
    }

    /// If you pass useLastConversation as false, then a new conversation will be created everytime. If you pass useLastConversation as true, then it will use old conversation which is already created with this data.
    /// - Parameter useLastConversation: Pass  useLastConversation
    @discardableResult
    @objc public func useLastConversation(_ useLastConversation: Bool) ->  KMConversationBuilder {
        conversation.useLastConversation = useLastConversation
        return self
    }

    /// If you want to show  the custom conversation title in chat screen then pass your title in withConversationTitle
    /// - Parameter conversationTitle: Pass custom conversation Title
    @discardableResult
    @objc public func withConversationTitle(_ conversationTitle: String) ->  KMConversationBuilder {
        conversation.conversationTitle = conversationTitle
        return self
    }

    /// If you want to pass extra data in the conversation then use the withMetaData to set the information
    /// - Parameter conversationMetadata: Pass  conversationMetadata
    @discardableResult
    @objc public func withMetaData(_ conversationMetadata: [AnyHashable : Any]) ->  KMConversationBuilder {
        conversation.conversationMetadata = conversationMetadata
        return self
    }

    /// If conversationTitle is set then by default isUseOriginalTitle will be true.
    /// - Parameter isUseOriginalTitle: isUseOriginalTitle 
    @discardableResult
    @objc public func useOriginalTitle(_ isUseOriginalTitle: Bool) ->  KMConversationBuilder {
        conversation.useOriginalTitle = isUseOriginalTitle
        return self
    }

    /// To set the conversation assignee, pass Agent ID or Bot Id.
    /// - Parameter conversationAssignee: Pass AgentId or botId
    @discardableResult
    @objc public func withConversationAssignee(_ conversationAssignee: String) -> KMConversationBuilder {
        conversation.conversationAssignee = conversationAssignee
        return self
    }

    /// To assign the conversation to a team, pass a team Id.
    /// - Parameter teamId: Pass a team ID
    @discardableResult
    @objc public func withTeamId(_ teamId: String) -> KMConversationBuilder {
        conversation.teamId = teamId
        return self
    }

    /// Finally call the build method on the KMConversationBuilder to build the KMConversation
    @objc public func build() ->  KMConversation {
        return conversation
    }

}


