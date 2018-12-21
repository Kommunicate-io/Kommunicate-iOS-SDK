//
//  ALKConversationViewModel+Extension.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 25/11/18.
//

import Foundation
import Applozic
import ApplozicSwift

extension ALKConversationViewModel {
    
    public func conversationAssignee(groupId: NSNumber?) -> ALContact? {
        let channelService = ALChannelService()
        let contactDbService = ALContactDBService()
        // Check if group conversation.
        guard let channelKey = groupId else {
            return nil
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
    
    
    public func updateAssigneeDetails(groupId: NSNumber?, completion: @escaping () -> ()) {
        let userService = ALUserService()
        let contactDbService = ALContactDBService()
        guard let assignee = conversationAssignee(groupId: groupId) else {
            completion()
            return
        }
        let userIds: [String] = [assignee.userId]
        userService.fetchAndupdateUserDetails(NSMutableArray(array: userIds), withCompletion: { (userDetailArray, error) in
            guard let userDetails = userDetailArray else {
                completion()
                return
            }
            for case let userDetail as ALUserDetail in userDetails {
                contactDbService.update(userDetail)
            }
            completion()
        })
    }
    
}
