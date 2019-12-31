//
//  ConversationFeedback.swift
//  Kommunicate
//
//  Created by Mukesh on 30/12/19.
//

import Foundation

// MARK: - ConversationFeedbackResponse
struct ConversationFeedbackResponse: Codable {
    let code: String
    let data: ConversationFeedback?
}

// MARK: - ConversationFeedback
struct ConversationFeedback: Codable {
    let id, groupID: Int
    let comments: String?
    let rating: Int
    let type, supportAgentID: Int?
    let userInfo: String?
    let createdAt, updatedAt: String
    let deleteAt: String?
    let dataCreatedAt, dataUpdatedAt: String
    let userID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case groupID = "groupId"
        case comments, rating, type
        case supportAgentID = "supportAgentId"
        case userInfo, createdAt, updatedAt, deleteAt
        case dataCreatedAt = "created_at"
        case dataUpdatedAt = "updated_at"
        case userID = "user_id"
    }
}

enum FeedbackError: LocalizedError {
    case invalidCodeValue // Value of key "code" is not equal to "SUCCESS"
    case notFound // Conversation feedback not found
    case api(_ error: APIError)
}

extension ConversationFeedbackResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(ConversationFeedbackResponse.self, from: data)
    }
}
