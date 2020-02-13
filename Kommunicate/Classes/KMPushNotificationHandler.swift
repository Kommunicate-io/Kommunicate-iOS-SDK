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

    var configuration: KMConfiguration!

    /// Make it false to show chat list on press of notification
    public static var hideChatListOnNotification: Bool = true

    public func dataConnectionNotificationHandlerWith(_ configuration: KMConfiguration) {

        self.configuration = configuration

        if (KMUserDefaultHandler.getApplicationKey() != nil) {
            Kommunicate.setup(applicationId: KMUserDefaultHandler.getApplicationKey())
        }

        // No need to add removeObserver() as it is present in pushAssist.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "showNotificationAndLaunchChat"), object: nil, queue: nil, using: {[weak self] notification in
            print("launch chat push notification received")
            let (notifData, msg) = KMPushNotificationHelper().notificationInfo(notification)
            guard
                let weakSelf = self,
                let notificationData = notifData,
                let message = msg
                else { return }

            guard let userInfo = notification.userInfo as? [String: Any], let state = userInfo["updateUI"] as? NSNumber else { return }

            switch state {
            case NSNumber(value: APP_STATE_ACTIVE.rawValue):
                guard !KMPushNotificationHelper().isNotificationForActiveThread(notificationData) else { return }

                ALUtilityClass.thirdDisplayNotificationTS(message, andForContactId: nil, withGroupId: notificationData.groupId, completionHandler: {

                    _ in
                    weakSelf.launchIndividualChatWith(notificationData: notificationData)
                })
            default:
                weakSelf.launchIndividualChatWith(notificationData: notificationData)
            }
        })
    }

    func launchIndividualChatWith(notificationData: KMPushNotificationHelper.NotificationData) {

        guard let topVC = ALPushAssist().topViewController, let groupId = notificationData.groupId else { return }

        guard !KMPushNotificationHelper().isKommunicateVCAtTop() else {
            KMPushNotificationHelper().handleNotificationTap(notificationData)
            return
        }

        if (KMPushNotificationHandler.hideChatListOnNotification) {
            Kommunicate.openChatWith(groupId: groupId, from: topVC) { result in
                print("Launch conversation from notification result :: \(result)")
            }
            return
        }
        let notificationData = KMPushNotificationHelper.NotificationData(groupId: notificationData.groupId)
        let vc = KMPushNotificationHelper().getConversationVCToLaunch(notification: notificationData, configuration: configuration)
        Kommunicate.configureListVC(vc)
        let nav = KMBaseNavigationViewController(rootViewController: vc)
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .fullScreen
        topVC.present(nav, animated: true, completion: nil)
    }

}
