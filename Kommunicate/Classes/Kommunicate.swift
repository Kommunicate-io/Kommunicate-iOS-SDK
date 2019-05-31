//
//  Kommunicate.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 07/03/18.
//

import Foundation
import UIKit
import Applozic
import ApplozicSwift

var TYPE_CLIENT : Int16 = 0
var TYPE_APPLOZIC : Int16 = 1
var TYPE_FACEBOOK : Int16 = 2

var APNS_TYPE_DEVELOPMENT : Int16 = 0
var APNS_TYPE_DISTRIBUTION : Int16 = 1

public typealias KMUser = ALUser
public typealias KMUserDefaultHandler = ALUserDefaultsHandler
public typealias KMPushNotificationService = ALPushNotificationService
public typealias KMAppLocalNotification = ALAppLocalNotifications
public typealias KMDbHandler = ALDBHandler
public typealias KMRegisterUserClientService = ALRegisterUserClientService
public typealias KMPushNotificationHandler = ALKPushNotificationHandler
public typealias KMConfiguration = ALKConfiguration

@objc
open class Kommunicate: NSObject {

    //MARK: - Public properties

    /// Returns true if user is already logged in.
    @objc open class var isLoggedIn: Bool {
        return KMUserDefaultHandler.isLoggedIn()
    }

    /**
     Default configuration which defines the behaviour of UI components.
     It's used while initializing any UI component or in
     `KMPushNotificationHandler`.
     - Note: This can be changed from outside if you want to enable or
            disable some features but avoid initializing a new `KMConfiguration`
            object as we have set some properties in the default configuration object
            which shouldn't be disabled. So use the `defaultConfiguration` and change
            it accordingly.
    */
    public static var defaultConfiguration: KMConfiguration = {
        var config = KMConfiguration()
        config.isTapOnNavigationBarEnabled = false
        config.isProfileTapActionEnabled = false
        let faqImage = UIImage(named: "faq_image", in: Bundle.kommunicate, compatibleWith: nil)
        config.rightNavBarImageForConversationView = faqImage
        config.rightNavBarImageForConversationListView = faqImage
        config.handleNavIconClickOnConversationListView = true
        config.disableSwipeInChatCell = true
        config.hideContactInChatBar = true
        return config
    }()
    
    /// Configuration which defines the behavior of ConversationView components.
    public static var kmConversationViewConfiguration = KMConversationViewConfiguration()

    public enum KommunicateError: Error {
        case notLoggedIn
        case conversationNotPresent
        case conversationCreateFailed
    }

    //MARK: - Private properties

    private static var applicationId = ""

    private var pushNotificationTokenData: Data? {
        didSet {
            updateToken()
        }
    }

    static var applozicClientType: ApplozicClient.Type = ApplozicClient.self

    //MARK: - Public methods


    /**
     Setup a application id which will be used for all the requests.

     - Parameters:
        - applicationId: Application id that needs to be set up.
     */
    @objc open class func setup(applicationId: String) {
        self.applicationId = applicationId
        ALUserDefaultsHandler.setApplicationKey(applicationId)
        self.defaultChatViewSettings()
    }

