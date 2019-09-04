## Migration Guides

### Migrating from versions < 2.2.0

####  FAQ Button configuration

    FAQ Button will appear in the navigation bar by default.
   `Kommunicate.defaultConfiguration.hideStartChatButton` and `Kommunicate.defaultConfiguration.hideRightNavBarButtonForConversationView` will not work.
    Use `Kommunicate.defaultConfiguration.hideFaqButtonInConversationList` and `Kommunicate.defaultConfiguration.hideFaqButtonInConversationView` to hide faq buttons in the navigation bar.

  ```swift
    // Hide FAQ Button in ConversationList screen
    Kommunicate.defaultConfiguration.hideFaqButtonInConversationList = true

    // Hide FAQ Button in Conversation screen
    Kommunicate.defaultConfiguration.hideFaqButtonInConversationView = true
  ```

#### Push notification setup changes

    We are now using UserNotificationCenter for push notifications. Update your AppDelegate with using this [documentation](https://docs.kommunicate.io/docs/ios-pushnotification).

#### Notification tap action.

    Default setting is on tap of notification, chat screen will be opened. On pressing back it won't go to chat list screen. 
    If you want to go to chat list on pressing back button in chat screen, then add below line in your AppDelegate's didFinishLaunchingWithOptions method.
    
    ```
    KMPushNotificationHandler.hideChatListOnNotification = false
    ```
