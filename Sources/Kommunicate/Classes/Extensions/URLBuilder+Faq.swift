//
//  URLBuilder+Faq.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 07/05/19.
//

import Foundation

extension URLBuilder {
    static func faqURL(for applicationKey: String) -> URLBuilder {
        return URLBuilder.helpcenterApi.add(item: "appId", value: applicationKey)
    }
}
