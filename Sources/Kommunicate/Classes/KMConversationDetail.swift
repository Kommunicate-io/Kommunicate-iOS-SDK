//
//  KMConversationDetail.swift
//  Pods
//
//  Created by Mukesh Thawani on 26/02/18.
//

import Foundation
import ApplozicCore

public protocol KMConversationDetailType {
    var groupId: Int {get}
    var user: String {get set}
    var agent: String {get set}
    var applicationKey: String {get}
    var createdBy: String {get}
}

/// Contains details of a conversation need to passed
open class KMConversationDetail: KMConversationDetailType, Encodable {

    public let groupId: Int
    public var user: String
    public var agent: String
    public var applicationKey: String
    public var createdBy: String

    public init(groupId: Int,
                user: String,
                agent: String,
                applicationKey: String,
                createdBy: String
                ) {
        self.groupId = groupId
        self.user = user
        self.agent = agent
        self.applicationKey = applicationKey
        self.createdBy = createdBy
    }

    enum CodingKeys: String, CodingKey {
        case groupId = "groupId"
        case user = "participantUserId"
        case agent = "defaultAgentId"
        case applicationKey = "applicationKey"
        case createdBy = "createdBy"
    }
}

public protocol KMGroupUserType {
    var id: String {get}
    var role: KMGroupUser.RoleType {get}
}

public class KMGroupUser: ALGroupUser, KMGroupUserType, Encodable {

    public enum RoleType: Int {
        case agent = 1
        case bot = 2
        case user = 3
    }

    public var id: String {
        return userId ?? ""
    }

    public var role: RoleType {
        return RoleType(
            rawValue: (groupRole as? Int) ?? RoleType.user.rawValue) ?? .user
    }

    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case role = "groupRole"
    }

    public convenience init(groupRole: RoleType, userId: String) {
        self.init()
        self.groupRole = groupRole.rawValue as NSNumber
        self.userId = userId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(role.rawValue, forKey: .role)
    }

    public func toDict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict[CodingKeys.id.rawValue] = self.id
        dict[CodingKeys.role.rawValue] = self.role.rawValue
        return dict
    }
}
