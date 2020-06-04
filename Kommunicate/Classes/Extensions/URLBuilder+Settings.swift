//
//  URLBuilder+AppTheme.swift
//  Kommunicate
//
//  Created by apple on 13/04/20.
//

import Foundation

extension URLBuilder {
    static func appSettings(for applicationKey: String) -> URLBuilder {
        let url = URLBuilder.kommunicateApi.add(paths: ["users", "v2","chat", "plugin", "settings"])
        return url.add(item: "appId", value: applicationKey)
    }
}
