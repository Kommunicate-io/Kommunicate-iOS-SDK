# CHANGELOG

The changelog for [Kommunicate-iOS-SDK](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK). Also see the [releases](https://github.com/Kommunicate-io/Kommunicate-iOS-SDK/releases) on Github.
## [7.2.0] 2024-09-11
- SSL Pining.
- Jail Break Detection.
- Resolved Rating Multiple Time Asking Issue.
- Rating Option will be avilable only after CSAT Enabling.
- Source Url UI added. 
- Crash Fixes.
- Improved Form and Text Area UI.
- Delete Message Sync.

## [7.1.9] 2024-05-27
- Added Privacy Manifest File.
- Fixed color difference in Attachment Icon.
- Added Five Star CSAT Ratting.
- Exposed Funtion to show or hide Attachment Options.
- Updated Check Box UI for Form.
- Updated Time and Date Format.(Similar to Android & Web)

## [7.1.8] 2024-04-23
- Added Support for EU region.
- Updated the default color for send message text to white.

## [7.1.7] 2024-04-10
- Iframe Support for HTML Content
- Added prefix to the files to avoid build issue in case of same name is used by other libraries
- Added support for conversation deletion sync.

## [7.1.6] 2024-03-15
- Fixed name getting cut issue in Navigation Bar.
- Improved the Flow of Showing Rating Bar.
- Improved read receipt label for messages. 

## [7.1.5] 2024-03-11
- Added Dynamic online/offline status Feature
- Added the last Message icon in Conversation List Screen.
- Fixed Link preview issue. 
- Fixed Assignee Image not showing with custom title.

## [7.1.4] 2024-03-06
- Fixed Build Conversation issue

## [7.1.3] 2024-02-21
- Fixed Form Rich Message Rendering issue
- Added support for showing assingment message 
- Fixed Reply meta issue on Quick Reply Button

## [7.1.2] 2024-02-12
- Zendesk (Zopim) integration optimisations
- Fixed Suggested Reply Rich Message is not getting rendered while scrolling on conversation screen
- Time Label Font Change
- Added support of form data using dialog flow fulfillment
- Fixed minor crashes

## [7.1.1] 2024-01-05
- Fixed link preview showing for deep link
- Added the caption Screen for Attachment.
- Fixed HTML Message view in Conversation List Screen.
- Fixed Location blue bar coming in message bubble
- Fixed New Form UI Cutting from Bottom.
- Updated the User Update Api

## [7.1.0] 2023-12-23
- Added support to trigger intents through quick reply
- Restrict agent reply for zendesk conversation
- Added Customisation for the line above chatbar.
- Changed UI for typing indicator
- Minor UI related bug fixes

## [7.0.9] 2023-12-12
- Fixed hidePostCTA message delete issue.

## [7.0.8] 2023-12-06
- Added Support of Video Rich Message.
- Fixed the attachment upload issue.
- Fixed Conversation Missmatch issue.

## [7.0.7] 2023-11-25
- Default configuration added for disabling the form submit button using 'disableFormPostSubmit'.
- Added support of prefill checkboxes on Form Template.

## [7.0.6] 2023-11-07
- Fixed createAndShowConversation bug 

## [7.0.5] 2023-11-02
- Fixed iOS 17 Button issue.
- Fixed the Typing Customization issue.
- Fixed buttons are getting cut in form template
- Added hidepostCTA support for all types of buttons.
- Default configuration added for hiding the form submit button with 'hidePostFormSubmit'.

## [7.0.4] 2023-10-27
- Fixed Single Threaded issue

## [7.0.3] 2023-10-27
- Fixed Button spacing
- Upgraded appsetttings api & optimised the create conversation flow

## [7.0.2] 2023-10-19
- Fixed the Button Title hidding in smaller devices.
- Changed foreground color for link present inside message.
- Fixed all messages are not loading in conversation screen.

## [7.0.1] 2023-09-26
- Added Support For Auto Suggestions Rich Message
- Added pseudonym support for iOS SDK
- Added custom input field rich message support in IOS SDK
- Fixed Trial Period Alert closable issue.
- Added support for XCode 15
- Added flag for identification of users with pseudo name
- Fixed language metadata clashing with message metaData
- Fixed hidePostCTA not getting reflected in iOS SDK
- Added support for elastic update of user's email

## [7.0.0] 2023-09-07
- Upgraded minimum SDK version to 13
- Passed kmUserLocale in groupMetadata and messageMetaData
- Added support for Sending GIF from device
- Added support for storing platform icons
- Exposed a customisation function for a rating menu icon on conversation screen.
- Minor Bug Fixes

## [6.9.9] 2023-08-28
- Fixed attachments upload issue

## [6.9.8] 2023-08-23
- Fixed keyboard overlapping in Rating Screen.
- Fixed Away Message & Rating message overlapping
- Bug Fixes

## [6.9.7] 2023-08-11
- Improved UI of multiple language selection & make it similar to android
- Refresh Icon Change

## [6.9.6] 2023-08-08
- Fixed agent status not updating realtime when conversation is opened from conversation list
- Fixed the Submit Button cuting issue on rating bar.
- Fixed down arrow coming in bottom of the screen when welcome message get rendered issue.
- Form Submit button width is corrected.
- Added border to the form and removed paddding form the top of each cell.

## [6.9.5] 2023-07-21
- Added feature for sending metadata with origin name, including information on iOS device, facilitating identification of app name and user's device type.
- Fixed the form submission with empty fields issue
- Added Support to trigger Assignment intent when language selected for Speech to Text.
- Fixed SPM build issue due to Dropdown dependency
- Fixed conversation restarting through user end via message templates even when restart conversation button is disabled

## [6.9.4] 2023-07-10
- Fixed hideEmptyStateStartNewButtonInConversationList customization bug
- Added Cusotmization for Start New Conversaion Button on Conversation List Screen

## [6.9.3] 2023-06-30
- Added customization for FAQ button text color, background colors on conversation,conversation list screen.
- Added Support for Drop Down field in Form Template
- Fixed Template Message bug

## [6.9.2] 2023-06-28
- Exposed a function to show/hide the Assignee online,offine status when conversation screen is on top.

## [6.9.1] 2023-06-07
- Fixed Upload attachment issue to custom cloud service

## [6.9.0] 2023-05-25
- Added Custom Cloud support for attachments.

## [6.8.9] 2023-04-28
- Added Restriction for start plan users
- Fixed Event data not getting passed for List Template Rich Message Event

## [6.8.8] 2023-04-19

-  Added Support for Custom Subtitle in Conversation Navigation Bar. By using this you can add Experince and Rating of the Agent.
```
Kommunicate.kmConversationViewConfiguration.toolbarSubtitleText = "7 Years Experience"
Kommunicate.kmConversationViewConfiguration.toolbarSubtitleRating = 4.5
```

- Added Support for delete conversation to end user. It can be enabled using below line
```
Kommunicate.defaultConfiguration.enableDeleteConversationOnLongpress = true
```

##[6.8.7] 2023-04-05
- Upgraded Kingfisher pod to 7.6.2 (latest)
- Upgraded KommunicateChatUI-iOS-SDK to 1.0.5

## [6.8.6] 2023-03-23
- Fixed Conversation Info Tap issue & SPM Build issue 

## [6.8.5] 2023-03-23
- Added Support for Conversation info screen
- Added Support for multiple selection button in form template

## [6.8.4] 2023-03-17
- Added customization for hidding Chat Widget on Helpcenter (FAQ) Page 
- Added Support Multiple language in Speech To Text

## [6.8.3] 2023-03-10
- Fixed SPM Build Issue due to Zendesk dependencies
- Upgraded KMChatUI-iOS-SDK to 1.0.1

## [6.8.1] 2023-03-09
- Fixed conversation client key issue

## [6.8.0] 2023-02-22
- Fixed Auto logout issue and setting client conversation key issue 
## [6.7.9] 2023-02-17
- Fixed attempt to insert section 1 but there are only 1 sections after the update crash
- Added Suppor rating button on conversation screen
- Added Support for metadata for form action messages
- Added deafult text for conversation list screen title

## [6.7.9] 2023-02-17
- Fixed attempt to insert section 1 but there are only 1 sections after the update crash
- Added Suppor rating button on conversation screen
- Added Support for metadata for form action messages
- Added deafult text for conversation list screen title

## [6.7.8] 2023-02-10
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
