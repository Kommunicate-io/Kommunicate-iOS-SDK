//
//  AppDelegate.swift
//  Kommunicate
//
//  Created by mukeshthawani on 02/19/2018.
//  Copyright (c) 2018 mukeshthawani. All rights reserved.
//
#if os(iOS)
    import Kommunicate
    import UIKit
    import UserNotifications

    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
        var window: UIWindow?

        // Pass your App Id here. You can get the App Id from install section in the dashboard.
        var appId = ""

        func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            /// For Regex Automation Testing.
            if let regexPattern = ProcessInfo.processInfo.environment["restrictedMessageRegexPattern"] {
                Kommunicate.defaultConfiguration.restrictedMessageRegexPattern = regexPattern
            }
            
            let filePath = "kommunicate_app_id.txt"
            if let appID = try? String(contentsOfFile: filePath).trimmingCharacters(in: .whitespacesAndNewlines) {
                appId = appID
                NSLog("kommunicate_app_id : AppID Found in file.")
            } else {
                NSLog("kommunicate_app_id : AppID Not Found.")
            }

            setUpNavigationBarAppearance()

            UNUserNotificationCenter.current().delegate = self

            registerForNotification()
            KMPushNotificationHandler.shared.dataConnectionNotificationHandlerWith(Kommunicate.defaultConfiguration, Kommunicate.kmConversationViewConfiguration)
            let kmApplocalNotificationHandler = KMAppLocalNotification.appLocalNotificationHandler()
            kmApplocalNotificationHandler?.dataConnectionNotificationHandler()
            
            if KMUserDefaultHandler.isLoggedIn() {
                // Get login screen from storyboard and present it
                if let viewController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "NavViewController") as? UINavigationController
                {
                    viewController.modalPresentationStyle = .fullScreen
                    window?.makeKeyAndVisible()
                    window?.rootViewController!.present(viewController, animated: true, completion: nil)
                }
            }
            return true
        }

        func applicationWillResignActive(_: UIApplication) {
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        }

        func applicationDidEnterBackground(_: UIApplication) {
            print("APP_ENTER_IN_BACKGROUND")
        }

        func applicationWillEnterForeground(_: UIApplication) {
            print("APP_ENTER_IN_FOREGROUND")
            UIApplication.shared.applicationIconBadgeNumber = 0
        }

        func applicationDidBecomeActive(_: UIApplication) {
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        }

        func applicationWillTerminate(_: UIApplication) {
            KMDbHandler.sharedInstance().saveContext()
        }

        func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
        {
            print("DEVICE_TOKEN_DATA :: \(deviceToken.description)") // (SWIFT = 3) : TOKEN PARSING

            var deviceTokenString = ""
            for i in 0 ..< deviceToken.count {
                deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
            }
            print("DEVICE_TOKEN_STRING :: \(deviceTokenString)")

            if KMUserDefaultHandler.getApnDeviceToken() != deviceTokenString {
                let kmRegisterUserClientService = KMRegisterUserClientService()
                kmRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { response, _ in
                    print("REGISTRATION_RESPONSE :: \(String(describing: response))")
                })
            }
        }

        func registerForNotification() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in

                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }

        // This function will be called when the app receive notification
        func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let service = KMPushNotificationService()
            let dict = notification.request.content.userInfo
            guard !service.isKommunicateNotification(dict) else {
                service.processPushNotification(dict, appState: UIApplication.shared.applicationState)
                completionHandler([])
                return
            }
            completionHandler([.sound, .badge, .alert])
        }

        // This function will be called right after user tap on the notification
        func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            let service = KMPushNotificationService()
            let dict = response.notification.request.content.userInfo
            if service.isApplozicNotification(dict) {
                service.processPushNotification(dict, appState: UIApplication.shared.applicationState)
            }
            completionHandler()
        }

        func setUpNavigationBarAppearance() {
            // App appearance
            let navigationBarProxy = UINavigationBar.appearance()
            navigationBarProxy.isTranslucent = false
            navigationBarProxy.barTintColor = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0) // light nav blue
            navigationBarProxy.tintColor = .white
            navigationBarProxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
#endif
