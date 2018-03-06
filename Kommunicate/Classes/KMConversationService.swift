//
//  KMConversationService.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 26/02/18.
//

import Foundation
import Applozic
import ApplozicSwift

public protocol KMConservationServiceable {
    associatedtype Response
    func createConversation(userId: String, agentId: String, botIds: [String]?,
                            completion: @escaping (Response) -> ())
}

public class KMConversationService: KMConservationServiceable {

    /// Conversation API response
    public struct Response {
        public var success: Bool = false
        public var channelKey: Int? = nil
        public var error: Error? = nil
    }

    //MARK: - Initialization

    public init() {}

    //MARK: - Public methods

    /**
     Creates a new conversation with the details passed.

     - Parameters:
        - userId: User id of the participant.
        - agentId: User id of the agent.

     - Returns: Response object.
    */
    public func createConversation(userId: String, agentId: String, botIds: [String]?, completion:@escaping (Response) -> ()) {

        let groupName = "Support"
        var members: [KMGroupUser] = []
        members.append(KMGroupUser(groupRole: .user, userId: userId))
        members.append(KMGroupUser(groupRole: .agent, userId: agentId))

        if let botUsers = getBotGroupUser(userIds: botIds) {
            members.append(contentsOf: botUsers)
        }
        let alChannelService = ALChannelService()
        let membersList = NSMutableArray()
        membersList.add(userId)
        alChannelService.createChannel(groupName, orClientChannelKey: nil, andMembersList: membersList, andImageLink: nil, channelType: 10, andMetaData: nil, adminUser: agentId, withGroupUsers: members as? NSMutableArray, withCompletion: {
            channel, error in
            guard error == nil else {return}
            guard let channel = channel, let key = channel.key as? Int else {
                completion(Response())
                return
            }
            self.createNewConversation(groupId: key, userId: userId, agentId: agentId, completion:{
                conversationResponse, error in
                var response = Response()
                guard conversationResponse != nil && error == nil else {
                    response.error = error
                    completion(response)
                    return
                }
                response.success = self.isConversationCreatedSuccessfully(for: conversationResponse)
                response.channelKey = channel.key as? Int
                completion(response)
            })
        })
    }

    /**
     Launch chat list from a ViewController.

     - Parameters:
     - viewController: ViewController from which the chat list will be launched.
     */
    public func launchChatList(from viewController: UIViewController) {
        let conversationVC = ALKConversationListViewController()
        let navVC = ALKBaseNavigationViewController(rootViewController: conversationVC)
        viewController.present(navVC, animated: false, completion: nil)
    }

    /**
     Launch group chat from a ViewController

     - Parameters:
     - groupId: groupId of the Group.
     - viewController: ViewController from which the group chat will be launched.
     */
    public func launchGroupWith(groupId: Int, from viewController: UIViewController) {
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(groupId as NSNumber, orClientChannelKey: nil) { (channel) in
            guard let channel = channel, let key = channel.key else {return}
            let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: key)
            let conversationViewController = ALKConversationViewController()
            conversationViewController.title = channel.name
            conversationViewController.viewModel = convViewModel
            viewController.navigationController?
                .pushViewController(conversationViewController, animated: false)
        }
    }

    //MARK: - Private methods

    private func createNewConversation(groupId: Int, userId: String, agentId: String, completion: @escaping (_ response: Any?, _ error: Error?)->()) {
        let user = KMGroupUser(groupRole: .user, userId: userId)
        let agent = KMGroupUser(groupRole: .agent, userId: agentId)
        guard let applicationKey = ALUserDefaultsHandler.getApplicationKey(),
            let LoggedInUser = ALUserDefaultsHandler.getUserId() else {
                completion(nil, nil)
                return
        }
        let detail = KMConversationDetail(
            groupId: groupId,
            user: user.id,
            agent:agent.id,
            applicationKey: applicationKey,
            createdBy: LoggedInUser)
        let api = "https://api.kommunicate.io/conversations"
        guard
            let paramData =  try? JSONEncoder().encode(detail),
            let paramString = String(data: paramData, encoding: .utf8)
            else {
                completion(nil, nil)
                return
        }

        let request = ALRequestHandler.createPOSTRequest(withUrlString: api, paramString: paramString)
        ALResponseHandler.processRequest(request, andTag: "ConversationCreate", withCompletionHandler: {
            jsonResponse, error in
            completion(jsonResponse, error)
        })

    }

    private func createBotUserFrom(userId: String) -> KMGroupUser {
        return KMGroupUser(groupRole: .bot, userId: userId)
    }

    /// Returns a list of KMGroupUser objects created from
    /// the userIds passed with role type set as bot.
    private func getBotGroupUser(userIds: [String]?) -> [KMGroupUser]? {
        guard let userIds = userIds else { return nil }
        return userIds.map {createBotUserFrom(userId: $0)}
    }

    /// Checks if API response returns success
    private func isConversationCreatedSuccessfully(for response: Any?) -> Bool {
        guard let response = response, let responseDict = response as? Dictionary<String, Any> else {
            return false
        }
        guard let code = responseDict["code"] as? String,
            code == "SUCCESS" else { return false }
        return true
    }
}
