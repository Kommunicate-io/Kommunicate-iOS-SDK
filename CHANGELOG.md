# CHANGELOG

The changelog for [Kommunicate-iOS-SDK](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK). Also see the [releases](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK/releases) on Github.

## [Unreleased]
- Upgraded KommunicateChatUI-iOS-SDK to 0.3.0
- [CM-1302] Added customization for back button on conversation list screen
- Fixed localisation text issue for Start New conversation Button on Conversation list screen.
## [6.7.7] 2023-01-31
- Added function to unsubscribe to Chat Events
- [CM-1280] Added Support for Create conversation Button on Conversation List Scren
## [6.7.5] - 2023-01-25
- [CM-1265] Improved Event Callbacks.
- [CM-1227] Added support to close the conversation ViewController
- Added Zendesk Integration
- [CM-1167] Added a feature Custom Bot Name on Conversation screen through chat context 
## [6.7.4] - 2022-11-02Z
- Upgraded KommunicateChatUI-iOS-SDK to 0.2.7
- [CM-1146] Fixed shared location preview issue by updating api key 
- [CM-1135] Added Event Callbacks for message receive, back press on covnersation & conversation list screen
## [6.7.3] - 2022-09-15Z
- Upgraded KommunicateChatUI-iOS-SDK to 0.2.6
- [CM-1020] Fixed Conversation is not opening on Push Notification tap when app is not running.
- [CM-894] Added Support for Real time update of Agent Online/Offline Status
- [CM-1070] Added Support to embed SDK inside View and Added Support to hide Navigation Bar.
## [6.7.2] - 2022-08-08Z
- Upgraded KommunicateChatUI-iOS-SDK to 0.2.5
- [CM-1015] Added Text To Speech Feature.
```
    You can enable this by adding below line in Appdelegate.swift file or before initiating the conversation.
    Kommunicate.defaultConfiguration.enableTextToSpeechInConversation = true
```
## [6.7.1] - 2022-07-01Z
- Updated KommunicateChatUI-iOS-SDK to 0.2.4
- [CM-984] Fixed Top Navigation Bar showing blank when open it from Notification
## [6.7.0] - 2022-06-24Z
- Updated KM Chat UI to 0.2.3
- [CM-961] Fixed Blank message comes if handover option is added in welcome message
- [CM-956] UITestCases Optimization & bitrise updation 
- [CM-945] Added support for setting default BotID, agentID, assignee and TeamID.Whenever customer creates a new conversation from Conversation List Screen by clicking `Create new Conversation` button , Conversation will be created based on this default settings.
- [CM-829] Optimized Typing Indicator for Bot Messages & Added Typing Indicator for Welcome Message
- [CM-918] Optimized Customisation -> Change message background color based on Primary color Selection on Dashboard
- [CM-870] Added OneTime Rating Feature
- [CM-701] Added Bot Typing Indicator Support
- [CM-699] Show rating same as web.
- [CM-848] Added Localisation Support for the Last message of conversation which will be shown on ConversationList Screeen
- Added a function to update conversation properties: team ID, assignee and metadata.

Sample Code Snippet: 
```
Use this method to update assignee or teamId & metadata. Don't try to update assignee & teamId at the same time.
  let conversationId = "your_conversation_id"
  let assigneeId = "your_assignee_id"
  let metaData = ["key1":"value1", "key2": "key2", "key3":"value3"]
```
If you want to update conversation assignee, then create conversation object like this:
``` 
 let conversation = KMConversationBuilder().withClientConversationId(conversationId).withConversationAssignee(assigneeId).build()
```
If you want to update teamId & conversation meta data, then create conversation object like this:
``` 
 let conversation = KMConversationBuilder().withClientConversationId(conversationId).withMetaData(metaData).withTeamId(teamId).build()
```
If you want to update teamId only, then create conversation object like this:
``` 
 let conversation = KMConversationBuilder().withClientConversationId(conversationId).withTeamId(teamId).build()
```
If you want to update conversation meta data only, then create conversation object like this:
``` 
  let conversation = KMConversationBuilder().withClientConversationId(conversationId).withMetaData(metaData).build()
``` 
after that call  the `updateConversation` by passing above created `conversation`

``` 
  Kommunicate.updateConversation(conversation: conversation) {response in
     switch response {
        case .success(let clientConversationId):
           print("conversation is updated successfully")
// To launch the conversation
           Kommunicate.showConversationWith(groupId: clientConversationId, from: self, completionHandler: {response in
              if response {
                  print("conversation is shown")
              } else {
                  print("conversation is not shown")
               }
            })
           break
        case .failure(let error):
           print("failed to update conversation")
           break
     }
  }
```
- Deprecated `Kommunicate.UpdateTeamId()` function.
- [CM-666] Move conversation metadata and assignee update to a separate function | iOS
## [6.6.0] - 2022-03-23Z
- Updated to KM Chat UI 0.2.0 
- [CM-825] Fixed SPM integration issues by adding SPM support for KM Chat UI & KM Core
- [CM-842] Added S3 service as the default service for upload/download images
- [CM-830] Added Event Callback for Conversation resolve
- [CM-758] Added callback for User Online Status 
- [CM-798] Launch Prechat with Custom Payload 

## [6.4.0] - 2022-01-21Z
- Updated KM Chat UI to 0.1.2 which has the updated KM Core (0.0.2) pod
- [CM-781] Fixed Lexical issue of KM Core Sdk
- [CM-766] Support for Drop Down in Prechat Lead Form 
- [CM-780] Added Support for Updating team Id for a conversation
- [CM-759] Fix for reply meta not reaching webhook when default chatContextData exists.
- [CM-709] Added Event Listeners 
- [CM-743] Updated reference images for snapshot tests
- [CM-670] Update API endpoints

## [6.3.1] - 2021-11-30

## [6.3.0] - 2021-09-30

### Enhancements
- Update ApplozicSwift to 6.4.0
- Added support for Xcode 13 and iOS 15
- [TD-2111] Added a password field to PreChat Form View.
- [TD-2099] Add support to update team for existing conversation
- [TD-2223] Add support for PreChatLeadCollection

## [6.2.1] - 2021-08-19

### Enhancements

- Added support to post rich message button notifications

## [6.2.0] - 2021-08-18Z

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
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
- [AL-3188]Send notification when conversation view is launched and closed.
