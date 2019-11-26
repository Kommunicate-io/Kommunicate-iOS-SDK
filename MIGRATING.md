## Migration Guides

### Migrating from versions < 3.0.0

#### Create new conversation and launch

This method will create new conversation and the launch conversation 
  ```swift
 let kmConversation =
      KMConversationBuilder()
          .withAgentIds( ["<AGENT_IDS>"])// Optional. If you do not pass any agent ID, the default agent will automatically get selected. AGENT_ID is the emailID used to signup on Kommunicate dashboard.
           .withBotIds(["<BOT_IDS>"])// Optional list of botIds. Go to Manage Bots(https://dashboard.kommunicate.io/bots/manage-bots) -> Copy botID
           .useLastConversation(false) // If you pass useLastConversation as false, then a new conversation will be created. everytime
           .build()

 Kommunicate.createConversation(conversation: kmConversation) { (conversationId) in
     print("Conversatino id @@ ",conversationId)

     guard !conversationId.isEmpty else {
         print("Failed to create conversation")
          return
      }
     DispatchQueue.main.async {
         Kommunicate.showConversationWith(groupId: conversationId, from: self, completionHandler: { (success) in
             print("conversation was shown")
         })
     }
 }
 ```

### Migrating from versions < 2.3.0

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
