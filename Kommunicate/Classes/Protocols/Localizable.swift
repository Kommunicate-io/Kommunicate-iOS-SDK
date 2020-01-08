//
//  Localizable.swift
//  Kommunicate
//
//  Created by Mukesh on 25/01/19.
//

import Foundation

protocol Localizable {
    func localizedString(forKey key: String, fileName: String) -> String
}

extension Localizable {

    func localizedString(forKey key: String, fileName: String) -> String {
        return NSLocalizedString(key, tableName: fileName, bundle: Bundle.main, value: Self.defaultValue(forKey: key), comment: "")
    }

    static func localizedString(forKey key: String, fileName: String) -> String {
        return NSLocalizedString(key, tableName: fileName, bundle: Bundle.main, value: defaultValue(forKey: key), comment: "")
    }

    private static func defaultValue(forKey: String, bundle: Bundle = .kommunicate) -> String {
        return NSLocalizedString(forKey, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
