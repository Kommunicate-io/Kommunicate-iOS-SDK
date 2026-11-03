//
//  KMPushNotificationService+Actions.swift
//  Kommunicate
//

import KommunicateCore_iOS_SDK
import UIKit
import UserNotifications

/// Reply and Mark as read actions on chat message notifications.
/// The push payload must have `aps.category` set to `ALPushNotificationService.chatMessageCategory`.
public extension ALPushNotificationService {
    static let chatMessageCategory = "KM_CHAT_MESSAGE"

    /// Registers the Reply and Mark as read actions. Call it once at app launch.
    static func registerNotificationActions() {
        let replyAction = UNTextInputNotificationAction(
            identifier: NotificationActionIdentifier.reply,
            title: NotificationActionText.reply,
            options: [],
            textInputButtonTitle: NotificationActionText.send,
            textInputPlaceholder: NotificationActionText.replyPlaceholder
        )
        let markAsReadAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.markAsRead,
            title: NotificationActionText.markAsRead,
            options: []
        )
        let category = UNNotificationCategory(
            identifier: chatMessageCategory,
            actions: [replyAction, markAsReadAction],
            intentIdentifiers: [],
            options: []
        )
        let center = UNUserNotificationCenter.current()
        // Keep the categories the app has already registered.
        center.getNotificationCategories { categories in
            var updatedCategories = categories.filter { $0.identifier != chatMessageCategory }
            updatedCategories.insert(category)
            center.setNotificationCategories(updatedCategories)
            // TODO: Remove debug log.
            NSLog("[KMNotificationAction] Registered categories: %@", updatedCategories.map { $0.identifier }.description)
        }
    }

    /// Handles the Reply and Mark as read actions from `userNotificationCenter(_:didReceive:withCompletionHandler:)`.
    /// Reply sends the message; both actions then mark the conversation read and remove its delivered notifications.
    /// - Parameters:
    ///   - response: The notification response.
    ///   - metadata: Metadata to add to the reply message.
    ///   - completion: Called when the action is handled. Pass the notification center's completion handler.
    /// - Returns: `false` if the response isn't one of these actions; `completion` isn't called in that case.
    func handleNotificationAction(
        _ response: UNNotificationResponse,
        metadata: [String: Any]? = nil,
        completion: @escaping () -> Void
    ) -> Bool {
        let actionIdentifier = response.actionIdentifier
        // TODO: Remove debug log.
        let content = response.notification.request.content
        NSLog("[KMNotificationAction] Action: %@, category: '%@', aps: %@",
              actionIdentifier, content.categoryIdentifier, String(describing: content.userInfo["aps"]))
        guard actionIdentifier == NotificationActionIdentifier.reply || actionIdentifier == NotificationActionIdentifier.markAsRead,
              let groupId = groupId(fromPayload: response.notification.request.content.userInfo)
        else {
            return false
        }

        // Keeps the app running in the background until the action is complete.
        var backgroundTask = UIBackgroundTaskIdentifier.invalid
        let endBackgroundTask = {
            guard backgroundTask != .invalid else { return }
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "KMNotificationAction", expirationHandler: endBackgroundTask)
        let finish = {
            DispatchQueue.main.async {
                endBackgroundTask()
                completion()
            }
        }
        let markAsRead = {
            KMCoreChannelService.sharedInstance().markConversation(asRead: groupId) { _, _ in
                self.removeDeliveredNotifications(groupId: groupId, completion: finish)
            }
        }

        guard actionIdentifier == NotificationActionIdentifier.reply else {
            markAsRead()
            return true
        }
        guard let replyText = (response as? UNTextInputNotificationResponse)?.userText.trimmingCharacters(in: .whitespacesAndNewlines),
              !replyText.isEmpty
        else {
            finish()
            return true
        }

        let message = KMMessageBuilder()
            .withText(replyText)
            .withMetadata(metadata ?? [:])
            .build()
            .toKMCoreMessage()
        message.groupId = groupId
        KMCoreMessageService.sharedInstance().sendMessages(message) { _, error in
            if let error = error {
                print("Unable to send notification reply: \(error)")
            }
            markAsRead()
        }
        return true
    }

    private func removeDeliveredNotifications(groupId: NSNumber, completion: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notifications in
            let identifiers = notifications
                .filter { self.groupId(fromPayload: $0.request.content.userInfo) == groupId }
                .map { $0.request.identifier }
            center.removeDeliveredNotifications(withIdentifiers: identifiers)
            completion()
        }
    }

    /// Reads the conversation's group ID from `AL_VALUE.message`, which has the format `<prefix>:<groupId>:<suffix>`.
    private func groupId(fromPayload userInfo: [AnyHashable: Any]) -> NSNumber? {
        guard isKommunicateNotification(userInfo),
              let value = userInfo["AL_VALUE"] as? String,
              let data = value.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let notificationMessage = payload["message"] as? String
        else {
            return nil
        }
        let components = notificationMessage.components(separatedBy: ":")
        guard components.count == 3, let groupId = Int(components[1]) else { return nil }
        return NSNumber(value: groupId)
    }
}

private enum NotificationActionIdentifier {
    static let reply = "KM_REPLY_ACTION"
    static let markAsRead = "KM_MARK_AS_READ_ACTION"
}

private enum NotificationActionText: Localizable {
    private static let fileName = Kommunicate.defaultConfiguration.localizedStringFileName
    static let reply = localizedString(forKey: "NotificationReplyAction", fileName: fileName)
    static let replyPlaceholder = localizedString(forKey: "NotificationReplyPlaceholder", fileName: fileName)
    static let send = localizedString(forKey: "NotificationReplySend", fileName: fileName)
    static let markAsRead = localizedString(forKey: "NotificationMarkAsReadAction", fileName: fileName)
}
