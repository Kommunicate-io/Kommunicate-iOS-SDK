//
//  Kommunicate.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 07/03/18.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import KommunicateCore_iOS_SDK
import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
    public typealias KMStyle = RichMessageKit.Style
#else
    public typealias KMStyle = KommunicateChatUI_iOS_SDK.Style
#endif

var TYPE_CLIENT: Int16 = 0
var TYPE_APPLOZIC: Int16 = 1
var TYPE_FACEBOOK: Int16 = 2

var APNS_TYPE_DEVELOPMENT: Int16 = 0
var APNS_TYPE_DISTRIBUTION: Int16 = 1

public typealias KMUser = ALUser
public typealias KMUserDefaultHandler = ALUserDefaultsHandler
public typealias KMPushNotificationService = ALPushNotificationService
public typealias KMAppLocalNotification = ALAppLocalNotifications
public typealias KMDbHandler = ALDBHandler
public typealias KMRegisterUserClientService = ALRegisterUserClientService
public typealias KMConfiguration = ALKConfiguration
public typealias KMMessageStyle = ALKMessageStyle
public typealias KMBaseNavigationViewController = ALKBaseNavigationViewController
public typealias KMChatBarConfiguration = ALKChatBarConfiguration
public typealias KMCustomEventHandler = ALKCustomEventHandler

let faqIdentifier = 11_223_346

enum KMLocalizationKey {
    static let noName = "NoName"
}

public enum KMServerConfiguration {
    case euConfiguration
    case defaultConfiguration
}

