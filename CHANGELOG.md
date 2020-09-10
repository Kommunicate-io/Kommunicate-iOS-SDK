# CHANGELOG

The changelog for [Kommunicate-iOS-SDK](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK). Also see the [releases](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK/releases) on Github.

## [Unreleased]

### Enhancements

- [CM-410] Added support for enabling CSAT from the Dashboard.

## [5.6.1] - 2020-08-21

### Enhancements
- [CM-289]Add restriction for adding more than 256 chars in case the conversation is assigned to a Dialogflow bot.

## [5.6.0] - 2020-08-14

### Enhancements
- [CM-327] Added support for showing Agent's away status.
### Fixes

- [CM-376] Use clientConversationId if present when single threaded option is enabled.
- [CM-395] Fixed an issue where only dashboard settings for single threaded conversation was used.
- [CM-375] Fixed issue if agentIds are passed in the conversation the default agentId was added.

## [5.4.0] - 2020-06-24

### Enhancements
- Migrated to Swift 5
### Fixes
- [CM-308] Fixed the issue where, in some cases, conversation did not switch correctly when we opened it through a notification.
- Fixed an issue where changing tint color through UIAppearance was not working in case of directly launching a conversation thread.
- [CM-330] Fix JSON parsing error in app settings response.

## [5.3.0] - 2020-06-09

### Enhancements
-[CM-23] Single thread conversation based on chat widget rules setup in dashboard
-[CM-14] Apply chat widget customization theme based on server response

## [5.1.0] - 2020-04-22

### Enhancements

- [CM-236] Enable CSAT by default.

## [5.0.0] - 2020-04-01

### Enhancements
- Added support for syncing package details when a suspension screen is shown.
- [CM-41] Now conversation feedback will be shown to the user if it's a resolved conversation.
- [CM-126] Added an alias for ApplozicSwift's `Style` type.

## [4.0.0] - 2020-03-09

### Enhancements
- Added way to set the conversation assignee during the conversation create.
- App ID sanity check: If an empty App ID is passed or if it is changed later, the app will be stopped in the debug mode.
- Added restart conversation option. If the conversation is closed, then the input text field will be disabled, and a restart button will be shown.
- Added logout method with completion and deprecated the ```Kommunicate.logoutUser()``` method.
- [CM-128] Add no conversations view in conversation list.

### Fixes
- [CM-122] Updated CSAT rating scale to 1-10 from 1-3.
- [CM-113] Notification tap action is not working in some screens.

## [3.1.0] - 2020-01-28

### Enhancements
- [CM-1] Added CSAT support. It will be shown once the conversation is resolved.

### Fixes
-[CM-134] Multiple conversations created on click of start new button.

## [3.0.0] - 2019-12-12

### Enhancements
- Added a new create conversation method based on the builder pattern.
- [AL-3762] Added an option to pass conversation title and it will be shown in navigation bar.
- [CM-2] Added support for changing user language.
- Added a method in `KMConfiguration` for updating chat context.

## [2.5.0]
### Enhancements
- Moved the new conversation button in navigation bar to the right.

## [2.4.0]
### Enhancements
- Added iOS 13 support
- Added support to change navigation bar properties using UIAppearance.

## [2.3.0]
### Enhancements
- [AL-3788] Simplified the setting to hide FAQ button and start new conversation button.

## [2.2.0]
### Fixes
- Fixed an issue where tapping on notification was opening other chat screen.
- Fixed an issue where away message was getting hidden after a message is sent by the logged-in user from some other platform.
- Fixed an issue where away message was being shown even when some of the agents were online.

## [2.1.0]

### Enhancements
[AL-3540]Added create conversation

## [2.0.0]

### Enhancements
[AL-3623] Now iOS 10 is the minimum version supported.

## [1.6.0]
---
### Enhancements
- [AL-3482] Now in `createConversation` API, clientConversationId can be passed. You can use this Id if you want to link a conversation with some event on your side.

## [1.5.0]
---
### Enhancements
- [AL-2816] Added support for showing FAQ.
- Now, contact details will be shown for one-to-one chat also.
- Assignee details will now be updated real-time provided MQTT/APNS is connected.

### Fixes
- Fixed a crash where viewModel was nil while opening the controller.

## [1.4.1]

### Fixes

- [AL-3493] Fixed an issue where Kommunicate localization file was not part of the pod.

## [1.4.0]

### Enhancments

- [AL-3393] Added support for passing send message metadata in create group.

## [1.3.0]

### Enhancments

- Now if the parent VC(from where the conversation is shown) doesn't have a navigation controller then the Conversation VC will still be shown.

## [1.2.0]

### Enhancements

- [AL-2993] Updated Kommunicate framework to Swift 4.2.
- [AL-3071] Added support to show conversation assignee details in conversation list screen.

## [1.1.0]

### Enhancements

- [AL-3189] Add localization support.

## [1.0.0]
---

### Enhancements

- [AL-2853]Added support for showing Away message.
- [AL-3062]While creating a conversation, a default agent will be fetched and added. Now it's not required  to pass the agent Ids.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
