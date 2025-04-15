//
//  URLBuilder+BusinessHours.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 17/03/25.
//

import Foundation

extension URLBuilder {
    static func businessHourURLFor() -> URLBuilder {
        let url = URLBuilder.chatApi.add(paths: ["rest", "ws", "team", "business-settings"])
        return url
    }
}
