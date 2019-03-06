//
//  KMConversationListTableVC.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 06/03/19.
//

import Applozic
import ApplozicSwift

class KMConversationListTableVC: ALKConversationListTableViewController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard
            let chatCell = cell as? ALKChatCell,
            let message = viewModel.chatFor(indexPath: indexPath) as? ALMessage,
            let assignee = ConversationDetail().conversationAssignee(groupId: message.groupId)
        else {
            return cell
        }
        chatCell.update(name: assignee.getDisplayName(), imageUrl: assignee.contactImageUrl)
        return chatCell
    }

}
