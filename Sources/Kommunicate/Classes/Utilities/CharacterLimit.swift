//
//  CharacterLimit.swift
//  Kommunicate
//
//  Created by Mukesh on 18/11/20.
//

import Foundation

public enum CharacterLimit: Localizable {
    public struct Limit {
        public let soft: Int
        public let hard: Int

        public init(soft: Int, hard: Int) {
            self.soft = soft
            self.hard = hard
        }
    }
    public static var charlimit = Limit(soft: 1800, hard: 2000)
    public static var botCharLimit = Limit(soft: 55, hard: 256)

    enum LocalizedText {
        static private let filename = Kommunicate.defaultConfiguration.localizedStringFileName
        static let charLimit = localizedString(forKey: "CharLimit", fileName: filename)
        static let botCharLimit = localizedString(forKey: "BotCharLimit", fileName: filename)
        static let removeCharMessage = localizedString(forKey: "RemoveCharMessage", fileName: filename)
        static let remainingCharMessage = localizedString(forKey: "RemainingCharMessage", fileName: filename)
    }
}
