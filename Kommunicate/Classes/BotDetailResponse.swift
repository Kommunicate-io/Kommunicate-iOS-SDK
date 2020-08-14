//
//  BotDetailResponse.swift
//  Kommunicate
//
//  Created by apple on 05/08/20.
//

import Foundation

protocol BotDetailResponseProtocol {
    var message: String { get }
    var data: [BotDetail]? { get }
    func botDetail() throws -> [BotDetail]
}

struct BotDetailResponse : Decodable, BotDetailResponseProtocol {
    let message: String
    let data: [BotDetail]?

    enum CodingKeys: String, CodingKey {
        case message
        case data
    }
}

public struct BotDetail: Decodable {
    let aiPlatform: String?
}

extension BotDetailResponse {
    enum BotType: String {
        case DIALOGFLOW = "dialogflow"
        case APIAI = "api.ai"
        case HELPDOCS = "helpdocs.io"
        case RASA = "rasa"
        case SMARTREPLY = "smartreply"
        case CUSTOM = "custom"
    }
    init(data: Data) throws {
        self = try JSONDecoder().decode(BotDetailResponse.self, from: data)
    }
    func botDetail() throws -> [BotDetail] {
        guard message == "success" else {
            throw KMBotError.invalidCodeValue
        }
        guard let botDetailResponse = data else {
            throw KMBotError.notFound
        }
        return botDetailResponse
    }
}

public enum KMBotError: LocalizedError {
    case invalidCodeValue
    case notFound
    case api(_ error: APIError)
}
