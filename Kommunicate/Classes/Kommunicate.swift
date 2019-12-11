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
public typealias KMConfiguration = ALKConfiguration
public typealias KMMessageStyle = ALKMessageStyle
public typealias KMBaseNavigationViewController = ALKBaseNavigationViewController
let conversationCreateIdentifier = 112233445
let faqIdentifier =  11223346

enum KMLocalizationKey {
    static let noName = "NoName"
}

@objc
open class Kommunicate: NSObject,Localizable{

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
        var navigationItemsForConversationList = [ALKNavigationItem]()
        let faqItem = ALKNavigationItem(identifier: faqIdentifier, text:  NSLocalizedString("FaqTitle", value: "FAQ", comment: ""))
        let startNewImage =  UIImage(named: "fill_214", in:  Bundle(for: ALKConversationListViewController.self), compatibleWith: nil)!
        let createConversationItem = ALKNavigationItem(identifier: conversationCreateIdentifier, icon: startNewImage)
        navigationItemsForConversationList.append(createConversationItem)
        navigationItemsForConversationList.append(faqItem)
        var navigationItemsForConversationView = [ALKNavigationItem]()
        navigationItemsForConversationView.append(faqItem)
        config.navigationItemsForConversationList = navigationItemsForConversationList
        config.hideStartChatButton = true
        config.navigationItemsForConversationView = navigationItemsForConversationView
        config.disableSwipeInChatCell = true
        config.chatBar.optionsToShow = .some([.camera, .location, .gallery, .video])
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

    /// Creates a new conversation with the details passed.
    /// - Parameter conversation: An instance of `KMConversation` object.
    /// - Parameter completion: If successful the success callback will have a conversationId else it will be KMConversationError on failure.
    open class func createConversation (
        conversation: KMConversation = KMConversationBuilder().build(),
        completion: @escaping (Result<String, KMConversationError>) -> ()) {

        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            completion(.failure(KMConversationError.internet))
            return
        }

