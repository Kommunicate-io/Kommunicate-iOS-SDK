//
//  MessageMetadataTests.swift
//  Kommunicate_Tests
//
//  Created by Mukesh on 06/12/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest

@testable import Kommunicate

class MessageMetadataTests: XCTestCase {
    var config: KMConfiguration!

    var messageMetadata: [AnyHashable: Any]? {
        return config.messageMetadata
    }

    override func setUp() {
        config = KMConfiguration()
    }

    func testChatContextUpdate() throws {
        try config.updateChatContext(with: ["chatInfo": "chat info value"])
        let metadata = try XCTUnwrap(messageMetadata)
        XCTAssertFalse(metadata.isEmpty)
        let context = try XCTUnwrap(chatContextFromMetadata(metadata))
        XCTAssertFalse(context.isEmpty)

        let value1 = try XCTUnwrap(context["chatInfo"] as? String)
        XCTAssertEqual(value1, "chat info value")
    }

    func testLanguageUpdate() throws {
        try config.updateUserLanguage(tag: "fr")
        let metadata = try XCTUnwrap(messageMetadata)
        XCTAssertFalse(metadata.isEmpty)
        let context = try XCTUnwrap(chatContextFromMetadata(metadata))
        XCTAssertFalse(context.isEmpty)

        let languageTag = try XCTUnwrap(context[ChannelMetadataKeys.languageTag] as? String)
        XCTAssertEqual(languageTag, "fr")
    }

    func testChatContext_whenLanguageIsSet() throws {
        try config.updateChatContext(with: ["chatInfo": "chat info value"])

        try config.updateUserLanguage(tag: "fr")
        let metadata = try XCTUnwrap(messageMetadata)
        XCTAssertFalse(metadata.isEmpty)
        let context = try XCTUnwrap(chatContextFromMetadata(metadata))
        XCTAssertFalse(context.isEmpty)

        let languageTag = try XCTUnwrap(context[ChannelMetadataKeys.languageTag] as? String)
        XCTAssertEqual(languageTag, "fr")

        let chatInfo = try XCTUnwrap(context["chatInfo"] as? String)
        XCTAssertEqual(chatInfo, "chat info value")
    }

    private func chatContextFromMetadata(_ metadata: [AnyHashable: Any]) throws -> [String: Any]? {
        guard
            let chatContext = metadata[ChannelMetadataKeys.chatContext] as? String,
            let contextData = chatContext.data(using: .utf8)
        else {
            return nil
        }
        do {
            let contextDict = try JSONSerialization
                .jsonObject(with: contextData, options: .allowFragments) as? [String: Any]
            return contextDict
        } catch {
            throw error
        }
    }
}
