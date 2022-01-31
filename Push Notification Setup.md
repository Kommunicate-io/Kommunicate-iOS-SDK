
## Adding the Kommunicate plugin:

Add the Kommunicate iOS SDK in your  app using the following guide:
[https://docs.kommunicate.io/docs/ios-installation](https://docs.kommunicate.io/docs/ios-installation)

## Setting set up FCM:

1. Add the Firebase Core and FirebaseMessaging pods in the PodFile and run ```pod install```.  
([https://firebase.google.com/docs/cloud-messaging/ios/client#add-sdks](https://firebase.google.com/docs/cloud-messaging/ios/client#add-sdks))  
 

2. In the AppDelegate.swift file, set up the methods to configure Firebase and set the Firebase Messaging delegate. This includes methods to get the FCM token and refresh it whenever it changes.  
([https://firebase.google.com/docs/cloud-messaging/ios/client#set-the-messaging-delegate](https://firebase.google.com/docs/cloud-messaging/ios/client#set-the-messaging-delegate))

## Setting up Kommunicate for notifications:

1.  In AppDelegate.swift file’s ```didReceiveRegistrationToken()```, pass the FCM registration token to Kommunicate server.

(https://docs.kommunicate.io/docs/ios-pushnotification#send-device-token-to-kommunicate-server)  

## Disabling Method Swizzling

1.  To disable method swizzling: add the flag ```FirebaseAppDelegateProxyEnabled``` in the app’s Info.plist file and set it to NO (boolean value)  
    
2.  For apps with method swizzling disabled, associating the FCM token with the device's APNs token and passing notification-received events to Analytics should be done manually.

## Receiving notifications:
To handle the app launch, when the user clicks on a notification, check if the notification received is a Kommunicate notification.

1. In the ```userNotificationCenter(_:didReceive:withCompletionHandler:)```, pass the response dictionary to Kommunicate Notification Service’s ```isKommunicateNotification()```.  
(https://docs.kommunicate.io/docs/ios-pushnotification#handle-app-launch-on-notification-click)  
  
2. If true, it can be then passed to process the notification, using the ```processPushNotification(dict)``` method.  
3. If false, the notification can be passed onto FCM’s ```appDidReceiveMessage(_:)``` method.  
([https://firebase.google.com/docs/cloud-messaging/ios/receive#handle_messages_with_method_swizzling_disabled](https://firebase.google.com/docs/cloud-messaging/ios/receive#handle_messages_with_method_swizzling_disabled)) 
