//
//  KMAppSettingsResponse.swift
//  Kommunicate
//
//  Created by Sunil on 13/04/20.
//

import Foundation

protocol KMAppSettingsResponseProtocol {
    var code: String { get }
    var response: AppSetting? { get }
    func appSettings() throws -> AppSetting
}

struct KMAppSettingsResponse: Decodable, KMAppSettingsResponseProtocol {
    let code: String
    let response: AppSetting?
    enum CodingKeys: String, CodingKey {
        case code
        case response
    }
}

public struct AppSetting: Decodable {
    let agentID: String
    let agentName, userName: String?
    let chatWidget: ChatWidgetResponse?
    let collectFeedback: Bool?
    let collectLead: Bool?
    let leadCollection: [LeadCollectionFields]?

    enum CodingKeys: String, CodingKey {
        case agentID = "agentId"
        case agentName, userName, chatWidget, collectFeedback, collectLead, leadCollection
    }
}

struct ChatWidgetResponse: Decodable {
    let primaryColor : String?
    let secondaryColor : String?
    let showPoweredBy : Bool?
    let isSingleThreaded : Bool?
    let hidePostCTAEnabled : Bool?
}

public struct LeadCollectionFields : Decodable {
    let type: String
    let field: String
    let required: Bool
    let placeholder: String
}

extension KMAppSettingsResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(KMAppSettingsResponse.self, from: data)
    }
    func appSettings() throws -> AppSetting {
        guard code == "SUCCESS" else {
            throw KMAppSettingsError.invalidCodeValue
        }
        guard let appSettingResponse = response else {
            throw KMAppSettingsError.notFound
        }
        return appSettingResponse
    }
}

enum KMAppSettingsError: LocalizedError {
    case invalidCodeValue
    case notFound
    case api(_ error: APIError)
}
