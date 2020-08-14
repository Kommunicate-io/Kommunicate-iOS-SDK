//
//  KMAppUserDefaultHandler.swift
//  Kommunicate
//
//  Created by Sunil on 14/08/20.
//

import Foundation
/// `KMAppUserDefaultHandler` will have user defaults to kommunicate sdk
class KMAppUserDefaultHandler : NSObject {
    static let DEFAULT_SUITE_NAME =  "group.kommunicate.sdk"

    static var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: DEFAULT_SUITE_NAME)
    }

    static func setBotType(_ botType: String, botId: String) {
        KMAppUserDefaultHandler.sharedUserDefaults?.setValue(botType, forKey: botId)
    }

    static func getBotType(botId: String) -> String? {
        return KMAppUserDefaultHandler.sharedUserDefaults?.value(forKey: botId) as? String
    }

    static func clear() {
        let userDefaults = KMAppUserDefaultHandler.sharedUserDefaults
        userDefaults?.removePersistentDomain(forName: KMAppUserDefaultHandler.DEFAULT_SUITE_NAME)
    }
}
