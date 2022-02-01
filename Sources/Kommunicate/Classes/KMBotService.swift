//
//  KMBotService.swift
//  Kommunicate
//
//  Created by Sunil on 04/08/20.
//

import Foundation
import KommunicateCore_iOS_SDK

/// `KMBotService` will have all the API releated to bots
public struct KMBotService {
    var channelService: ALChannelService
    var channelDBService: ALChannelDBService
    static let conversationAssignee = "CONVERSATION_ASSIGNEE"

    public init() {
        channelService = ALChannelService()
        channelDBService = ALChannelDBService()
    }

    /// This method is used for fetching `BotDetail`
    /// - Parameters:
    ///   - applicationKey: Application key of the kommunicate
    ///   - botId: Bot id of the detail that you would like to fetch
    ///   - completion: A result of type `BotDetail` or `KMBotError`
    public func botDetail(applicationKey: String = KMUserDefaultHandler.getApplicationKey(),
                          botId: String,
                          completion: @escaping (Result<BotDetail, KMBotError>) -> Void)
    {
        guard let url = URLBuilder.botDetail(for: applicationKey, botId: botId).url else {
            completion(.failure(.api(.urlBuilding)))
            return
        }
        DataLoader.request(url: url, completion: {
            result in
            switch result {
            case let .success(data):
                guard let botDetailResponse = try? BotDetailResponse(data: data) else {
                    completion(.failure(.api(.jsonConversion)))
                    return
                }
                do {
                    let botDetailArray = try botDetailResponse.botDetail()
                    guard !botDetailArray.isEmpty,
                          let botDetail = botDetailArray.first, let botType = botDetail.aiPlatform
                    else {
                        completion(.failure(.notFound))
                        return
                    }
                    print("Bot detail fetched successfully for botId:\(botId) And Bot platform:", botDetail.aiPlatform as Any)
                    /// Add the botType and botId in user defaults
                    DispatchQueue.main.async {
                        KMAppUserDefaultHandler.shared.setBotType(botType, botId: botId)
                        completion(.success(botDetail))
                    }
                } catch let error as KMBotError {
                    print("Got some error in bot detail: %@ ", error.localizedDescription)
                    completion(.failure(error))
                } catch {
                    completion(.failure(.notFound))
                }
            case let .failure(error):
                completion(.failure(.api(.network(error))))
            }
        })
    }

    /// This method is used for fetching the assignee userId for groupId.
    /// - Parameter groupId: GroupId of the channel
    /// - Returns: Assignee userId of this channel groupId.
    func assigneeUserIdFor(groupId: NSNumber) -> String? {
        guard let channel = channelService.getChannelByKey(groupId),
              channel.type == Int16(SUPPORT_GROUP.rawValue),
              let assigneeId = channel.metadata?[KMBotService.conversationAssignee] as? String
        else {
            return nil
        }
        return assigneeId
    }

    /// This method is used for checking conversation is assigned to particular bot type
    /// - Parameters:
    ///   - type: type of the bot  from enum `BotType`
    ///   - groupId: groupId of conversation
    ///   - completion: true in case if the passed  bot type and response bot type are same..
    func conversationAssignedToBotForBotType(type: String, groupId: NSNumber, completion: @escaping (Bool) -> Void) {
        guard let assigneeId = assigneeUserIdFor(groupId: groupId),
              let channelUserX = channelDBService.loadChannelUserX(byUserId: groupId, andUserId: assigneeId),
              channelUserX.role == 2
        else {
            completion(false)
            return
        }
        fetchBotType(assigneeId) { result in
            switch result {
            case let .success(botType):
                completion(botType == type)
            case .failure:
                completion(false)
            }
        }
    }

    /// Fetch the bot type for given botId.
    /// - Parameters:
    ///   - botId: Pass the botId for fetching bot type
    ///   - completion: Result with botType or `KMBotError`
    func fetchBotType(_ botId: String, completion: @escaping (Result<String, KMBotError>) -> Void) {
        if let botType = KMAppUserDefaultHandler.shared.getBotType(botId: botId) {
            completion(.success(botType))
        } else {
            botDetail(botId: botId) { result in
                switch result {
                case let .success(botDetail):
                    guard let aiPlatform = botDetail.aiPlatform else {
                        completion(.failure(.notFound))
                        return
                    }
                    completion(.success(aiPlatform))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
}
