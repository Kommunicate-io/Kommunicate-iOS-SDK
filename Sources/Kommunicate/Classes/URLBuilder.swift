//
//  URLBuilder.swift
//  Kommunicate
//
//  Created by Mukesh on 15/01/19.
//

import Foundation
import ApplozicCore

final class URLBuilder {

    private var components = URLComponents()
    private var pathComponents = [String]()

    static var kommunicateApi: URLBuilder {
        return URLBuilder(host: "api.kommunicate.io")
    }

    static var chatApi: URLBuilder {
        guard let baseURL = URL(string: ALUserDefaultsHandler.getBASEURL()),
              let host = baseURL.host else {
            return URLBuilder(host: "")
        }
        return URLBuilder(host: host)
    }

    static var helpcenterApi: URLBuilder {
        guard let baseUrl = ALUserDefaultsHandler.getBASEURL() else {
            return URLBuilder(host: "helpcenter.kommunicate.io")
        }
        if baseUrl.contains("-ca") {
            return URLBuilder(host: "helpcenter-ca.kommunicate.io")
        } else if baseUrl.contains("-test") {
            return URLBuilder(host: "helpcenter-test.kommunicate.io")
        }
        return URLBuilder(host: "helpcenter.kommunicate.io")
    }

    var url: URL? {
        var components = self.components
        if !pathComponents.isEmpty {
            components.path = "/" + pathComponents.joined(separator: "/")
        }
        return components.url
    }

    init(host: String, scheme: String = "https") {
        components.host = host
        components.scheme = scheme
    }

    @discardableResult
    func add(path: LosslessStringConvertible) -> URLBuilder {
        pathComponents.append(String(describing: path))
        return self
    }

    @discardableResult
    func add(paths: [LosslessStringConvertible]) -> URLBuilder {
        paths.forEach { add(path: $0)}
        return self
    }

    @discardableResult
    func add(item: String, value: LosslessStringConvertible) -> URLBuilder {
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: item, value: String(describing: value)))
        components.queryItems = items
        return self
    }
}

extension URLBuilder {

    /// Bot Detail url builder
    static func botDetail(for applicationKey: String, botId: String) -> URLBuilder {
        return URLBuilder.kommunicateApi.add(paths: ["rest", "ws", "botdetails", botId])
    }
}

