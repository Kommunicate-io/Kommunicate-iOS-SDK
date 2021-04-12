//
//  ALKConversationViewModel+Extension.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 25/11/18.
//

import Foundation
import ApplozicCore

class ConversationDetail {

    let channelService = ALChannelService()
    let userService = ALUserService()
    let contactDbService = ALContactDBService()
    let channelDbService = ALChannelDBService()

    func conversationAssignee(groupId: NSNumber?, userId: String?) -> (ALContact?,ALChannel?) {
        // Check if group conversation.
        guard let channelKey = groupId else {
            guard let userId = userId else {
                return (nil,nil)
            }
            return (ALContactService().loadContact(byKey: "userId", value: userId),nil)
        }

        let channel = channelService.getChannelByKey(channelKey)
        let metadata = channel?.metadata
        // Check if metadata contains assignee details

        if(channel?.type == Int16(SUPPORT_GROUP.rawValue)){
            guard let assigneeId = metadata?[ChannelMetadataKeys.conversationAssignee] as? String else {
                return (nil,channel)
            }

            // Load contact from assignee id
            guard let assignee = contactDbService.loadContact(byKey: "userId", value: assigneeId) else {
                return (nil,channel)
            }
            return (assignee,channel)
        }
        return (nil,channel)
    }


    func updatedAssigneeDetails(groupId: NSNumber?,
                                userId: String?,
                                completion: @escaping (ALContact?, ALChannel?) -> ()) {

        var (assignee, alChannel) = conversationAssignee(groupId: groupId, userId: userId)
        guard let contact = assignee else {
            completion(nil,alChannel)
            return
        }

        let userIds: [String] = [contact.userId]
        userService.fetchAndupdateUserDetails(NSMutableArray(array: userIds)) {[weak self] userDetailArray, _ in
            guard let strongSelf = self, let userDetails = userDetailArray else {
                completion(contact, alChannel)
                return
            }
            for case let userDetail as ALUserDetail in userDetails {
                strongSelf.contactDbService.update(userDetail)
            }
            (assignee, alChannel) = strongSelf.conversationAssignee(groupId: groupId, userId: userId)
            completion(assignee, alChannel)
        }
    }

    func isClosedConversation(channelId: Int) -> Bool {
        guard let channel = channelService.getChannelByKey(channelId as NSNumber) else {
            return false
        }
        return channel.isClosedConversation
    }

    func feedbackFor(channelId: Int, completion: @escaping (Feedback?)->()) {
        let conversationService = KMConversationService()
        conversationService.feedbackFor(groupId: channelId, completion: { result in
            switch result {
            case .success(let value):
                completion(value.feedback)
            case .failure(let error):
                print("Conversation feedback error: \(error.localizedDescription)")
                completion(nil)
            }
        })
    }

    func isAssignedToBot(groupID: Int) -> Bool {
        guard let assigneeId = assigneeUserIdFor(groupID: groupID),
              let channelUserX = channelDbService.loadChannelUserX(byUserId: groupID as NSNumber, andUserId: assigneeId),
              let userRole = channelUserX.role as? Int else {
            return false
        }
        return userRole == KMGroupUser.RoleType.bot.rawValue
    }

    private func assigneeUserIdFor(groupID: Int) -> String? {
        guard let channel = channelService.getChannelByKey(groupID as NSNumber),
              channel.type == Int16(SUPPORT_GROUP.rawValue),
              let assigneeId = channel.metadata?[KMBotService.conversationAssignee] as? String else {
            return nil
        }
        return assigneeId
    }
}

extension ALChannel {
    static let ClosedStatus = 2

    var isClosedConversation: Bool {
        guard let conversationStatus = metadata[AL_CHANNEL_CONVERSATION_STATUS] as? String else {
            return false
        }
        return type == Int16(SUPPORT_GROUP.rawValue) &&
            Int(conversationStatus) ?? 0 == ALChannel.ClosedStatus
    }
}
