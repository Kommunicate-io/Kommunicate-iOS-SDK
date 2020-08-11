//
//  KMBotService.swift
//  Kommunicate
//
//  Created by Sunil on 04/08/20.
//

import Foundation
import Applozic

/// `KMBotService` will have all the API releated to bots
public struct KMBotService {
    var channelService: ALChannelService
    var channelDBService : ALChannelDBService
    static let conversationAssignee = "CONVERSATION_ASSIGNEE"

    public init() {
        channelService = ALChannelService()
        channelDBService = ALChannelDBService()
    }

    /// This method is used for fetching `BotDetail`
    /// - Parameters:
    ///   - applicationKey: Application key of the kommunicate
    ///   - botId: Bot id of the detail that you would like to fetch
    ///   - completion: A Result of type `BotDetail` or `KMBotError`

    public func botDetail(applicationKey: String = KMUserDefaultHandler.getApplicationKey(),
                          botId: String,
                          completion: @escaping (Result<BotDetail, KMBotError>)->()) {
        guard let url = URLBuilder.botDetail(for: applicationKey, botId: botId).url else {
            completion(.failure(.api(.urlBuilding)))
            return
        }

        DataLoader.request(url: url, completion: {
            result in
            switch result {
            case .success(let data):

                guard let botDetailResponse = try? BotDetailResponse(data: data) else {
                    completion(.failure(.api(.jsonConversion)))
                    return
                }

                do {
                    let botDetailArray = try botDetailResponse.botDetail()
                    guard botDetailArray.count > 0,
                        let botDetail = botDetailArray.first, let botType = botDetail.aiPlatform  else {
                            completion(.failure(.notFound))
                            return;
                    }
                    print("Bot detail fetched successfully for botId:\(botId) And Bot platform:",botDetail.aiPlatform as Any)
                    /// Add the botType and botId in user defaults
                    DispatchQueue.main.async {
                        KMUserDefaultHandler.setBotType(botType, botId: botId)
                        completion(.success(botDetail))
                    }
                } catch let error as KMBotError {
                    print("Got some error in bot detail: %@ ",error.localizedDescription)
                    completion(.failure(error))
                } catch {
                    completion(.failure(.notFound))
                }

            case .failure(let error):
                completion(.failure(.api(.network(error))))
            }
        })
    }

    /// This method is used for fetchnig the assignee userId for groupId.
    /// - Parameter groupId: GroupId of the channel
    /// - Returns: Assignee userId of this channel groupId.
    func assigneeUserIdFor(groupId: NSNumber) -> String? {
        guard let channel = channelService.getChannelByKey(groupId),
            channel.type == Int16(SUPPORT_GROUP.rawValue),
            let assigneeId = channel.metadata?[KMBotService.conversationAssignee] as? String else {
                return nil
        }
        return assigneeId
    }

    /// This method is used for fetching bot type is assigned to bot.
    /// - Parameters:
    ///   - groupId: GroupId of the channel.
    ///   - completion: If Assigned to bot completion handler will have true.
    func fetchBotTypeIfAssignedToBot(groupId: NSNumber,  completion: @escaping (Bool) -> ()) {
        guard let assigneeId = self .assigneeUserIdFor(groupId: groupId),
            let channelUserX = channelDBService.loadChannelUserX(byUserId: groupId, andUserId: assigneeId), channelUserX.role == 2 else {
                completion(false)
                return
        }

        if let botType = KMUserDefaultHandler.getBotType(botId: assigneeId) {
            completion(botType == BotDetailResponse.BotType.dialogflow)
        } else {
            self.botDetail(botId: assigneeId) { (result) in
                switch result {
                case .success(let botDetail) :
                    completion(botDetail.aiPlatform == BotDetailResponse.BotType.dialogflow)
                case .failure(_) :
                    completion(false)
                }
            }
        }
    }

}
