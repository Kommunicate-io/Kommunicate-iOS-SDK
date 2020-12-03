//
//  KMConversationService+ConversationFeedback.swift
//  Kommunicate
//
//  Created by Mukesh on 30/12/19.
//

import Foundation

extension KMConversationService {

    private enum FeedbackParamKey {
        static let groupId = "groupId"
        static let comment = "comments"
        static let rating = "rating"
        static let applicationId = "applicationId"
        static let assigneeId = "supportAgentName"
        static let userName = "name"
        static let userId = "userId"
        static let userInfo = "userInfo"
    }

    /// Fetches conversation feedback for the given group id.
    /// - Parameters:
    ///   - groupId: Group id for which feedback has to be fetched.
    ///   - completion: A Result of type `ConversationFeedback`.
    func feedbackFor(
        groupId: Int,
        completion: @escaping (Result<ConversationFeedback, FeedbackError>)->()
    ) {
        guard let url = URLBuilder.feedbackURLFor(groupId: String(describing: groupId)).url else {
            completion(.failure(.api(.urlBuilding)))
            return
        }
        DataLoader.request(url: url) {
            result in
            switch result {
            case .success(let data):
                guard let feedbackResponse = try? ConversationFeedbackResponse(data: data) else {
                    completion(.failure(.api(.jsonConversion)))
                    return
                }
                print(feedbackResponse)
                do {
                    let feedback = try feedbackResponse.conversationFeedback()
                    completion(.success(feedback))
                } catch let error as FeedbackError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.notFound))
                }
            case .failure(let error):
                completion(.failure(.api(.network(error))))
            }
        }
    }

    /// Submits conversation feedback for the given group id.
    /// - Parameters:
    ///   - groupId: Group id for which feedback has to be submitted.
    ///   - feedback: Feedback that should be submitted.
    ///   - completion: A Result of type `ConversationFeedback`.
    func submitFeedback(
        groupId: Int,
        feedback: Feedback,
        userId: String,
        userName: String,
        assigneeId: String,
        applicationId: String,
        completion: @escaping (Result<ConversationFeedback, FeedbackError>)->()
    ) {
        guard let url = URLBuilder.feedbackURLForSubmission().url else {
            completion(.failure(.api(.urlBuilding)))
            return
        }
        let userInfo: [String: Any] = [
            FeedbackParamKey.userName: userName,
            FeedbackParamKey.userId: userId
        ]
        var params: [String: Any] = [
            FeedbackParamKey.groupId: groupId,
            FeedbackParamKey.rating: feedback.rating.rawValue,
            FeedbackParamKey.applicationId: applicationId,
            FeedbackParamKey.assigneeId: assigneeId,
            FeedbackParamKey.userInfo: userInfo
        ]
        if let comment = feedback.comment, !comment.isEmpty {
            params[FeedbackParamKey.comment] = [comment]
        }
        DataLoader.postRequest(url: url, params: params) { result in
            switch result {
            case .success(let data):
                guard let feedbackResponse =
                    try? ConversationFeedbackSubmissionResponse(data: data) else {
                        completion(.failure(.api(.jsonConversion)))
                        return
                }
                do {
                    let feedback = try feedbackResponse.conversationFeedback()
                    completion(.success(feedback))
                } catch let error as FeedbackError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.notFound))
                }
            case .failure(let error):
                completion(.failure(.api(.network(error))))
            }
        }
    }
}