    private class func observeListControllerNavigationClick() {
        let notifName = defaultConfiguration.nsNotificationNameForNavIconClick
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(notifName),
            object: nil,
            queue: nil) {
                notification in
                guard let vc = notification.object as? ALKConversationListViewController else {
                    return
                }
                openFaq(from: vc, with: defaultConfiguration)
        }
    }

    open class func openFaq(from vc: UIViewController, with configuration: ALKConfiguration) {
        guard let url = URLBuilder.faqURL(for: ALUserDefaultsHandler.getApplicationKey()).url else {
            return
        }
        let faqVC = FaqViewController(url: url, configuration: configuration)
        let navVC = ALKBaseNavigationViewController(rootViewController: faqVC)
        vc.present(navVC, animated: true, completion: nil)
    }

    /**
     Registers a new user, if it's already registered then user will be logged in.

     - Parameters:
        - kmUser: A KMUser object which contains user details.
        - completion: The callback with registration response and error.
    */
    @objc open class func registerUser(
        _ kmUser: KMUser,
        completion : @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void) {
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()

        registerUserClientService.initWithCompletion(kmUser, withCompletion: { (response, error) in

            if (error != nil)
            {
                print("Error while registering to applozic");
                let errorPass = NSError(domain:"Error while registering to applozic", code:0, userInfo:nil)
                completion(response , errorPass as NSError?)
            }
            else if(!(response?.isRegisteredSuccessfully())!)
            {
                ALUtilityClass.showAlertMessage("Invalid Password", andTitle: "Oops!!!")
                let errorPass = NSError(domain:"Invalid Password", code:0, userInfo:nil)
                completion(response , errorPass as NSError?)
            }
            else
            {
                print("registered")
                completion(response , error as NSError?)
            }
        })
    }

    /// Logs out the current logged in user and clears all the cache.
    @objc open class func logoutUser() {
        let registerUserClientService = ALRegisterUserClientService()
        if let _ = ALUserDefaultsHandler.getDeviceKeyString() {
            registerUserClientService.logout(completionHandler: {
                _, _ in
                NSLog("Applozic logout")
            })
        }
    }

    /**
     Creates a new conversation with the details passed.

     - Parameters:
        - userId: User id of the participant.
        - agentId: User id of the agent.
        - botIds: A list of bot ids to be added in the conversation.
        - useLastConversation: If there is a conversation already present then that will be returned.

     - Returns: Group id if successful otherwise nil.
     */
    @objc open class func createConversation(
        userId: String,
        agentIds: [String] = [],
        botIds: [String]?,
        useLastConversation: Bool = false,
        clientConversationId: String? = nil,
        completion:@escaping (_ clientGroupId: String) -> ()) {
        let service = KMConversationService()
        if KMUserDefaultHandler.isLoggedIn() {

            var allAgentIds = agentIds
            var allBotIds = ["bot"] // Default bot that should be added everytime.

            if let botIds = botIds { allBotIds.append(contentsOf: botIds) }
            service.defaultAgentFor(completion: {
                result in
                switch result {
                case .success(let agentId):
                    allAgentIds.append(agentId)
                case .failure(let error):
                    print("Error while fetching agents id: \(error)")
                    completion("")
                }
                allAgentIds = allAgentIds.uniqueElements

                var clientConversationId = clientConversationId
                if useLastConversation {
                    clientConversationId = service.createClientIdFrom(userId: userId, agentIds: allAgentIds, botIds: botIds ?? [])
                }
                service.createConversation(
                    userId: KMUserDefaultHandler.getUserId(),
                    agentIds: allAgentIds,
                    botIds: allBotIds,
                    clientConversationId: clientConversationId,
                    completion: { response in
                        completion(response.clientChannelKey ?? "")
                })
            })
        }
    }

    /// This method is used to return an instance of conversation list view controller.
    ///
    /// - Returns: Instance of `ALKConversationListViewController`
    @objc open class func conversationListViewController() -> ALKConversationListViewController {
        let conversationVC = ALKConversationListViewController(configuration: Kommunicate.defaultConfiguration)
        conversationVC.conversationListTableViewController.dataSource.cellConfigurator = {
            (messageModel, tableCell) in
            let cell = tableCell as! ALKChatCell
            let message = ChatMessage(message: messageModel)
            cell.update(viewModel: message, identity: nil, disableSwipe: Kommunicate.defaultConfiguration.disableSwipeInChatCell)
            cell.chatCellDelegate = conversationVC.conversationListTableViewController.self
        }
        let conversationViewController = KMConversationViewController(configuration: Kommunicate.defaultConfiguration)
        conversationViewController.kmConversationViewConfiguration = kmConversationViewConfiguration
        conversationViewController.viewModel = ALKConversationViewModel(contactId: nil, channelKey: nil, localizedStringFileName: defaultConfiguration.localizedStringFileName)
        conversationVC.conversationViewController = conversationViewController
        observeListControllerNavigationClick()
        return conversationVC
    }

    /**
     Launch chat list from a ViewController.

     - Parameters:
        - viewController: ViewController from which the chat list will be launched.
     */
    @objc open class func showConversations(from viewController: UIViewController) {
        let conversationVC = conversationListViewController()
        let navVC = ALKBaseNavigationViewController(rootViewController: conversationVC)
        viewController.present(navVC, animated: false, completion: nil)
    }

    /**
     Launch group chat from a ViewController

     - Parameters:
        - clientGroupId: clientChannelKey of the Group.
        - viewController: ViewController from which the group chat will be launched.
        - completionHandler: Called with the information whether the conversation was
                            shown or not.

     */
    @objc open class func showConversationWith(groupId clientGroupId: String, from viewController: UIViewController, completionHandler: @escaping (Bool) -> Void) {
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) { (channel) in
            guard let channel = channel, let key = channel.key else {
                completionHandler(false)
                return
            }
            let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: key, localizedStringFileName: defaultConfiguration.localizedStringFileName)
            let conversationViewController = KMConversationViewController(configuration: Kommunicate.defaultConfiguration)
            conversationViewController.title = channel.name
            conversationViewController.viewModel = convViewModel
            conversationViewController.kmConversationViewConfiguration = kmConversationViewConfiguration
            if let navigationVC = viewController.navigationController {
                navigationVC.pushViewController(conversationViewController, animated: false)
            } else {
                let navigationController = UINavigationController(rootViewController: conversationViewController)
                viewController.present(navigationController, animated: false, completion: nil)
            }
            completionHandler(true)
        }
    }

    /**
     Creates and launches the conversation. In case multiple conversations
     are present then the conversation list will be presented. If a single
     conversation is present then that will be launched.

     - Parameters:
        - viewController: ViewController from which the group chat will be launched.
     */

    open class func createAndShowConversation(
        from viewController: UIViewController,
        completion:@escaping (_ error: KommunicateError?) -> ()){
        guard isLoggedIn else {
            completion(KommunicateError.notLoggedIn)
            return
        }

        let applozicClient = applozicClientType.init(applicationKey: KMUserDefaultHandler.getApplicationKey())
        applozicClient?.getLatestMessages(false, withCompletionHandler: {
            messageList, error in
            print("Kommunicate: message list received")

            // If more than 1 thread is present then the list will be shown
            if let messages = messageList, messages.count > 1, error == nil {
                showConversations(from: viewController)
                completion(nil)
            } else {
                createAConversationAndLaunch(from: viewController, completion: {
                    conversationError in
                    completion(conversationError)
                })
            }
        })
    }

    /**
     Generates a random id that can be used as an `userId`
     when you don't have any user information that can be used as an
     userId.

     - Returns: A random alphanumeric string of length 32.
    */
    @objc open class func randomId() -> String {
        return String.random(length: 32)
    }


    //MARK: - Private methods

    private func updateToken() {
        guard let deviceToken = pushNotificationTokenData else { return }
        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)")  // (SWIFT = 3) : TOKEN PARSING

        var deviceTokenString: String = ""
        for i in 0..<deviceToken.count
        {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("DEVICE_TOKEN_STRING :: \(deviceTokenString)")

        if (ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString)
        {
            let alRegisterUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { (response, error) in
                print ("REGISTRATION_RESPONSE :: \(String(describing: response))")
            })
        }
    }


    private class func isNilOrEmpty(_ string: NSString?) -> Bool {

        switch string {
        case .some(let nonNilString): return nonNilString.length == 0
        default:return true

        }
    }

    private class func createAConversationAndLaunch(
        from viewController: UIViewController,
        completion:@escaping (_ error: KommunicateError?) -> ()) {
        let userId = ALUserDefaultsHandler.getUserId() ?? Kommunicate.randomId()
        createConversation(
            userId: userId,
            botIds: nil,
            useLastConversation: true,
            completion: { response in
                guard !response.isEmpty else {
                    completion(KommunicateError.conversationCreateFailed)
                    return
                }
                DispatchQueue.main.async {
                    showConversationWith(groupId: response, from: viewController, completionHandler: { success in
                        guard success else {
                            completion(KommunicateError.conversationNotPresent)
                            return
                        }
                        print("Kommunicate: conversation was shown")
                        completion(nil)
                    })
                }
        })
    }

    static private func defaultChatViewSettings() {
        ALUserDefaultsHandler.setGoogleMapAPIKey("AIzaSyCOacEeJi-ZWLLrOtYyj3PKMTOFEG7HDlw") //REPLACE WITH YOUR GOOGLE MAPKEY
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), ALKConversationViewController.description()])
        ALApplozicSettings.setFilterContactsStatus(true)
        ALUserDefaultsHandler.setDebugLogsRequire(true)
        ALApplozicSettings.setSwiftFramework(true)
        ALApplozicSettings.hideMessages(withMetadataKeys: ["KM_ASSIGN", "KM_STATUS"])
    }
}

