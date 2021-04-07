//
//  KMNotificationHelper.swift
//  Kommunicate
//
//  Created by Sunil on 28/01/20.
//

import Foundation
import ApplozicCore
import ApplozicSwift

public class KMPushNotificationHelper {
    /// Stores information about the notification that arrives
    var conversationViewConfig : KMConversationViewConfiguration!
    var configuration: ALKConfiguration!

    public struct NotificationData {
        public let groupId: NSNumber?
        public var isMute: Bool = false
        public init(groupId: NSNumber?) {
            /// For group check mute only.
            self.groupId = groupId
            if let groupId = groupId {
                let group = ALChannelService().getChannelByKey(groupId)
                isMute = group?.isNotificationMuted() ?? false
            }
        }
    }

    public init(_ configuration: ALKConfiguration,_ conversationViewConfig: KMConversationViewConfiguration) {
        self.configuration = configuration
        self.conversationViewConfig = conversationViewConfig
    }

    // MARK: - Public methods

    /// Return information for incoming notification
    ///
    /// - Parameter notification: notification that arrived
    /// - Returns: `NotificationData` containing information about userId, groupId or conversationId
    ///             `String` which is the message for which notification came
    public func notificationInfo(_ notification: Notification) -> (NotificationData?, String?) {
        guard let object = notification.object as? String else { return (nil, nil) }
        let notifData = notificationData(using: object)
        guard
            let userInfo = notification.userInfo,
            let alertValue = userInfo["alertValue"] as? String else {
                return (notifData, nil)
        }
        return (notifData, alertValue)
    }

    /// Return information for incoming notification
    ///
    /// - Parameter message: message of notification
    /// - Returns: `NotificationData` containing information about groupId
    public func notificationData(message: ALMessage) -> NotificationData {
        return NotificationData(groupId: message.channelKey)
    }

    /// Checks if the incoming notification is for currently opened chat.
    ///
    /// - NOTE: Use this information to decide whether to show/hide notification
    /// - Parameters:
    ///   - notification: notification that is tapped
    /// - Returns: Bool value indicating whether notification is for active chat.
    public func isNotificationForActiveThread(_ notification: NotificationData) -> Bool {
        guard
            let topVC = ALPushAssist().topViewController as? KMConversationViewController,
            let viewModel = topVC.viewModel
        else {
            guard let topVC = ALPushAssist().topViewController,
                  let navVC = topVC.presentingViewController as? ALKBaseNavigationViewController,
                  let conversationViewController = navVC.topViewController as? KMConversationViewController,
                  let viewModel = conversationViewController.viewModel
            else {
                return false
            }
            return isChatThreadIsOpen(notification, userId: viewModel.contactId, groupId: viewModel.channelKey)
        }
        return isChatThreadIsOpen(notification, userId: viewModel.contactId, groupId: viewModel.channelKey)
    }

    private func isChatThreadIsOpen(_ notification: NotificationData, userId: String?, groupId: NSNumber?) -> Bool {
        let isGroupMessage = notification.groupId != nil && notification.groupId == groupId
        if isGroupMessage{
            return true
        }
        return false
    }

    /// Launches `KMConversationViewController` from list.
    ///
    /// - NOTE: Use this when list is at the top.
    /// - Parameters:
    ///   - viewController: `KMConversationListViewController` instance which is on top.
    ///   - notification: notification that is tapped.
    public func openConversationFromListVC(_ viewController: KMConversationListViewController, notification: NotificationData) {
        viewController.launchChat(groupId: notification.groupId)
    }

    /// Returns an instance of list view controller which should be pushed from outside.
    ///
    /// - NOTE: Use this to launch chat when some other screen is opened.
    /// - Parameters:
    ///   - notification: notification that is tapped.
    ///   - configuration: `ALKConfiguration` object.
    /// - Returns: An instance of `KMConversationListViewController`
    public func getConversationVCToLaunch(notification: NotificationData) -> KMConversationListViewController {
        let viewController = KMConversationListViewController(configuration: configuration, kmConversationViewConfiguration: Kommunicate.kmConversationViewConfiguration)
        viewController.channelKey = notification.groupId
        return viewController
    }

