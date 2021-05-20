//
//  URLBuilder+Assignment.swift
//  Kommunicate
//
//  Created by Mukesh on 08/04/21.
//

import Foundation

extension URLBuilder {
    static func assigneeChangeURL(groupId: Int, assigneeUserId assignee: String) -> URLBuilder {
        let url = URLBuilder.chatApi
            .add(paths: ["rest", "ws", "group", "assignee", "change"])
            .add(item: "groupId", value: groupId)
            .add(item: "assignee", value: assignee)
            .add(item: "switchAssignee", value: true)
            .add(item: "takeOverFromBot", value: true)
        return url
    }
}
