//
//  URLBuilder+AwayMessage.swift
//  Kommunicate
//
//  Created by Mukesh on 16/01/19.
//

import Foundation


extension URLBuilder {
    static func awayMessageURLFor(applicationKey: String, groupId: String) -> URLBuilder {
        let url = URLBuilder.kommunicateApi.add(paths: ["applications", applicationKey, "awaymessage"])
        url.add(item: "conversationId", value: groupId)
        return url
    }
}
