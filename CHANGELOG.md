# CHANGELOG

The changelog for [Kommunicate-iOS-SDK](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK). Also see the [releases](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK/releases) on Github.

2.3.0 (upcoming)
### Enhancements
- [AL-3762] Add passing conversation title and show it in navigation title

2.2.0
### Fixes
- Fixed an issue where tapping on notification was opening other chat screen.
- Fixed an issue where away message was getting hidden after a message is sent by the logged-in user from some other platform.
- Fixed an issue where away message was being shown even when some of the agents were online.

2.1.0

### Enhancements
[AL-3540]Added create conversation

2.0.0

### Enhancements
[AL-3623] Now iOS 10 is the minimum version supported.

1.6.0
---
### Enhancements
- [AL-3482] Now in `createConversation` API, clientConversationId can be passed. You can use this Id if you want to link a conversation with some event on your side.

1.5.0
---
### Enhancements
- [AL-2816] Added support for showing FAQ.
- Now, contact details will be shown for one-to-one chat also.
- Assignee details will now be updated real-time provided MQTT/APNS is connected.

### Fixes
- Fixed a crash where viewModel was nil while opening the controller.

1.4.1

### Fixes

- [AL-3493] Fixed an issue where Kommunicate localization file was not part of the pod.

1.4.0

### Enhancments

- [AL-3393] Added support for passing send message metadata in create group.

1.3.0

### Enhancments

- Now if the parent VC(from where the conversation is shown) doesn't have a navigation controller then the Conversation VC will still be shown.

1.2.0

### Enhancements

- [AL-2993] Updated Kommunicate framework to Swift 4.2.
- [AL-3071] Added support to show conversation assignee details in conversation list screen.

1.1.0

### Enhancements

- [AL-3189] Add localization support.

1.0.0
---

### Enhancements

- [AL-2853]Added support for showing Away message.
- [AL-3062]While creating a conversation, a default agent will be fetched and added. Now it's not required  to pass the agent Ids.
- [AL-3188]Send notification when conversation view is launched and closed.
