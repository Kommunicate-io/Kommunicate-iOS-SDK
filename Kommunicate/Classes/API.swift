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
        var url: URL {
            return URL(string: self.rawValue)!
        }
    }
}

