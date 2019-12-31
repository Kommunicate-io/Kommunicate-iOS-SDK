//
//  KMConversationService+ConversationFeedback.swift
//  Kommunicate
//
//  Created by Mukesh on 30/12/19.
//

import Foundation

extension KMConversationService {
    /**
     Fetches conversation feedback for the given group id.

     - Parameters:
     - groupId: Group id for which feedback has to be fetched.

     - Returns: A Result of type `ConversationFeedback`.

     **/
    func feedbackFor(
        groupId: Int,
        completion: @escaping (Result<ConversationFeedback, FeedbackError>)->()) {

        // Set up the URL request
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
}

extension ConversationFeedbackResponse {
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
