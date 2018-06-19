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

@objc
open class Kommunicate: NSObject {

    //MARK: - Public properties

    /// Returns true if user is already logged in.
    @objc open static var isLoggedIn: Bool {
        return KMUserDefaultHandler.isLoggedIn()
    }

    //MARK: - Private properties

    private static var applicationId = ""

    private var pushNotificationTokenData: Data? {
        didSet {
            updateToken()
        }
    }

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
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: applicationId)

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
                if(Kommunicate.isNilOrEmpty(ALUserDefaultsHandler.getApnDeviceToken() as NSString?))
                {
                    alChatLauncher.registerForNotification()
                }
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
        agentId: String,
        botIds: [String]?,
        useLastConversation: Bool = false,
        completion:@escaping (_ clientGroupId: String) -> ()) {
        let service = KMConversationService()
        if KMUserDefaultHandler.isLoggedIn() {
            service.createConversation(
                userId: KMUserDefaultHandler.getUserId(),
                agentId: agentId,
                botIds: botIds,
                useLastConversation: useLastConversation,
                completion: { response in
                completion(response.clientChannelKey ?? "")
            })
        }
    }

    /**
     Launch chat list from a ViewController.

     - Parameters:
        - viewController: ViewController from which the chat list will be launched.
     */
    @objc open class func showConversations(from viewController: UIViewController) {
        let conversationVC = ALKConversationListViewController()
        let navVC = ALKBaseNavigationViewController(rootViewController: conversationVC)
        viewController.present(navVC, animated: false, completion: nil)
    }

    /**
     Launch group chat from a ViewController

     - Parameters:
        - clientGroupId: clientChannelKey of the Group.
        - viewController: ViewController from which the group chat will be launched.
     */
    static public func showConversationWith(groupId clientGroupId: String, from viewController: UIViewController) {
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) { (channel) in
            guard let channel = channel, let key = channel.key else {return}
            let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: key)
            let conversationViewController = ALKConversationViewController()
            conversationViewController.title = channel.name
            conversationViewController.viewModel = convViewModel
            viewController.navigationController?
                .pushViewController(conversationViewController, animated: false)
        }
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

    static private func defaultChatViewSettings() {
        ALUserDefaultsHandler.setGoogleMapAPIKey("AIzaSyCOacEeJi-ZWLLrOtYyj3PKMTOFEG7HDlw") //REPLACE WITH YOUR GOOGLE MAPKEY
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), ALKConversationViewController.description()])
        ALApplozicSettings.setFilterContactsStatus(true)
        ALUserDefaultsHandler.setDebugLogsRequire(true)
        ALApplozicSettings.setSwiftFramework(true)
    }
}
