//
//  URLBuilder+WaitingQueue.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 20/01/25.
//

import Foundation

extension URLBuilder {
    /// Returns a URLBuilder configured to fetch the waiting queue list for a specific team.
    /// - Parameter teamID: The unique identifier of the team
    /// - Returns: A configured URLBuilder instance
    static func waitingQueueFor(teamID: String) -> URLBuilder {
        
        guard !teamID.isEmpty else {
            assertionFailure("teamID cannot be empty")
            return URLBuilder.chatApi
        }
        
        let url = URLBuilder.chatApi.add(paths: ["rest", "ws", "group", "waiting", "list"])
        url.add(item: "teamId", value: teamID)
        return url
    }
}
