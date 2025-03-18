//
//  KmURLConstants.swift
//  Kommunicate
//
//  Created by Sunil on 22/11/19.
//

import Foundation

struct API {
    enum Backend: String {
        case chat = "https://chat.kommunicate.io"
        case chatEu = "https://chat-eu.kommunicate.io"
        case kommunicateApi = "https://api.kommunicate.io"
        case kommunicateApiEu = "https://api-eu.kommunicate.io"
        var url: URL {
            return URL(string: rawValue)!
        }
    }
}
