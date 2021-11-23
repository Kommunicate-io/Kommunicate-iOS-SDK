# CHANGELOG

The changelog for [Kommunicate-iOS-SDK](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK). Also see the [releases](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK/releases) on Github.

## [Unreleased]

### Enhancements
- Update ApplozicSwift to 6.3.0
- [TD-2111] Added a password field to PreChat Form View.
- [TD-2099] Add support to update team for existing conversation
- [TD-2223] Add support for PreChatLeadCollection

## [6.2.0] - 2021-08-18Z
### Fixes

- [TD-1943] Fix for launch conversation error

### Enhancements

- [TD-1867] Updated bot detail API
- [TD-1731] Added support to sync messages on chat screen opening

## [6.1.0] - 2021-06-22

### Enhancements

- Moved Kommunicate folder under Sources for SPM support
- [TD-1700] Added support to update group metadata while creating a conversation

## [6.0.0] - 2021-05-04Z

### Enhancements

- [TD-1667] Added a configuration option that prevents the user from sending a message when a conversation is assigned to a bot.
- [TD-1673] Now, the conversation assignee can be updated in an existing conversation using `Kommunicate.createConversation()` method.
- [TD-1718]  Feedback input view now shows up when a resolved conversation is reopened and resolved again
- [TD-1678] Added Swift Package Manager support for Kommunicate
## [5.14.0] - 2021-03-24Z

### Enhancements

- [TD-1611] Now, we'll show/hide away message on agent change.
### Fixes

- [TD-1606] Fixed an issue where character limit was not shown when a conversation is assigned to a Dialogflow bot.

## [5.13.0] - 2021-02-27

### Enhancements

- [CM-635] Added an option to set the regex for validating phone number in the pre-chat view.
- [CM-633] Added config options to show and make certain fields mandatory in the pre-chat view.

## [5.12.0] - 2021-02-16

### Enhancements

- [CM-581] Added an option to set the team ID when creating a new conversation.

## [5.11.0] - 2021-02-01

### Enhancements

- [CM-579] Set default primary color and sent message's text color.

## [5.10.0] - 2021-01-19

### Enhancements

- [CM-545] Added a check for whitespace and newline characters in the user ID.

## [5.9.0] - 2020-12-04

### Enhancements

- [CM-502] Added an option to launch a conversation with conversation list in the background.
- [CM-500] Added message character limit to limit the number of characters in a message.
- [CM-557] Now, conversation feedback from the SDK will be shown in the Dashboard.

### Fixes
- Fixed an issue where back button was not changing in RTL.

## [5.8.0] - 2020-11-02

### Enhancements
- [CM-451] Added support for setting a prefilled message to send before launching a chat.
- [CM-356] Added support for language change rich message.
- [CM-474] Added send message API for sending text and rich messages.
- [CM-519] Enabled document sharing in the default configuration.
- [CM-507] Enable screen transition animations in all screens.

## [5.7.0] - 2020-09-10

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
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
