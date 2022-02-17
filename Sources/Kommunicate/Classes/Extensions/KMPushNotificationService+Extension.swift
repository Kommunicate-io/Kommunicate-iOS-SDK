//
//  KMPushNotificationService+Extension.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 21/08/19.
//

import ApplozicCore

public extension ALPushNotificationService {
    func isKommunicateNotification(_ dict: [AnyHashable: Any]) -> Bool {
        return isApplozicNotification(dict)
    }

    func processPushNotification(_ dict: [AnyHashable: Any],
                                 appState: UIApplication.State)
    {
        switch appState {
        case .active:
            processPushNotification(dict, updateUI: NSNumber(value: APP_STATE_ACTIVE.rawValue))
        case .background:
            processPushNotification(dict, updateUI: NSNumber(value: APP_STATE_BACKGROUND.rawValue))
        case .inactive:
            processPushNotification(dict, updateUI: NSNumber(value: APP_STATE_INACTIVE.rawValue))
        @unknown default:
            print("Unknown UIApplication state while processing push notification")
        }
    }
}
