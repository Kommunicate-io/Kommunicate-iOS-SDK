//
//  KMAppUserDefaultHandler.swift
//  Kommunicate
//
//  Created by Sunil on 14/08/20.
//

import Foundation
/// `KMAppUserDefaultHandler` will have all the user defaults related to kommunicate sdk
class KMAppUserDefaultHandler: NSObject {
    static let defaultSuiteName = "group.kommunicate.sdk"

    static let shared = KMAppUserDefaultHandler(
        userDefaultSuite: UserDefaults(suiteName: defaultSuiteName) ?? .standard
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
    var botTypingIndicatorInterval: Int {
        set {
            userDefaultSuite.set(newValue, forKey: Key.BotTypingIndicatorInterval)
        }
        get {
            return userDefaultSuite.integer(forKey: Key.BotTypingIndicatorInterval)
        }
    }
    
    var currentActivatedPlan: String {
        set {
            userDefaultSuite.set(newValue, forKey: Key.CurrentActivatedPlan)
        }
        get {
            return userDefaultSuite.string(forKey: Key.CurrentActivatedPlan) ?? "trial"
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
    
    func setDialogFlowBotType(_ botType: String, botId: String) {
        guard !botType.isEmpty, !botId.isEmpty else { return }
        let key = "dialogflow_\(botId)"
        userDefaultSuite.setValue(botType, forKey: key)
    }
    
    func getDialogFlowBotType(botId: String) -> String? {
        guard !botId.isEmpty else { return nil }
        let key = "dialogflow_\(botId)"
        return userDefaultSuite.value(forKey: key) as? String
    }

    func clear() {
        userDefaultSuite.removePersistentDomain(forName: KMAppUserDefaultHandler.defaultSuiteName)
    }
}

private extension KMAppUserDefaultHandler {
    enum Key {
        static let CSATEnabled = "CSAT_ENABLED"
        static let BotMessageDelayInterval = "BOT_MESSAGE_DELAY_INTERVAL"
        static let CSATRatingBase = "CSAT_RATTING_BASE"
        static let BotTypingIndicatorInterval = "BOT_TYPING_INDICATOR_INTERVAL"
        static let CurrentActivatedPlan = "KM_CURRENT_ACTIVATED_PLAN"
    }
}
