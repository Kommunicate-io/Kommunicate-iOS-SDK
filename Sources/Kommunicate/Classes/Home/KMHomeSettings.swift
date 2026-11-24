//
//  KMHomeSettings.swift
//  Kommunicate
//
//  Settings that drive the home screen (Welcome / Conversations / FAQ / News tabs).
//

import Foundation

/// A single card shown in the News tab. Mirrors an item of `whatsNewList` in the settings json.
struct KMWhatsNewItem {
    let title: String
    let meta: String
    let description: String
    let link: String
    let linkText: String

    init?(dictionary: [String: Any]) {
        func text(_ key: String) -> String {
            (dictionary[key] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        title = text("title")
        meta = text("meta")
        description = text("description")
        link = text("link")
        linkText = text("linkText")
        guard !title.isEmpty || !description.isEmpty else { return nil }
    }

    /// Only web and mail links are opened from the News tab.
    var openableURL: URL? {
        guard let url = URL(string: link),
              let scheme = url.scheme?.lowercased(),
              ["http", "https", "mailto"].contains(scheme)
        else { return nil }
        return url
    }
}

enum KMHomeSettings {
    /// Same defaults as the Android SDK's sample settings until `whatsNewList` is provided.
    /// An explicit empty list shows no cards.
    static var whatsNewList: [KMWhatsNewItem] = defaultWhatsNewList

    static let defaultWhatsNewList: [KMWhatsNewItem] = [
        [
            "title": "October 2025 Product Release Notes",
            "meta": "October 2025",
            "description": "2FA, bulk delete, search URLs, and more.",
            "link": "https://www.kommunicate.io",
            "linkText": "Read release notes"
        ],
        [
            "title": "Brash Solutions automated 500 daily queries with Kommunicate",
            "meta": "Customer story",
            "description": "Learn how they diverted phone calls to AI chatbots and scaled support.",
            "link": "https://www.kommunicate.io",
            "linkText": "Read the case study"
        ]
    ].compactMap { KMWhatsNewItem(dictionary: $0) }

    static func apply(from settings: [String: Any]) {
        if let items = settings["whatsNewList"] as? [[String: Any]] {
            whatsNewList = items.compactMap { KMWhatsNewItem(dictionary: $0) }
        }
    }
}
