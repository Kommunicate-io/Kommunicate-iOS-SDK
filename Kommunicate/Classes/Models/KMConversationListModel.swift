//
//  KMConversationListModel.swift
//  Kommunicate
//
//  Created by apple on 28/01/20.
//

import Foundation
import ApplozicSwift
import Applozic

protocol KMConversationListViewModelDelegate: AnyObject {
    func startedLoading()
    func listUpdated()
    func rowUpdatedAt(position: Int)
}

public final class KMConversationListModel: NSObject, ALKConversationListViewModelProtocol, Localizable {
    weak var delegate: KMConversationListViewModelDelegate?
    
    var localizationFileName = String()
    var alChannelService = ALChannelService()
    var alContactService = ALContactService()
    var conversationService = ALConversationService()
    var conversationListModelHelper = ALKConversationListModelHelper()
    
    fileprivate var allMessages = [Any]()
    
    func prepareController(dbService: ALMessageDBService) {
        delegate?.startedLoading()
        dbService.getMessages(nil)
    }
    
    public func getChatList() -> [Any] {
        return allMessages
    }
    
    public func numberOfSections() -> Int {
        return 1
    }
    
    public func numberOfRowsInSection(_: Int) -> Int {
        return allMessages.count
    }
    
    public func chatFor(indexPath: IndexPath) -> ALKChatViewModelProtocol? {
        guard indexPath.row < allMessages.count else {
            return nil
        }
        
        guard let alMessage = allMessages[indexPath.row] as? ALMessage else {
            return nil
        }
        return alMessage
    }
    
    public func remove(message: ALMessage) {
        let messageToDelete = allMessages.filter { ($0 as? ALMessage) == message }
        guard let messageDel = messageToDelete.first as? ALMessage,
            let index = (allMessages as? [ALMessage])?.index(of: messageDel) else {
                return
        }
        allMessages.remove(at: index)
    }
    
    func updateTypingStatus(in viewController: ALKConversationViewController, userId: String, status: Bool) {
        let contactDbService = ALContactDBService()
        let contact = contactDbService.loadContact(byKey: "userId", value: userId)
        guard let alContact = contact else { return }
        guard !alContact.block || !alContact.blockBy else { return }
        
        viewController.showTypingLabel(status: status, userId: userId)
    }
    
    func updateMessageList(messages: [Any]) {
        allMessages = messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.delegate?.listUpdated()
        }
    }
    
    func updateDeliveryReport(convVC: ALKConversationViewController?, messageKey: String?, contactId: String?, status: Int32?) {
        guard let vc = convVC else { return }
        vc.updateDeliveryReport(messageKey: messageKey, contactId: contactId, status: status)
    }
    
    func updateStatusReport(convVC: ALKConversationViewController?, forContact contact: String?, status: Int32?) {
        guard let vc = convVC else { return }
        vc.updateStatusReport(contactId: contact, status: status)
    }
    
    func addMessages(messages: Any) {
        allMessages = conversationListModelHelper.addMessages(messages: messages, allMessages: allMessages)
        delegate?.listUpdated()
    }
    
    func updateStatusFor(userDetail: ALUserDetail) {
        guard let alMessages = allMessages as? [ALMessage], let userId = userDetail.userId else { return }
        let messages = alMessages.filter { ($0.contactId != nil) ? $0.contactId == userId : false }
        guard let firstMessage = messages.first, let index = alMessages.index(of: firstMessage) else { return }
        delegate?.rowUpdatedAt(position: index)
    }
    
    func syncCall(viewController: ALKConversationViewController?, message: ALMessage, isChatOpen: Bool) {
        if isChatOpen {
            viewController?.sync(message: message)
        }
    }
    
    func fetchMoreMessages(dbService: ALMessageDBService) {
        guard !ALUserDefaultsHandler.getFlagForAllConversationFetched() else { return }
        delegate?.startedLoading()
        dbService.fetchConversationfromServer(completion: {
            _ in
            NSLog("List updated")
        })
    }
    
    public func sendUnmuteRequestFor(message: ALMessage, withCompletion: @escaping (Bool) -> Void) {
        conversationListModelHelper.sendUnmuteRequestFor(message: message) { (success) in
            withCompletion(success)
        }
    }
    
    public func sendMuteRequestFor(message: ALMessage, tillTime: NSNumber, withCompletion: @escaping (Bool) -> Void) {
        conversationListModelHelper.sendMuteRequestFor(message: message, tillTime: tillTime) { (success) in
            withCompletion(success)
        }
    }
    
    public func block(conversation: ALMessage, withCompletion: @escaping (Error?, Bool) -> Void) {
        conversationListModelHelper.block(conversation: conversation) { (error, success) in
            withCompletion(error, success)
        }
    }
    
    public func unblock(conversation: ALMessage, withCompletion: @escaping (Error?, Bool) -> Void) {
        conversationListModelHelper.unblock(conversation: conversation) { (error, success) in
            withCompletion(error, success)
        }
    }
    
    public func updateUserDetail(userId: String, completion: @escaping (Bool) -> Void) {
        conversationListModelHelper.updateUserDetail(userId: userId) { result in
            completion(result)
        }
    }
    
    public func userBlockNotification(userId: String, isBlocked: Bool) {
        conversationListModelHelper.userBlockNotification(userId : userId,  isBlocked: isBlocked)
    }
    
    public func muteNotification(conversation: ALMessage, isMuted: Bool) {
        conversationListModelHelper.muteNotification(conversation: conversation, isMuted: isMuted)
    }
    
    func conversationViewModelOf(
        type conversationViewModelType: ALKConversationViewModel.Type,
        contactId: String?,
        channelId: NSNumber?,
        conversationId: NSNumber?
    ) -> ALKConversationViewModel {
        var convProxy: ALConversationProxy?
        if let convId = conversationId, let conversationProxy = conversationService.getConversationByKey(convId) {
            convProxy = conversationProxy
        }
        
        let convViewModel = conversationViewModelType.init(
            contactId: contactId,
            channelKey: channelId,
            conversationProxy: convProxy,
            localizedStringFileName: localizationFileName
        )
        return convViewModel
    }
}
