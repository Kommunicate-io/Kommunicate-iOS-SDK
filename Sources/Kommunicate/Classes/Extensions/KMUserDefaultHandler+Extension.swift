//
//  KMUserDefaultHandler+Extension.swift
//  Kommunicate
//
//  Created by Mukesh on 21/02/20.
//

import Foundation

extension KMUserDefaultHandler {
    static var isAppIdEmpty: Bool {
        guard let currentAppId = KMUserDefaultHandler.getApplicationKey() else { return true }
        return currentAppId.isEmpty
    }

    static var matchesCurrentAppId: (String) -> Bool = {
        guard let currentAppId = KMUserDefaultHandler.getApplicationKey() else { return false }
        return currentAppId == $0
    }
}
