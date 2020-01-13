//
//  URLBuilder+ConversationFeedback.swift
//  Kommunicate
//
//  Created by Mukesh on 30/12/19.
//

import Foundation

extension URLBuilder {
    static func feedbackURLFor(groupId: String) -> URLBuilder {
        let url = URLBuilder.kommunicateApi.add(paths: ["feedback", groupId])
        return url
    }

    static func feedbackURLForSubmission() -> URLBuilder {
        let url = URLBuilder.kommunicateApi.add(path: "feedback")
        return url
    }
}