        if let conversationTitle = conversation.conversationTitle, conversationTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("The conversation title should not be empty")
            completion(.failure(KMConversationError.invalidTitle))
            return
        }

        let service = KMConversationService()
        if KMUserDefaultHandler.isLoggedIn() {
            var allAgentIds = conversation.agentIds
            var allBotIds = ["bot"] // Default bot that should be added everytime.

            if let botIds = conversation.botIds { allBotIds.append(contentsOf: botIds) }

            service.defaultAgentFor(completion: {
                result in
                switch result {
                case .success(let agentId):
                    allAgentIds.append(agentId)
                case .failure(let error):
                    completion(.failure(KMConversationError.api(error)))
                    return;
                }
                allAgentIds = allAgentIds.uniqueElements
                conversation.agentIds = allAgentIds
                conversation.botIds = allBotIds

                if conversation.useLastConversation {
                    conversation.clientConversationId = service.createClientIdFrom(userId: conversation.userId, agentIds: conversation.agentIds, botIds: conversation.botIds ?? [])
                }

                service.createConversation(conversation: conversation, completion: { response in

                    guard let conversationId = response.clientChannelKey else {
                        completion(.failure(KMConversationError.api(response.error)))
                        return;
                    }
                    completion(.success(conversationId))
                })
            })
        } else {
            completion(.failure(KMConversationError.notLoggedIn))
        }
    }

    /// This method is used to return an instance of conversation list view controller.
    ///
    /// - Returns: Instance of `ALKConversationListViewController`
    @objc open class func conversationListViewController() -> ALKConversationListViewController {
        let conversationVC = ALKConversationListViewController(configuration: Kommunicate.defaultConfiguration)
        configureListVC(conversationVC)
        return conversationVC
    }

    /**
     Launch chat list from a ViewController.

     - Parameters:
        - viewController: ViewController from which the chat list will be launched.
     */
    @objc open class func showConversations(from viewController: UIViewController) {
        let conversationVC = conversationListViewController()
        let navVC = KMBaseNavigationViewController(rootViewController: conversationVC)
        navVC.modalPresentationStyle = .fullScreen
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
            self.openChatWith(groupId: key, from: viewController, completionHandler: { result in
                completionHandler(result)
            })
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

    open class func openFaq(from vc: UIViewController, with configuration: ALKConfiguration) {
        guard let url = URLBuilder.faqURL(for: ALUserDefaultsHandler.getApplicationKey()).url else {
            return
        }
        let faqVC = FaqViewController(url: url, configuration: configuration)
        let navVC = KMBaseNavigationViewController(rootViewController: faqVC)
        vc.present(navVC, animated: true, completion: nil)
    }

    //MARK: - Internal methods

    class func configureListVC(_ vc: ALKConversationListViewController) {
        vc.conversationListTableViewController.dataSource.cellConfigurator = {
            (messageModel, tableCell) in
            let cell = tableCell as! ALKChatCell
            let message = ChatMessage(message: messageModel)
            cell.update(viewModel: message, identity: nil, disableSwipe: Kommunicate.defaultConfiguration.disableSwipeInChatCell)
            cell.chatCellDelegate = vc.conversationListTableViewController.self
        }
        let conversationViewController = KMConversationViewController(configuration: Kommunicate.defaultConfiguration)
        conversationViewController.kmConversationViewConfiguration = kmConversationViewConfiguration
        conversationViewController.viewModel = ALKConversationViewModel(contactId: nil, channelKey: nil, localizedStringFileName: defaultConfiguration.localizedStringFileName)
        vc.conversationViewController = conversationViewController
        observeListControllerNavigationCustomButtonClick()
    }

    class func openChatWith(groupId: NSNumber, from viewController: UIViewController, completionHandler: @escaping (Bool) -> Void) {
        let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: groupId, localizedStringFileName: defaultConfiguration.localizedStringFileName)
        let conversationViewController = KMConversationViewController(configuration: Kommunicate.defaultConfiguration)
        conversationViewController.viewModel = convViewModel
        conversationViewController.kmConversationViewConfiguration = kmConversationViewConfiguration
        if let navigationVC = viewController.navigationController {
            navigationVC.pushViewController(conversationViewController, animated: false)
        } else {
            let navigationController = KMBaseNavigationViewController(rootViewController: conversationViewController)
            navigationController.modalPresentationStyle = .fullScreen
            viewController.present(navigationController, animated: false, completion: nil)
        }
        completionHandler(true)
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
        let kommunicateConversationBuilder = KMConversationBuilder()
            .useLastConversation(true)
        let conversation = kommunicateConversationBuilder.build()
        createConversation(conversation: conversation) { (result) in
            switch result {
            case .success(let conversationId):
                DispatchQueue.main.async {
                    showConversationWith(groupId: conversationId, from: viewController, completionHandler: { success in
                        guard success else {
                            completion(KommunicateError.conversationNotPresent)
                            return
                        }
                        print("Kommunicate: conversation was shown")
                        completion(nil)
                    })
                }
            case .failure(_):
                completion(KommunicateError.conversationCreateFailed)
                return
            }
        }
    }

    private class func showAlert(viewController:ALKConversationListViewController){

         let alertMessage =  NSLocalizedString("UnableToCreateConversationError", value: "Unable to create conversation", comment: "")

        let okText =  NSLocalizedString("OkButton", value: "Okay", comment: "")

        let alert = UIAlertController(
            title: "",
            message: alertMessage,
            preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: okText, style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    private class func createConversationAndLaunch(notification:Notification){

        guard let vc = notification.object as? ALKConversationListViewController else {
            return
        }
        vc.view.isUserInteractionEnabled = false
        vc.navigationController?.view.isUserInteractionEnabled = false
        let alertView =  displayAlert(viewController :vc)

        Kommunicate.createConversation() { (result) in
            switch result {
            case .success(let conversationId):
                DispatchQueue.main.async {
                    vc.view.isUserInteractionEnabled = true
                    vc.navigationController?.view.isUserInteractionEnabled = true
                    alertView.dismiss(animated: false, completion: nil)
                    showConversationWith(groupId: conversationId, from: vc, completionHandler: { (success) in
                        print("Conversation was shown")
                    })
                }
            case .failure( _):
                DispatchQueue.main.async {
                    vc.view.isUserInteractionEnabled = true
                    vc.navigationController?.view.isUserInteractionEnabled = true
                    alertView.dismiss(animated: false, completion: {
                        showAlert(viewController: vc)
                    })
                }
            }
        }

    }

    private class func  displayAlert(viewController:ALKConversationListViewController) -> UIAlertController {

        let alertTitle =  NSLocalizedString("WaitMessage", value: "Please wait...", comment: "")

        let loadingAlertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        loadingAlertController.view.addSubview(activityIndicator)

        let xConstraint: NSLayoutConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint: NSLayoutConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerY, multiplier: 1.4, constant: 0)

        NSLayoutConstraint.activate([ xConstraint, yConstraint])
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()

        let height: NSLayoutConstraint = NSLayoutConstraint(item: loadingAlertController.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 80)
        loadingAlertController.view.addConstraint(height);

        viewController.present(loadingAlertController, animated: true, completion: nil)

        return loadingAlertController
    }

    private class func observeListControllerNavigationCustomButtonClick() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(ALKNavigationItem.NSNotificationForConversationListNavigationTap),
            object: nil,
            queue: nil) {
                notification in
                guard let notificationInfo = notification.userInfo else{
                    return
                }

                let identifier = notificationInfo["identifier"] as? Int
                if identifier  ==  conversationCreateIdentifier  {
                    createConversationAndLaunch(notification: notification)
                }else if identifier == faqIdentifier{
                    guard let vc = notification.object as? ALKConversationListViewController else {
                        return
                    }
                    openFaq(from: vc, with: defaultConfiguration)
                }
        }
    }

    static private func defaultChatViewSettings() {
        KMUserDefaultHandler.setBASEURL(API.Backend.chat.rawValue)
        KMUserDefaultHandler.setGoogleMapAPIKey("AIzaSyCOacEeJi-ZWLLrOtYyj3PKMTOFEG7HDlw") //REPLACE WITH YOUR GOOGLE MAPKEY
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), KMConversationViewController.description()])
        ALApplozicSettings.setFilterContactsStatus(true)
        ALUserDefaultsHandler.setDebugLogsRequire(true)
        ALApplozicSettings.setSwiftFramework(true)
        ALApplozicSettings.hideMessages(withMetadataKeys: ["KM_ASSIGN", "KM_STATUS"])
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
    @available(*, deprecated, message: "Use createConversation(conversation:completion:)")
    @objc open class func createConversation(
        userId: String,
        agentIds: [String] = [],
        botIds: [String]?,
        useLastConversation: Bool = false,
        clientConversationId: String? = nil,
        completion:@escaping (_ clientGroupId: String) -> ()) {
        let kommunicateConversationBuilder = KMConversationBuilder()
            .useLastConversation(useLastConversation)
            .withAgentIds(agentIds)
            .withBotIds(botIds ?? [])
        let conversation =  kommunicateConversationBuilder.build()

        createConversation(conversation: conversation) { (result) in

            switch result {
            case .success(let conversationId):
                completion(conversationId)
            case .failure(_):
                completion("")
            }
        }
    }
}

class ChatMessage: ALKChatViewModelProtocol,Localizable {
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
        let (_,channel) = ConversationDetail().conversationAssignee(groupId: self.channelKey, userId: self.contactId)

        guard let alChannel = channel  else {
            self.groupName = localizedString(forKey: KMLocalizationKey.noName, fileName: Kommunicate.defaultConfiguration.localizedStringFileName)
            return
        }
        self.groupName = alChannel.name ?? localizedString(forKey: KMLocalizationKey.noName, fileName: Kommunicate.defaultConfiguration.localizedStringFileName)
        self.avatarGroupImageUrl = alChannel.channelImageURL
    }

}