@objc
open class Kommunicate: NSObject, Localizable {
    // MARK: - Public properties

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
        var faqItem = ALKNavigationItem(identifier: faqIdentifier, text: NSLocalizedString("FaqTitle", value: "FAQ", comment: ""))
        faqItem.faqTextColor = .kmDynamicColor(light: kmConversationViewConfiguration.faqTextColor, dark: kmConversationViewConfiguration.faqTextDarkColor)
        faqItem.faqBackgroundColor = .kmDynamicColor(light: kmConversationViewConfiguration.faqBackgroundColor, dark: kmConversationViewConfiguration.faqDarkBackgroundColor)
        navigationItemsForConversationList.append(faqItem)
        var navigationItemsForConversationView = [ALKNavigationItem]()
        navigationItemsForConversationView.append(faqItem)
        config.navigationItemsForConversationList = navigationItemsForConversationList
        config.navigationItemsForConversationView = navigationItemsForConversationView
        config.disableSwipeInChatCell = true
        config.chatBar.optionsToShow = .some([.camera, .location, .gallery, .video, .document])
        return config
    }()

    /// Configuration which defines the behavior of ConversationView components.
    public static var kmConversationViewConfiguration = KMConversationViewConfiguration()

    public static let shared = Kommunicate()
    public static var presentingViewController = UIViewController()
    public static var leadArray = [LeadCollectionField]()
    static var embeddedViewController: String = ""

    public enum KommunicateError: Error {
        case notLoggedIn
        case conversationNotPresent
        case conversationCreateFailed
        case teamNotPresent
        case conversationUpdateFailed
        case appSettingsFetchFailed
        case prechatFormNotFilled
        case bothTeamIDAndAssigneeIDShouldNotPresent
        case clientConversationIdNotPresent
        case conversationOpenFailed
        case zendeskKeyNotPresent
    }

    // MARK: - Private properties

    private static var applicationId = ""

    private var pushNotificationTokenData: Data? {
        didSet {
            updateToken()
        }
    }

    public class func isFridaRunning() -> Bool {
        func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
            let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
            return littleEndian ? _OSSwapInt16(port) : port
        }
         
        var serverAddress = sockaddr_in()
        serverAddress.sin_family = sa_family_t(AF_INET)
        serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
        serverAddress.sin_port = swapBytesIfNeeded(port: in_port_t(27042))
        let sock = socket(AF_INET, SOCK_STREAM, 0)
         
        let result = withUnsafePointer(to: &serverAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }
        if result != -1 {
            return true
        }
        return false
    }

    private static var isJailbrokenCache: Bool?

    public class func isDeviceJailbroken() -> Bool {
        // If the result is already cached, return it
        if let cachedResult = isJailbrokenCache {
            return cachedResult
        }

        // Perform the jailbreak detection only once
        let isJailbroken: Bool = {
            // Return false immediately if root detection is disabled in the configuration
            guard defaultConfiguration.rootDetection else { return false }
                
            // Return false if the app is running on a simulator
            #if targetEnvironment(simulator)
            return false
            #endif
                
            // List of paths for suspicious apps that indicate jailbreaking
            let suspiciousAppsPaths = [
                "/Applications/Cydia.app",
                "/Applications/blackra1n.app",
                "/Applications/FakeCarrier.app",
                "/Applications/Icy.app",
                "/Applications/IntelliScreen.app",
                "/Applications/MxTube.app",
                "/Applications/RockApp.app",
                "/Applications/SBSettings.app",
                "/Applications/WinterBoard.app"
            ]
                
            // Check if any of the suspicious apps are installed
            for path in suspiciousAppsPaths {
                if FileManager.default.fileExists(atPath: path) {
                    return true
                }
            }
                
            // Check if Frida is running in the background
            if isFridaRunning() {
                return true
            }
                
            // Return false if no suspicious apps are found
            return false
        }()
            
        // Cache the result
        isJailbrokenCache = isJailbroken
            
        return isJailbroken
    }

    static var applozicClientType: ApplozicClient.Type = ApplozicClient.self

    override public init() {
        super.init()
    }

    // MARK: - Public methods

    /**
     Setup an App ID. It will be used for all Kommunicate related requests.

     - NOTE: If the App ID is modified then make sure to log out and log in.

     - Parameters:
     - applicationId: App ID that needs to be set up.
     */
    @objc open class func setup(applicationId: String) {
        guard !applicationId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            assertionFailure("Kommunicate App ID: Empty value passed")
            return
        }
        guard KMUserDefaultHandler.isAppIdEmpty ||
            KMUserDefaultHandler.matchesCurrentAppId(applicationId)
        else {
            assertionFailure("Kommunicate App ID changed: log out and log in again")
            return
        }
        self.applicationId = applicationId
        ALUserDefaultsHandler.setApplicationKey(applicationId)
        Kommunicate.shared.defaultChatViewSettings()
        Kommunicate.shared.setupDefaultStyle()
    }

    /**
     Registers a new user, if it's already registered then user will be logged in.

     - Parameters:
     - kmUser: A KMUser object which contains user details.
     - completion: The callback with registration response and error.
     */
    @objc open class func registerUser(
        _ kmUser: KMUser,
        completion: @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void
    ) {
        guard !isDeviceJailbroken() else {
            let errorPass = NSError(domain: "It seems that user device is rooted. Can't perform Login.", code: 0, userInfo: nil)
            completion(nil, errorPass as NSError?)
            return
        }
        let validationError = validateUserData(user: kmUser)
        guard validationError == nil else {
            print("Error while registering the user to Kommunicate: ", validationError!.localizedDescription)
            completion(nil, validationError)
            return
        }

        if isLoggedIn, let appID = KMUserDefaultHandler.getApplicationKey(), let currentUserId = KMUserDefaultHandler.getUserId(), currentUserId != kmUser.userId {
            // LOGOUT the current user & login Again
            logoutUser(completion: { result in
                switch result {
                case .success:
                    setup(applicationId: appID)
                    registerNewUser(kmUser, isVisitor: false, completion: completion)
                case .failure:
                    print("Error while logging out the existing user")
                    let errorPass = NSError(domain: "Error while logging out the existing user", code: 0, userInfo: nil)
                    completion(nil, errorPass as NSError?)
                }
            })
            return
        }
        registerNewUser(kmUser, isVisitor: false, completion: completion)
    }
    
    /// Deprecated wrapper for backward compatibility
    @available(*, deprecated, message: "Use `registerUserAsVisitor(_:completion:)` instead.")
    @objc open class func registerUserAsVistor( // Note: Typo preserved intentionally
        _ kmUser: KMUser = createVisitorUser(),
        completion: @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void
    ) {
        registerUserAsVisitor(kmUser, completion: completion)
    }
    
    @objc open class func registerUserAsVisitor(
        _ kmUser: KMUser = createVisitorUser(),
        completion: @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void
    ) {
        guard !isDeviceJailbroken() else {
            let errorPass = NSError(domain: "It seems that user device is rooted. Can't perform Login.", code: 0, userInfo: nil)
            completion(nil, errorPass as NSError?)
            return
        }
        if isLoggedIn, let appID = KMUserDefaultHandler.getApplicationKey(), let currentUserId = KMUserDefaultHandler.getUserId(), currentUserId != kmUser.userId {
            // LOGOUT the current user & login Again
            logoutUser(completion: { result in
                switch result {
                case .success:
                    setup(applicationId: appID)
                    registerNewUser(kmUser, isVisitor: true, completion: completion)
                case .failure:
                    print("Error while logging out the existing user")
                    let errorPass = NSError(domain: "Error while logging out the existing user", code: 0, userInfo: nil)
                    completion(nil, errorPass as NSError?)
                }
            })
            return
        }
        registerNewUser(kmUser, isVisitor: true, completion: completion)
    }
    
    @objc open class func createVisitorUser() -> KMUser {
        let kmUser = KMUser()
        kmUser.userId = randomId()
        return kmUser
    }
    
    private class func registerNewUser(_ kmUser: KMUser, isVisitor : Bool, completion: @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void) {
        
        let kmAppSetting = KMAppSettingService()
        kmAppSetting.appSetting { result in
            switch result {
            case let .success(appSetting):
                DispatchQueue.main.async {
                    kmAppSetting.updateAppsettings(chatWidgetResponse: appSetting.chatWidget)
                    KMAppUserDefaultHandler.shared.isCSATEnabled
                        = appSetting.collectFeedback ?? false
                    if !KMAppUserDefaultHandler.shared.isCSATEnabled {
                        Kommunicate.defaultConfiguration.rateConversationMenuOption = false
                    }
                    if let zendeskaccountKey = appSetting.chatWidget?.zendeskChatSdkKey {
                        ALApplozicSettings.setZendeskSdkAccountKey(zendeskaccountKey)
                    }
                    if let chatWidget = appSetting.chatWidget, let isSingleThreaded = chatWidget.isSingleThreaded, isSingleThreaded != ALApplozicSettings.getIsSingleThreadedEnabled() {
                        ALApplozicSettings.setIsSingleThreadedEnabled(isSingleThreaded)
                    }
                    
                    if isVisitor,
                       kmUser.displayName == nil,
                       let chaWidget = appSetting.chatWidget,
                       let pseudonymsEnabled = chaWidget.pseudonymsEnabled,
                       pseudonymsEnabled {
                        kmUser.metadata = modifyVisitorMetadata(kmUser: kmUser)
                        kmUser.displayName = appSetting.userName
                    }
                    
                    let registerUserClientService = ALRegisterUserClientService()
                    registerUserClientService.initWithCompletion(kmUser, withCompletion: { response, error in
                        if error != nil {
                            print("Error while registering the user to Kommunicate")
                            let errorPass = NSError(domain: "Error while registering the user to Kommunicate", code: 0, userInfo: nil)
                            completion(response, errorPass as NSError?)
                        } else if !(response?.isRegisteredSuccessfully())! {
                            let errorPass = NSError(domain: "Invalid Password", code: 0, userInfo: nil)
                            print("Error while registering the user to Kommunicate: ", errorPass.localizedDescription)
                            completion(response, errorPass as NSError?)
                        } else {
                            print("Registered the user to Kommunicate")
                            completion(response, error as NSError?)
                        }
                    })
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "Error getting app settings", code: 0, userInfo: nil))
                }
            }
        }
    }
    
    private class func modifyVisitorMetadata(kmUser : KMUser) -> NSMutableDictionary {
        var metadata = kmUser.metadata
        if metadata == nil {
            metadata = NSMutableDictionary()
        }
        var toAdd : [String : Any] = [ChannelMetadataKeys.pseudoName : "true"]
        toAdd.updateValue("true", forKey: "hidden")
        updateVisitorMetadata(toAdd: toAdd, metadata: metadata!, updateContext: ChannelMetadataKeys.kmPseudoUser)
        return metadata!
    }
    
    private class func updateVisitorMetadata(toAdd: [String: Any], metadata : NSMutableDictionary, updateContext : String) {
        var context: [String: Any] = [:]

        do {
            let contextDict = try alreadyPresentMetadata(metadata: metadata as? [AnyHashable : Any], context: updateContext)
            context = contextDict ?? [:]
            context.merge(toAdd, uniquingKeysWith: { $1 })

            let messageInfoData = try JSONSerialization
                .data(withJSONObject: context, options: .prettyPrinted)
            let messageInfoString = String(data: messageInfoData, encoding: .utf8) ?? ""
            metadata[updateContext] = messageInfoString
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private class func alreadyPresentMetadata(metadata : [AnyHashable: Any]? , context : String) -> [String: Any]? {
        guard
            let metadata = metadata,
            let context = metadata[context] as? String,
            let contextData = context.data(using: .utf8)
        else {
            return nil
        }
        do {
            let contextDict = try JSONSerialization
                .jsonObject(with: contextData, options: .allowFragments) as? [String: Any]
            return contextDict
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    /// Logs out the current logged in user and clears all the cache.
    open class func logoutUser(completion: @escaping (Result<String, KMError>) -> Void) {
        let applozicClient = applozicClientType.init(applicationKey: KMUserDefaultHandler.getApplicationKey())
        applozicClient?.logoutUser(completion: { error, _ in
            Kommunicate.shared.clearUserDefaults()
        #if canImport(ChatProvidersSDK)
            KMZendeskChatHandler.shared.endChat()
        #endif
            guard error == nil else {
                completion(.failure(KMError.api(error)))
                return
            }
            completion(.success("success"))
        })
    }
    
    /// Fetches appsettings, configuration set on dashbaord
    open class func refreshAppsettings() {
        let appSettingsService = KMAppSettingService()
        appSettingsService.appSetting {
            result in
            switch result {
            case let .success(appSettings):
                if let chatWidget = appSettings.chatWidget,
                   let isSingleThreaded = chatWidget.isSingleThreaded,
                   isSingleThreaded != ALApplozicSettings.getIsSingleThreadedEnabled() {
                    ALApplozicSettings.setIsSingleThreadedEnabled(isSingleThreaded)
                }
            case let .failure(error):
                print("Failed to fetch Appsettings due to \(error.localizedDescription)")
                return
            }
        }
    }
    
    
    /// Creates a new conversation with the details passed.
    /// - Parameter conversation: An instance of `KMConversation` object.
    /// - Parameter completion: If successful the success callback will have a conversationId else it will be KMConversationError on failure.
    open class func createConversation(
        conversation: KMConversation = KMConversationBuilder().build(),
        completion: @escaping (Result<String, KMConversationError>) -> Void
    ) {
        guard !isDeviceJailbroken() else {
            print("The user device is suspected to be rooted.")
            completion(.failure(KMConversationError.deviceRooted))
            return
        }
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
            refreshAppsettings()
            // If single threaded is not enabled for this conversation,
            // then check in global app settings.
            let isSingleThreaded = ALApplozicSettings.getIsSingleThreadedEnabled()
            if isSingleThreaded {
                conversation.useLastConversation = isSingleThreaded
            }
            let isClientIdEmpty = (conversation.clientConversationId ?? "").isEmpty
            
            if isClientIdEmpty, conversation.useLastConversation {
                conversation.clientConversationId = service.createClientIdFrom(
                    userId: conversation.userId,
                    agentIds: conversation.agentIds,
                    botIds: conversation.botIds ?? []
                )
            }
            
            service.createConversation(conversation: conversation, completion: { response in
                DispatchQueue.main.async {
                    guard let conversationId = response.clientChannelKey else {
                        completion(.failure(KMConversationError.api(response.error)))
                        return
                    }
                    KMCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.newConversation, data: ["conversationId": conversationId])
                    completion(.success(conversationId))
                }
            })
        } else {
            completion(.failure(KMConversationError.notLoggedIn))
        }
    }
    
    /**
     Launch a new conversation with the details passed in group chat from a ViewController

     - Parameters:
     - conversation: An instance of `KMConversation` object.
     - viewController: ViewController from which the group chat will be launched.
     - completionHandler: If successful launch the conversation the success callback will have a conversationId else it will be KMConversationError on failure.

     */
    open class func launchConversation(
        conversation: KMConversation,
        viewController: UIViewController,
        completion: @escaping (Result<String, KMConversationError>) -> Void
    ) {
        // Check if the device is jailbroken
        guard !isDeviceJailbroken() else {
            print("The user device is suspected to be rooted.")
            completion(.failure(KMConversationError.deviceRooted))
            return
        }
        
        // Check network availability
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else {
            completion(.failure(KMConversationError.internet))
            return
        }
        
        // Validate conversation title
        if let conversationTitle = conversation.conversationTitle,
           conversationTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("The conversation title should not be empty")
            completion(.failure(KMConversationError.invalidTitle))
            return
        }

        let service = KMConversationService()

        // Check user login status
        guard KMUserDefaultHandler.isLoggedIn() else {
            completion(.failure(KMConversationError.notLoggedIn))
            return
        }

        // Refresh app settings
        refreshAppsettings()

        // Determine if single-threaded conversation is enabled
        let isSingleThreaded = ALApplozicSettings.getIsSingleThreadedEnabled()
        if isSingleThreaded {
            conversation.useLastConversation = isSingleThreaded
        }

        // Handle clientConversationId for single-threaded conversations
        if (conversation.clientConversationId ?? "").isEmpty, conversation.useLastConversation {
            conversation.clientConversationId = service.createClientIdFrom(
                userId: conversation.userId,
                agentIds: conversation.agentIds,
                botIds: conversation.botIds ?? []
            )
        }

        // Create a new conversation
        service.createConversation(conversation: conversation) { response in
            DispatchQueue.main.async {
                guard let conversationId = response.clientChannelKey else {
                    completion(.failure(KMConversationError.api(response.error)))
                    return
                }

                // Publish a custom event for the new conversation
                KMCustomEventHandler.shared.publish(
                    triggeredEvent: KMCustomEvent.newConversation,
                    data: ["conversationId": conversationId]
                )

                // Show the conversation view
                showConversationWith(
                    groupId: conversationId,
                    from: viewController,
                    prefilledMessage: conversation.prefilledMessage
                ) { success in
                    DispatchQueue.main.async {
                        guard success else {
                            completion(.failure(KMConversationError.api(KommunicateError.conversationOpenFailed)))
                            return
                        }
                        completion(.success(conversationId))
                    }
                }
            }
        }
    }

    /// This method is used to return an instance of conversation list view controller.
    ///
    /// - Returns: Instance of `ALKConversationListViewController`
    @objc open class func conversationListViewController() -> KMConversationListViewController {
        let conversationVC = KMConversationListViewController(configuration: Kommunicate.defaultConfiguration, kmConversationViewConfiguration: Kommunicate.kmConversationViewConfiguration)
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
        viewController.present(navVC, animated: true, completion: nil)
    }
    
    /**
      Launch chat list inside a container..
      - Parameters:
      - viewController: ViewController from which the chat list  will be added as child vc
      - rootView: view container where chat will be loaded.
      */
     @objc open class func embedConversationList(from viewController: UIViewController, on rootView: UIView) {
         updateSettingsForEmbeddedMode(viewController: viewController)
         openChatIn(rootView: rootView, groupId: 0, from: viewController, showListOnBack: true,completionHandler: {_ in
         })
     }
    
    /**
     Close the Conversation Screen
     - Parameters:
     - viewController: ViewController from where ConversationVC  presented
     */
    @objc public static func closeConversationVC(from viewController: UIViewController) {
        guard let navController = viewController.navigationController,let topVC = navController.visibleViewController, topVC.isKind(of: KMConversationViewController.self) || topVC.isKind(of: KMConversationListViewController.self) else { return }
        let poppedVC = navController.popViewController(animated: true)
        if poppedVC == nil {
            topVC.dismiss(animated: true)
        }
    }
    
    /**
     Launch group chat from a ViewController

     - Parameters:
     - clientGroupId: clientChannelKey of the Group.
     - viewController: ViewController from which the group chat will be launched.
     - prefilledMessage: Prefilled message for chatbox.
     - showListOnBack: If true, then the conversation list will be shown on tap of the back button,
     - completionHandler: Called with the information whether the conversation was
     shown or not.

     */
    @objc open class func showConversationWith(
        groupId clientGroupId: String,
        from viewController: UIViewController,
        prefilledMessage: String? = nil,
        showListOnBack: Bool = false,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) { channel in
            guard let channel = channel, let key = channel.key else {
                completionHandler(false)
                return
            }
            
            // Fetch Chat Context & check for custom bot name in it.if its present then store it in local
            do {
                if let messageMetadata = channel.metadata as? [String: Any],
                    let jsonData = messageMetadata[ChannelMetadataKeys.chatContext] as? String,
                    !jsonData.isEmpty,
                    let data = jsonData.data(using: .utf8),
                    let chatContextData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any],
                    let customBot = chatContextData["bot_customization"] as? [String: String],
                    let customBotName = customBot["name"],
                    let customBotId = customBot["id"],
                    !customBotName.isEmpty, !customBotId.isEmpty {
                        ALApplozicSettings.setCustomBotName(customBotName)
                        ALApplozicSettings.setCustomizedBotId(customBotId)
                } else {
                    ALApplozicSettings.clearCustomBotConfiguration()
                }
                
            } catch {
                print("Failed to fetch custom bot name")
                ALApplozicSettings.clearCustomBotConfiguration()
            }
          
            self.openChatWith(
                groupId: key,
                from: viewController,
                prefilledMessage: prefilledMessage,
                showListOnBack: showListOnBack
             ) { result in
                 completionHandler(result)
             }
        }
    }
    
    /**
     Launch group chat in a container

     - Parameters:
     - rootView: UIView in which Conversation needs to be loaded
     - clientGroupId: clientChannelKey of the Group.
     - viewController: ViewController from which the group chat will be launched.
     - prefilledMessage: Prefilled message for chatbox.
     - showListOnBack: If true, then the conversation list will be shown on tap of the back button,
     - completionHandler: Called with the information whether the conversation was
     shown or not.

     */
    @objc open class func showConversationIn(
        rootView: UIView,
        groupId clientGroupId: String,
        from viewController: UIViewController,
        prefilledMessage: String? = nil,
        showListOnBack: Bool = false,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) { channel in
            guard let channel = channel, let key = channel.key else {
                completionHandler(false)
                return
            }
            
            openChatIn(rootView: rootView, groupId: key, from: viewController, prefilledMessage: prefilledMessage,showListOnBack: showListOnBack){ result in
                completionHandler(result)
            }
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
        completion: @escaping (_ error: KommunicateError?) -> Void
    ) {
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
     Creates and launches the conversation based on zendesk session.

     - Parameters:
     - viewController: ViewController from which the group chat will be launched.
     */
    open class func openZendeskChat(from: UIViewController,completion: @escaping (_ error: KommunicateError?) -> Void) {
        #if canImport(ChatProvidersSDK)
        let zendeskHandler = KMZendeskChatHandler.shared
        guard let accountKey = ALApplozicSettings.getZendeskSdkAccountKey(), !accountKey.isEmpty else {
            completion(.zendeskKeyNotPresent)
            return
        }

        guard let existingZendeskConversationId = ALApplozicSettings.getLastZendeskConversationId(),
              existingZendeskConversationId != 0 else {
                zendeskHandler.resetConfiguration()
                zendeskHandler.initiateZendesk(key: accountKey)
                // If there is no existing conversation id then create a new conversation.
                let kmConversation = KMConversationBuilder()
                              .useLastConversation(false)
                              .build()

                createConversation(conversation: kmConversation) { result in
                  switch result {
                   case .success(let conversationId):
                      ALApplozicSettings.setLastZendeskConversationId(NSNumber(value: Int(conversationId) ?? 0))
                      
                      print("New Conversation is created for Zendesk Configuration. Conversation id: ",conversationId)
                      showConversationWith(
                          groupId: conversationId,
                          from: from,
                          showListOnBack: false, // If true, then the conversation list will be shown on tap of the back button.
                          completionHandler: { success in
                              success == true ? completion(nil) : completion(.conversationOpenFailed)
                          print("conversation was shown")
                              
                      })
                   case .failure(let kmConversationError):
                      completion(.conversationCreateFailed)
                      print("Failed to create a conversation: ", kmConversationError)
                  }
              }
            return
        }
        
        // Update group id so that messages can be fetched & stored locally
        zendeskHandler.setGroupId(existingZendeskConversationId.stringValue)

        guard let channel = ALChannelService().getChannelByKey(existingZendeskConversationId)  else {
            completion(.conversationNotPresent)
            return
        }
        // If bot is handling the chat then we shouldn't send any messages to Zendesk.
        if let assignee = channel.assigneeUserId, !assignee.isEmpty,
           let contact = ALContactService().loadContact(byKey: "userId", value: assignee) {
            if contact.roleType == NSNumber.init(value: AL_APPLICATION_WEB_ADMIN.rawValue) {
                zendeskHandler.handedOffToAgent(groupId: existingZendeskConversationId.stringValue, happendNow: false)
            }
        }
        
        zendeskHandler.initiateZendesk(key: accountKey)
        // Open Conversation
        showConversationWith(groupId: existingZendeskConversationId.stringValue, from: from, completionHandler: { bool in
            bool == true ? completion(nil) : completion(.conversationOpenFailed)
            print("Opening Existing conversation which is assigned to BOT")
        })
    #endif
    }
    
    /**
     Creates and launches the conversation. In case multiple conversations
     are present then the conversation list will be presented. If a single
     conversation is present then that will be launched.
     - Parameters:
     - viewController: ViewController where the group chat will be launched.
     - rootView: view container where the group chat will be loaded.
     */
    open class func createAndEmbedConversation(from viewController: UIViewController,rootView:UIView,completion: @escaping (_ error: KommunicateError?) -> Void) {
        guard isLoggedIn else {
            completion(KommunicateError.notLoggedIn)
            return
        }
        updateSettingsForEmbeddedMode(viewController: viewController)
        let applozicClient = applozicClientType.init(applicationKey: KMUserDefaultHandler.getApplicationKey())
        applozicClient?.getLatestMessages(false, withCompletionHandler: {
            messageList, error in
            print("Kommunicate: message list received")

            // If more than 1 thread is present then the list will be shown
            if let messages = messageList, messages.count > 1, error == nil {
                embedConversationList(from: viewController, on: rootView)
                completion(nil)
            } else {
                createAConversationAndLaunch(from: viewController, on: rootView,completion: {
                    conversationError in
                    completion(conversationError)
                })
            }
        })
    }


    /**
     Updates the conversation parameters.
     Requires the conversation ID and the specific parameters that need to be updated for the specified conversation ID.
     Use this method to update either assignee or teamId & metadata. Should not use this method to update assignee & teamId at the same time.

     - Parameters:
     - conversation: Conversation that needs to be updated
     - completion: Called with the status of the conversation update
     */
    open class func updateConversation(conversation: KMConversation, completion: @escaping (Result<String, KommunicateError>) -> Void) {
        guard let clientConversationId = conversation.clientConversationId, !clientConversationId.isEmpty else { return completion(.failure(.clientConversationIdNotPresent)) }
        
        if conversation.conversationAssignee != nil && conversation.teamId != nil {
            return completion(.failure(.bothTeamIDAndAssigneeIDShouldNotPresent))
        }
      
        let service = KMConversationService()
        if let assignee = conversation.conversationAssignee {
            service.isGroupPresent(clientId: clientConversationId, completion: { present, channel in
                guard present else{
                    return completion(.failure(.conversationNotPresent))
                }
                let groupID = Int(truncating: channel?.key ?? 0)
                
                guard groupID != 0 else{
                    return completion(.failure(.conversationUpdateFailed))
                }

                service.assignConversation(groupId: groupID, to: assignee){ result in
                    switch result {
                    case .success:
                        completion(.success(clientConversationId))
                    case .failure(_):
                        completion(.failure(.conversationUpdateFailed))
                    }
                }
            
            })
            return
        }

        let defaultMetaData = NSMutableDictionary (
            dictionary: ALChannelService().metadataToHideActionMessagesAndTurnOffNotifications())
    
        if let conversationMetaDict = conversation.conversationMetadata as NSDictionary? as! [String:Any]? {
            let jsonObject = try? JSONSerialization.data(withJSONObject: conversationMetaDict, options: [])
            if let jsonString = String(data: jsonObject!, encoding: .utf8) {
                defaultMetaData.setValue(jsonString, forKey: ChannelMetadataKeys.conversationMetaData)
            }
        }

        if let teamId = conversation.teamId {
            defaultMetaData.setValue(teamId, forKey: ChannelMetadataKeys.teamId)
        }
        
        service.updateConversationMetadata(groupId: clientConversationId, metadata: defaultMetaData) { response in
            if response.success {
                completion(.success(clientConversationId))
            } else {
                completion(.failure(KommunicateError.conversationUpdateFailed))
            }
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
    
    /**
        Fetches appsettings configuration and get the disable chat widget config.
     - Parameter completion: returns disablechatwidget configuration value
 
     */
      @objc open class func isChatWidgetDisabled(completionHandler: @escaping (Bool) -> Void) {
        let appSettingsService = KMAppSettingService()
        appSettingsService.appSetting {
            result in
            switch result {
            case let .success(appSettings):
                guard let chatWidget = appSettings.chatWidget,
                      let isWidgetDisabled = chatWidget.disableChatWidget else {
                    completionHandler(false)
                    return
                }
                completionHandler(isWidgetDisabled)
            case .failure:
               completionHandler(false)
            }
        }
    }

    open class func openFaq(from vc: UIViewController, with configuration: ALKConfiguration) {
        guard let url = URLBuilder.faqURL(for: ALUserDefaultsHandler.getApplicationKey(), hideChat: configuration.hideChatInHelpcenter).url else {
            return
        }
        let faqVC = FaqViewController(url: url, configuration: configuration)
        let navVC = KMBaseNavigationViewController(rootViewController: faqVC)
        vc.present(navVC, animated: true, completion: nil)
    }
    
    /// Updates the assigned status dynamically based on code logic.
    ///  - Parameter assigneeID: The Channel ID parameter is required to match the conversation in which the status needs to be updated. If the Channel ID is not provided, the status will be updated in all conversations.
    ///  - Parameter status: A predefined status among 'Online', 'Offline', 'Away', and 'Default'. The 'Default' status corresponds to the assignee status fetched from MQTT.
    open class func updateAssigneeStatus(assigneeID: String = "", status: KMUserStatus) {
        KMUpdateAssigneeStatus.shared.assigneeID = assigneeID
        KMUpdateAssigneeStatus.shared.status = status
    }

    /// Sends a new message from the logged-in user.
    /// - Parameter message: An instance of `KMMessage` object.
    /// - Parameter completion: If there's any error while sending this message, then it will be returned in this block.
    open class func sendMessage(
        message: KMMessage,
        completion: @escaping (Error?) -> Void
    ) {
        guard !message.conversationId.isEmpty else {
            let emptyConversationId = NSError(domain: "Empty conversation ID", code: 0, userInfo: nil)
            completion(emptyConversationId)
            return
        }
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: message.conversationId) { channel in
            guard let channel = channel, let key = channel.key else {
                let noConversationError = NSError(domain: "No conversation found", code: 0, userInfo: nil)
                completion(noConversationError)
                return
            }
            let alMessage = message.toALMessage()
            alMessage.groupId = key
            ALMessageService.sharedInstance().sendMessages(alMessage) { _, error in
                guard error == nil else {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
    }

    /**
     Creates and launches the conversation with PreChat Lead Collection.

     - Parameters:
     - appID: User's application ID.
     - conversation: Instance of a KMConversation object, can be set to nil or customized as required.
     - viewController: ViewController from which the pre-chat form view will be launched.
     */

    open class func createConversationWithPreChat(appID: String, conversation: KMConversation?, viewController: UIViewController, completion: @escaping (KommunicateError?) -> Void) {
        KMUserDefaultHandler.setApplicationKey(appID)
        Kommunicate.presentingViewController = viewController

        let kmAppSetting = KMAppSettingService()
        kmAppSetting.appSetting { result in
            switch result {
            case let .success(appSetting):
                guard let isPreChatEnable = appSetting.collectLead else { return }
                if isPreChatEnable {
                    UserDefaults.standard.set(appSetting.chatWidget?.preChatGreetingMsg!, forKey: "leadCollectionTitle")
                    leadArray = appSetting.leadCollection!

                    if !KMUserDefaultHandler.isLoggedIn() {
                        DispatchQueue.main.async {
                            if !Kommunicate.leadArray.isEmpty {
                                let customPreChatVC = CustomPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)
                                customPreChatVC.submitButtonTapped = { (response: [String: String]) in

                                    Kommunicate.userSubmittedResponse(name: response[CustomPreChatFormViewController.name] ?? "", email: response[CustomPreChatFormViewController.email] ?? "", phoneNumber: response[CustomPreChatFormViewController.phone] ?? "", password: "")
                                }
                                customPreChatVC.closeButtonTapped = {
                                    Kommunicate().closeButtonTapped()
                                }
                                viewController.present(customPreChatVC, animated: false, completion: nil)
                            } else {
                                let preChatVC = KMPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)
                                preChatVC.submitButtonTapped = {
                                    Kommunicate.userSubmittedResponse(name: preChatVC.formView.nameTextField.text!, email: preChatVC.formView.emailTextField.text!, phoneNumber: preChatVC.formView.phoneNumberTextField.text!, password: "")
                                }
                                preChatVC.closeButtonTapped = {
                                    Kommunicate().closeButtonTapped()
                                }
                                viewController.present(preChatVC, animated: false, completion: nil)
                            }
                        }
                    }
                    completion(nil)
                } else {
                    print("Pre-Chat Lead Collection is not enabled.")

                    _ = applozicClientType.init(applicationKey: appID)
                    let kmUser = KMUser()
                    kmUser.userId = Kommunicate.randomId()
                    kmUser.applicationId = applicationId

                    Kommunicate.registerUser(kmUser, completion: {
                        response, error in
                        guard error == nil else {
                            print("[REGISTRATION] Kommunicate user registration error: %@", error.debugDescription)
                            return
                        }
                        print("User registration was successful: %@ \(String(describing: response?.isRegisteredSuccessfully()))")

                        if conversation != nil {
                            createConversation(conversation: conversation!) { result in
                                switch result {
                                case let .success(conversationId):
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
                                case .failure:
                                    completion(KommunicateError.conversationCreateFailed)
                                    return
                                }
                            }
                        } else {
                            Kommunicate.createAndShowConversation(from: viewController, completion: {
                                error in
                                if error != nil {
                                    print("Error while launching")
                                }
                            })
                            let kommunicateConversationBuilder = KMConversationBuilder()
                                .useLastConversation(false)
                            let conversation = kommunicateConversationBuilder.build()
                            createConversation(conversation: conversation) { result in
                                switch result {
                                case let .success(conversationId):
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
                                case .failure:
                                    completion(KommunicateError.conversationCreateFailed)
                                    return
                                }
                            }
                        }
                    })
                }
            case let .failure(error):
                print("Error in fetching Kommunicate app settings: %@", error)
                completion(KommunicateError.appSettingsFetchFailed)
            }
        }
    }

    /**
     launches the PreChat Lead Collection with custom payload

      - Parameters:
      - appID: User's application ID.
      - inputList: list of LeadCollectionField objects to create a form in pre Chat.
      - viewController: ViewController from which the pre-chat form view will be launched.
      - prechatCompletion:  Callback to inform prechat launched successfully or not
      - onFormCompletion: Callback to pass form response or error
      */
    open class func launchPreChatWithCustomPayload(appID: String, viewController: UIViewController, inputList: [LeadCollectionField], prechatcompletion: @escaping (KommunicateError?) -> Void, onFormCompletion: @escaping ([String: String]?, KommunicateError?) -> Void) {
        KMUserDefaultHandler.setApplicationKey(appID)
        Kommunicate.presentingViewController = viewController

        leadArray = inputList

        if !KMUserDefaultHandler.isLoggedIn() {
            DispatchQueue.main.async {
                if !Kommunicate.leadArray.isEmpty {
                    let customPreChatVC = CustomPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)

                    customPreChatVC.submitButtonTapped = { (response: [String: String]) in
                        onFormCompletion(response, nil)
                        Kommunicate.presentingViewController.dismiss(animated: true, completion: nil)
                    }
                    customPreChatVC.closeButtonTapped = {
                        Kommunicate().closeButtonTapped()
                        onFormCompletion(nil, .prechatFormNotFilled)
                    }
                    viewController.present(customPreChatVC, animated: true, completion: nil)
                    prechatcompletion(nil)
                } else {
                    let preChatVC = KMPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)
                    preChatVC.submitButtonTapped = {
                        Kommunicate.userSubmittedResponse(name: preChatVC.formView.nameTextField.text!, email: preChatVC.formView.emailTextField.text!, phoneNumber: preChatVC.formView.phoneNumberTextField.text!, password: "")
                    }
                    preChatVC.closeButtonTapped = {
                        Kommunicate().closeButtonTapped()
                        onFormCompletion(nil, .prechatFormNotFilled)
                    }
                    viewController.present(preChatVC, animated: true, completion: nil)
                    prechatcompletion(nil)
                }
            }
        }
        prechatcompletion(nil)
    }

    open class func userSubmittedResponse(name: String, email: String, phoneNumber: String, password _: String) {
        guard let appID = KMUserDefaultHandler.getApplicationKey() else { return }
        Kommunicate.presentingViewController.dismiss(animated: false, completion: nil)
        let kmUser = KMUser()
        kmUser.applicationId = appID

        if !email.isEmpty {
            kmUser.userId = email
            kmUser.email = email
        } else if !name.isEmpty {
            kmUser.userId = name
        } else if !phoneNumber.isEmpty {
            kmUser.userId = phoneNumber
        } else {
            kmUser.userId = Kommunicate.randomId()
        }

        if !phoneNumber.isEmpty {
            kmUser.contactNumber = phoneNumber
        }
        kmUser.contactNumber = phoneNumber
        kmUser.displayName = name

        Kommunicate.setup(applicationId: appID)
        Kommunicate.registerUser(kmUser, completion: {
            response, error in
            guard error == nil else {
                print("[REGISTRATION] Kommunicate user registration error: %@", error.debugDescription)
                return
            }
            print("User registration was successful: %@ \(String(describing: response?.isRegisteredSuccessfully()))")
            Kommunicate.createAndShowConversation(from: Kommunicate.presentingViewController, completion: {
                error in
                if error != nil {
                    print("Error while launching conversation")
                }
            })
        })
    }

    public func closeButtonTapped() {
        Kommunicate.presentingViewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - Internal methods

    class func configureListVC(_ vc: KMConversationListViewController) {
        vc.conversationListTableViewController.dataSource.cellConfigurator = {
            messageModel, tableCell in
            let cell = tableCell as! ALKChatCell
            let message = ChatMessage(message: messageModel)
            cell.update(viewModel: message, identity: nil)
            cell.delegate = vc.conversationListTableViewController.self
        }
        let conversationViewController = KMConversationViewController(configuration: Kommunicate.defaultConfiguration, conversationViewConfiguration: kmConversationViewConfiguration, individualLaunch: false)
        conversationViewController.viewModel = ALKConversationViewModel(contactId: nil, channelKey: nil, localizedStringFileName: defaultConfiguration.localizedStringFileName)
        vc.conversationViewController = conversationViewController
    }

    class func openChatWith(
        groupId: NSNumber,
        from viewController: UIViewController,
        prefilledMessage: String? = nil,
        showListOnBack: Bool = false,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if showListOnBack {
            let conversationListVC = conversationListViewController()
            conversationListVC.channelKey = groupId
            let navVC = KMBaseNavigationViewController(rootViewController: conversationListVC)
            navVC.modalPresentationStyle = .fullScreen
            viewController.present(navVC, animated: true) {
                completionHandler(true)
            }
        } else {
            let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: groupId, localizedStringFileName: defaultConfiguration.localizedStringFileName, prefilledMessage: prefilledMessage)
            let conversationVC = KMConversationViewController(configuration: Kommunicate.defaultConfiguration, conversationViewConfiguration: kmConversationViewConfiguration)
            conversationVC.viewModel = convViewModel
            let navVC = KMBaseNavigationViewController(rootViewController: conversationVC)
            navVC.modalPresentationStyle = .fullScreen
            viewController.present(navVC, animated: true) {
                completionHandler(true)
            }
        }
    }
    
    class func openChatIn(
        rootView:UIView,
        groupId: NSNumber,
        from viewController: UIViewController,
        prefilledMessage: String? = nil,
        showListOnBack: Bool = false,
        completionHandler: @escaping (Bool) -> Void
     ) {
         if showListOnBack {
             let conversationListVC = conversationListViewController()
             if groupId != 0 {
                 conversationListVC.channelKey = groupId
             }
             let navVC = KMBaseNavigationViewController(rootViewController: conversationListVC)
             navVC.willMove(toParent: viewController)
             navVC.view.frame = rootView.bounds
             rootView.addSubview(navVC.view)
             viewController.addChild(navVC)
             navVC.didMove(toParent: viewController)
             completionHandler(true)
         } else {
             let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: groupId, localizedStringFileName: defaultConfiguration.localizedStringFileName, prefilledMessage: prefilledMessage)
             let conversationVC = KMConversationViewController(configuration: Kommunicate.defaultConfiguration, conversationViewConfiguration: kmConversationViewConfiguration)
             conversationVC.viewModel = convViewModel
             let navVC = KMBaseNavigationViewController(rootViewController: conversationVC)
             navVC.willMove(toParent: viewController)
             navVC.view.frame = rootView.bounds
             rootView.addSubview(navVC.view)
             viewController.addChild(navVC)
             navVC.didMove(toParent: viewController)
             completionHandler(true)
         }
     }
    
    class func updateSettingsForEmbeddedMode(viewController: UIViewController) {
        let embeddedVC = viewController.description
        // Update VC List
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), KMConversationViewController.description(),embeddedVC])
        embeddedViewController = embeddedVC
    }

    // MARK: - Private methods

    private func updateToken() {
        guard let deviceToken = pushNotificationTokenData else { return }
        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)") // (SWIFT = 3) : TOKEN PARSING

        var deviceTokenString = ""
        for i in 0 ..< deviceToken.count {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("DEVICE_TOKEN_STRING :: \(deviceTokenString)")

        if ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString {
            let alRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { response, _ in
                print("REGISTRATION_RESPONSE :: \(String(describing: response))")
            })
        }
    }

    private class func createAConversationAndLaunch(
        from viewController: UIViewController,
        on rootView: UIView? = nil,
        completion: @escaping (_ error: KommunicateError?) -> Void
    ) {
        let kommunicateConversationBuilder = KMConversationBuilder()
            .useLastConversation(true)
        let conversation = kommunicateConversationBuilder.build()
        createConversation(conversation: conversation) { result in
            switch result {
            case let .success(conversationId):
                DispatchQueue.main.async {
                    if let rootView = rootView {
                        showConversationIn(rootView: rootView,groupId: conversationId, from: viewController, completionHandler: { success in
                            guard success else {
                                completion(KommunicateError.conversationNotPresent)
                                return
                            }
                            print("Kommunicate: conversation was shown")
                            completion(nil)
                        })
                    } else {
                        showConversationWith(groupId: conversationId, from: viewController,completionHandler: { success in
                            guard success else {
                                completion(KommunicateError.conversationNotPresent)
                                return
                            }
                            print("Kommunicate: conversation was shown")
                            completion(nil)
                        })
                    }
                }
            case .failure:
                completion(KommunicateError.conversationCreateFailed)
                return
            }
        }
    }

    func defaultChatViewSettings() {
        if serverConfig == .euConfiguration {
            ALUserDefaultsHandler.setBASEURL(API.Backend.chat_eu.rawValue)
            ALUserDefaultsHandler.setChatBaseURL(API.Backend.kommunicateApi_eu.rawValue)
        } else {
            ALUserDefaultsHandler.setBASEURL(API.Backend.chat.rawValue)
            ALUserDefaultsHandler.setChatBaseURL(API.Backend.kommunicateApi.rawValue)
        }
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), KMConversationViewController.description()])
        ALApplozicSettings.setFilterContactsStatus(true)
        ALUserDefaultsHandler.setDebugLogsRequire(true)
        ALApplozicSettings.setSwiftFramework(true)
        let hiddenMessageMetaDataFlagArray = ["KM_STATUS" , "KM_ASSIGN_TO", "KM_ASSIGN_TEAM"]
        ALApplozicSettings.hideMessages(withMetadataKeys:hiddenMessageMetaDataFlagArray)
        ALApplozicSettings.enableS3StorageService(true)
    }

    func setupDefaultStyle() {
        let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [ALKBaseNavigationViewController.self])
        navigationBarProxy.tintColor = navigationBarProxy.tintColor ?? UIColor.white
        navigationBarProxy.titleTextAttributes =
            navigationBarProxy.titleTextAttributes ?? [NSAttributedString.Key.foregroundColor: UIColor.white]
        KMMessageStyle.sentMessage = KMStyle(font: KMMessageStyle.sentMessage.font, text: UIColor.white)
    }

    private func clearUserDefaults() {
        let kmAppSetting = KMAppSettingService()
        KMAppUserDefaultHandler.shared.clear()
        kmAppSetting.clearAppSettingsData()
    }

    private static func validateUserData(user: KMUser) -> NSError? {
        guard let userId = user.userId, !userId.isEmpty else {
            return NSError(domain: "User ID is not present", code: 0, userInfo: nil)
        }
        guard !userId.containsWhitespace else {
            return NSError(domain: "User ID contains whitespace or newline characters", code: 0, userInfo: nil)
        }
        return nil
    }

    /**
     Subscribe Chat Events
     - Parameters:
     - events: list of events to subscribe.
     - callback: ALKCustomEventCallback to send subscribed event's data
     */
    public static func subscribeCustomEvents(events: [KMCustomEvent], callback: ALKCustomEventCallback) {
        KMCustomEventHandler.shared.setSubscribedEvents(eventsList: events, eventDelegate: callback)
    }
    
    /*
     Unsubscribe Chat Events
     */
    public static func unsubcribeCustomEvents() {
        KMCustomEventHandler.shared.unsubscribeEvents()
    }
    
    /**
     Update prefilled text on the chat bar when conversation vc on top
     - Parameters:
     - text: string needs to be updated on chat bar
    */
    open class func updatePrefilledText(_ text: String) {
        let pushAssist = ALPushAssist()
        guard let topVc = pushAssist.topViewController,
              topVc is KMConversationViewController
        else {
            print("Failed to update prefilled text on chat bar")
            return
        }
        (topVc as! KMConversationViewController).updateChatbarText(text: text)
    }
      
    /*
     This method will show/hide assignee's online, offline status and away message on conversation screen when its on top.
     - Parameters:
     - hide: boolean to show/hide the views
     */
    open class func hideAssigneeStatus(_ hide: Bool) {
        let pushAssist = ALPushAssist()
        guard let topVc = pushAssist.topViewController,
              topVc is KMConversationViewController
        else {
            print("Failed to hide assignee status")
            return
        }
        (topVc as! KMConversationViewController).hideAssigneeStatus(hide)
    }
    
    var serverConfig: KMServerConfiguration = .defaultConfiguration
    
    open class func setServerConfiguration(_ environment: KMServerConfiguration) {
        Kommunicate.shared.serverConfig = environment
        if environment == .euConfiguration {
            ALUserDefaultsHandler.setBASEURL(API.Backend.chat_eu.rawValue)
            ALUserDefaultsHandler.setChatBaseURL(API.Backend.kommunicateApi_eu.rawValue)
        } else {
            ALUserDefaultsHandler.setBASEURL(API.Backend.chat.rawValue)
            ALUserDefaultsHandler.setChatBaseURL(API.Backend.kommunicateApi.rawValue)
        }
    }
    
    // MARK: - Deprecated methods
    
    /**
     Updates the conversation teamid.
     Requires the conversation  and the team ID to update

     - Parameters:
     - conversation: Conversation that needs to be updated
     - teamId :  teamId that needs to be udpated in conversation

     - completion: Called with the status of the Team ID update
     */
    @available(*, deprecated, message: "Use updateConversation(conversation: completion:)")
    open class func updateTeamId(conversation: KMConversation, teamId: String, completion: @escaping (Result<String, KommunicateError>) -> Void) {
        guard let groupID = conversation.clientConversationId, !groupID.isEmpty else { return }

        guard !teamId.isEmpty else {
            return completion(.failure(KommunicateError.teamNotPresent))
        }
        conversation.teamId = teamId
        
        updateConversation(conversation: conversation){
            response in
               switch response{
               case .success(let clientConversationId):
                   completion(.success(clientConversationId))
                   break
               case .failure(let error):
                   completion(.failure(error))
                   break
               }
        }
    }
    
    /// Logs out the current logged in user and clears all the cache.
    @available(*, deprecated, message: "Use logoutUser(completion:)")
    @objc open class func logoutUser() {
        let registerUserClientService = ALRegisterUserClientService()
        if let _ = ALUserDefaultsHandler.getDeviceKeyString() {
            registerUserClientService.logout(completionHandler: {
                _, _ in
                Kommunicate.shared.clearUserDefaults()
                NSLog("Applozic logout")
            })
        }
    }
    
    open class func createSettings(settings: String) -> Bool {
        return KMConfigurationSetter.createCustomSetting(settings: settings)
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
        userId _: String,
        agentIds: [String] = [],
        botIds: [String]?,
        useLastConversation: Bool = false,
        clientConversationId _: String? = nil,
        completion: @escaping (_ clientGroupId: String) -> Void
    ) {
        let kommunicateConversationBuilder = KMConversationBuilder()
            .useLastConversation(useLastConversation)
            .withAgentIds(agentIds)
            .withBotIds(botIds ?? [])
        let conversation = kommunicateConversationBuilder.build()

        createConversation(conversation: conversation) { result in

            switch result {
            case let .success(conversationId):
                completion(conversationId)
            case .failure:
                completion("")
            }
        }
    }
}
