//
//  URLBuilder.swift
//  Kommunicate
//
//  Created by Mukesh on 15/01/19.
//

import Foundation

final class URLBuilder {

    private var components = URLComponents()
    private var pathComponents = [String]()

    static var kommunicateApi: URLBuilder {
        return URLBuilder(host: "api.kommunicate.io")
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
