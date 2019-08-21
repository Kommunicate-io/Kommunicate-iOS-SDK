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
