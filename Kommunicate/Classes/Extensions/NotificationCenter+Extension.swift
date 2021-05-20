//
//  NotificationCenter+Extension.swift
//  Kommunicate
//
//  Created by apple on 23/01/20.
//

import Foundation
import ApplozicCore

/// Wraps the observer token received from
/// NotificationCenter.addObserver(forName:object:queue:using:)
/// and unregisters it in deinit.
final class NotificationToken: NSObject {
    let notificationCenter: NotificationCenter
    let token: Any

    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        notificationCenter.removeObserver(token)
    }
}

extension NotificationCenter {
    /// Convenience wrapper for addObserver(forName:object:queue:using:)
    /// that returns our custom NotificationToken.
    func observe(name: NSNotification.Name?, object obj: Any?,
                 queue: OperationQueue?, using block: @escaping (Notification) -> ())
        -> NotificationToken {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token)
    }
}

extension Notification.Name {
    static let pushNotification = Notification.Name("pushNotification")
    static let reloadTable = Notification.Name("reloadTable")
    static let updateChannelName = Notification.Name("UPDATE_CHANNEL_NAME")
    static let updateUserDetails = Notification.Name("USER_DETAILS_UPDATE_CALL")
    static let newMessageNotification = Notification.Name(NEW_MESSAGE_NOTIFICATION)
}

