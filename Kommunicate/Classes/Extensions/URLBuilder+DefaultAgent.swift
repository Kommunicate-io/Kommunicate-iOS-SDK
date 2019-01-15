//
//  URLBuilder+DefaultAgent.swift
//  Kommunicate
//
//  Created by Mukesh on 16/01/19.
//

import Foundation


extension URLBuilder {
    static func agentsURLFor(applicationKey: String) -> URLBuilder {
        let url = URLBuilder.kommunicateApi.add(paths: ["users", "chat", "plugin", "settings"])
        url.add(item: "appId", value: applicationKey)
        return url
    }
}
