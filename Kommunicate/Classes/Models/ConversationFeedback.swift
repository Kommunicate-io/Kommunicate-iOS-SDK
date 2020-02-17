//
//  ConversationFeedback.swift
//  Kommunicate
//
//  Created by Mukesh on 30/12/19.
//

import Foundation

// MARK: - FeedbackResponse
protocol FeedbackResponse {
    var code: String { get }
    var data: ConversationFeedback? { get }

    func conversationFeedback() throws -> ConversationFeedback
}

// MARK: - ConversationFeedbackResponse
struct ConversationFeedbackResponse: Decodable, FeedbackResponse {
    let code: String
    let data: ConversationFeedback?
}

// MARK: - ConversationFeedbackSubmissionResponse
struct ConversationFeedbackSubmissionResponse: FeedbackResponse {
    let code: String
    let data: ConversationFeedback?

    enum CodingKeys: String, CodingKey {
        case code
        case data
    }

    enum FeedbackResponseKeys: String, CodingKey {
        case data
    }
}

// MARK: - ConversationFeedback
struct ConversationFeedback: Decodable {
    let id, groupID: Int
    let comments: [String]?
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

extension ConversationFeedbackSubmissionResponse: Decodable {
    init(data: Data) throws {
        self = try JSONDecoder().decode(ConversationFeedbackSubmissionResponse.self, from: data)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
        let feedbackResponse = try values.nestedContainer(
            keyedBy: FeedbackResponseKeys.self,
            forKey: .data
        )
        data = try feedbackResponse.decode(ConversationFeedback.self, forKey: .data)
    }
}

extension FeedbackResponse {
    func conversationFeedback() throws -> ConversationFeedback {
        guard code == "SUCCESS" else {
            throw FeedbackError.invalidCodeValue
        }
        guard let feedback = data else {
            throw FeedbackError.notFound
        }
        return feedback
    }
}