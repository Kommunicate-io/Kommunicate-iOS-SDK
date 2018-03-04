//
//  KMChatManager.swift
//  Kommunicate_Example
//
//  Created by Mukesh Thawani on 01/03/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Applozic
import ApplozicSwift
import Kommunicate

var TYPE_CLIENT : Int16 = 0
var TYPE_APPLOZIC : Int16 = 1
var TYPE_FACEBOOK : Int16 = 2

var APNS_TYPE_DEVELOPMENT : Int16 = 0
var APNS_TYPE_DISTRIBUTION : Int16 = 1

class KMChatManager: NSObject {

    static let applicationId = "2a4647fd52360a256f98a9822b18ba656"

    static let shared = KMChatManager(applicationKey: KMChatManager.applicationId as NSString)

    init(applicationKey: NSString) {
        super.init()
        ALUserDefaultsHandler.setApplicationKey(applicationKey as String)

        self.defaultChatViewSettings()

    }

    var pushNotificationTokenData: Data? {
        didSet {
            updateToken()
        }
    }

    func updateToken() {
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


    // ----------------------
    // Call This at time of your app's user authentication OR User registration.
    // This will register your User at applozic server.
    //----------------------

    func registerUser(_ alUser: ALUser, completion : @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void) {
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)

        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()

        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in

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
                if(KMChatManager.isNilOrEmpty(ALUserDefaultsHandler.getApnDeviceToken() as NSString?))
                {
                    alChatLauncher.registerForNotification()
                }
                completion(response , error as NSError?)
            }
        })
    }

    class func isNilOrEmpty(_ string: NSString?) -> Bool {

        switch string {
        case .some(let nonNilString): return nonNilString.length == 0
        default:return true

        }
    }

    func getApplicationKey() -> NSString {

        let appKey = ALUserDefaultsHandler.getApplicationKey() as NSString?
        let applicationKey = appKey
        return applicationKey!;
    }

    func isUserPresent() -> Bool {
        guard let _ = ALUserDefaultsHandler.getApplicationKey() as String?,
            let _ = ALUserDefaultsHandler.getUserId() as String? else {
                return false
        }
        return true
    }

    func logoutUser() {
        let registerUserClientService = ALRegisterUserClientService()
        if let _ = ALUserDefaultsHandler.getDeviceKeyString() {
            registerUserClientService.logout(completionHandler: {
                _, _ in
                NSLog("Applozic logout")
            })
        }
    }

    func defaultChatViewSettings() {
        ALUserDefaultsHandler.setGoogleMapAPIKey("AIzaSyCOacEeJi-ZWLLrOtYyj3PKMTOFEG7HDlw") //REPLACE WITH YOUR GOOGLE MAPKEY
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), ALKConversationViewController.description()])
        ALApplozicSettings.setFilterContactsStatus(true)
        ALUserDefaultsHandler.setDebugLogsRequire(true)
    }

    func launchChatList(from viewController: UIViewController) {
        let conversationVC = ALKConversationListViewController()
        let navVC = ALKBaseNavigationViewController(rootViewController: conversationVC)
        viewController.present(navVC, animated: false, completion: nil)
    }

    func launchChatWith(contactId: String, from viewController: UIViewController) {
        let alContactDbService = ALContactDBService()
        var title = ""
        if let alContact = alContactDbService.loadContact(byKey: "userId", value: contactId), let name = alContact.getDisplayName() {
            title = name
        }
        title = title.isEmpty ? "No name":title
        let convViewModel = ALKConversationViewModel(contactId: contactId, channelKey: nil)
        let conversationViewController = ALKConversationViewController()
        conversationViewController.title = title
        conversationViewController.viewModel = convViewModel
        viewController.navigationController?.pushViewController(conversationViewController, animated: false)
    }

    func launchGroupWith(clientGroupId: String, from viewController: UIViewController) {
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) { (channel) in
            guard let channel = channel, let key = channel.key else {return}
            let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: key)
            let conversationViewController = ALKConversationViewController()
            conversationViewController.title = channel.name
            conversationViewController.viewModel = convViewModel
            viewController.navigationController?.pushViewController(conversationViewController, animated: false)
        }
    }

}


