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

        let (assignee,alChannel) = conversationAssignee(groupId: groupId, userId: userId)

        guard let contact =  assignee  else {
            completion(nil,alChannel)
            return
        }

        let userIds: [String] = [contact.userId]
        userService.fetchAndupdateUserDetails(NSMutableArray(array: userIds), withCompletion: { (userDetailArray, error) in
            guard let userDetails = userDetailArray else {
                completion(contact,alChannel)
                return
            }
            for case let userDetail as ALUserDetail in userDetails {
                self.contactDbService.update(userDetail)
            }
            completion(assignee,alChannel)
        })
    }

}
