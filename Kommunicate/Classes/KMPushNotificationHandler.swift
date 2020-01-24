//
//  KMPushNotificationHandler.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 23/08/19.
//

import Foundation
import Applozic
import ApplozicSwift

public class KMPushNotificationHandler: Localizable {
    public static let shared = KMPushNotificationHandler()
    var navVC: UINavigationController?

    var contactId: String?
    var groupId: NSNumber?
    var conversationId: NSNumber?
    var configuration: KMConfiguration!

    /// Make it false to show chat list on press of notification
    public static var hideChatListOnNotification: Bool = true

    private var alContact: ALContact? {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.contactId) else {
            return nil
        }
        return alContact
    }

    private var alChannel: ALChannel? {
        let alChannelService = ALChannelService()

        // TODO:  This is a workaround as other method uses closure.
        // Later replace this with:
        // alChannelService.getChannelInformation(, orClientChannelKey: , withCompletion: )
        guard let alChannel = alChannelService.getChannelByKey(self.groupId) else {
            return nil
        }
        return alChannel
    }

    public func dataConnectionNotificationHandlerWith(_ configuration: KMConfiguration) {

        self.configuration = configuration

        if (KMUserDefaultHandler.getApplicationKey() != nil) {
            Kommunicate.setup(applicationId: KMUserDefaultHandler.getApplicationKey())
        }

        // No need to add removeObserver() as it is present in pushAssist.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "showNotificationAndLaunchChat"), object: nil, queue: nil, using: {[weak self] notification in
            print("launch chat push notification received")
            self?.contactId = nil
            self?.groupId = nil
            self?.conversationId = nil
            //Todo: Handle group

            guard let weakSelf = self, let object = notification.object as? String else { return }
            let components = object.components(separatedBy: ":")

            if components.count > 2 {
                guard let componentElement = Int(components[1]) else { return }
                let id = NSNumber(integerLiteral: componentElement)
                weakSelf.groupId = id
            } else if components.count == 2 {
                guard let conversationComponent = Int(components[1]) else { return }
                weakSelf.conversationId = NSNumber(integerLiteral: conversationComponent)
                weakSelf.contactId = components[0]
            } else {
                weakSelf.contactId = object
            }

            guard let userInfo = notification.userInfo as? [String: Any], let state = userInfo["updateUI"] as? NSNumber else { return }

            switch state {
            case NSNumber(value: APP_STATE_ACTIVE.rawValue):
                guard let userInfo = notification.userInfo, let alertValue = userInfo["alertValue"] as? String else {
                    return
                }
                ///TODO: FIX HERE. USE conversationId also.
                ALUtilityClass.thirdDisplayNotificationTS(alertValue, andForContactId: weakSelf.contactId, withGroupId: weakSelf.groupId, completionHandler: {

                    _ in
                    weakSelf.notificationTapped(userId: weakSelf.contactId, groupId: weakSelf.groupId)

                })
            default:
                weakSelf.launchIndividualChatWith(userId: weakSelf.contactId, groupId: weakSelf.groupId)
            }
        })
    }

    func launchIndividualChatWith(userId: String?, groupId: NSNumber?) {
        NSLog("Called via notification and user id is: ", userId ?? "Not Present")
        guard let topVC = ALPushAssist().topViewController, let groupId = self.groupId else { return }

        if (KMPushNotificationHandler.hideChatListOnNotification) {
            Kommunicate.openChatWith(groupId: groupId, from: topVC) { result in
                print("Launch conversation from notification result :: \(result)")
            }
            return
        }

        let notificationData = NotificationHelper.NotificationData(userId: userId, groupId: groupId, conversationId: conversationId)
        let vc = NotificationHelper().getConversationVCToLaunch(notification: notificationData, configuration: configuration)
        Kommunicate.configureListVC(vc)
        let nav = KMBaseNavigationViewController(rootViewController: vc)
        navVC?.modalTransitionStyle = .crossDissolve
        navVC?.modalPresentationStyle = .fullScreen
        topVC.present(nav, animated: true, completion: nil)
    }

    func notificationTapped(userId: String?, groupId: NSNumber?) {
        launchIndividualChatWith(userId: userId, groupId: groupId)
    }

}
