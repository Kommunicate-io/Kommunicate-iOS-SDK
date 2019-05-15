//
//  ALKConversationViewModel+Extension.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 25/11/18.
//

import Foundation
import Applozic

class ConversationDetail {

    let channelService = ALChannelService()
    let userService = ALUserService()
    let contactDbService = ALContactDBService()

    func conversationAssignee(groupId: NSNumber?, userId: String?) -> ALContact? {
        // Check if group conversation.
        guard let channelKey = groupId else {
            guard let userId = userId else {
                return nil
            }
            return ALContactService().loadContact(byKey: "userId", value: userId)
        }

        let channel = channelService.getChannelByKey(channelKey)
        let metadata = channel?.metadata
        // Check if metadata contains assignee details
        guard let assigneeId = metadata?[ChannelMetadataKeys.conversationAssignee] as? String else {
            return nil
        }

        // Load contact from assignee id
        guard let assignee = contactDbService.loadContact(byKey: "userId", value: assigneeId) else {
            return nil
        }
        return assignee
    }


    func updatedAssigneeDetails(groupId: NSNumber?,
                                userId: String?,
                                completion: @escaping (ALContact?) -> ()) {
        guard let assignee = conversationAssignee(groupId: groupId, userId: userId) else {
            completion(nil)
            return
        }
        let userIds: [String] = [assignee.userId]
        userService.fetchAndupdateUserDetails(NSMutableArray(array: userIds), withCompletion: { (userDetailArray, error) in
            guard let userDetails = userDetailArray else {
                completion(assignee)
                return
            }
            for case let userDetail as ALUserDetail in userDetails {
                self.contactDbService.update(userDetail)
            }
            completion(assignee)
        })
    }

}