    /// Refrehses `KMConversationViewController` for the arrived notification.
    ///
    /// - NOTE: Use this when `KMConversationViewController` is at top
    /// - Parameters:
    ///   - viewController: An instance of `KMConversationViewController` which is at top.
    ///   - notification: notification that is tapped.
    public func refreshConversation(_ viewController: KMConversationViewController, with notification: NotificationData) {
        viewController.unsubscribingChannel()
        if !self.isChatThreadIsOpen(notification,
                                    userId: viewController.viewModel.contactId,
                                    groupId: viewController.viewModel.channelKey) {
            viewController.viewModel.prefilledMessage = nil
        }
        viewController.viewModel.contactId = nil
        viewController.viewModel.channelKey = notification.groupId
        viewController.viewModel.conversationProxy = nil
        viewController.viewWillLoadFromTappingOnNotification()
        viewController.refreshViewController()
    }

    /// Checks whether Kommunicate ViewController is at top.
    ///
    /// - WARNING: Doesn't work if Kommunicate's Controller is added inside some container.
    /// - Returns: Bool value indicating whether Kommunicate view is at top.
    public func isKommunicateVCAtTop() -> Bool {

        if NotificationHelper().isApplozicVCAtTop() {
            return true
        }
        guard let topVC = ALPushAssist().topViewController else { return false }
        let topVCName = String(describing: topVC.classForCoder)
        switch topVCName {
        case "FaqViewController",
             "RatingViewController":
            return true
        case _ where topVCName.hasPrefix("KM"):
            return true
        default:
            return false
        }
    }

    /// Handles notification tap when any of Applozic's VC is at top.
    ///
    /// - WARNING: Use this only when `isKommunicateVCAtTop` returns true.
    /// - Parameter notification: Contains details about arrived notification.
    public func handleNotificationTap(_ notification: NotificationData) {
        guard let topVC = ALPushAssist().topViewController else { return }
        switch topVC {
        case let vc as KMConversationListViewController:
            print("KMConversationListViewController on top")
            openConversationFromListVC(vc, notification: notification)
        case let vc as KMConversationViewController:
            print("KMConversationViewController on top")
            refreshConversation(vc, with: notification)
        default:
            if let searchVC = topVC as? UISearchController,
                let vc = searchVC.presentingViewController as? KMConversationListViewController {
                openConversationFromListVC(vc, notification: notification)
                return
            }
            print("Some other view controller need to find chat vc")
            findChatVC(notification)
        }
    }

    // MARK: - Private helper methods

    private func notificationData(using object: String) -> NotificationData? {
        let components = object.components(separatedBy: ":")
        switch components.count {
        case 3:
            guard let componentElement = Int(components[1]) else { return nil }
            let groupId = NSNumber(integerLiteral: componentElement)
            return NotificationData(groupId: groupId)
        default:
            print("Not handled")
            return nil
        }
    }

    private func findChatVC(_ notification: NotificationData) {
        guard let vc = ALPushAssist().topViewController else { return }
        dismissOurVCIfVisible(vc) { handleTap in
            if (handleTap){
                self.handleNotificationTap(notification)
            }
        }
    }

    private func dismissOurVCIfVisible(_ vc: UIViewController,
                                       completion: @escaping (Bool) -> Void) {

        if(!isKommunicateVCAtTop()) {
            completion(false)
            return;
        }

        guard !String(describing: vc.classForCoder).hasPrefix("KMConversation") else {
            completion(true)
            return
        }
        guard
            vc.navigationController != nil,
            vc.navigationController?.popViewController(animated: true) == nil else {
                vc.dismiss(animated: true) {
                    completion(true)
                }
                return
        }
        vc.dismiss(animated: true) {
            completion(true)
        }
    }
}
