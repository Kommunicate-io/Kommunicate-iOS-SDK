//
//  KMAppUserDefaultHandler.swift
//  Kommunicate
//
//  Created by Sunil on 14/08/20.
//

import Foundation
/// `KMAppUserDefaultHandler` will have all the user defaults related to kommunicate sdk
class KMAppUserDefaultHandler: NSObject {
    static let DEFAULT_SUITE_NAME = "group.kommunicate.sdk"

    static let shared = KMAppUserDefaultHandler(
        userDefaultSuite: UserDefaults(suiteName: DEFAULT_SUITE_NAME) ?? .standard
    )

    var isCSATEnabled: Bool {
        set {
            userDefaultSuite.set(newValue, forKey: Key.CSATEnabled)
        }
        get {
            return userDefaultSuite.bool(forKey: Key.CSATEnabled)
        }
    }
    var botMessageDelayInterval: Int {
             set {
                 userDefaultSuite.set(newValue, forKey: Key.BotMessageDelayInterval)
             }
             get {
                 return userDefaultSuite.integer(forKey: Key.BotMessageDelayInterval)
             }
         }
    var csatRatingBase: Int {
        set {
            userDefaultSuite.set(newValue, forKey: Key.CSATRatingBase)
        }
        get {
            return userDefaultSuite.integer(forKey: Key.CSATRatingBase)
        }
    }

    private let userDefaultSuite: UserDefaults

    init(userDefaultSuite: UserDefaults) {
        self.userDefaultSuite = userDefaultSuite
    }

    func setBotType(_ botType: String, botId: String) {
        userDefaultSuite.setValue(botType, forKey: botId)
    }

    func getBotType(botId: String) -> String? {
        return userDefaultSuite.value(forKey: botId) as? String
    }

    func clear() {
        userDefaultSuite.removePersistentDomain(forName: KMAppUserDefaultHandler.DEFAULT_SUITE_NAME)
    }
}

private extension KMAppUserDefaultHandler {
    enum Key {
        static let CSATEnabled = "CSAT_ENABLED"
        static let BotMessageDelayInterval = "BOT_MESSAGE_DELAY_INTERVAL"
        static let CSATRatingBase = "CSAT_RATTING_BASE"
    }
}