class ChatMessage: ALKChatViewModelProtocol {
    var messageType: ALKMessageType
    var avatar: URL?
    var avatarImage: UIImage?
    var avatarGroupImageUrl: String?
    var name: String
    var groupName: String
    var theLastMessage: String?
    var hasUnreadMessages: Bool
    var totalNumberOfUnreadMessages: UInt
    var isGroupChat: Bool
    var contactId: String?
    var channelKey: NSNumber?
    var conversationId: NSNumber!
    var createdAt: String?

    init(message: ALKChatViewModelProtocol) {
        self.avatar = message.avatar
        self.avatarImage = message.avatarImage
        self.avatarGroupImageUrl = message.avatarGroupImageUrl
        self.name = message.name
        self.groupName = message.groupName
        self.theLastMessage = message.theLastMessage
        self.hasUnreadMessages = message.hasUnreadMessages
        self.totalNumberOfUnreadMessages = message.totalNumberOfUnreadMessages
        self.isGroupChat = message.isGroupChat
        self.contactId = message.contactId
        self.channelKey = message.channelKey
        self.conversationId = message.conversationId
        self.createdAt = message.createdAt
        self.messageType = message.messageType
        // Update message to show conversation assignee details
        guard
            isGroupChat,
            let assignee = ConversationDetail().conversationAssignee(groupId: self.channelKey, userId: self.contactId)
            else { return }
        self.groupName = assignee.getDisplayName()
        self.avatarGroupImageUrl = assignee.contactImageUrl
    }

}
