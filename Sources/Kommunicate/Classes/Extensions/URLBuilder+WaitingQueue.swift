//
//  URLBuilder+WaitingQueue.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 20/01/25.
//

import Foundation

extension URLBuilder {
    static func waitingQueueFor(teamID: String) -> URLBuilder {
        let url = URLBuilder.chatApi.add(paths: ["rest", "ws", "group", "waiting", "list"])
        url.add(item: "teamId", value: teamID)
        return url
    }
}
